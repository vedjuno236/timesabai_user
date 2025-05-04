import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final dateFromControllerProvider = Provider<TextEditingController>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final controller = TextEditingController();
  controller.text = "${selectedDate.toLocal()}".split(' ')[0];
  return controller;
});
