//
// import 'package:flutter/cupertino.dart';
//
// class DarkThemeProvider with ChangeNotifier {
//   DarkThemePreference darkThemePreference = DarkThemePreference();
//
//   bool _darkTheme = false;
//   bool get darkTheme => _darkTheme;
//
//   set darkTheme(bool value) {
//     _darkTheme = value;
//     darkThemePreference.setDarkTheme(value: value);
//     notifyListeners();
//   }
// }
//
// final darkThemeProviderProvider =
//     ChangeNotifierProvider<DarkThemeProvider>((ref) {
//   return DarkThemeProvider();
// });
