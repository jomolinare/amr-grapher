void calculateBilling() {
  // Calculate billThisCycle
  usageThisCycle = currentkWhReading - billingCycleStartUsage;
  float tier1 = usageThisCycle;
  float tier2 = 0;
  float tier3 = 0;
  currentTier  = 1; // Save which tier we're currently in
  if (tier1 > 500) {
    tier1 = 500;
    tier2 = usageThisCycle - 500;
    currentTier  = 2;
  }
  if (tier2 > 1000) {
    tier2 = 500;
    tier3 = usageThisCycle - 1000;
    currentTier  = 3;
  }
  billThisCycle = (tier1 * tier1rate) + (tier2 * tier2rate) + (tier3 * tier3rate) + (kWhSurcharges * usageThisCycle) + basicService;

  // Calculate billToday
  float currentRate = 0;
  switch(currentTier) {
  case 1:
    currentRate = tier1rate;
    break;
  case 2:
    currentRate = tier2rate;
    break;
  case 3:
    currentRate = tier3rate;
  }
  currentRate = currentRate + kWhSurcharges;
  float usageToday = currentkWhReading - midnightUsage;
  billToday = (usageToday * currentRate) + (basicService / 30); // basicService/30 will be close enough for estimating
  // Also, this doesn't take Tier changes during the day into account, but I would expect the difference in costs to be
  //  minimal when that happens. But revisit this sometime to make it accurate, especially for high use people.
}


void calculateUsage(int range) {
  // range should be either 1 or 24, for the number of hours to calculate
  // range == 1 will be requested after our setup() is complete
  // range == 24 will be requested during setup() to give us a full array of info

  // Let's save our current usage to our cumulativeHourlyUsage array
  if (currentkWhReading != 0) {
    // If we just started the sketch then we might not have received any data from the AMR yet.
    // If we haven't then we won't replace cumulativeHourlyUsage[hour()] with our saveString, we'll
    //  just leave the data we pulled in from out hourly log file.
    cumulativeHourlyUsage[hour()] = currentkWhReading;
  }
  if (range == 24) {
    for (int i = 0; i < range; i++) {
      // Then let's calculate how much we used during the past hour by getting the difference between the last two hours
      if (i == 0) {
        // It's the first hour of the day, so we need to "Wrap around" to the previous days data
        hourlyUsage[i] = cumulativeHourlyUsage[i] - cumulativeHourlyUsage[23];
      } 
      else {
        // It's not the last hour of the day, calculate it normally
        hourlyUsage[i] = cumulativeHourlyUsage[i] - cumulativeHourlyUsage[i - 1];
      }
      if (hourlyUsage[i] < 0) {
        // We're subtracting one day from another, resulting in a negative number. This is invalid
        //  so we zero it out manually.
        hourlyUsage[i] = 0;
      }
    }
  }
  else {
    if (hour() == 0) {
      // It's the first hour of the day, so we need to "Wrap around" to the previous days data
      hourlyUsage[hour()] = cumulativeHourlyUsage[hour()] - cumulativeHourlyUsage[23];
    } 
    else {
      // It's not the last hour of the day, calculate it normally
      hourlyUsage[hour()] = cumulativeHourlyUsage[hour()] - cumulativeHourlyUsage[hour() - 1];
    }
  }

  // Then let's see if we need to interpolate the usage data for previous hours
  //calculateInterpolatedHourlyUsage();

  for (int i = 0; i < 24; i++) {
    // Our current interpolation code doesn't work, so just to get data in here
    //  let's just copy the data over until we fix the interpolation code.
    interpolatedHourlyUsage[i] = hourlyUsage[i];
  }
}

void calculateInterpolatedHourlyUsage() {
  // This interpolation code is supposed to make our graph prettier (less abrubt changes)
  //  if we've got low usage during our last day. For example:
  //    hourlyUsage[3] == 0
  //    hourlyUsage[4] == 1
  //  becomes
  //    interpolatedHourlyUsage[3] == .5
  //    interpolatedHourlyUsage[4] == .5
  
  
  float[] usage = new float[48];
  usage = concat(hourlyUsage, hourlyUsage); 
  // Create a new array and put two copies of the hourlyUsage array in it.
  //   This is an experiement for me. It may work fine for small datasets
  //   like this 24 hour one, but maybe not large ones.
  // This will help us avoid running into out of range values when we're
  //   searching beyond the 24 hour day and back into yesterday

  // We're going to loop through each hour and see if the hour is 0, if so
  //   Then we'll look for the next hour that's non-zero (up to 4 hours).
  //   Once we fine a non-zero hour we'll take that non-zero number and
  //   divide it by the number of 0 hours we had to get an average. Then
  //   we'll save that average into each of the interpolatedHourlyUsage
  //   hours that had zero usage.
  // We'll need to do this for each hour through the day. We might have
  //   to wrap around to the previous day to do so.

  // Setup some variables to track what we're doing
  int divisor = 1; // This will increment each time we fine a zero usage hour

  for (int i = 0; i < 24; i++) {
    if (debug) { 
      print("i:" + i + "=" + usage[i]);
    }
    if (usage[i] == 0) {
      if (usage[i+1] != 0) {
        divisor++;
        interpolatedHourlyUsage[i] = usage[i+1] / divisor;
        if (debug) { 
          print(" i+1:" + (i+1) + " divisor:" + divisor + " interpolated=" + usage[i+1] / divisor);
        }
        //break;
      }
      else if (usage[i+2] != 0) {
        divisor++;
        interpolatedHourlyUsage[i] = usage[i+2] / divisor;
        if (debug) { 
          print(" i+2:" + (i+2) + " divisor:" + divisor + " interpolated=" + usage[i+2] / divisor);
        }
        //break;
      }
      else if (usage[i+3] != 0) {
        divisor++;
        interpolatedHourlyUsage[i] = usage[i+3] / divisor;
        if (debug) { 
          print(" i+3:" + (i+3) + " divisor:" + divisor + " interpolated=" + usage[i+3] / divisor);
        }
        //break;
      }
      else if (usage[i+4] != 0) {
        divisor++;
        interpolatedHourlyUsage[i] = usage[i+4] / divisor;
        if (debug) { 
          print(" i+4:" + (i+4) + " divisor:" + divisor + " interpolated=" + usage[i+4] / divisor);
        }
        //break;
      }
    }
    divisor = 1;
    if (debug) { 
      println();
    }
  }
}

