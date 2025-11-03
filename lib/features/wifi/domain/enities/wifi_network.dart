import 'wifi_encryption_type.dart';

class WifiNetwork implements Comparable {
  final String ssid;
  final bool isKnown;
  final bool isConnected;
  final WifiEncryptionType encryptionType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WifiNetwork &&
          runtimeType == other.runtimeType &&
          ssid == other.ssid &&
          encryptionType == other.encryptionType;

  @override
  int get hashCode => Object.hash(ssid, encryptionType);

  @override
  int compareTo(other) {
    {
      // First priority: connected networks
      if (isConnected && !other.isConnected) return -1;
      if (!isConnected && other.isConnected) return 1;

      // Second priority: known networks
      if (isKnown && !other.isKnown) return -1;
      if (!isKnown && other.isKnown) return 1;

      // Third priority: alphabetical by SSID
      return ssid.toLowerCase().compareTo(other.ssid.toLowerCase());
    }
  }

  WifiNetwork({
    required this.ssid,
    required this.encryptionType,
    this.isKnown = false,
    this.isConnected = false,
  });
}