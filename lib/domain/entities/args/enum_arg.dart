import 'arg.dart';

class EnumArg extends Arg {
  final List<String> options;
  final String initial;

  EnumArg({
    required this.options,
    required this.initial,
  }) : super(type: 'enum');

  factory EnumArg.fromJson(Map<String, dynamic> json) {
    List<dynamic> optionsJson = json['options'] ?? [];
    List<String> optionsList = optionsJson.cast<String>();

    String initialValue = json['initial'] ?? (optionsList.isNotEmpty ? optionsList[0] : '');

    if (!optionsList.contains(initialValue)) {
      initialValue = optionsList.isNotEmpty ? optionsList[0] : '';
    }

    return EnumArg(
      options: optionsList,
      initial: initialValue,
    );
  }
}
