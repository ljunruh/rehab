import 'package:flutter/material.dart';

enum CalendarMode {
  exercises,
  pain,
}

class CalendarProvider extends ChangeNotifier {
  CalendarMode _calendarMode = CalendarMode.exercises;

  CalendarMode get calendarMode => _calendarMode;

  void setCalendarMode(CalendarMode mode) {
    if (_calendarMode == mode) return;
    _calendarMode = mode;
    notifyListeners();
  }
}