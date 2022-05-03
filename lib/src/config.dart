import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:io';

class ConfigProvider extends ChangeNotifier{
    late Map<String, dynamic> _config;
    late String _filename; 

    // constructor
    ConfigProvider({required String filename}){
        _filename = filename;
        buildConfig();
    }

    // read config file
    buildConfig(){
        File json = File(_filename);
        String jsonString = json.readAsStringSync();

        jsonString = jsonString.replaceAllMapped(RegExp(r"(://)|[$]", multiLine: false, caseSensitive: false), 
            (Match m) => ""
        );
        // remove comments
        jsonString = jsonString.replaceAllMapped(RegExp(r"//.*", multiLine: false, caseSensitive: false), 
            (Match m) => ""
        );
        // remove leading commas on last child of array/object
        jsonString = jsonString.replaceAllMapped(RegExp(r",([\n\s]+(\}|\]))", multiLine: true, caseSensitive: false), 
            (Match m) => "${m[1]}"
        );
        
        _config = jsonDecode(jsonString);
        notifyListeners();
    }

    setConfig<T>(String configName, T value){
        _setNestedMapValue<T>(_config, configName, value);
        _save();
        notifyListeners();
    }

    T? getConfig<T>(String configName){
        return _getNestedMapValue<T>(_config, configName);
    }

    // save to _filename
    _save() {
        File(_filename).writeAsStringSync(jsonEncode(_config));
    }

    // get nested value in nested maps of type "Map<String, dynamic>", using a string syntax like "value.subvalue.array[5].someValue"
    T? _getNestedMapValue<T>(Map<String, dynamic> nestedMap, String catKeys){
        List<String> keys = catKeys.split(".");

        if(keys.isEmpty || nestedMap.isEmpty){
            return null;
        }
        
        dynamic value = nestedMap;
        // for every key in the dot separated keys 
        for(var key in keys){
            String? indexlessKey    = RegExp(r'(\w+)\[(\w)\]').firstMatch(key)?.namedGroup("1");
            String? arrayIndex      = RegExp(r'(\w+)\[(\w)\]').firstMatch(key)?.namedGroup("2");

            // if key has array index "[n]"
            if((arrayIndex != null) && (indexlessKey != null)){
                // get normal key value
                value = value[indexlessKey];
                // converte keys to list and access it by index
                value = (value as Map).keys.toList()[int.parse(arrayIndex)];
            }
            // if key is normal
            else{
                value = value[key];
            }
        }

        return value as T?;
    }

    // set nested value in nested maps of type "Map<String, dynamic>", using a string syntax like "value.subvalue.array[5].someValue"
    _setNestedMapValue<T>(Map<String, dynamic> nestedMap, String catKeys, T newValue){
        List<String> keys = catKeys.split(".");

        dynamic value = nestedMap;
        // for every key in the dot separated keys 
        for(var key in keys){

            if(key == keys.last){
                value[key] = newValue;
                break;
            }
            
            String? indexlessKey    = RegExp(r'(\w+)\[(\w)\]').firstMatch(key)?.namedGroup("1");
            String? arrayIndex      = RegExp(r'(\w+)\[(\w)\]').firstMatch(key)?.namedGroup("2");

            // if key has array index "[n]"
            if((arrayIndex != null) && (indexlessKey != null)){
                // get normal key value
                value = value[indexlessKey];
                // converte keys to list and access it by index
                value = (value as Map).keys.toList()[int.parse(arrayIndex)];
            }
            // if key is normal
            else{
                value = value[key];
            }
        }
    }
}