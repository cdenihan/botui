import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/presentation/blocs/sensor/sensor_bloc.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';

class SensorsScreen extends StatefulWidget {
  @override
  _SensorsScreenState createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  String _selectedSensor = "Temperature";
  final List<String> _timeRanges = ["1 min", "5 min", "1 hr"];

  @override
  void initState() {
    super.initState();
        context.read<SensorBloc>().add(LoadSensorsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: createTopBar("Sensors"),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: BlocBuilder<SensorBloc, SensorState>(
                  builder: (context, state) {
                    if (state is SensorLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is SensorLoaded) {
                      final sensors = state.sensors;
                      return Column(
                        children: [
                                                    Container(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8.0),
                            color: Colors.grey[850],
                            child: DropdownButton<String>(
                              dropdownColor: Colors.grey[900],
                              value: _selectedSensor,
                              icon: Icon(Icons.arrow_drop_down,
                                  color: Colors.white),
                              style:
                              TextStyle(color: Colors.white, fontSize: 18),
                              underline: Container(height: 1, color: Colors.white),
                              onChanged: (value) {
                                setState(() {
                                  _selectedSensor = value ?? _selectedSensor;
                                });
                              },
                              items: sensors.map<DropdownMenuItem<String>>(
                                      (sensor) {
                                    return DropdownMenuItem<String>(
                                      value: sensor.name,
                                      child: Text(sensor.name),
                                    );
                                  }).toList(),
                            ),
                          ),
                          const SizedBox(height: 8),
                                                    Expanded(
                            child: Container(
                              color: Colors.grey[800],
                              child: Center(
                                child: Text(
                                  "Graph for $_selectedSensor",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 24),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                                                    Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _timeRanges
                                .map((range) => _buildRangeButton(range))
                                .toList(),
                          ),
                        ],
                      );
                    } else if (state is SensorError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: TextStyle(color: Colors.red, fontSize: 18),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
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
              },
      child: Text(label),
    );
  }
}
