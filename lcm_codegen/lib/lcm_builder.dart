import 'package:build/build.dart';
import 'src/generator.dart';

class LcmBuilder implements Builder {
  const LcmBuilder();

  @override
  Map<String, List<String>> get buildExtensions => const {
    '.lcm': ['.lcm.g.dart'], // input -> generated output next to it
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final input = buildStep.inputId;
    final content = await buildStep.readAsString(input);

    // Your single-struct parser; consider extending to support multiple structs.
    final dartCode = LcmDartGenerator.generateClass(content);

    final output = AssetId(
      input.package,
      input.path.replaceFirst(RegExp(r'\.lcm$'), '.lcm.g.dart'),
    );

    await buildStep.writeAsString(output, dartCode);
  }
}

Builder lcmBuilder(BuilderOptions options) => const LcmBuilder();
