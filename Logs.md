# Logs #

The sketch generates four log files:
  1. AMR\_Log.csv
  1. hourLog.txt
  1. kWh-usage-daily.csv
  1. kWh-usage-monthly.csv

## AMR\_Log.csv ##
**AMR\_Log.csv** is a save-only log that saves the current usage every 5 minutes. The format is:
  * MM/DD/YYYY,HH:MM,kWh usage (float)
  * Example: 08/21/2011,15:10,24671.0

## hourLog.txt ##
**hourLog.txt** is a simple text file with the kWh meter reading for the last 24 hours. Each reading is a float value on its own line and there are no headers or other data. Line 1 is hour 0, or 12:00am to 12:59am. The last line is hour 23, or 11:00pm to 11:59pm. Since this data is used for the Hourly Usage graph that always has hour 0 on the left and hour 23 on the right, the data in the hourLog.txt is saved the same way. This means that part way through the file the incrementing numbers will suddenly jump back to old data from yesterday. An example:
```
  24653.0
  24653.0
  24654.0
  24654.0
  24654.0
  24655.0
  24655.0
  24655.0
  24657.0
  24658.0
  24660.0
  24662.0
  24664.0
  24667.0
  24670.0
  24671.0 <-- Our current hour
  24646.0 <-- The jump back to yesterdays data
  24647.0
  24648.0
  24649.0
  24650.0
  24651.0
  24652.0
  24652.0
```

This hourLog.txt file is now inside the data folder inside of the sketch folder since it shouldn't be necessary for the user to change this. So now it's "hidden" in this folder.

## kWh-usage-daily.csv ##
**kWh-usage-daily.csv** stores the meter reading at 23:59:59 and the usage that day. The file _does_ have a header line. An example:

```
 Date,EndOfDayReading,DayTotalkWh
 08/18/2011,24601.0,41
 08/19/2011,24628.0,27
 08/20/2011,24652.0,24
```

The **kWh-usage-daily.csv** file can be of any reasonable length. I currently have the sketch appending to the file in a never ending fashion, but then I only read in the last 31 days. This way I have a log file I could use for other purposes if I wanted.

You can also manually populate this file if you have appropriate data. Just be sure to use the proper format. My code doesn't do any real sanity checking on the data.

## kWh-usage-monthly.csv ##
**kWh-usage-monthly.csv** is the most complex of the files but is still straightforward. This file also has a header line. The file stores one month of data per line. But in this case, the sketch is only reading from two of the fields: EndOfMonthkWhReading and MonthTotalkWh. The other fields are created when saving to the file, but two of the fields are to be manually entered once you've received your utility bill. Those two fields are ActualkWh and ActualDollars. And as of now, those two fields are just for your information but may be used in future versions.
The kWh-usage-monthly.csv file can be a bit strange and picky right now. The sketch doesn't actually read the date field when it reads the file on launch. It simply reads the data in line by line and assumes that they're sequentially correct! Part of the reason I do that is because my billing data varies. It's officially the 15th of the month but can be pushed back to up to the 20th of the month by my utility company. It's usually pushed back to make the date land on a week day. Holidays can also push it back. And I've also seen it pushed back for no apparent reason! So that's the big reason I don't want to mess with the actual date. The sketch will update the log file at 23:59:59 immediately before the new billing cycle starts, and it will use that date (the 15th in my case) as the date for that log file line. However, once I receive my actual utility bill I will update that date to be the bill date. This is a sticky issue that I wish I had an elegant solution to, but I don't yet. Until then it will just have to be inelegant. In reality the graphs seem to work fine without "fixing" this problem.
Please note that I use "Dollars" in the field names even though they're actually unit-less. If you've
An example of the log file:

```
  Date,EndOfMonthkWhReading,MonthTotalkWh,EstimatedDollars,ActualkWh,ActualDollars
  06/16/2011,22199.0, 709.0,      , 709.0,100.12
  07/19/2011,23292.0,1093.0,      ,1093.0,163.32
  08/17/2011,24451.0,1101.0,162.59,1167.0,166.71
```

_Please note that I've used spaces to line the fields up visually, but DO NOT use spaces in your log files_

Also, note that since I didn't have the AMRUSB-1 or this sketch before August 2011, I also didn't have an EstimatedDollars amount to fill in, therefore, there is a double-comma on two of those lines indicating an empty field. I manually added in the old data from my utility bills so the sketch would read it in and graph it. You can do the same if you're careful to follow the correct format. As I said above, my sketch does no sanity checking of the data, be careful!