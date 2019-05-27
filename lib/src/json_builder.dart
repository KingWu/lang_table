library json_builder;

import 'dart:io';

import 'package:lang_table/src/extra_key_value.dart';
import 'package:lang_table/src/print_tool.dart';
import 'package:path/path.dart' as path;

class JsonBuilder{
  List<ExtractedHeader> localeMessageHeaderList = [];
  ExtractedHeader jsonKeyHeader;

  // <Header, FileName>
  Map<String, String> localeFileNameMap = {};

  // <Header, StringBuffer>
  Map<String, StringBuffer> localeStringBuilderMap = {};

  Map<String, bool> isLocaleFirstWriteMap = {};

  bool initialize(List<ExtractedHeader> allHeaders){
    jsonKeyHeader = _pullJsonKeyHeaderFromList(allHeaders);
    localeMessageHeaderList = allHeaders;
    _buildLocaleMap();
    return isInitialized();
  }


  bool isInitialized(){
    return null != jsonKeyHeader && localeMessageHeaderList.isNotEmpty;
  }


  String getJsonKeyHeader(){
    return jsonKeyHeader.header;
  }

  List<ExtractedHeader> getMessageLocaleHeaderList(){
    return localeMessageHeaderList;
  }

  void writeData(String jsonKey, String localeHeader, String message){
    StringBuffer localeBuilder = localeStringBuilderMap[localeHeader];
    if(null != localeBuilder){
      bool isFirstWrite = isLocaleFirstWriteMap[localeHeader];
      if(isFirstWrite){
        isLocaleFirstWriteMap[localeHeader] = false;
      }
      else{
        localeBuilder.writeln(',');
      }
      localeBuilder.write('\t"$jsonKey":"$message"');
    }
  }

  void generateFiles(String outputDir){
    Directory current = Directory.current;

    for(MapEntry<String, String> fileEntry in localeFileNameMap.entries){
      // Create File
      File generatedFile = File(path.join(current.path, outputDir, fileEntry.value));
      if(!generatedFile.existsSync()){
        generatedFile.createSync(recursive: true);
      }

      StringBuffer localeBuilder = localeStringBuilderMap[fileEntry.key];
      localeBuilder.writeln('');
      localeBuilder.write('}');

      // Generate File
      generatedFile.writeAsStringSync(localeBuilder.toString());
    }
  }

  ExtractedHeader _pullJsonKeyHeaderFromList(List<ExtractedHeader> headers){
    for(ExtractedHeader header in headers){
      if(ContentType.key == header.type){
        headers.remove(header);
        return header;
      }
    }
    return null;
  }

  void _buildLocaleMap(){
   for(ExtractedHeader localeHeader in localeMessageHeaderList){
     isLocaleFirstWriteMap[localeHeader.header] = true;
     localeFileNameMap[localeHeader.header] = 'string_${localeHeader.code}.json';
     StringBuffer localeBuffer = StringBuffer();
     localeBuffer.writeln("{");
     localeStringBuilderMap[localeHeader.header] = localeBuffer;
   }
  }
}