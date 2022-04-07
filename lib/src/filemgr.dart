import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'platforminfo.dart';

class Filemgr{  

    final Map<String, String> _dirs = {};
    final Map<String, String> _files = {};
    
    static const String _windowsHome   = "HOMEPATH";
    static const String _linuxHome     = "HOME";

    File? _logFile;

    // constructor
    Filemgr();

    // add new diretory path
    addStdDir() async{
        Map<String, String> envVars = Platform.environment;
        String path;

        switch (PlatformInfo.getPlatform()){
            case PlatformType.Linux:
                path = _linuxHome;
            break;
            
            case PlatformType.Windows:
                path = _windowsHome;
            break;
            
            default:
                print("Platform " + Platform.environment.toString() + " is supported in this application");
                return;
        }

        path = envVars[path] ?? _linuxHome;
        path = p.join(path, "." +  p.basename(Platform.resolvedExecutable));

        Directory pathDir = Directory(path);
        if(!(await pathDir.exists())){
            pathDir.create();
        }

        _dirs["std"] = path;
    } 

    // add new file to track
    addNewFile(String filename, String dirKey) async {

        String path;

        if(_dirs[dirKey] == null){
            return;
        }
        else{
            path = _dirs[dirKey] ?? ''; 
        }

        path = p.join(path, filename);
        _files[filename] = path;

        File file = File(path);
        if(!(await file.exists())){
            file.create();
        }
    }

    // add log file
    addLogFile(String filename, String dirKey) async {
        String path;

        if(_dirs[dirKey] == null){
            return;
        }
        else{
            path = _dirs[dirKey] ?? ''; 
        }

        path = p.join(path, filename);
        _files[filename] = path;

        File file = File(path);
        if(!(await file.exists())){
            file.create();
        }        

        _logFile = file;
        // clear file
        _logFile?.writeAsString("", mode: FileMode.write);
    }

    logInfo(String message) async{
        await _logFile?.writeAsString("[INFO] " + message + "\n", mode: FileMode.append);
    }

    logWarning(String message) async{
        await _logFile?.writeAsString("[WARNING] "+message + "\n", mode: FileMode.append);
    }

    logError(String message) async{
        await _logFile?.writeAsString("[ERROR] "+message + "\n", mode: FileMode.append);
    }
}
