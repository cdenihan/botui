// presentation/pages/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/features/settings/application/settings_providers.dart';
import 'package:stpvelox/features/settings/domain/entities/setting.dart';
import 'package:stpvelox/core/widgets/responsive_grid.dart';
import 'package:stpvelox/core/widgets/top_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: createTopBar(context, "Settings"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: settingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                e.toString(),
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
            data: (settings) => ResponsiveGrid(
              children: settings.map((setting) {
                return _buildSettingItem(context, ref, setting);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, WidgetRef ref, Setting setting) {
    final notifier = ref.read(settingsProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () => notifier.tapSetting(setting, context),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(setting.icon, size: 48, color: setting.color),
              const SizedBox(height: 8),
              Text(
                setting.label,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              if (setting.type == SettingType.toggle)
                Switch(
                  value: setting.value!(),
                  onChanged: (_) => notifier.tapSetting(setting, context),
                  activeColor: setting.color,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
