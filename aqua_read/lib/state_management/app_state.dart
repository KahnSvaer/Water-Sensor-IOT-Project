import 'package:flutter/material.dart';

class AppState {
  // Private constructor
  AppState._();

  // Singleton instance
  static final AppState _instance = AppState._();

  factory AppState() {return _instance;}

  final ValueNotifier<int> backgroundPageIndex = ValueNotifier<int>(1);
  final ValueNotifier<bool> buttonHighlight = ValueNotifier<bool>(true);

  void updateIndex(int index) {
    if (backgroundPageIndex.value != index) {
      backgroundPageIndex.value = index;
    }
  }

  void setHighlightTrue() {
    buttonHighlight.value = true;
  }

  void setHighlightFalse() {
    buttonHighlight.value = false;
  }
}
