void draw () {
  int timer = millis(); // Create a timer to see how long it takes us to run through our draw() loop
  background(255);      // Clear the window and make it white

  if (justReceivedData) {
    // If we just received data then we want to change the color of our kWh display text
    // Then we reset justReceivedData to false so that it will turn back to black in the next loop
    fill(0, 128, 0); // Green
    justReceivedData = false;
  }
  else {
    fill(0); // Black
  }
  textAlign(CENTER);
  textFont(smallFont);
  text ("Current Reading:", width / 2, 100);
  text ("Current Time:", width / 2, 134);
  textFont(bigFont);
  text (nfc(currentkWhReading, 0) + " kWh", width/2, 120);
  text (hour() + ":" + nf(minute(), 2, 0), width/2, 154);

  fill(128);
  textAlign(LEFT);
  textFont(bigFont);
  text ("Last Contact: " + ((millis()-lastContact) / 1000), 10, 120);
  textAlign(RIGHT);
  if (currentkWhReading == 0 || longestLOS < (millis()-lastContact)) {
    // LongestLOS should update to lastContact before we have our first data from the AMR
    // Or, it should also update if lastContact is greater than longestLOS
    longestLOS = (millis()-lastContact);
  }
  text ("Longest LOS: " + longestLOS / 1000, width-10, 120);
  
  
  if (((millis() - lastContact) / 1000 == 180) && currentkWhReading == 0) {
    // We're waiting more than 3 minutes for data from the AMR and haven't received our first data still
    // So let's reset the AMR to see if we can get things going.
    // My meter pretty reliably puts out info more frequently than every 180 seconds, so you may need to adjust
    //   this figure if your meter or AMR doesn't receive data that frequently. We don't want to go resetting
    //   the AMR more frequently than is necessary!
    AMRReset();
  }
  
  
  /////////////////////////////  ONLY DO THE FOLLOWING CODE IF WE HAVE A VALID KWH READING /////////////////////////////
  if (currentkWhReading != 0) {
    if (midnightUsage == -1000) {
      dailyUsage[30] = 0; // Update the dailyUsage for today to be 0 since we don't have a valid start usage from midnight
    }
    else {
      dailyUsage[30] = currentkWhReading - midnightUsage; // Update the dailyUsage for today for the graph to use
    }
    //dailyUsage[30]   = currentkWhReading - midnightUsage; // Update the dailyUsage for today for the graph to use
    monthlyUsage[23] = usageThisCycle;                    // Update the monthlyUsage for this month for the graph to use
    
    // We're drawing the graphs first so that they're behind our other elements
    //        usage array, startX, startY, graph width, graph height, hilite which bar, graph name
    drawGraph(hourlyUsage,      5,    200,  width - 20,          125,           hour(), "Hourly Usage:");
    drawGraph(dailyUsage,       5,    390,  width - 20,          200,               30, "Daily Usage for past month:");
    drawGraph(monthlyUsage,     5,    675,  width - 20,          200,               23, "Monthly Usage for past 2 years:");
    drawTierGraph(0, 60, width, 25);

    if (second() == 0 && minute() % 5 == 0) { // Every 5 minutes
      if (wroteToLog == true || currentkWhReading == 0) {   // We've already written to the log during this current second, don't do it again, or we don't have valid data to save
      } 
      else {
        saveMinuteLog();
        saveWindowImage();
        wroteToLog = true;  // Indicate we've written to the log on the first time so that we don't write 59 more log entries during
        //                  //   the one second that our max 60 fps gives us. Luckily we're doing 1fps and shouldn't need this, but just in case
        
        saveLastUpdateTimestamp();
        
        fill(255, 0, 0);    // Red
        ellipse(width - 20, height - 20, 15, 15); // Make a little "record" symbol in the bottom right corner to say we're writing to the log
        calculateBilling(); // Also update our billing numbers
        calculateUsage(24); // This would probably be better as 1 instead of 24, but it takes so little to process we might as well do 24
      }
    } 
    else {
      wroteToLog = false;   // If we're not at the proper second then don't log and write false so we're ready when it is the proper second
    }

    if (hour() == 0 && minute() == 0 && second() == 0) { // Midnight
      // It's a new day so we need to update our usage for the day by storing our current usage
      midnightUsage = currentkWhReading;
    }

    fill(0);
    textFont(bigFont);
    textAlign(RIGHT);
    text (nf(currentkWhReading - midnightUsage, 0, 0) + " kWh so far today.", width - 10, 27);
    textAlign(LEFT);
    text ("So far this month: " + nfc(usageThisCycle, 0) + " kWh", 10, 27);
    textAlign(RIGHT);
    if (currencyBefore) {
      text (currencySymbol + nf(billToday, 0, 2) + " so far today.", width - 10, 52);
      textAlign(LEFT);
      text ("So far this month: " + currencySymbol + nf(billThisCycle, 0, 2), 10, 52);
    }
    else {
      text (nf(billToday, 0, 2) + currencySymbol + " so far today.", width - 10, 52);
      textAlign(LEFT);
      text ("So far this month: " + nf(billThisCycle, 0, 2) + currencySymbol, 10, 52);
    }

    if (hour() == 23 && minute() == 59 && second() == 59) {
      // It's the last second of the day, we'll save to at least one log now
      saveDailyLog();
      loadDailyLog();
      if (day() + 1 == billingCycleStartDay) {
        // It's the last day of the billing cycle, so also save to our month log
        saveMonthLog();
        // We're essentially on a new billing cycle now, so update billingCycleStartUsage
        billingCycleStartUsage = currentkWhReading;
      }
    }
    
    if (billingCycleStartUsage == 0) {
      // If we loaded up the sketch and couldn't load the log files, or they didn't have enough info
      //   in them to get our billingCycleStartUsage, then we'll just make it the current reading
      //   so we have a more "sane" number.
      billingCycleStartUsage = currentkWhReading;
    }

    if (minute() == 0 && second() == 1) {
      save24HourLog();
    }
  }
  else {
    /////////////////////////////  Only do the following code if we DO NOT have a valid kWh reading /////////////////////////////
    fill(255,0,0);
    textFont(bigFont);
    textAlign(CENTER);
    text("Waiting for data", width/2, height/2);
    text("from the AMR...", width/2, height/2 + 22);
  }
  
  if (debug) {
    // Indicate we're in debug mode
    textFont(bigFont);
    textAlign(LEFT);
    fill(255, 0, 0);
    text("Debug Mode", 10, 154);
  }
  
  // Then draw the resulting time in millis() to show how long it took to go through our draw() loop
  textFont(smallFont);
  fill(128);
  textAlign(RIGHT);
  text((millis() - timer) + " millis draw time", width - 2, height - 2);
}
