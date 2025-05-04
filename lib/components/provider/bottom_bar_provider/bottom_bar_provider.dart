// int selectedIndex =
//     0; //to handle which item is currently selected in the bottom app bar
// String text = "Home";
//
// //call this method on click of each bottom app bar item to update the screen
// void updateTabSelection(int index, String buttonText) {
//   setState(() {
//     selectedIndex = index;
//     text = buttonText;
//   });
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomBarProvider with ChangeNotifier {
  ///Index bottom bar
  int _selectedIndex = 0;
  int get getSelectedIndex => _selectedIndex;

  ///Class name bottom bar
  String _nameBottomBar = "Home";
  String get getNameBottomBar => _nameBottomBar;

  Future updateTabSelection(
      {required int index, required String buttonText}) async {
    _selectedIndex = index;
    _nameBottomBar = buttonText;
    notifyListeners();
  }
}

final stateBottomBarProvider = ChangeNotifierProvider<BottomBarProvider>((ref) {
  return BottomBarProvider();
});
