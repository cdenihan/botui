import 'package:flutter/material.dart';
import 'package:stpvelox/domain/entities/setting.dart';

class SettingModel extends Setting {
  SettingModel({
    required super.icon,
    required super.label,
    required super.color,
  });

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      icon: IconsMap[json['icon']] ?? Icons.settings,
      label: json['label'],
      color: Color(int.parse(json['color'], radix: 16)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': IconsMapInverse[icon] ?? 'settings',
      'label': label,
      'color': color.value.toRadixString(16),
    };
  }
}

const IconsMap = <String, IconData>{
  'wifi': Icons.wifi,
  'power_settings_new': Icons.power_settings_new,
  'refresh': Icons.refresh,
};

var IconsMapInverse = <IconData, String>{
  Icons.wifi: 'wifi',
  Icons.power_settings_new: 'power_settings_new',
  Icons.refresh: 'refresh',
};
