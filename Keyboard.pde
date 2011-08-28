void keyPressed() {
  if (key == 'g' || key == 'G') {
    // For debugging let's print our arrays out
    println("hour()=" + hour() + "  day()=" + day());
    print("cumulative:  ");
    for (int i = 0; i < 24; i++ ) {
      print(nfs(cumulativeHourlyUsage[i], 5, 1) + " ");
    }
    println();
    print("hourlyUsage: ");
    for (int i = 0; i < 24; i++ ) {
      print(nfs(hourlyUsage[i], 5, 1) + " ");
    }
    println();
    //for (int i = 0; i < 24; i++ ) {
    //  print(nfs(interpolatedHourlyUsage[i], 5, 1) + " ");
    //}
    //println();
    print("dailyUsage:   ");
    for (int i = 0; i < 31; i++ ) {
      print(nf(dailyUsage[i], 2, 0) + " ");
    }
    println();
    print("monthlyUsage: ");
    for (int i = 0; i < 24; i++ ) {
      print(nf(monthlyUsage[i], 3, 0) + " ");
    }
    println();
    //println("billToday:              " + nf(billToday,     0, 2));
    //println("billThisCycle:          " + nf(billThisCycle, 0, 2));
    println("midnightUsage:          " + midnightUsage);
    println("billingCycleStartUsage: " + billingCycleStartUsage);
    println("*******************************");
  }
  
  if (key == 'd' || key == 'D') {
    debug = !debug; // Toggle debug mode
  }
  
  if (key == 'r' || key == 'R') {
    AMRReset();
  }
  
  if (key == 's') {
    saveWindowImage();
  }
  
  if (key == 'S') {
    saveUserPrefs();
  }
  if (key == 'L') {
    loadUserPrefs();
  }
  
  if (key == 'c' || key == 'C') {
    calculateBilling();
    calculateUsage(24);
  }
}
