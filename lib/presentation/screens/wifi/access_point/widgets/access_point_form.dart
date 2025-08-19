import 'package:flutter/material.dart';
import 'package:stpvelox/core/utils/password_generator.dart';
import 'package:stpvelox/domain/entities/access_point_config.dart';
import 'package:stpvelox/domain/entities/wifi_band.dart';
import 'package:stpvelox/domain/entities/wifi_encryption_type.dart';

class AccessPointForm extends StatefulWidget {
  final AccessPointConfig? initialConfig;
  final Function(AccessPointConfig) onStart;
  final VoidCallback onStop;
  final bool isStarted;

  const AccessPointForm({
    super.key,
    this.initialConfig,
    required this.onStart,
    required this.onStop,
    required this.isStarted,
  });

  @override
  State<AccessPointForm> createState() => _AccessPointFormState();
}

class _AccessPointFormState extends State<AccessPointForm> {
  final _formKey = GlobalKey<FormState>();
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();

  WifiBand _selectedBand = WifiBand.bandAuto;
  WifiEncryptionType _encryptionType = WifiEncryptionType.wpa3Personal;
  bool _isHidden = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialConfig != null) {
      final config = widget.initialConfig!;
      _ssidController.text = config.ssid;
      _passwordController.text = config.password;
      _selectedBand = config.band;
      _encryptionType = config.encryptionType;
      _isHidden = config.hidden;
    } else {
      _ssidController.text = 'STP-Velox-Robot';
      _passwordController.text = PasswordGenerator.generateReadablePassword();
    }
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Network Configuration',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ssidController,
                    decoration: const InputDecoration(
                      labelText: 'Network Name (SSID)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.wifi),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a network name';
                      }
                      if (value.length < 3) {
                        return 'Network name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _passwordController.text =
                                  PasswordGenerator.generateReadablePassword();
                            },
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Generate Password',
                          ),
                        ],
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<WifiBand>(
                    value: _selectedBand,
                    decoration: const InputDecoration(
                      labelText: 'WiFi Band',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.signal_wifi_4_bar),
                    ),
                    items: WifiBand.values.map((band) {
                      return DropdownMenuItem(
                        value: band,
                        child: Text(band.displayName),
                      );
                    }).toList(),
                    onChanged: (WifiBand? value) {
                      if (value != null) {
                        setState(() {
                          _selectedBand = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<WifiEncryptionType>(
                    value: _encryptionType,
                    decoration: const InputDecoration(
                      labelText: 'Security',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.security),
                    ),
                    items: [
                      WifiEncryptionType.wpa3Personal,
                      WifiEncryptionType.wpa2Personal,
                      WifiEncryptionType.open,
                    ].map((type) {
                      String label;
                      switch (type) {
                        case WifiEncryptionType.wpa3Personal:
                          label = 'WPA3 Personal (Recommended)';
                          break;
                        case WifiEncryptionType.wpa2Personal:
                          label = 'WPA2 Personal';
                          break;
                        case WifiEncryptionType.open:
                          label = 'Open (No Security)';
                          break;
                        default:
                          label = type.toString();
                      }
                      return DropdownMenuItem(
                        value: type,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (WifiEncryptionType? value) {
                      if (value != null) {
                        setState(() {
                          _encryptionType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Hidden Network'),
                    subtitle:
                        const Text('Network won\'t appear in WiFi scan results'),
                    value: _isHidden,
                    onChanged: (value) {
                      setState(() {
                        _isHidden = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (widget.isStarted) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onStop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.stop, size: 28),
                    label: const Text('Stop Hotspot',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final config = AccessPointConfig(
                          ssid: _ssidController.text,
                          password: _passwordController.text,
                          band: _selectedBand,
                          encryptionType: _encryptionType,
                          hidden: _isHidden,
                        );
                        widget.onStart(config);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.refresh, size: 28),
                    label: const Text('Restart',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final config = AccessPointConfig(
                          ssid: _ssidController.text,
                          password: _passwordController.text,
                          band: _selectedBand,
                          encryptionType: _encryptionType,
                          hidden: _isHidden,
                        );
                        widget.onStart(config);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.router, size: 28),
                    label: const Text('Start Hotspot',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
