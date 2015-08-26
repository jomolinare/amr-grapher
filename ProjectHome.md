This project is a Processing sketch that currently talks with the excellent AMRUSB-1 device created by [Grid Insight](http://www.gridinsight.com/) and creates logs, graphs and calculations to show how much electricity your home is using over time.

The sketch is best used by letting it run continuously for long periods of time. In this current version things get a bit messed up if you don't have it running continuously, including if your computer goes to sleep. But when I say messed up, I mean visually. It will simply mean that there will be a spike in your usage because it will think that you just used a bunch of electricity this day, when in reality it was used over several days. (I fixed things so that if you leave it off for less than a day it won't have visual problems, but I didn't test things for days of inactivity yet).

Future versions will allow for other meter types: Water and Gas. Electricity is my main utility cost so I've started with that, not to mention that my gas meter is incompatible with the AMRUSB-1, and my water meter is too far away to receive reliably. So I'll need to rely on others to help with gas meter readings at least.

You will need [Processing](http://www.processing.org/) to run the sketch.

Please read the [AMR Grapher Overview](https://code.google.com/p/amr-grapher/wiki/AMRGrapherOverview) Wiki page for more details about the sketch.