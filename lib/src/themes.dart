import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'filemgr.dart';

class ThemesTheme{
    ThemeData materialThemeData;

    ThemesTheme({
        required this.materialThemeData
    });
}

class ThemesProvider extends ChangeNotifier{

    // map for all loaded themes
    Map<String, ThemesTheme> _themes = {};
    static const String _defaultThemeKey = "monokai-color-theme";
    String _activeThemeKey = _defaultThemeKey;

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

    // converto color in hex string "#ffffff" to integer
    Color _hex2Color(String hex){
        var num = int.parse(
            hex.replaceAll("#", "FF"), radix:16
        );
        return Color(num);
    }

    Color _getThemeColor(Map<String, dynamic> theme, String name, Color defaultColor){
        String? hexColor = theme["colors"][name];

        if(hexColor == null){
            return defaultColor;
        }
        else{
            return _hex2Color(hexColor);
        }
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
                theme = jsonDecode(themeString);
            }
            catch(e){
                continue;
            }

            var name = theme["name"] ?? p.basenameWithoutExtension(file.path);

            // save theme in array with the key same as "name" in json or filename without extension
            _themes[name] = ThemesTheme(
                materialThemeData: ThemeData(

                    brightness: theme["type"] == "dark" ? Brightness.dark : Brightness.light,
                    // appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
                    // scaffoldBackgroundColor: const Color(0xFF121212),

                    backgroundColor: _getThemeColor(theme,"editor.background", Colors.black),
                    primaryColor: _getThemeColor(theme,"editor.background", Colors.black),

                    hoverColor:     _getThemeColor(theme,"tab.activeForeground", Colors.black),
                    focusColor:     _getThemeColor(theme,"tab.activeForeground", Colors.black),
                    highlightColor: _getThemeColor(theme,"tab.activeForeground", Colors.black),
                    dividerColor:   _getThemeColor(theme,"contrastBorder", Colors.black),

                    // iconTheme: const IconThemeData().copyWith(color: const Color(0xFF4d4f5d)),
                    iconTheme: const IconThemeData(
                        color: Color(0xFF4d4f5d),
                        opacity: 100,
                        size: 25,
                    ),

                    tooltipTheme: TooltipThemeData(
                        textStyle: TextStyle(
                            color: _getThemeColor(theme,"button.foreground", Colors.black),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0
                        ),
                        decoration: BoxDecoration(
                            color: _getThemeColor(theme,"sideBar.background", Colors.black),
                            border: Border.all(
                                width: 1,
                                color: _getThemeColor(theme,"contrastBorder", Colors.black),
                            )
                        ),
                    ),

                    colorScheme: ColorScheme(
                        brightness: theme["type"] == "dark" ? Brightness.dark : Brightness.light,
                        
                        error: _getThemeColor(theme,"sideBar.background", Colors.black),
                        onError: _getThemeColor(theme,"errorForeground", Colors.black),

                        background: _getThemeColor(theme,"editor.background", Colors.black),
                        onBackground: _getThemeColor(theme,"editor.foreground", Colors.black),

                        primary: _getThemeColor(theme,"sideBar.background", Colors.black),
                        onPrimary: _getThemeColor(theme,"sideBar.foreground", Colors.black),
                        // onPrimary: Color(0xFF373d53),

                        secondary: _getThemeColor(theme,"statusBar.background", Colors.black),
                        onSecondary: _getThemeColor(theme,"statusBar.background", Colors.black),

                        surface: _getThemeColor(theme,"statusBar.background", Colors.black),
                        onSurface: _getThemeColor(theme,"statusBar.background", Colors.black),

                    ),
                    
                    textTheme: TextTheme(
                        headline2: TextStyle(
                            color: _getThemeColor(theme,"button.foreground", Colors.black),
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold
                        ),
                        headline4: TextStyle(
                            color: _getThemeColor(theme,"button.foreground", Colors.black),
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.0
                        ),
                        bodyText1: TextStyle(
                            color: _getThemeColor(theme,"button.foreground", Colors.black),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0
                        ),
                        bodyText2: TextStyle(
                            color: _getThemeColor(theme,"button.foreground", Colors.black),
                            letterSpacing: 1.0
                        )
                    )
                )
            );
        }
    }

}


