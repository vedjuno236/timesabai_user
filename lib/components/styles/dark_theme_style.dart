
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timesabai/components/styles/size_config.dart';

class AppTheme {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    if (isDarkTheme) {
      ///dark theme
      return ThemeData(
        fontFamily: "BoonHome",
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Color(0xff262626),
          secondary: Color(0xffF56C15),
          background: Color(0xff2D2D2E),
        ),
        cardTheme: const CardTheme(
          color: Color(0xff262626),
        ),

        textTheme: const TextTheme(
          titleSmall: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
          titleMedium: TextStyle(
            color: Colors.white,
            fontSize: 17.0,
          ),
          titleLarge: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
          bodySmall: TextStyle(
            color: Color(0xff818181),
            fontSize: 16.0,
          ),
          bodyMedium: TextStyle(
            color: Color(0xff818181),
            fontSize: 17.0,
          ),
          bodyLarge: TextStyle(
            color: Color(0xff818181),
            fontSize: 18.0,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
          hintStyle: TextStyle(
            fontSize: 16,
            // decorationColor: Colors.white,
            color: Color(0xff818181),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        // scaffoldBackgroundColor: const Color(0xff262626),
        scaffoldBackgroundColor: const Color(0xff2D2D2E),
        primaryColorDark: Colors.black,
        primaryColorLight: Colors.white,
        primarySwatch: Colors.green,
        secondaryHeaderColor: Colors.black,
        primaryColor: const Color(0xff282727),
        indicatorColor: const Color(0xff0E1D36),
        hintColor: Colors.grey.shade700,
        highlightColor: Colors.transparent,
        hoverColor: const Color(0xff3A3A3B),
        focusColor: const Color(0xff0B2512),

        disabledColor: Colors.grey,
        // textSelectionColor:  Colors.white : Colors.black,
        cardColor: const Color(0xff262626),
        canvasColor: const Color(0xff262626),
        brightness: Brightness.dark,
        buttonTheme: Theme.of(context)
            .buttonTheme
            .copyWith(colorScheme: const ColorScheme.dark()),
        appBarTheme: AppBarTheme(
          elevation: 0.0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: SizeConfig.textMultiplier * 1.8,
          ),
          color: const Color(0xff262626),
        ),
      );
    } else {
      ///light theme
      return ThemeData(
        fontFamily: "BoonHome",
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.black,
          secondary: Color(0xffF56C15),
          background: Color(0xffF1F5FB),
        ),
        cardTheme: const CardTheme(
          color: Color(0xffF3F5F7),
        ),
        textTheme: const TextTheme(
          titleSmall: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
          ),
          titleMedium: TextStyle(
            color: Colors.black,
            fontSize: 17.0,
          ),
          titleLarge: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
          ),
          bodySmall: TextStyle(
            color: Color(0xff9B9B9B),
            fontSize: 16.0,
          ),
          bodyMedium: TextStyle(
            color: Color(0xff9B9B9B),
            fontSize: 17.0,
          ),
          bodyLarge: TextStyle(
            color: Color(0xff9B9B9B),
            fontSize: 18.0,
          ),
        ),

        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
          hintStyle: TextStyle(
            fontSize: 16,
            color: Color(0xff9B9B9B),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        scaffoldBackgroundColor: const Color(0xffF0F2F6),
        primaryColorDark: Colors.white,
        primaryColorLight: Colors.black,
        primarySwatch: Colors.green,
        secondaryHeaderColor: Colors.white,
        primaryColor: Colors.white,

        indicatorColor: const Color(0xffCBDCF8),
        hintColor: Colors.grey.shade400,
        highlightColor: Colors.transparent,
        hoverColor: const Color(0xffF7F7F7),
        // hoverColor: const Color(0xffF1F5FB),
        focusColor: const Color(0xffA8DAB5),
        disabledColor: Colors.grey,

        // textSelectionColor: Colors.white : Colors.black,
        cardColor: Colors.white,
        canvasColor: Colors.grey[50],
        brightness: Brightness.light,
        buttonTheme: Theme.of(context)
            .buttonTheme
            .copyWith(colorScheme: const ColorScheme.light()),
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          centerTitle: true,
          elevation: 0.0,
        ),
      );
    }
  }
}
