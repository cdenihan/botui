import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DashboardScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title or Logo Placeholder
                Text(
                  "Device Dashboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Dashboard Tiles
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildDashboardTile(
                      context: context,
                      label: "Sensors",
                      icon: Icons.sensors,
                      destination: SensorsScreen(),
                    ),
                    _buildDashboardTile(
                      context: context,
                      label: "Program",
                      icon: Icons.code,
                      destination: ProgramScreen(),
                    ),
                    _buildDashboardTile(
                      context: context,
                      label: "Settings",
                      icon: Icons.settings,
                      destination: SettingsScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTile({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Widget destination,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
      child: Container(
        width: 200,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SensorsScreen extends StatefulWidget {
  @override
  _SensorsScreenState createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  String _selectedSensor = "Temperature";
  final List<String> _sensors = ["Temperature", "Humidity", "Pressure"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, "Sensors"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Sensor Selection
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      color: Colors.grey[850],
                      child: DropdownButton<String>(
                        dropdownColor: Colors.grey[900],
                        value: _selectedSensor,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        underline: Container(height: 1, color: Colors.white),
                        onChanged: (value) {
                          setState(() {
                            _selectedSensor = value ?? _selectedSensor;
                          });
                        },
                        items: _sensors.map<DropdownMenuItem<String>>((sensor) {
                          return DropdownMenuItem<String>(
                            value: sensor,
                            child: Text(sensor),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Graph placeholder
                    Expanded(
                      child: Container(
                        color: Colors.grey[800],
                        child: Center(
                          child: Text(
                            "Graph for $_selectedSensor",
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Time Range Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRangeButton("1 min"),
                        _buildRangeButton("5 min"),
                        _buildRangeButton("1 hr"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeButton(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey[700],
        minimumSize: Size(80, 40),
      ),
      onPressed: () {
        // Handle range change
      },
      child: Text(label),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, "Settings"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: [
                    _buildSettingItem(Icons.wifi, "Wi-Fi", Colors.green),
                    _buildSettingItem(
                        Icons.power_settings_new, "Shutdown", Colors.red),
                    _buildSettingItem(Icons.refresh, "Reboot", Colors.orange),
                    // Add more settings as needed
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: () {
          // Handle setting action
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 18),
            )
          ],
        ),
      ),
    );
  }
}

class ProgramScreen extends StatefulWidget {
  @override
  _ProgramScreenState createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  String _programArg = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, "Program"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Argument Input
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.grey[850],
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              style: TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                labelText: "Argument",
                                labelStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white70),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              onChanged: (val) {
                                _programArg = val;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Start program with _programArg
                            },
                            child: Text("Start"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Terminal Output
                    Expanded(
                      child: Container(
                        color: Colors.grey[800],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Program started...\n",
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 18),
                                  ),
                                  TextSpan(
                                    text: "Loading data...\n",
                                    style: TextStyle(
                                        color: Colors.yellow, fontSize: 18),
                                  ),
                                  TextSpan(
                                    text: "Error: Unable to reach server.\n",
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTopBar(BuildContext context, String title) {
  return Container(
    color: Colors.grey[900],
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    height: 50,
    child: Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 48), // Placeholder to balance arrow icon space
      ],
    ),
  );
}
