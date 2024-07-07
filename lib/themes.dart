
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sync_lyrics/utils/custom_themes.dart';

class AppTheme {
  /// Tema claro de la app
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color.fromARGB(255, 234, 234, 234),
      scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: WidgetStateProperty.all(false),
          trackVisibility: WidgetStateProperty.all(false),
          radius: const Radius.circular(0),
          thickness: WidgetStateProperty.all(0),
        ),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 82, 176, 226)),
      // snackBarTheme: SnackBarThemeData(
      //   contentTextStyle: GoogleFonts.tenorSans().copyWith(
      //     fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
      //     color: Colors.white
      //   )
      // ),
      textTheme: GoogleFonts.nunitoSansTextTheme(),
      extensions: const [
        CustomAppTheme(
          element: Color.fromARGB(255, 234, 234, 234),
          internalShadow: Color.fromARGB(255, 255, 255, 255),
          externalShadow: Color.fromARGB(255, 176, 180, 192),
          selected: Color.fromARGB(255, 220, 220, 220),
          buttons: Color.fromARGB(255, 200, 200, 200),
          error: Color.fromARGB(255, 211, 47, 47)
        ),
        CustomButtonTheme(
          addLine: Color.fromARGB(255, 124, 195, 127),
          addSpace: Color.fromARGB(255, 245, 223, 114),
          removeLine: Color.fromARGB(255, 219, 110, 102),
          moveLine: Color.fromARGB(255, 117, 174, 221)
        )
      ]
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color.fromARGB(255, 31, 33, 41),
      scrollbarTheme: const ScrollbarThemeData(thumbVisibility: WidgetStatePropertyAll(true)),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 82, 176, 226),
        brightness: Brightness.dark
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: GoogleFonts.tenorSans().copyWith(
          fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
          color: Colors.white
        )
      ),
      textTheme: GoogleFonts.nunitoSansTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white
      ),
    );
  }
}
