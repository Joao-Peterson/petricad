import 'dart:convert';
import 'dart:io';
import 'package:command_palette/command_palette.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'default_vscode_theme.dart';

class ThemesTheme{
    ThemeData libThemeData;
    CommandPaletteStyle commandPaletteStyleData;
    TreeViewTheme treeViewThemeData;

    ThemesTheme({
        required this.libThemeData,
        required this.commandPaletteStyleData,
        required this.treeViewThemeData,
    });
}

class ThemesProvider extends ChangeNotifier{

    // map for all loaded themes
    Map<String, ThemesTheme> _themes = {};

    // default theme
    static const String _defaultThemeKey = "Owlet (Palenight)";

    // current theme
    String _activeThemeKey = _defaultThemeKey;

    // themes directory, passed via constructor
    late String _themesDir;

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
    ThemesProvider({required String themesDir, required String startTheme}){
        _activeThemeKey = startTheme;
        _themesDir = themesDir;
        buildThemes();
    }

    // read theme files
    buildThemes(){
        if(!(Directory(_themesDir).existsSync())){
            exit(-1);
        }

        // for every json theme file in the themes directory
        for(var file in Directory(_themesDir).listSync(followLinks: false, recursive: false)){
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
                themeString = themeString.replaceAllMapped(RegExp(r",([\n\s]*(\}|\]))", multiLine: true, caseSensitive: false), 
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
                            color: _getThemeColor(theme,"editor.foreground"),
                            fontSize: 13.0,
                            fontWeight: FontWeight.normal,
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

                        primary: _getThemeColor(theme,"activityBar.background"),
                        onPrimary: _getThemeColor(theme,"activityBar.foreground"),
                        inversePrimary: _getThemeColor(theme,"list.highlightForeground"),

                        secondary: _getThemeColor(theme,"sideBar.background"),
                        onSecondary: _getThemeColor(theme,"sideBar.background"),

                        // tertiary: _getThemeColor(theme,"list.activeSelectionBackground"),
                        // onTertiary: _getThemeColor(theme,"list.activeSelectionForeground"),
                        // tertiary: _getThemeColor(theme,"statusBar.debuggingBackground"),
                        tertiary: _getThemeColor(theme,"statusBar.background"),
                        onTertiary: _getThemeColor(theme,"statusBar.foreground"),

                        surface: _getThemeColor(theme,"editor.background"),
                        onSurface: _getThemeColor(theme,"editor.foreground"),

                    ),

                    inputDecorationTheme: InputDecorationTheme(
                        filled: true,
                        fillColor: _getThemeColor(theme,"editor.background"),

                        hintStyle: TextStyle(
                            color: _getThemeColor(theme,"editor.foreground"),
                            fontSize: 13.0,
                            letterSpacing: 0,
                            fontWeight: FontWeight.normal
                        ),
                        labelStyle: TextStyle(
                            color: _getThemeColor(theme,"editor.foreground"),
                            fontSize: 13.0,
                            letterSpacing: 0,
                            fontWeight: FontWeight.normal
                        ),
                    ),

                    textButtonTheme: TextButtonThemeData(
                        style: ButtonStyle(
                            backgroundColor:    MaterialStateProperty.all<Color>(_getThemeColor(theme,"editor.background")),
                            foregroundColor:    MaterialStateProperty.all<Color>(_getThemeColor(theme,"editor.foreground")),
                            overlayColor:       MaterialStateProperty.all<Color>(_getThemeColor(theme,"list.activeSelectionBackground")),
                            elevation:          MaterialStateProperty.all<double>(1),
                            shape:              MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
                            )),  
                        )
                    ),

                    scrollbarTheme: ScrollbarThemeData(
                        thumbColor: MaterialStateProperty.all<Color>(_getThemeColor(theme,"list.activeSelectionBackground")),
                    ),

                    textTheme: TextTheme(
                        button: TextStyle(
                            color: _getThemeColor(theme,"editor.foreground"),
                            fontSize: 13.0,
                            letterSpacing: 0,
                            fontWeight: FontWeight.normal
                        ),
                        bodyText2: TextStyle(
                            color: _getThemeColor(theme,"editor.foreground"),
                            fontSize: 13.0,
                            letterSpacing: 0,
                            fontWeight: FontWeight.normal
                        ),
                        subtitle1: TextStyle(
                            color: _getThemeColor(theme,"editor.foreground"),
                            fontSize: 13.0,
                            letterSpacing: 0,
                            fontWeight: FontWeight.normal
                        ),
                        subtitle2: TextStyle(
                            color: _getThemeColor(theme,"editor.foreground"),
                            fontSize: 10.0,
                            fontWeight: FontWeight.normal
                        ),
                    )

                ),

                commandPaletteStyleData: CommandPaletteStyle(
                    elevation: 5,
                    borderRadius: BorderRadius.zero,
                    commandPaletteBarrierColor: Colors.black26,
                    highlightSearchSubstring: true,

                    actionLabelTextStyle: TextStyle(
                        color: _getThemeColor(theme,"editor.foreground"),
                        fontSize: 13.0,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal
                    ),
                    highlightedLabelTextStyle: TextStyle(
                        color: _getThemeColor(theme,"list.highlightForeground"),
                        fontSize: 13.0,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal
                    ),

                    actionColor: _getThemeColor(theme,"sideBar.background"),
                    selectedColor: _getThemeColor(theme,"list.activeSelectionBackground"),

                    textFieldInputDecoration: const InputDecoration(
                        hintText: ">...",
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    )
                ),

                treeViewThemeData: TreeViewTheme(
                    expanderTheme: ExpanderThemeData(
                        type: ExpanderType.chevron,
                        color: _getThemeColor(theme,"icon.foreground"),
                        size: 20,
                    ),
                    iconPadding: 5,
                    iconTheme: IconThemeData(
                        size: 20,
                        color: _getThemeColor(theme,"icon.foreground"),
                    ),
                    verticalSpacing: 2,
                    labelStyle: TextStyle(
                        color: _getThemeColor(theme,"editor.foreground"),
                        fontSize: 13.0,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal
                    ),
                    parentLabelStyle: TextStyle(
                        color: _getThemeColor(theme,"editor.foreground"),
                        fontSize: 13.0,
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold
                    ),
                    labelOverflow: TextOverflow.clip,
                    parentLabelOverflow: TextOverflow.clip,
                )
            );
        }

        notifyListeners();
    }

    // -------------------------------------- Private calls ----------------------- //

    // converto color in hex string "#ffffff" to integer
    Color _hex2Color(String hex){
        int num = 0;
        
        // #FFFFFFFF case
        if(hex.length >= 9){
            hex = hex.replaceAll("#", "");
            num = int.parse(hex, radix:16);
            num = ((0xffffff00 & num) >> 8) | ((0x000000ff & num) << 3*8);
        }
        // #FFFFFF case
        else{
            hex = hex.replaceAll("#", "FF");
            num = int.parse(hex, radix:16);
        }
        
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
