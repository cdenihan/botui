import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stpvelox/core/utils/sudo_process.dart';

class ScreenRotationScreen extends StatefulWidget {
  const ScreenRotationScreen({super.key});

  @override
  State<ScreenRotationScreen> createState() => _ScreenRotationScreenState();
}

class _ScreenRotationScreenState extends State<ScreenRotationScreen> {
  int _currentRotation = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentRotation();
  }

  Future<void> _loadCurrentRotation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentRotation = prefs.getInt('screen_rotation') ?? 0;
    });
  }

  Future<void> _applyRotation(int rotation) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Save rotation to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('screen_rotation', rotation);

      // Update the flutter-pi service file with the new rotation
      await _updateFlutterPiService(rotation);

      // Restart the flutter-ui service
      await SudoProcess.run('systemctl', ['restart', 'flutter-ui']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rotation applied! Restarting service...'),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error applying rotation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateFlutterPiService(int rotation) async {
    // Read the current service file
    final readResult = await SudoProcess.run('cat', ['/etc/systemd/system/flutter-ui.service']);

    if (readResult.exitCode != 0) {
      throw Exception('Failed to read flutter-ui.service file');
    }

    String serviceContent = readResult.stdout.toString();

    // Update or add the rotation argument to the ExecStart line
    final lines = serviceContent.split('\n');
    final updatedLines = <String>[];

    for (String line in lines) {
      if (line.trim().startsWith('ExecStart=')) {
        // Remove existing -r argument if present
        String updatedLine = line.replaceAll(RegExp(r'-r\s+\d+'), '').trim();

        // Find the position to insert the rotation argument (before the app path)
        final match = RegExp(r'(flutter-pi[^\s]*)\s+(.*)').firstMatch(updatedLine);
        if (match != null) {
          final flutterPiCmd = match.group(1);
          final restOfLine = match.group(2) ?? '';
          updatedLine = 'ExecStart=$flutterPiCmd -r $rotation $restOfLine';
        } else {
          // Fallback: just append the rotation argument
          updatedLine = '$updatedLine -r $rotation';
        }

        updatedLines.add(updatedLine);
      } else {
        updatedLines.add(line);
      }
    }

    final newServiceContent = updatedLines.join('\n');

    // Write the updated service file
    await SudoProcess.run('sh', [
      '-c',
      'echo "${newServiceContent.replaceAll('"', '\\"')}" > /etc/systemd/system/flutter-ui.service',
    ]);

    // Reload systemd daemon
    await SudoProcess.run('systemctl', ['daemon-reload']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Screen Rotation'),
        backgroundColor: Colors.grey[900],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Applying rotation...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Select Screen Rotation',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The screen will restart after applying the rotation',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildRotationCard(0, 'Normal', Icons.stay_current_portrait),
                        _buildRotationCard(90, '90°', Icons.screen_rotation),
                        _buildRotationCard(180, '180°', Icons.stay_current_portrait),
                        _buildRotationCard(270, '270°', Icons.screen_rotation),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRotationCard(int rotation, String label, IconData icon) {
    final isSelected = _currentRotation == rotation;

    return Card(
      color: isSelected ? Colors.blue[700] : Colors.grey[800],
      elevation: isSelected ? 8 : 4,
      child: InkWell(
        onTap: () => _applyRotation(rotation),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: rotation * 3.14159 / 180,
                child: Icon(
                  icon,
                  size: 64,
                  color: isSelected ? Colors.white : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[400],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 8),
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
