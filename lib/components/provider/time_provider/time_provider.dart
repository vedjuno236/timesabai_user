import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimeNotifier extends StateNotifier<TimeOfDay> {
  TimeNotifier() : super(TimeOfDay.now());

  void updateTime(TimeOfDay newTime) {
    state = newTime;
  }
}

// Create a provider for TimeNotifier
final timeProvider = StateNotifierProvider<TimeNotifier, TimeOfDay>((ref) {
  return TimeNotifier();
});
