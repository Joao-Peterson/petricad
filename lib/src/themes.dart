import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'filemgr.dart';
import 'default-vscode-theme.dart';

class ThemesTheme{
    ThemeData libThemeData;

    ThemesTheme({
        required this.libThemeData
    });
}

class ThemesProvider extends ChangeNotifier{

    // map for all loaded themes
    Map<String, ThemesTheme> _themes = {};

    // default theme
    // static const String _defaultThemeKey = "Light (Visual Studio)";
    static const String _defaultThemeKey = "Nanowise";
    // static const String _defaultThemeKey = "Monokai";
    // static const String _defaultThemeKey = "Owlet (Palenight)";
    // static const String _defaultThemeKey = "GitHub Dark Dimmed";

    // current theme
    String _activeThemeKey = _defaultThemeKey;

    // -------------------------------------- Public calls ------------------------ //

    // set theme
    setTheme(String name){
        ThemesTheme? newTheme = _themes[name];

        if(newTheme != null){
            _activeThemeKey = name;
            notifyListeners();
        }   
        else{
            return;
        }
    }

    // get current theme
    ThemesTheme getTheme(){
        // returns the current theme or a guaranteed default theme if the former is null
        return _themes[_activeThemeKey] ?? (_themes[_defaultThemeKey]!);
    }

    // get theme list
    List<String> getThemeNameList(){
        List<String> list = [];

        for(var theme in _themes.keys){
            list.add(theme);
        }
        
        return list;
    }

    // constructor
    ThemesProvider({required String themesDir}){
        if(!(Directory(themesDir).existsSync())){
            exit(-1);
        }

        // for every json theme file in the themes directory
        for(var file in Directory(themesDir).listSync(followLinks: false, recursive: false)){
            String themeString = File(file.path).readAsStringSync();
            late Map<String, dynamic> theme;
            
            try{
                // special chars                 
                themeString = themeString.replaceAllMapped(RegExp(r"(://)|[$]", multiLine: false, caseSensitive: false), 
                    (Match m) => ""
                );

                // remove comments
                themeString = themeString.replaceAllMapped(RegExp(r"//.*", multiLine: false, caseSensitive: false), 
                    (Match m) => ""
                );

                // remove leading commas on last child of array/object
                themeString = themeString.replaceAllMapped(RegExp(r",([\n\s]+(\}|\]))", multiLine: true, caseSensitive: false), 
                    (Match m) => "${m[1]}"
                );
                
                theme = jsonDecode(themeString);
            }
            catch(e){
                continue;
            }

            var name = theme["name"] ?? p.basenameWithoutExtension(file.path);

            

            // save theme in array with the key same as "name" in json or filename without extension
            _themes[name] = ThemesTheme(
                libThemeData: ThemeData(

                    brightness: theme["type"] == "dark" ? Brightness.dark : Brightness.light,
                    // appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
                    // scaffoldBackgroundColor: const Color(0xFF121212),

                    backgroundColor: _getThemeColor(theme,"editor.background"),
                    primaryColor:   _getThemeColor(theme,"editor.background"),

                    hoverColor:     _getThemeColor(theme,"activityBar.foreground"),
                    focusColor:     _getThemeColor(theme,"activityBar.foreground"),
                    highlightColor: _getThemeColor(theme,"activityBar.foreground"),
                    dividerColor:   _getThemeColor(theme,"activityBar.inactiveForeground"),

                    // iconTheme: const IconThemeData().copyWith(color: const Color(0xFF4d4f5d)),
                    iconTheme: IconThemeData(
                        color: _getThemeColor(theme,"activityBar.inactiveForeground"),
                        opacity: 100,
                        size: 25,
                    ),

                    tooltipTheme: TooltipThemeData(
                        textStyle: TextStyle(
                            color: _getThemeColor(theme,"activityBar.foreground"),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0
                        ),
                        decoration: BoxDecoration(
                            color: _getThemeColor(theme,"sideBar.background"),
                            border: Border.all(
                                width: 1,
                                color: _getThemeColor(theme,"activityBar.inactiveForeground"),
                            )
                        ),
                    ),

                    colorScheme: ColorScheme(
                        brightness: theme["type"] == "dark" ? Brightness.dark : Brightness.light,
                        
                        error: _getThemeColor(theme,"sideBar.background"),
                        onError: _getThemeColor(theme,"errorForeground"),

                        background: _getThemeColor(theme,"editor.background"),
                        onBackground: _getThemeColor(theme,"editor.foreground"),

                        primary: _getThemeColor(theme,"sideBar.background"),
                        onPrimary: _getThemeColor(theme,"sideBar.foreground"),

                        secondary: _getThemeColor(theme,"statusBar.background"),
                        onSecondary: _getThemeColor(theme,"statusBar.background"),

                        surface: _getThemeColor(theme,"statusBar.background"),
                        onSurface: _getThemeColor(theme,"statusBar.background"),

                    ),
                    
                    textTheme: TextTheme(
                        headline2: TextStyle(
                            color: _getThemeColor(theme,"editor.foreground"),
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold
                        ),
                        headline4: TextStyle(
                            color: _getThemeColor(theme,"editor.foreground"),
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.0
                        ),
                        bodyText1: TextStyle(
                            color: _getThemeColor(theme,"editor.foreground"),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0
                        ),
                        bodyText2: TextStyle(
                            color: _getThemeColor(theme,"editor.foreground"),
                            letterSpacing: 1.0
                        )
                    )
                )
            );
        }
    }

    // -------------------------------------- Private calls ----------------------- //

    // converto color in hex string "#ffffff" to integer
    Color _hex2Color(String hex){
        // #FFFFFFFF case
        if(hex.length >= 9){
            hex = hex.replaceAll("#", "");
        }
        // #FFFFFF case
        else{
            hex = hex.replaceAll("#", "FF");
        }
        
        var num = int.parse(hex, radix:16);
        return Color(num);
    }

    // get color from json file an return as Color
    Color _getThemeColor(Map<String, dynamic> theme, String name){
        String? hexColor = theme["colors"] == null ? null : theme["colors"][name];

        if(hexColor == null){
            return defaultVscodeTheme[name] ?? Colors.black;
        }
        else{
            return _hex2Color(hexColor);
        }
    }

}


