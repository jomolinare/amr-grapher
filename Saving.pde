//  EVERY 5 MINUTES LOG --------------------------------------------------------------
void saveMinuteLog() {
  // This log file will save a running history of our kWh usage, timestamped and
  //  updated every 5 minutes. The draw() loop will save to this log every 5
  //  minutes on even minutes, such as 0, 5, 10, 15, etc.
  // The log format:
  //  MM/DD/YYYY,HH:MM,Usage
  //
  // We don't have a function to load this file back in because we don't want/need to.
  
  FileWriter file;
  String minuteLog = nf(month(), 2) +"/"+ nf(day(), 2)+"/"+year()+","+nf(hour(), 2)+":"+nf(minute(), 2)+","+currentkWhReading;
  try
  {
    file = new FileWriter(sketchPath + "/AMR_Log.csv", true); // Boolean tells to append
    file.write("\n" + minuteLog, 0, minuteLog.length()+1);  // (string, start char, end char)
    file.close();
    if (debug) { println("Wrote to AMR_Log.csv file."); }
  }
  catch(Exception e) { println("Error: Can't open AMR_Log.csv file!"); }
}



//  ROLLING 24 HOUR LOG --------------------------------------------------------------
void save24HourLog() {
  // This log file will store the last 24 hours of usage in kWh in a "rolling" fashion,
  //   meaning the data inside it will never be older than 24 hours old.
  // Each line in the file will consist of a single value, the kWh, in float format.
  // Each line in the file will equate to one hour, starting at 0 (midnight 12:00-12:59am)
  //   and ending at 23 (11:59pm).
  
  FileWriter file;
  String hourLog = "";
  for (int i = 0; i < 24; i++) {
    // Create the text to save to the log
    hourLog = hourLog + cumulativeHourlyUsage[i]; // We're just going to write one kWh reading per line per hour, starting at hour 0
    if (i < 23) { 
      hourLog = hourLog + "\n";
    } // Add a return to each line except the last
  }
  try
  {
    file = new FileWriter(sketchPath + "/hourLog.txt", false); // False says overwrite the file contents
    file.write(hourLog, 0, hourLog.length());
    file.close();
    if (debug) { println("Wrote to hourLog file."); }
  }
  catch(Exception e) { println("Error: Can't open hourLog.txt file!"); }
}



void load24HourLog() {
  String[] strings = loadStrings("hourLog.txt");
  for (int i = 0; i < strings.length; i++) {
    cumulativeHourlyUsage[i] = parseFloat(strings[i]);
  }
  // Add some error checking here to make sure we loaded the file fine
  // if (debug) { println("hourLog.txt successfully loaded."); }
}



// DAILY LOGS ------------------------------------------------------------------------
void saveDailyLog() {
  // To be called every day at 23:59:59
  // kWh-usage-daily.csv format:
  // MM/DD/YYYY,EndOfDaykWhReading,DayTotalkWh
  // Note: since my meter doesn't do decimal kWh I've stripped it from the output here
  
  FileWriter file;
  String dayLog = ""; // Initialize the single-line string we'll be appending to the file
  dayLog = "\n" + nf(month(), 2) + "/" + nf(day(), 2) + "/" + year() + ","; // Newline + "DD/MM/YYYY,"
  dayLog = dayLog + currentkWhReading + ",";                                // "EndOfDayReading,"
  dayLog = dayLog + (currentkWhReading - midnightUsage);                    // "DayTotalkWh"
  try
  {
    file = new FileWriter(sketchPath + "/kWh-usage-daily.csv", true); // True says to append to the file
    file.write(dayLog, 0, dayLog.length());
    file.close();
    if (debug) { println("Wrote to the dayLog file."); }
  }
  catch(Exception e) { println("Error: Can't open kWh-usage-daily.csv"); }
}

void loadDailyLog() {
  String[] strings = loadStrings("kWh-usage-daily.csv");
  strings = expand(strings, strings.length+1); // Expand the array by 1 (strings.length automatically gives us 1 more than the length when counting from 0)
  strings[strings.length - 1] = ",," + (currentkWhReading - midnightUsage); // Update the last value on the array to be our usage today so far
  strings = reverse(strings);
  strings = shorten(strings); // Remove the header line from the array
  if (strings.length > 31) { // We have more than a month of data so we need to remove older data
    // We're using 30 rather than 31 because strings[30] will be updated to be our kWh usage so far today
    //
    // This needs to be way more intelligent about month lengths and stuff. We'll probably need to use the Java Calendar functions to do so.
    // We'll have to calculate the amount of days between billing dates and use that number instead of 30.
    while (strings.length > 31) {
      strings = shorten(strings); // shorten removes one line from the array each time it's called
    }
  }
  // Then zero out our array so things don't get messed up if the log file is shorter than the array
  for (int i = 0; i < 31; i++) {
    dailyUsage[i] = 0;
  }
  for (int i = 0; i < strings.length; i++) {
    String[] cells = split(strings[i], ","); // Split up our string into individual "cells" at the comma (CSV==Comma Separated Values)
    dailyUsage[i] = parseFloat(cells[2]);    // cells[2] should be DayTotalkWh
  }
  dailyUsage = reverse(dailyUsage);
  // Add some error checking here to make sure we loaded the file fine
  // if (debug) { println("kWh-usage-daily.csv successfully loaded."); }
}




// MONTH LOGS ------------------------------------------------------------------------
void saveMonthLog() {
  // To be called at 23:59:59 on the last day of this billing cycle
  // kWh-usage-monthly.csv format:
  // MM/DD/YYYY,EndOfMonthkWhReading,MonthTotalkWh,EstimatedCost,ActualkWh,ActualCost
  // Note: since my meter doesn't do decimal kWh I've stripped it from the output here
  
  FileWriter file;
  String monthLog = "";
  monthLog = "\n" + nf(month(), 2) + "/" + nf(day(), 2) + "/" + year() + ",";    // Newline + "DD/MM/YYYY,"
  monthLog = monthLog + currentkWhReading + ",";                                 // "EndOfMonthkWhReading,"
  monthLog = monthLog + (currentkWhReading - billingCycleStartUsage) + ",";      // "MonthTotalkWh,"
  monthLog = monthLog + billThisCycle + ",,,";                                   // "EstimatedCost,ActualkWh,ActualCost"
  // ActualCost above and the tripple comma are here because we don't know the ActualkWh and ActualCost and will, for now,
  //  need to add in that value manually once the utility bill has been received.
  try
  {
    file = new FileWriter(sketchPath + "/kWh-usage-monthly.csv", true); // True says to append to the file
    file.write(monthLog, 0, monthLog.length());
    file.close();
    if (debug) { println("Wrote to kWh-usage-monthly.csv file."); }
  }
  catch(Exception e) { println("Error: Can't open kWh-usage-monthly.csv file!"); }
}


void loadMonthLog() {
  String[] strings = loadStrings("kWh-usage-monthly.csv");
  strings = expand(strings, strings.length+1);         // Expand the array by 1 (strings.length automatically gives us 1 more than the length when counting from 0)
  strings[strings.length - 1] = ",," + usageThisCycle; // Update the last value on the array to be our usage so far this billing cycle
  strings = reverse(strings);
  strings = shorten(strings);     // Remove the header line from the array
  if (strings.length > 24) {      // We have more than 2 years of data so we need to remove older data
    while (strings.length > 24) {
      strings = shorten(strings); // shorten removes one line from the array each time it's called
    }
  }
  // Then zero out our array so things don't get messed up if the log file is shorter than the array
  for (int i = 0; i < 24; i++) {
    monthlyUsage[i] = 0;
  }
  for (int i = 0; i < strings.length; i++) {
    String[] cells = split(strings[i], ","); // Split up our string into individual "cells" at the comma (CSV==Comma Separated Values)
    if (i == 1) {
      // We need to save last months kWh usage to billingCycleStartUsage and since we're reversed array[1] will be our data
      billingCycleStartUsage = parseFloat(cells[1]); // cells[1] should be EndOfMonthkWhReading, and billingCycleStartUsage is a float
    }
    monthlyUsage[i] = parseFloat(cells[2]);  // cells[2] should be MonthTotalkWh
  }
  monthlyUsage = reverse(monthlyUsage);
  // Add some error checking here to make sure we loaded the file fine
  // if (debug) { println("kWh-usage-daily.csv successfully loaded."); }
}



// IMAGE FILE ------------------------------------------------------------------------
void saveWindowImage() {
  save(sketchPath + "/graph.png");
}
