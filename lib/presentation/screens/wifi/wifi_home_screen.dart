import 'package:flutter/material.dart';
import 'package:stpvelox/presentation/screens/wifi/device_info_screen.dart';
import 'package:stpvelox/presentation/screens/wifi/wifi_scan_list_screen.dart';
import 'package:stpvelox/presentation/widgets/dashboard_tile.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';

import 'wifi_manual_connect_screen.dart';

class WifiHomeScreen extends StatelessWidget {
  const WifiHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createTopBar(context, 'WiFi Control'),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: DashboardTile(
                  label: "Scan & Select WiFi",
                  icon: Icons.wifi,
                  destination: WifiScanListScreen(),
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                flex: 2,
                child: DashboardTile(
                  label: "Connect by SSID",
                  icon: Icons.connect_without_contact,
                  destination: WifiManualConnectScreen(),
                  color: Colors.green,
                  isMain: true,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                flex: 1,
                child: DashboardTile(
                  label: "View Device Info",
                  icon: Icons.info,
                  destination: DeviceInfoScreen(),
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
