AMR Grapher

Originally Created 17 July 2011
by Scott Adams

See the "About" tab in the sketch or the project website at https://code.google.com/p/amr-grapher/ for more information.

About:

	This Processing sketch currently reads data from the AMRUSB-1
	utility meter reader created by Grid Insight (http://www.gridinsight.com/)
	and saves the data to log files at set intervals and displays graphs and
	other information in its window. The sketch may work as is or be modified
	to work with other AMRUSB-1 based devices if/when then come to market.

Requirements:

	You must have Processing installed on your computer to use this "sketch" (sketch is a term that Processing uses to describe one or more files of computer code that it can "run" or "execute"). Processing is a computer language and IDE (Integrated Development Environment) that can be downloaded for free from http://www.processing.org/. It is open source software and can run on Mac, Linux, Windows, and some Android devices.
	
	You must also have an AMRUSB-1 device from http://www.gridinsight.com, or other devices that perform the same as the AMRUSB-1. At the time of this writing I know of no other devices just like the AMRUSB-1, but there should eventually be more devices.
	
	Computer requirements are fairly minimal and will be the requirements that Processing needs.
	
	AS OF AUGUST 26, 2011 AND BEFORE, THE SKETCH WILL ONLY WORK ON A MACINTOSH COMPUTER WITHOUT MODIFICATION. IF YOU HAVE LINUX OR WINDOWS YOU WILL NEED TO ALTER THE PATH TO THE SERIAL PORT THAT THE AMRUSB-1 DEVICE IS ON. LOOK FOR "/dev/tty.usbmodem" ON THE AMR_Grapher TAB AND REPLACE IT WITH THE CORRECT ONE FOR YOUR OPERATING SYSTEM. I HOPE TO HAVE THIS FIXED SOON.
	
Install:

	Formal installation isn't required. You simply need to open the sketch with Processing.
	
	From the File -> Open dialog, find the AMR_Grapher folder you downloaded and open the folder. You will then need to open the AMR_Grapher.pde file.
	
	Once you've opened the AMR_Grapher.pde file a window will appear showing AMR_Grapher and the other necessary files that are all associated with this sketch.
	
	(You can optionally move the AMR_Grapher folder into your Processing sketch folder that contains your other sketches.)

Change Settings:

	You will want to change the settings under the label:
	////////////////////  USER CONFIGURABLE OPTIONS ////////////////////
	
	See the AMR_Grapher.pde file for those settings and descriptions on what to change.

Run Sketch:
	
	Click the "Run" icon in the top left of the window (the icon is a triangle inside of a circle).
	
	Or you can choose "Run" from the "Sketch" menu.

BUGS OR OTHER ISSUES:
	
	Please see the "About" tab or the project website for the most current listing of bugs or issues. https://code.google.com/p/amr-grapher/

News or Changelog:

	Please see the project website for the most up to date information: https://code.google.com/p/amr-grapher/