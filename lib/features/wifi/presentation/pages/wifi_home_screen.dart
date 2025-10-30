import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/core/widgets/responsive_grid.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';
import 'package:stpvelox/features/wifi/application/network_mode_notifier.dart';
import 'package:stpvelox/features/wifi/domain/enities/network_mode.dart';
import 'package:stpvelox/features/wifi/domain/presentation/screens/access_point_config_screen.dart';
import 'package:stpvelox/features/wifi/domain/presentation/screens/saved_networks_screen.dart';
import 'package:stpvelox/features/wifi/presentation/pages/access_point_status_screen.dart';
import 'package:stpvelox/features/wifi/presentation/pages/device_info_screen.dart';
import 'package:stpvelox/features/wifi/presentation/pages/lan_only_status_screen.dart';
import 'package:stpvelox/features/wifi/presentation/pages/wifi_scan_list_screen.dart';
import 'package:stpvelox/features/wifi/presentation/widgets/grid_tile.dart';

class WifiHomeScreen extends ConsumerStatefulWidget {
  const WifiHomeScreen({super.key});

  @override
  ConsumerState<WifiHomeScreen> createState() => _WifiHomeScreenState();
}

class _WifiHomeScreenState extends ConsumerState<WifiHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(networkModeProvider.notifier).loadNetworkMode();
    });
  }

  void _handleModeChange(NetworkMode selectedMode) {
    ref.read(networkModeProvider.notifier).updateNetworkMode(selectedMode);

    // Check if mode change was successful after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final state = ref.read(networkModeProvider);
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red[600],
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${_getModeDisplayName(selectedMode)}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green[600],
          ),
        );
      }
    });
  }

  String _getModeDisplayName(NetworkMode mode) {
    switch (mode) {
      case NetworkMode.client:
        return 'WiFi Client Mode';
      case NetworkMode.accessPoint:
        return 'Hotspot Mode';
      case NetworkMode.lanOnly:
        return 'LAN Only Mode';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(networkModeProvider);
    final currentMode = (state.isLoading) ? NetworkMode.client : state.mode;

    return Scaffold(
      appBar: createTopBar(context, 'Network Control'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              _buildModeSelector(currentMode),
              const SizedBox(height: 12),
              Expanded(child: _buildContent(currentMode)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector(NetworkMode currentMode) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Mode:',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<NetworkMode>(
                value: currentMode,
                dropdownColor: Colors.grey[800],
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down,
                    color: Colors.white, size: 28),
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
                items: NetworkMode.values.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Row(
                      children: [
                        Icon(_getModeIcon(mode),
                            color: _getModeColor(mode), size: 24),
                        const SizedBox(width: 12),
                        Text(_getModeDisplayName(mode)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (NetworkMode? selectedMode) {
                  if (selectedMode != null && selectedMode != currentMode) {
                    _handleModeChange(selectedMode);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(NetworkMode currentMode) {
    return ResponsiveGrid(
      children: [
        if (currentMode == NetworkMode.client) ...[
          ResponsiveGridTile(
            label: "Connect to WiFi",
            icon: Icons.wifi,
            color: Colors.blue[600]!,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WifiScanListScreen()),
            ),
          ),
          ResponsiveGridTile(
            label: "Saved Networks",
            icon: Icons.bookmark,
            color: Colors.green[600]!,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavedNetworksScreen()),
            ),
          ),
        ],
        if (currentMode == NetworkMode.accessPoint) ...[
          ResponsiveGridTile(
            label: "Hotspot Settings",
            icon: Icons.router,
            color: Colors.purple[600]!,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AccessPointConfigScreen()),
            ),
          ),
          ResponsiveGridTile(
            label: "Network Status",
            icon: Icons.network_check,
            color: Colors.orange[600]!,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccessPointStatusScreen()),
            ),
          ),
        ],
        if (currentMode == NetworkMode.lanOnly)
          ResponsiveGridTile(
            label: "LAN Status",
            icon: Icons.cable,
            color: Colors.grey[600]!,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LanOnlyStatusScreen()),
            ),
          ),
        ResponsiveGridTile(
          label: "Device Info",
          icon: Icons.info,
          color: Colors.teal[600]!,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DeviceInfoScreen()),
          ),
        ),
      ],
    );
  }

  IconData _getModeIcon(NetworkMode mode) {
    switch (mode) {
      case NetworkMode.client:
        return Icons.wifi;
      case NetworkMode.accessPoint:
        return Icons.router;
      case NetworkMode.lanOnly:
        return Icons.cable;
    }
  }

  Color _getModeColor(NetworkMode mode) {
    switch (mode) {
      case NetworkMode.client:
        return Colors.blue[300]!;
      case NetworkMode.accessPoint:
        return Colors.purple[300]!;
      case NetworkMode.lanOnly:
        return Colors.grey[400]!;
    }
  }
}
