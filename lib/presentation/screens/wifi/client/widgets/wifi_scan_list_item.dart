import 'package:flutter/material.dart';
import 'package:stpvelox/domain/entities/wifi_encryption_type.dart';
import 'package:stpvelox/domain/entities/wifi_network.dart';
import 'package:stpvelox/presentation/screens/wifi/client/wifi_detail_screen.dart';

class WifiScanListItem extends StatelessWidget {
  final WifiNetwork network;

  const WifiScanListItem({super.key, required this.network});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        tileColor: Colors.grey[900],
        title: Text(
          network.ssid,
          style: TextStyle(
            fontSize: 16,
            fontWeight:
                network.isConnected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              network.isConnected
                  ? 'Connected'
                  : network.isKnown
                      ? 'Saved Network - Tap to connect'
                      : 'Tap to configure',
              style: TextStyle(
                color: network.isConnected
                    ? Colors.green
                    : network.isKnown
                        ? Colors.blue
                        : Colors.grey,
              ),
            ),
            if (network.encryptionType != WifiEncryptionType.open)
              Text(
                _getEncryptionLabel(network.encryptionType),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              network.isKnown ? Icons.bookmark : Icons.wifi,
              color: network.isConnected
                  ? Colors.green
                  : network.isKnown
                      ? Colors.blue
                      : Colors.grey,
            ),
            if (network.encryptionType != WifiEncryptionType.open)
              const Icon(
                Icons.lock,
                size: 12,
                color: Colors.grey,
              ),
          ],
        ),
        trailing: network.isKnown && !network.isConnected
            ? IconButton(
                onPressed: () {
                  // When connecting to a saved network from the scan list, we don't have credentials here.
                  // The WifiDetailScreen will handle collecting them if needed.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WifiDetailScreen(network: network),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow, color: Colors.green),
                tooltip: 'Quick Connect',
              )
            : Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WifiDetailScreen(network: network),
            ),
          );
        },
      ),
    );
  }

  String _getEncryptionLabel(WifiEncryptionType encryptionType) {
    switch (encryptionType) {
      case WifiEncryptionType.wpa3Personal:
        return 'WPA3';
      case WifiEncryptionType.wpa2Personal:
        return 'WPA2';
      case WifiEncryptionType.wpa3Enterprise:
        return 'WPA3 Enterprise';
      case WifiEncryptionType.wpa2Enterprise:
        return 'WPA2 Enterprise';
      case WifiEncryptionType.open:
        return 'Open';
    }
  }
}
