library airtable_generator;

import 'package:lang_table/base_platform_generator.dart';
import 'package:lang_table/src/extra_key_value.dart';
import 'package:lang_table/src/print_tool.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lang_table/src/json_builder.dart';
import 'dart:io';

class AirTableGenerator implements PlatformGenerator {
  @override
  void build(ConfigOption config) async{

    Map<String, String> headers = {};
    headers['Authorization'] = 'Bearer ${config.apiKey}';


    var offset;
    bool isError = false;

    JsonBuilder jsonBuilder = JsonBuilder();

    do{
      var offsetParama = '';
      if(null != offset){
        offsetParama = '&offset=${offset}';
      }

      var response = await http.get('${config.input}?sort%5B0%5D%5Bfield%5D=JSON%20Key%20%5Bcode%3Dkey%5D&sort%5B0%5D%5Bdirection%5D=asc${offsetParama}', headers: headers);
      printInfo('Request failed with status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        printInfo('jsonResponse: ${jsonResponse.toString()}');

        offset = jsonResponse['offset'];
        List<dynamic> records = jsonResponse['records'];
        if(records.length > 0){
          if(!jsonBuilder.isInitialized()){
            bool isSuccess = jsonBuilder.initialize(extractHeaderList(records[1]));
            if(!isSuccess){
              printError("Missing Json Key Header or Locale headers");
              isError = true;
              break;
            }
          }
          processRecords(jsonBuilder, records);
          sleep(Duration(milliseconds: 220)); // Rate Limit : 5 request per second
        }
      }
      else {
        printError("Request failed with status: ${response.statusCode}.");
        printError("Request Message : ${response.body}.");
        isError = true;
        break;
      }
    } while(offset != null);

    if(!isError){
      // Generate Code
      jsonBuilder.generateFiles(config.outputDir);
    }
  }

  @override
  String validArguments(ConfigOption config) {
    if(null == config.apiKey){
      return 'Argument "api-key" is missing';
    }

    if(config.target != 'Flutter'){
      return 'platform [${config.platform}] does not support the target [${config.target}]';
    }
    return null;
  }

  List<ExtractedHeader> extractHeaderList(record){
    List<ExtractedHeader> headers = [];
    printInfo(record.toString());

    Map<String, dynamic> fields = record['fields'];
    for(String jsonKey in fields.keys){
      ExtractedHeader extractedHeader = convertToExtractedHeader(jsonKey);
      if(ContentType.none != extractedHeader.type){
        headers.add(extractedHeader);
      }
    }
    return headers;
  }

  void processRecords(JsonBuilder jsonBuilder, List<dynamic> records){
    String jsonKeyHeader = jsonBuilder.getJsonKeyHeader();
    List<ExtractedHeader> localeHeaderList = jsonBuilder.getMessageLocaleHeaderList();

    for(dynamic record in records){
      Map<String, dynamic> fields = record['fields'];
      if(fields.isEmpty){
        continue;
      }

      printInfo('--------');
      printInfo(fields.toString());


      String jsonKey = fields[jsonKeyHeader];

      printInfo('jsonKey: $jsonKey');

      for(ExtractedHeader localeHeader in localeHeaderList){
        String message = fields[localeHeader.header];
        printInfo('message: $message');

        if(null != message){
          jsonBuilder.writeData(jsonKey, localeHeader.header, message);
        }
      }
    }
  }
}