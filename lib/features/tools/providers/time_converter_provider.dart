import 'package:flutter/material.dart';

class TimeConverterProvider with ChangeNotifier {
  // Timezones and their offsets from UTC
  final Map<String, int> _timezones = {
    'WIB (UTC+7)': 7,
    'WITA (UTC+8)': 8,
    'WIT (UTC+9)': 9,
    'London (UTC+0)': 0,
  };

  Map<String, int> get timezones => _timezones;

  String _selectedZone = 'WIB (UTC+7)';
  TimeOfDay _selectedTime = TimeOfDay.now();

  String get selectedZone => _selectedZone;
  TimeOfDay get selectedTime => _selectedTime;

  set selectedZone(String value) {
    _selectedZone = value;
    notifyListeners();
  }

  set selectedTime(TimeOfDay value) {
    _selectedTime = value;
    notifyListeners();
  }

  Map<String, String> getConvertedTimes() {
    final Map<String, String> results = {};
    
    // Get source offset
    final sourceOffset = _timezones[_selectedZone]!;
    
    // Convert source TimeOfDay to UTC DateTime
    final now = DateTime.now();
    final sourceDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    
    // Calculate UTC time
    final utcDateTime = sourceDateTime.subtract(Duration(hours: sourceOffset));

    _timezones.forEach((zone, offset) {
      if (zone == _selectedZone) return;

      final convertedDateTime = utcDateTime.add(Duration(hours: offset));
      final hour = convertedDateTime.hour.toString().padLeft(2, '0');
      final minute = convertedDateTime.minute.toString().padLeft(2, '0');
      results[zone] = '$hour:$minute';
    });

    return results;
  }
}
