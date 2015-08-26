# Introduction #

I'm a sucker for graphical data. You can learn so much from data if it's formatted well. Having access to raw data is good, but being able to see trends without reading a bunch of numbers and doing math in your head, now that's useful!

The first day I received my AMRUSB-1 from [Grid Insight](http://www.gridinsight.com/) I had it up and running in no time with the built-in "screen" command in the Mac OS X Terminal. And as fun as it was to see meter readings coming in from my and the neighbors' meters I knew that logging that data was the first priority. Beta 01 was born, lived for 2 days then Beta 02 came along and I was logging data. But since I've been logging and _graphing_ my homes temperatures for over a year I knew that was my next step. So while still in Beta 02 I added a simple graph.

Now I'm at Beta 06 and have a pretty full featured little sketch with three graphs showing hourly, daily, and monthly usage data bar graphs. I'm saving to four log files and saving an image of the window too. I'm also calculating daily and monthly electricity costs with tier support too. Good times.

The sketch is designed to run 24/7/365 so that it has constant knowledge of what's going on. So it's best to run this on a computer that's on all the time but is energy efficient (and doesn't go to sleep).

# Features #

The interface is a single window that happens to be the exact size of an iPhone 4 Retina Display in vertical orientation (with room for the status bar above it). So if you have the screen image saved to a web server directory that's accessible you could write a quick web app to always have your usage data available on your iPhone. It would probably be trivial to make this work on other smart phones too.

There are no buttons or fields on the screen since the sketch is essentially a display-only "app." But the data that is there should help you get a good idea of how you're doing on energy consumption.

The window shows:
  * kWh usage so far this month (this billing cycle)
  * kWh usage so far today (since midnight)
  * Money spent so far this month
  * Money spent so far today
  * What [Tier](Tier.md) you're currently in
  * Graph of where you are in the tiers
  * Current kWh reading from the meter
  * Current Time
  * Current reading and time turn green for 1 second after we have received data from the AMRUSB-1
  * The number of seconds since last contact from the AMRUSB-1
  * The longest number of seconds between contact from the AMRUSB-1
  * An Hourly Usage graph
    * Shows 24 hour time, 0 on the left 23 on the right
    * Graph height automatically fills the space and scales to the maximum kWh usage today
    * The current hour of the day is highlighted in a different color
    * The graph bars have a gradient on either side to give them a 3D look
  * A Daily Usage for past month graph
    * Shows data for the past 31 days
    * The newest data (today) is on the right side of the graph
    * The oldest data is on the left side of the graph
    * Day numbers and names are shown under each bar so you can identify them and see, for example, that you use more electricity on the weekends
    * The current day is highlighted in a different color
    * The billing cycle start day is highlighted in a different color too
    * The graph height automatically scales to the maximum kWh usage for the past month and doesn't show more horizontal lines than can visually fit well
  * A Monthly Usage for past 2 years graph
    * Like above, but with 24 months of data
    * Month number and month name are shown under each bar
    * Newest month is on right and is highlighted
  * There is a timer that counts the number of milliseconds that it took to draw the window
  * There is a red "record" circle in the bottom right of the window that indicates that we just saved data to the logs
  * Data is saved to the logs every 5 minutes
  * A PNG image file of the window is saved to the sketch directory every 5 minutes (it is overwritten each time so there is only one PNG file)

# User Settings #

There are a few setting that you'll **need** to change if you want the sketch to work properly. The primary one is your electric meters serial number. In my area they are 8 digits. If you've connected your AMRUSB-1 to your computer and read from it with a terminal emulation program then you should see the serial number as the second field of data you receive from the AMRUSB-1.
Other settings:
  * Billing cycle start day. The day of the month your billing cycle starts. Mine is 15.
  * Your currency symbol and whether it is before or after the figure
  * Your Tier rates. Current tiers are assumed to be:
    * Tier 1 = 0-500 kWh
    * Tier 2 = 501-1000 kWh
    * Tier 3 = 1001 or more kWh
  * Your additional surcharges that are chareged for every kWh you use (a State Energy Surcharge in my case)
  * Your baseline fees, meaning a set dollar amount that doesn't change based on usage
  * Your [baselineUsage](baselineUsage.md). This is a kWh value that you may want to calculate manually. It's meant to be the minimal kWh usage that your household uses when there are no heavy loads running. You might think of it as the amount of electricity your house would use if you were away on vacation and weren't using the air conditioning, doing laundry, etc. It would be all the "phantom loads" like wall warts, but also things like night lights, lighted house number markers, refrigerator, and even your pool pump.

# Limitations #

Since I'm consistently only getting readings from my electric meter I've designed this sketch to work only with electric meter readings. More specifically, the sketch will only work with Standard Consumption Messages (SCM) from electric meters. If your meter puts out Interval Data Messages (IDM) then I'm pretty sure my sketch will be very unhelpful to you. I hope to fix this in a future version but will need help from someone that has an IDM meter to do so.

The sketch will also only log and graph data from **one** meter.

For more limitations or issues please see either the About tab in the sketch, or the [Issues](https://code.google.com/p/amr-grapher/issues/list) tab.

# Logs #

The sketch generates four log files:
  1. AMR\_Log.csv
  1. hourLog.txt
  1. kWh-usage-daily.csv
  1. kWh-usage-monthly.csv

Please see [Logs](Logs.md) for a more complete description of the log files.