/*

   Copyright 2011 Scott C. Adams

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   
   
   ==========================================================================
   
   
   AMR Grapher

   This Processing sketch currently reads data from the AMRUSB-1
   utility meter reader created by Grid Insight (http://www.gridinsight.com/)
   and saves the data to log files at set intervals and displays graphs and
   other information in its window. The sketch may work as is or be modified
   to work with other AMRUSB-1 based devices if/when then come to market.

   Originally Created 17 July 2011
   by Scott Adams
   See the "About" tab or https://code.google.com/p/amr-grapher/ for more information
  
  
*/


////////////////////  USER CONFIGURABLE OPTIONS ////////////////////
// You actually SHOULD change all of the values below to reflect your situation
String  meterSerialNumber    = "37287446"; // Save the serial number of our electric meter so we can only show its results
int     billingCycleStartDay = 15;         // The day of the month our electric company starts our bill
char    currencySymbol       = '$';        // Character to show as our currency
Boolean currencyBefore       = true;       // True if we place our currency charcter before our figure (example: true=$40.00 false=40.00€)
float   tier1rate            = 0.1083;     // Tier 1 electric rate in currency, 0-500 kWh
float   tier2rate            = 0.1541;     // Tier 2 electric rate in currency, 501-1000 kWh
float   tier3rate            = 0.1756;     // Tier 3 electric rate in currency, >1000 kWh
float   kWhSurcharges        = 0.00529;    // Total of any extra surcharges charged by electric company, charged on every kWh
float   basicService         = 10.00;      // A minimim electric bill service charge regardless of kWh usage
float   baselineUsage        = 0.167;      // A kWh figure estimated to be your house's baseline kWh usage, ie. all "phantom loads",
//                                         //   no intermittent large loads like A/C, hair dryer, etc. But it will likely include
//                                         //   refridgerator, DVR, clocks, computer, "wall wart" chargers, etc.
//                                         // This seems to be best estimated on a night when the temperatures don't require heat or A/C
//                                         //   and obviously no unusual loads are present.
//                                         // The baselineUsage will only really be used for graph display and won't be added to usage data.


////////////////////  CREATE AND SETUP THE VARIABLES WE NEED ////////////////////
import processing.serial.*;        // The serial library lets us talk with the AMR
import java.text.SimpleDateFormat; // This library lets us format our date displays on the graphs
import java.util.Calendar;         // This library lets us do date math more easily
import java.util.Date;             // This library lets us do date math more easily

Boolean debug = false; // Setting to true will output more text to the console, can also be toggled with "d" key when sketch is running


Serial  AMRport;                  // The serial port
String  saveString;               // String that will be saved to the log file
String  tempString;               // String that will hold the most recent data, which may be invalid so we don't always want to save it
Boolean wroteToLog       = false; // Helps us keep track of when we wrote to the log so we don't do it multiple times per second
Boolean justReceivedData = false; // To help us know when we have new data so we can indicate it in the window
PFont   bigFont;
PFont   smallFont;
PFont   tinyFont;

// Operating System detection and settings
String operatingSystem = System.getProperty("os.name"); // We'll use this to let us know which path for serial and image saving is appropriate based on operating system
String separator       = System.getProperty("file.separator"); // Mac and Linux should be "/", Windows should be "\" I think
//     We'll use this when we need to traverse a directory, like when saving/reading to/from the "data" folder inside of our sketch folder
String serialPath      = "/dev/tty.usbmodem"; // Default to the Mac path since that's what I'm using, but it may be overwritten in setup() depending on OS
//     We'll then use an if/then to figure out what option we should use based on operatingSystem, in setup()


// Billing section.
float   midnightUsage          = 0;     // Stores our cumulative kWh at midnight so we can calculate our total usage today
float   billingCycleStartUsage = 0;     // Stores our cumulative kWh at our billing cycle start so we can calculate our total usage so far this month
float   billThisCycle          = 0.0;   // A total of our estimated bill so far this billing cycle
float   usageThisCycle         = 0.0;   // A total of our kWhs this billing cycle
float   billToday              = 0.0;   // A total of our estimated bill just for today
int     currentTier            = 1;     // To store which of the three tiers we're currently in
float   currentkWhReading      = 0.0;   // This will be our main place to store our current kWh reading


float[] dailyUsage              = new float[31]; // 31 days, max. Stores daily kWh usage for this billing period. Read from file on sketch load.
float[] monthlyUsage            = new float[24]; // 24 months max, or 2 years. Stores the usage for each month for the last 2 years. Read from file on sketch load.
float[] hourlyUsage             = new float[24]; // 24 hours. Stores calculated hourly kWh usage, usually between 0 and 5 for houses, ie. 0, 1, 1, 0, etc.
float[] interpolatedHourlyUsage = new float[24]; // Used to show graphs with interpolated data that will "smooth" the data out
float[] cumulativeHourlyUsage   = new float[24]; // Stores our total kWh usage, continually going up, ie. 23443kWh, 23444kWh, etc.
// cumulativeHourlyUsage will be used to determine hourlyUsage by subtracting one hour from the previous hour.
// Interpolation will turn something like:
// 0:00 1:00 2:00 3:00 4:00 5:00
//    0    0    0    1    0    1
// to:
//  .25  .25  .25  .25   .5   .5


int     lastContact  = 0;             // The last time, in millis, that we received data from the AMR
int     longestLOS   = 0;             // The longest time, in millis, that we went without signal from the AMR (LOS=Loss Of Signal)






////////////////////  SETUP()  ////////////////////
void setup () {
  // set the window size:
  size(640, 920); // 640,920 is the iPhone Retina display size for vertical orientation as a web app
  frameRate(1);
  
  
  // Print a list of all available serial ports
  if (debug) { 
    println(Serial.list());
  }
  
  // Set the serialPath depending on the operating system we're running on
  if (operatingSystem.equals("Linux")) {
    serialPath = "/dev/ttyACM0";
  }
  else if (operatingSystem.equals("Mac OS X")) {
    serialPath = "/dev/tty.usbmodem";
  }
  else {
    serialPath = "COM1"; // Not sure if this is correct, Windows folks let me know please!
  }
  
  // Try to auto select the correct port based on its path
  // This needs be be updated to make sure it will work with Linux and Windows,
  //   probably by just adding two more path names to the match() test.
  String[] ports = Serial.list();                         // Store a list of available serial ports
  for (int i = 0; i < ports.length; i++) {                // Loop through those available serial ports
    if (match(ports[i], serialPath) != null) {            // If one of those ports contains the text of serialPath
      AMRport = new Serial(this, Serial.list()[i], 9600); // Then save that port as our AMRport
      break;                                              // And break out of the for loop since we found our desired port
    }
  }
  
  
  // Don't generate a serialEvent() until we get a newline character:
  // '\n' is a newline, and the AMR sends one at the end of every line it sends
  AMRport.bufferUntil('\n');
  
  
  // Set inital background, turn on smoothing, and setup our fonts
  background(255); // 255 is white
  smooth();
  bigFont   = createFont("SansSerif", 20, true);
  smallFont = createFont("SansSerif", 12, true);
  tinyFont  = createFont("SansSerif",  9, true);
  
  
  // Zero out our arrays
  for (int i = 0; i < 24; i++) {
    hourlyUsage[i]               = 0;
    interpolatedHourlyUsage[i]   = 0;
    cumulativeHourlyUsage[i]     = 0;
  }
  for (int i = 0; i < 31; i++) {
    dailyUsage[i]                = 0;
  }
  
  
  load24HourLog();
  
  loadLastUpdateTimestamp();
  
  // Calculate our hourlyUsage based on our newly loaded data
  calculateUsage(24);
  
  // Load the data from midnight from the hourLog.txt so we can calculate our usage so far today
  midnightUsage = cumulativeHourlyUsage[23];
  
  saveString = str(cumulativeHourlyUsage[hour()]);
  
  loadDailyLog();
  loadMonthLog();
  
  calculateBilling();
  
  AMRSetup();
}
