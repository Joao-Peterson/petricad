import 'package:flutter/material.dart';

class Themes{
    static ThemeData dark = ThemeData(

        brightness: Brightness.dark,
        // appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        // scaffoldBackgroundColor: const Color(0xFF121212),

        backgroundColor: const Color(0xFF202330),
        primaryColor: const Color(0xFF292d3e),

        hoverColor: const Color(0xFF84828c),
        focusColor: const Color(0xFF84828c),
        highlightColor: const Color(0xFF84828c),
        dividerColor: const Color(0xFF383c4c),

        // iconTheme: const IconThemeData().copyWith(color: const Color(0xFF4d4f5d)),
        iconTheme: const IconThemeData(
            color: Color(0xFF4d4f5d),
            opacity: 100,
            size: 25,
        ),

        tooltipTheme: TooltipThemeData(
            textStyle: const TextStyle(
                color: Color(0xFFd6d2d5),
                fontSize: 13.0,
                fontWeight: FontWeight.w300,
                letterSpacing: 0
            ),
            decoration: BoxDecoration(
                color: const Color(0xFF202330),
                border: Border.all(
                    width: 1,
                    color: const Color(0xFF4d4f5d),
                )
            ),
        ),

        colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            
            error: Color(0xFF550000),
            onError: Color(0xFFFF0000),

            background: Color(0xFF202330),
            onBackground: Color(0xFF373d53),

            primary: Color(0xFF292d3e),
            onPrimary: Color(0xFF4d4f5d),
            // onPrimary: Color(0xFF373d53),

            secondary: Color(0xFF84828c),
            onSecondary: Color(0xFFDAE2FF),

            surface: Color(0xFF272738),
            onSurface: Color(0xFFFFFFFF),

        ),
        
        textTheme: const TextTheme(
            headline2: TextStyle(
                color: Colors.white,
                fontSize: 32.0,
                fontWeight: FontWeight.bold
            ),
            headline4: TextStyle(
                color: Colors.grey,
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.0
            ),
            bodyText1: TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0
            ),
            bodyText2: TextStyle(
                color: Colors.grey,
                letterSpacing: 1.0
            )
        )
    );
}
