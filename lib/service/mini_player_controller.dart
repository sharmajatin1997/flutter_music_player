import 'package:flutter/material.dart';

class MiniPlayerController extends ChangeNotifier {
  bool _isVisible = false;

  bool get isVisible => _isVisible;

  void showMiniPlayer() {
    _isVisible = true;
    notifyListeners();
  }

  void hideMiniPlayer() {
    _isVisible = false;
    notifyListeners();
  }
}

// Global instance
final miniPlayerController = MiniPlayerController();
