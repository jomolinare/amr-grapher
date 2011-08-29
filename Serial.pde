void serialEvent (Serial AMRport) {  
  // get the ASCII string:
  tempString = AMRport.readStringUntil('\n');
  tempString = trim(tempString);
  if (calculateChecksum(tempString) == 1) {
    // The checksum was invalid, erase tempString so we don't save the invalid data to the file
    tempString = "";
    return;
  }
  
  // For now, let's only save data for the meter we're interested in logging
  // And we'll only save the usage data from the entire string
  String[] separateData = splitTokens(tempString, ",*");
  if (separateData[1].equals(meterSerialNumber)) {
    tempString = separateData[3];
    saveString = tempString; // Update our saveString with the most recent legit data
    currentkWhReading = parseFloat(tempString);
    justReceivedData = true;
    if (millis()-lastContact > longestLOS) {
      longestLOS = millis() - lastContact;
    }
    lastContact = millis();
    if (usageThisCycle < 0 || currentkWhReading != parseFloat(tempString)) {
      // This is probably our first data from the AMR, we need to update our usage calcs
      // Or the kWh reading has changed, so update our usage calcs
      calculateBilling(); // Uupdate our billing numbers
      calculateUsage(24); // This would probably be better as 1 instead of 24, but it takes so little to process we might as well do 24
    }
  }
  else {
    // The serial number didn't match our meter, so erase the data from tempString
    tempString = "";
  }
}


void AMRSetup() {
  AMRport.write("FULL OFF\n");
//  delay(250);
//  AMRport.write("RBKT\n");
//  delay(250);
//  AMRport.write("WGHT 5\n");
}

void AMRReset() {
  fill(255,0,0);
  textFont(bigFont);
  textAlign(CENTER);
  text("Waited too long for data!", width/2, height/2 + 44);
  text("Resetting AMR...", width/2, height/2 + 66);
  delay(100);
  AMRport.write("RSET\n");
  delay(5000);
  AMRSetup();
}
