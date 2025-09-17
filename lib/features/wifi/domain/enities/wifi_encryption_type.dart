enum WifiEncryptionType {
  open,
  wpa2Personal,
  wpa3Personal,
  wpa2Enterprise,
  wpa3Enterprise,
}

extension WifiEncryptionTypeExtension on WifiEncryptionType {
  String get formatted {
    switch (this) {
      case WifiEncryptionType.open:
        return 'Open';
      case WifiEncryptionType.wpa2Personal:
        return 'WPA2 Personal';
      case WifiEncryptionType.wpa3Personal:
        return 'WPA3 Personal';
      case WifiEncryptionType.wpa2Enterprise:
        return 'WPA2 Enterprise';
      case WifiEncryptionType.wpa3Enterprise:
        return 'WPA3 Enterprise';
    }
  }
}
