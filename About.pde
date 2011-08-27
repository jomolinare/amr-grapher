// KNOWN ISSUES
//
// The code currently makes no effort to handle Daylight Savings Time changes, but I believe
//   that this will only cause cosmetic problems on the two days that time changes.
// The code only handles ONE meter reading and it's assumed to be an electric meter, although
//   you could simply tweak the display text of kWh to gallons or therms or whatever as a quick fix.
// The sketch assumes SCM (Standard Consumption Messages) data from the AMR. It currently has
//   no awareness of IDM (Interval Data Messages) and will probably choke on them if it receives them.
// The sketch needs code and a file to keep track of the last time the sketch data was valid
//   so that if the sketch is closed for more than a hour it won't use old data and mess up stuff.
// I display the month names under the Monthly Usage graph, but in my case my billing cycle straddles
//   the months. This makes it seem like the month name may be off if we're after the billing cycle
//   clicks over to the next month, or similar in reverse. This may be a symantic problem that can't
//   easily be worked around.
// I live in the United States of America and I'm hence biased to our conventions. Feedback from
//   other users from other countries would be appreciated to make this sketch more globally friendly.
// The billing cycle start day in my area flexes depending on the day of the week. Meaning, it will
//   move to the nearest business day. We're not accounting for that, yet. It also flexes around
//   holidays, and is sometimes randomly a day early/late for some reason. Also not accounted for.
// The interpolatedHourlyUsage array and its related calculations isn't working.
// File loading code doesn't do enough error checking.
// The code might need to reset the AMR after the initial received reading if it goes a long time
//   without receiving anything (like 20+ minutes in my case).
//
//
//
// TODO
//
// Add an entire AMRUSB-1 control section to send and receive special commands to the unit via GUI
//   including graphing the reception strength, frequencies graph, etc.
// Add checks to see if we're receiving data. If we're not, then don't save it to logs as if it were accurate.
// Make serial port auto select aware of Linux and Windows port paths and react accordingly
// Properly handle meter looping of value from 99999 to 00000 or whatever it is (mine is 99999 to 0)
// Make sure everything still works for people that have solar power where the meter may turn backwards
// Add a daily log with total kWh per day, log a "rolling" 365 days for comparisons
// We currently only handle usage data for an electric meter. Add interval data and gas/water usage too.
// We currently only store data for a single electric meter. Add option to store data for more than one, save serial #.
// My meter only has a 1kWh resolution. Add support and options for finer resolutions.
// Since my meter only has a 1kWh resolution I'm also only using 24 hours for each "usage bucket". Finer resolutions,
//   or high usage situations might need or want more "usage buckets" per day, like 48 half-hours.
// Add easily customizable tier kWh levels. I'm sure not every company uses 500, 1000, 1001+ like mine.
// Evenatully add support for "time of use" meters, which would affect billing rates per time of day.
// Add code to determine the correct billing start date that flexes to the nearest business day, and an option to disable this
// Add a curved line to represent the graph instead of, or in addition to, the bar graph
// Add Pachube upload
// Add code to save to and load from a file that stores our last data save time/date so we can invalidate info from
//   hourLog.txt if it's been more than an hour since we last ran the sketch
// Create buffer images for the graphs to speed up drawing
// Maybe change the every 5 minute log (or add another log) that only logs the time when a kWh ticks over to the next one
//   if it has been over x minutes (since sometimes I get readings from my meter every couple seconds and that'd be WAY
//   more data than we want or need to save.
// Add a dollar figure to each line of the Tier graph that's the # of kWh X $/kWh (don't add the baseline fees)
// Log files should generate header lines and save them to the file if the file didn't yet exist
// Change Daily Usage graph to color each bar or part of a bar the color of the Tier it represents
// Cange Monthly Usage graph to color each bar segment the color of each Tier
// Add code to change billing cycle start date and TIME to be an empirical time rather than midnight
// Add a configuration file to store our user settings in so that we can make it easier for inexperienced users
//   to put in their information. This would also make it possible to distribute an executable of the sketch. And
//   ideally we might present the user with a form of a dialog to present them with a list of received meter serial
//   numbers to let them choose theirs from, and other settings, upon the very first launch. Then we create that
//   configuration file for them so they can't mess it up (unless they manually mess with the file afterwards). Save
//   the config file in the "data" folder so it's lets obvious. Call it preferences.txt ?
//
//
//
// VERSION HISTORY
//
//
// 26 August 2011
//    Converted project to be tracked by git so it could easily be uploaded to Google Code project site, located
//      at https://code.google.com/p/amr-grapher/
//    The conversion to git makes version numbers mostly irrelavent, so I removed it from the file name until I
//      learn how the "Pros" handle this
//    Added LICENSE.txt file with Apache License 2.0 in it
//    Added a quick error check on load24HourLog() to see if hourLog.txt exists. If it doesn't then zero our the
//      cumulativeHourlyUsage array. But this causes a problem on the Hourly Usage graph since it now ranges from
//      0 to the current kWh reading, which could be tens of thousands.
//    Added a quick error checks on loadDailyLog() and loadMonthLog()
//
// 20 August 2011 b06
//    Preparation for release to the public. Added Apache License 2.0. Cleaned up code.
//    Renamed to "AMR Grapher", but may be listed as AMR_Grapher, or amr-grapher depending on technical limitations/preferences
//      of the Processing IDE or the Google Code website where this project is hosted.
//    Added a tiny bit of code to hilite the billing cycle start day on the Daily Usage graph
//    Modified kWh-usage-monthly.csv file to have ActualkWh field to store our usage according to the power company,
//      changed save code to account for this extra field. The field will have to be manually filled in externally.
//    Changed save/load code to use full float values rather than strip the decimals out
//    Added code to save a PNG file of the window every 5 minutes, or when the 's' key is hit. Saves to sketch directory.
//
// 07 August 2011 b05
//    Altered our drawGraph() function to be more versatile. It can now draw our hourly graph and the daily graph.
//    Added the daily graph that shows daily usage for the last billing cycle
//    Altered the color scheme (mostly inverted black and white)
//    Added some visual "white space" to clean things up a bit
//    Added code to make vertical line spacing on the daily graph cleaner
//      (not bunched up with a line every pixel or two, but every 10-20 pixels instead)
//    Added gradient color to the bar graph lines
//    Changed the window size to match an iPhone Retina display in vertical orientation
//    currentkWhReading is now our primary way to read current usage instead of saveString
//    Cleaned up the graph drawings visually
//    Made the sketch window not update the graphs until we had our first data from the AMR, including text saying we're waiting
//    Altered the drawGraph() function to add "hilite" so we can manually hilight a certain bar of the graph
//    Changed our usage calculations to only occur when we have a new kWh reading from the AMR, and every 5 minutes just in case
//    Added graph labels
//    Added "Monthly Usage for past 2 years" graph
//    Added some labels like "Last Contact", "Longest LOS", "Current Reading", "X millis draw time"
//    
//
// 04 August 2011 b04
//    Added a daily .csv log with fields: "Date, EndOfDayReading, DayTotalkWh" saved daily at 23:59:59
//    Added a monthly .csv log with fields: "Date, EndOfMonthkWhReading,MonthTotalkWh,EstimatedCost,ActualCost" saved
//      at 23:59:59 on the last day of the billing cycle
//    Switched load24HourLog() to loadStrings from BufferedReader code, now it's much smaller and simpler
//    Added code to read in the daily and monthly logs, but haven't utilized it yet
//    
//
// 30 July 2011   b03
//    Now we globally keep track of kWh usage this billing cycle, and show it in the draw window
//    Changed the graph so that its size is settable in the function call
//    Also changed the graph so that it was all float values so it will fit any size and draw smoothly
//    Rearranged display text into a more space conscience layout
//    Added a horizontal bar graph showing the Tier usages, allows you to see when you're approaching a new tier rate
//    Added horizontal lines and numbers along side the graph to show kWh numbers
//
//
// 19 July 2011   b02
//    Add "rcvd" indicator in window to show when new data has been received
//    Added code to auto select the usbmodem serial port. Mac only for now.
//    Now storing the raw incoming data in tempString, and confirmed valid data
//      in saveString so that we always have valid data to save to the log
//    Save log data at even intervals, like 9:00:00, 9:05:00, 9:10:00 (but don't include seconds in the log file)
//    Added hourLog.txt that stores our hourly usage so we can save and load previous data, and use it for graphs
//    Added text display of how many kWh have been used so far today
//    Add a baseline usage kWh rate to show in the graph when we don't have enough data yet
//    Added billing cycle stuff to show how much our electricity has cost us today and this billing cycle
//      This includes billing cycle start day of month; tier 1, 2, 3; additional surcharges per kWh, and baseline rate.
//    Added a Tier indicator so we know which tier we're in so we can hopefully use less power when approaching or in high tiers
//
//
// 17 July 2011   b01   Initial Version
//    Code based off of a simple Serial Data Logger for Arduino that I modified to work better with the AMRUSB-1 by Grid Insight
//    Added checksum verification and some rudimentary logic to attempt to not log empty/null data
//    Also added some minimal code to display the single reading in the window rather than via println()
