import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:io';

class ConfigProvider extends ChangeNotifier{
    late Map<String, dynamic> _config;
    late String _filename; 

    ConfigProvider({required String filename}){
        File json = File(filename);
        _config = jsonDecode(json.readAsStringSync());
        _filename = filename;
    }

    save() async{
        File(_filename).writeAsString(jsonEncode(_config));
    }

    // get nested value in nested maps of type "Map<String, dynamic>", using a string syntax like "value.subvalue.array[5].someValue"
    T _getNestedMapValue<T>(Map<String, dynamic> nestedMap, String catKeys){
        List<String> keys = catKeys.split(".");

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

        return value as T;
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

    setConfig<T>(String configName, T value){
        _setNestedMapValue<T>(_config, configName, value);
        notifyListeners();
    }

    T getConfig<T>(String configName){
        return _getNestedMapValue<T>(_config, configName);
    }
}