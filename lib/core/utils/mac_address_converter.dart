int macAddressToInt(String mac) {
  // Remove colons, dashes, or spaces
  String cleanMac = mac.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');

  if (cleanMac.length != 12) {
    throw FormatException('Invalid MAC address format');
  }

  // Parse hex string to integer
  return int.parse(cleanMac, radix: 16);
}