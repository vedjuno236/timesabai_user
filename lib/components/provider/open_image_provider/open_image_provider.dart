import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileImageNotifier extends StateNotifier<File?> {
  ProfileImageNotifier() : super(null);

  void setProfileImage(File file) {
    state = file;
  }

  void clearProfileImage() {
    state = null;
  }
}

final profileImageProvider =
StateNotifierProvider<ProfileImageNotifier, File?>((ref) {
  return ProfileImageNotifier();
});



final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});
