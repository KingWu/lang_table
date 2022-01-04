library airtable_generator;

import 'package:lang_table/lang_table.dart';
import 'package:lang_table/src/extra_key_value.dart';
import 'package:lang_table/src/print_tool.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lang_table/src/json_builder.dart';
import 'dart:io';

class AirTableGenerator implements PlatformGenerator {
  @override
  void build(ConfigOption config) async {
    Map<String, String> headers = {};
    headers['Authorization'] = 'Bearer ${config.apiKey}';

    var offset;
    bool isError = false;

    JsonBuilder jsonBuilder = JsonBuilder();

    do {
      var offsetParama = '';
      if (null != offset) {
        offsetParama = '?offset=${offset}';
      }

      var response = await http.get(Uri.parse('${config.input}${offsetParama}'),
          headers: headers);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        offset = jsonResponse['offset'];
        List<dynamic> records = jsonResponse['records'];

        if (records.length > 0) {
          if (!jsonBuilder.isInitialized()) {
            bool isSuccess =
                jsonBuilder.initialize(extractHeaderList(records[1]));
            if (!isSuccess) {
              printError("Missing Json Key Header or Locale headers");
              isError = true;
              break;
            }
          }
          processRecords(jsonBuilder, records);
          sleep(
              Duration(milliseconds: 220)); // Rate Limit : 5 request per second
        }
      } else {
        printError("Request failed with status: ${response.statusCode}.");
        printError("Request Message : ${response.body}.");
        isError = true;
        break;
      }
    } while (offset != null);

    if (!isError) {
      // Generate Code
      jsonBuilder.generateFiles(config.outputDir);
      printInfo('Success to generate files');
    }
  }

  @override
  String? validArguments(ConfigOption config) {
    if (null == config.apiKey) {
      return 'Argument "api-key" is missing';
    }

    if (config.target != 'Flutter') {
      return 'platform [${config.platform}] does not support the target [${config.target}]';
    }
    return null;
  }

  List<ExtractedHeader> extractHeaderList(record) {
    List<ExtractedHeader> headers = [];

    Map<String, dynamic> fields = record['fields'];
    for (String jsonKey in fields.keys) {
      ExtractedHeader extractedHeader = convertToExtractedHeader(jsonKey);
      if (ContentType.none != extractedHeader.type) {
        headers.add(extractedHeader);
      }
    }
    return headers;
  }

  void processRecords(JsonBuilder jsonBuilder, List<dynamic> records) {
    String jsonKeyHeader = jsonBuilder.getJsonKeyHeader();
    List<ExtractedHeader> localeHeaderList =
        jsonBuilder.getMessageLocaleHeaderList();

    for (dynamic record in records) {
      Map<String, dynamic> fields = record['fields'];
      if (fields.isEmpty) {
        continue;
      }

      String? jsonKey = fields[jsonKeyHeader];

      for (ExtractedHeader localeHeader in localeHeaderList) {
        dynamic message = fields[localeHeader.header];
        if (message is List) {
          message = message[0];
        }

        if (null != message) {
          jsonBuilder.writeData(jsonKey, localeHeader.header, message);
        }
      }
    }
  }
}
