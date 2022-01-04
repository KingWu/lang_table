library lang_table;

import 'package:lang_table/src/generator/airtable_generator.dart';

class ConfigOption {
  String? platform;
  String? input;
  String? apiKey;
  String? outputDir;
  String? target;

  @override
  String toString() {
    return 'ConfigOption{platform: $platform, input: $input, apiKey: $apiKey, outputDir: $outputDir, target: $target}';
  }
}

abstract class PlatformGenerator {
  void build(ConfigOption config);
  String? validArguments(ConfigOption config);
}

PlatformGenerator? platformGeneratorFactory(String? platform) {
  if (platform == 'airTable') {
    return AirTableGenerator();
  }
  return null;
}
