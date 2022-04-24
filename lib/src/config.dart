import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:io';

class ConfigProvider extends ChangeNotifier{
    late Map<String, dynamic> config;

    ConfigProvider({required String filename}){
        File json = File(filename);
        config = jsonDecode(json.readAsStringSync());
    }

    save({required String filename}) async{
        File(filename).writeAsString(jsonEncode(config));
    }
}