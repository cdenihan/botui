import 'wifi_encryption_type.dart';

class WifiNetwork {
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

  WifiNetwork({
    required this.ssid,
    required this.encryptionType,
    this.isKnown = false,
    this.isConnected = false,
  });
}