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
            return PlatformType.web;
        }
        if (Platform.isMacOS) {
            return PlatformType.macos;
        }
        if (Platform.isFuchsia) {
            return PlatformType.fuchsia;
        }
        if (Platform.isLinux) {
            return PlatformType.linux;
        }
        if (Platform.isWindows) {
            return PlatformType.windows;
        }
        if (Platform.isIOS) {
            return PlatformType.ios;
        }
        if (Platform.isAndroid) {
            return PlatformType.android;
        }

        return PlatformType.unknown;
    }
}

enum PlatformType {
    web,
    ios,
    android,
    macos,
    fuchsia,
    linux,
    windows,
    unknown
}