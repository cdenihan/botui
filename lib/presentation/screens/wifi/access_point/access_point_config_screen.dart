import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/domain/entities/access_point_config.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/access_point/access_point_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/access_point/access_point_event.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/access_point/access_point_state.dart';
import 'package:stpvelox/presentation/screens/wifi/access_point/widgets/access_point_form.dart';
import 'package:stpvelox/presentation/screens/wifi/access_point/widgets/access_point_status.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';

class AccessPointConfigScreen extends StatefulWidget {
  const AccessPointConfigScreen({super.key});

  @override
  State<AccessPointConfigScreen> createState() =>
      _AccessPointConfigScreenState();
}

class _AccessPointConfigScreenState extends State<AccessPointConfigScreen> {
  bool _isStarted = false;
  AccessPointConfig? _config;

  @override
  void initState() {
    super.initState();
    context.read<AccessPointBloc>().add(LoadAccessPointConfigEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createTopBar(context, 'Hotspot Settings'),
      body: BlocListener<AccessPointBloc, AccessPointState>(
        listener: (context, state) {
          if (state is AccessPointLoadedState && state.config != null) {
            setState(() {
              _config = state.config!;
            });
          } else if (state is AccessPointStartedState) {
            setState(() {
              _isStarted = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hotspot started successfully')),
            );
          } else if (state is AccessPointStoppedState) {
            setState(() {
              _isStarted = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hotspot stopped')),
            );
          } else if (state is AccessPointErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccessPointStatus(
                isStarted: _isStarted,
                ssid: _config?.ssid ?? '',
              ),
              const SizedBox(height: 16),
              AccessPointForm(
                initialConfig: _config,
                isStarted: _isStarted,
                onStart: (config) {
                  context.read<AccessPointBloc>().add(StartAccessPointEvent(config));
                },
                onStop: () {
                  context.read<AccessPointBloc>().add(StopAccessPointEvent());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}