void drawGraph(float[] usage, int startX, int startY, int w, int h, int hilite, String label) {
  int   textX     = startX + 36; // 36px should be enough for 4 digits of kWh readings (for monthly usage)
  float barWidth  = 0.0;         // To store the width of our bars
  float barPad    = 2;           // A pixel padding added to either side of each bar
  float maxHeight = max(usage);  // The upper bound for our graph height in kWh
  
  // Find our best fit for our array length within our window width
  barWidth = w - textX;
  barWidth = barWidth / usage.length;
  
  if (maxHeight == 0) {
    // We can't have maxHeight of 0, so artificially inflate it to 1
    maxHeight = 1;
  }
  
  // Draw the graph label above and to the left of the graph
  fill(0);
  textFont(bigFont);
  textAlign(LEFT);
  text(label, startX + textX, startY - 12);
  
  // Then we'll draw the graph numbers along the left side
  textFont(smallFont);
  textAlign(RIGHT);
  int decrementer = 1; // Setup a decrementer that will be 1 for small kWh usages, and 2 or more for large kWh usages
  if (maxHeight * 12 > h) { // 12==our font height, h is our graph height, this will be true if we don't have room to display all of our kWh values
    float temp = ceil((parseInt(maxHeight) * 10) / 50);
    decrementer = parseInt(temp);
  }
  fill(100);
  for (int i = parseInt(maxHeight); i > 0; i = i - decrementer) {
    noStroke();
    text(i, textX, map(maxHeight-i, 0, maxHeight, 0, h) + startY + 6);
    stroke(150);
    noSmooth(); // Turn off smoothing so our single pixel black lines don't turn into 2 pixel grey lines
    line(textX + 1, map(maxHeight-i, 0, maxHeight, 0, h) + startY, w + 10, map(maxHeight-i, 0, maxHeight, 0, h) + startY);
    smooth();   // Turn smoothing back on for everyone else
  }
  
  // for debugging:
  if (debug) {
    textAlign(LEFT);
    text("barWidth= " + barWidth + " barWidth * usage.length=" + barWidth * usage.length + " graph width - textX = " + (w - textX), textX + startX, startY);
  }
  
  
  // Now that we drew those numbers along the side we should shrink our graph to fit beside the numbers
  startX = startX + textX + 2;
  
  
  // Draw the actual graph
  for (int i = 0; i < usage.length; i++) {
    float x = (i * barWidth) + barPad + startX;
    float y = 0; // Initialize this so we can use it below without errors
    if (usage[i] == -1000) {
      // If it's -1000, which is an invalid value, we'll make it be zero height
      y = map(0, 0, maxHeight, 0, h);
    }
    else if (usage[i] == 0) {
      // It's 0, which is equivalent to "no data yet," but we should "pad" it
      //   to our baselineUsage figure so the graph is visible
      y = map(baselineUsage, 0, maxHeight, 0, h);
    }
    else {
      y = map(usage[i], 0, maxHeight, 0, h);
    }
    y = h - y; // Invert the initial y value so we can draw from the top left
    float rectW = barWidth - barPad;
    float rectH = h - y;
    int barHue = 220; // Default to blue
    if (i == hilite) {
      fill(200); // Fill with a brigher color for our current hour
      barHue = 175; // Change our hue for out current hour
    }
    if (label.equals("Daily Usage for past month:") && i == abs(billingCycleStartDay + (day() - 29)) ) {
      // Let's manually hilite the billingCycleStartDay
      // We need to make this if() more robust I think, maybe using Java Calendar library?
      fill(150);
      barHue = 0;
    }

    //noStroke();
    //rect(x, y + startY, rectW, rectH);
    drawGrad(x, y + startY, rectW, rectH, barHue);
    
    // Let's try drawing a number to represent which bar we're on
    textFont(smallFont);
    textAlign(CENTER);
    fill(0);
    if (label.equals("Hourly Usage:")) {
      text(i, x + (barWidth / 2) - 2, startY + h + 12);
    }
    else if (label.equals("Daily Usage for past month:")) {
      // Display the day of month number
      Calendar date = Calendar.getInstance();
      SimpleDateFormat dateFormat = new SimpleDateFormat("dd");
      String displayDay;
      date.add(Calendar.DAY_OF_MONTH, (i+1) - 31);
      displayDay = dateFormat.format(date.getTime());
      text(displayDay, x + (barWidth / 2) - 2, startY + h + 12);
      // Display the day name
      //textFont(tinyFont);
      dateFormat = new SimpleDateFormat("E"); // "E" means Sun Mon Tue Wed Thu Fri Sat
      displayDay = dateFormat.format(date.getTime()); // Format our calendar "date" to three letter day name
      displayDay = displayDay.substring(0, 2); // Shorten the string to the first two characters (Su Mo Tu We Th Fr Sa)
      text(displayDay, x + (barWidth / 2) - 2, startY + h + 26);
    }
    else if (label.equals("Monthly Usage for past 2 years:")) {
      Calendar date = Calendar.getInstance();
      SimpleDateFormat dateFormat = new SimpleDateFormat("MM");
      String displayMonth;
      date.add(Calendar.MONTH, - 24);
      for (int j = 0; j < (i+1); j++) {
        // It'd probably be better and easier to just use something like i-month(), unless we want to display "Jan", etc under each bar
        date.roll(Calendar.MONTH, true);
      }
      displayMonth = dateFormat.format(date.getTime());
      text(displayMonth, x + (barWidth / 2) - 2, startY + h + 12);
      // Display the month
      textFont(tinyFont);
      dateFormat = new SimpleDateFormat("MMM");
      displayMonth = dateFormat.format(date.getTime());
      text(displayMonth, x + (barWidth / 2) - 2, startY + h + 24);
    }
  }
}

void drawGrad(float x, float y, float w, float h, int barHue) {
  // Draws a gradient bar with a "ramp" up from dark to light, then plateaus through the center, then ramps back to dark
  // This hopefully gives a 3D effect to the bar graph bars.
  // We'll be drawing a bunch of vertical lines of various brighness to simulate a solid bar
  
  // Let's round our figures out so that the bars will be nice and crisp (and not transparent for some reason)
  x = round(x);
  y = ceil(y);  // Use ceil here so our bottoms line up on the graph
  w = round(w);
  h = floor(h); // Use floor here so our bottoms line up on the graph
  
  colorMode(HSB, 360, 100, w); // Change our color mode to HSB since we want to affect Brightness only
  int sat = 40;                // Save the saturation value so we can use it below
  for (int i = 0; i < w; i++) {
    if (i/w < .2) {            // If < .2, which is a percentage, then we're at the left edge of the bar
      stroke(barHue, sat, i*4);// Change our stroke brightness
    }
    if (i/w > .7) {            // If > .7, which is a percentage, then we're at the right edge of the bar
      stroke(barHue, sat, (w-i) * 3);// Change our stroke brightness
    }
    line(x+i, y, x+i, y+h);    // Draw our line in the color we've specified
  }
  colorMode(RGB, 255);         // Reset color mode to original mode
}




void drawTierGraph(int startX, int startY, int w, int h) {
  // This will draw a horizontal bar graph showing how "full" each of the three tiers are.
  // Assuming 3 Tiers: 0-500, 501-1000, 1001+
  // Since the first 2 tiers are 500 kWh wide, if tier 3 happens to be more than 500 then
  //   we'll have to scale tier 1 and 2 down.
  // If we end up with a user configurable set of tiers we'll have to update this
  //   to reflect the user settings.

  textAlign(CENTER);
  textFont(bigFont);

  // Draw a couple lines to "enclose" our horizontal bar graph
  stroke(128);
  line(startX, startY-1, width, startY-1);
  line(startX, startY+h, width, startY+h);
  // Draw some more lines in decreasing darkness to simulate a drop shadow
  stroke(160);
  line(startX, startY+h+1, width, startY+h+1);
  stroke(200);
  line(startX, startY+h+2, width, startY+h+2);
  stroke(240);
  line(startX, startY+h+3, width, startY+h+3);


  // Tier 1
  if (currentTier >= 1) {
    float tierW = 0.0;
    if (currentTier > 1) {
      // The whole tier 1 graph will be 100% full
      tierW = map(500, 0, 500, 0, w-1);
      // No need for the "background" rectangle here since it will be 100% covered
    }
    else {
      // Map the "percentage full" the bar will be (not a real percentage though)
      tierW = map(currentkWhReading - billingCycleStartUsage, 0, 500, 0, w-1);
    }
    fill(0, 255, 0); // Green
    noStroke();
    rect(startX, startY, tierW, h/3);
  }

  // Tier 2
  if (currentTier >= 2) {
    float tierW = 0.0;
    if (currentTier > 2) {
      // The whole tier 2 graph will be 100% full
      tierW = map(500, 0, 500, 0, w-1);
    }
    else {
      tierW = map((currentkWhReading - billingCycleStartUsage) - 500, 0, 1000, 0, w-1);
    }
    fill(255, 255, 0); // Yellow
    noStroke();
    rect(startX, startY + (h/3), tierW, h/3);
  }

  // Tier 3
  if (currentTier > 2) {
    float tierW = 0.0;
    tierW = map((currentkWhReading - billingCycleStartUsage) - 1000, 0, 1000, 0, w-1);
    fill(255, 0, 0); // Red
    noStroke();
    rect(startX, startY + ((h/3) * 2), tierW, h/3);
  }
  
  fill(0);
  text ("Current Tier: " + currentTier, width/2, startY + (h / 2) + 8);
  
  // If Tier 3 ever grows beyond 500 kWh wide it'd be nice to keep it 100% width, but then scale down both
  //  tier 1 and 2 graph widths proportionly (make them narrower). Alternatively, we could probably add a
  //  fourth or fifth bar graph line underneath Tier 3.
}

