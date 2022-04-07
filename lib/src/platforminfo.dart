import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformInfo {

    static bool isDesktop() {
        if(!kIsWeb){
            return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
        }
        else{
            return false;
        }
    }

    static bool isMobile() {
        if(!kIsWeb){
            return Platform.isIOS || Platform.isAndroid;
        }
        else{
            return false;
        }
    }
    
    static bool isWeb() {
        return kIsWeb;
    }
    
    static PlatformType getPlatform() {
        if (kIsWeb) {
            return PlatformType.Web;
        }
        if (Platform.isMacOS) {
            return PlatformType.MacOS;
        }
        if (Platform.isFuchsia) {
            return PlatformType.Fuchsia;
        }
        if (Platform.isLinux) {
            return PlatformType.Linux;
        }
        if (Platform.isWindows) {
            return PlatformType.Windows;
        }
        if (Platform.isIOS) {
            return PlatformType.IOS;
        }
        if (Platform.isAndroid) {
            return PlatformType.Android;
        }

        return PlatformType.Unknown;
    }
}

enum PlatformType {
    Web,
    IOS,
    Android,
    MacOS,
    Fuchsia,
    Linux,
    Windows,
    Unknown
}