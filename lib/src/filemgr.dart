import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'platforminfo.dart';

class Filemgr extends ChangeNotifier{  

    final Map<String, String> _dirs = {};
    final Map<String, String> _files = {};
    
    static const String _windowsHome   = "HOMEPATH";
    static const String _linuxHome     = "HOME";

    RandomAccessFile? _logFile;

    // constructor
    Filemgr();

    // -------------------------------------- Dirs utilities ---------------------- //

    // add standard directory path
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

    // add new directory
    addDir(String dirKey, String dirPath) async {
        if(!(await Directory(dirPath).exists())){
            await Directory(dirPath).create();
        }

        _dirs[dirKey] = dirPath;
    }

    // add dir to a parent dir
    addDirToDir(String dirKey, String dirPath, String parentDirKey) async {
        String? parent = _dirs[parentDirKey];
        String path;
        
        if(parent != null){
            path = p.join(parent, dirPath);
        }
        else{
            return;
        }

        await addDir(dirKey, path);
    }

    // get the dir path
    String? getDirPath(String dirKey){
        return _dirs[dirKey];
    }

    // -------------------------------------- File utilities ---------------------- //

    // add new file to track
    addNewFile(String key, String filename, String dirKey, {String? defaultContent}) async {

        String path;

        if(_dirs[dirKey] == null){
            return;
        }
        else{
            path = _dirs[dirKey]!; 
        }

        path = p.join(path, filename);
        _files[key] = path;

        File file = File(path);
        if(!(await file.exists())){
            await file.create();

            if(defaultContent != null){
                await file.writeAsString(defaultContent, mode: FileMode.write);
            }
        }
    }

    // get file path by name
    String? getFilePath(String filename){
        return _files[filename];
    }

    // -------------------------------------- Log utilities ----------------------- //

    // add log file
    addLogFile(String key, String filename, String dirKey) async {
        String path;

        if(_dirs[dirKey] == null){
            return;
        }
        else{
            path = _dirs[dirKey]!; 
        }

        path = p.join(path, filename);
        _files[key] = path;

        File file = File(path);
        if(!(await file.exists())){
            file.create();
        }        

        file.writeAsString("", mode: FileMode.write);
        _logFile = await file.open(mode: FileMode.append);
        // clear file
    }

    // log to the log file with an info tag
    logInfo(String message){
        _logFile?.writeStringSync("[INFO   ] " + message + "\n");
    }

    // log to the log file with an warning tag
    logWarning(String message){
        _logFile?.writeStringSync("[WARNING] " + message + "\n");
    }

    // log to the log file with an error tag
    logError(String message){
        _logFile?.writeStringSync("[ERROR  ] " + message + "\n");
    }
}
