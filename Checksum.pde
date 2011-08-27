int calculateChecksum (String nmeaString) {
  // This code is based off of code at http://forum.processing.org/topic/xor-checksum
  // I believe code on processing.org is open source, but I'm unable to verify this.
  
  // We first need to strip off the beginning "$" character
  nmeaString = nmeaString.substring(1);
  
  // Then we need to grab the checksum that was sent as the last characters of the string, after the asterisk
  String[] temp = split(nmeaString, '*'); // Create a new String array then separate the data from the checksum at the * character
  // temp[0] should now look something like "UMSCM,37287443,4,23364"
  // temp[1] should now look something like "62"
  String checksum = temp[1];
  // For clarity, let's save our parsed temp[0] into nmeaString
  nmeaString = temp[0];
  
  byte xorResult = 0;
  for (int i = 0; i < nmeaString.length(); i++) { // Loop as many times as there are characters in the string
    xorResult ^= byte(nmeaString.charAt(i)); // ^ is XOR, which is the method used to encode the checksum
  }
  // Now "xorResult" is what we've calculated the checksum to be, so we need to check it against what the given data thinks the checksum is
  String calculatedChecksum = hex(xorResult); // Convert our byte/hex data to a string so we can compare them
  
  // And for testing let's print things out:
  if (debug) { print("calculated checksum for: " + nmeaString + " given: " + checksum + ", calculated: " + calculatedChecksum); }
  
  if (calculatedChecksum.equals(checksum)) { // I'm using .equals instead of == since I've had problems with that operand messing up sometimes
    // They're the same checksums, so return 0 to say it's good
    // I know 1 usually means true, but programming conventions also seem to usually return 0 when the function had no problems,
    //   so that's what I'm doing here.
    if (debug) { println("  They match!"); }
    return 0;
  }
  else {
    // They checksums don't match, so they're bad
    if (debug) { println("  They DON'T match!"); }
    return 1;
  }
}
