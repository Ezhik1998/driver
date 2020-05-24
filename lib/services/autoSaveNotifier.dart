import 'package:flutter/material.dart';

class AutoSaveNotifier with ChangeNotifier {
  bool _autoSave;

  AutoSaveNotifier(this._autoSave);

  getAutoSave() => _autoSave;

  setTheme(bool autoSave) async {
    _autoSave = autoSave;
    notifyListeners();
  }
}