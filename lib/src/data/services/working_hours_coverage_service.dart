import 'package:flutter/material.dart';
import 'package:provider_app/src/domain/models/working_hours_coverage_model.dart';

enum SchedulePreset {
  standardWeekdays, // Mon - Fri (8:00 AM - 6:00 PM)
  sixDays, // Mon - Sat (8:00 AM - 6:00 PM)
  fullWeek, // Mon - Sun (8:00 AM - 8:00 PM)
  morningShift, // Mon - Sat (7:00 AM - 3:00 PM)
}

class WorkingHoursCoverageService extends ChangeNotifier {
  static final WorkingHoursCoverageService _instance =
      WorkingHoursCoverageService._internal();
  factory WorkingHoursCoverageService() => _instance;
  static WorkingHoursCoverageService get instance => _instance;

  WorkingHoursCoverageService._internal();

  // Instant Availability (Live Radar)
  bool _isAvailableNow = true;
  bool get isAvailableNow => _isAvailableNow;

  // Day Schedules (Monday - Sunday)
  final List<DaySchedule> _schedules = [
    const DaySchedule(
      dayKey: 'mon',
      dayName: 'Monday',
      shortName: 'Mon',
      isOpen: true,
      openTime: TimeOfDay(hour: 8, minute: 0),
      closeTime: TimeOfDay(hour: 18, minute: 0),
    ),
    const DaySchedule(
      dayKey: 'tue',
      dayName: 'Tuesday',
      shortName: 'Tue',
      isOpen: true,
      openTime: TimeOfDay(hour: 8, minute: 0),
      closeTime: TimeOfDay(hour: 18, minute: 0),
    ),
    const DaySchedule(
      dayKey: 'wed',
      dayName: 'Wednesday',
      shortName: 'Wed',
      isOpen: true,
      openTime: TimeOfDay(hour: 8, minute: 0),
      closeTime: TimeOfDay(hour: 18, minute: 0),
    ),
    const DaySchedule(
      dayKey: 'thu',
      dayName: 'Thursday',
      shortName: 'Thu',
      isOpen: true,
      openTime: TimeOfDay(hour: 8, minute: 0),
      closeTime: TimeOfDay(hour: 18, minute: 0),
    ),
    const DaySchedule(
      dayKey: 'fri',
      dayName: 'Friday',
      shortName: 'Fri',
      isOpen: true,
      openTime: TimeOfDay(hour: 8, minute: 0),
      closeTime: TimeOfDay(hour: 18, minute: 0),
    ),
    const DaySchedule(
      dayKey: 'sat',
      dayName: 'Saturday',
      shortName: 'Sat',
      isOpen: true,
      openTime: TimeOfDay(hour: 8, minute: 30),
      closeTime: TimeOfDay(hour: 17, minute: 0),
    ),
    const DaySchedule(
      dayKey: 'sun',
      dayName: 'Sunday',
      shortName: 'Sun',
      isOpen: false,
      openTime: TimeOfDay(hour: 9, minute: 0),
      closeTime: TimeOfDay(hour: 15, minute: 0),
    ),
  ];
  List<DaySchedule> get schedules => List.unmodifiable(_schedules);

  // Coverage Settings
  String _baseLocation = 'Kollupitiya, Colombo 03';
  String get baseLocation => _baseLocation;

  // Base Coordinates (Kollupitiya, Colombo 03 by default)
  double _baseLatitude = 6.8982;
  double get baseLatitude => _baseLatitude;
  double _baseLongitude = 79.8550;
  double get baseLongitude => _baseLongitude;

  double _radiusKm = 20.0;
  double get radiusKm => _radiusKm;

  final List<String> _catalogZones = [
    'Colombo 01 - 05 (Central)',
    'Colombo 06 - 08 (Wellawatte/Borella)',
    'Colombo 09 - 15 (North / Port)',
    'Dehiwala - Mount Lavinia',
    'Rajagiriya & Kotte',
    'Nugegoda & Kohuwala',
    'Battaramulla & Pelawatte',
    'Maharagama & Pannipitiya',
    'Moratuwa & Ratmalana',
    'Malabe & Kaduwela',
    'Kelaniya & Kiribathgoda',
    'Wattala & Hendala',
    'Homagama & Kottawa',
    'Negombo Town',
    'Panadura & Wadduwa',
  ];
  List<String> get catalogZones => List.unmodifiable(_catalogZones);

  final Set<String> _selectedZones = {
    'Colombo 01 - 05 (Central)',
    'Colombo 06 - 08 (Wellawatte/Borella)',
    'Dehiwala - Mount Lavinia',
    'Rajagiriya & Kotte',
    'Nugegoda & Kohuwala',
    'Battaramulla & Pelawatte',
    'Maharagama & Pannipitiya',
    'Moratuwa & Ratmalana',
  };
  Set<String> get selectedZones => Set.unmodifiable(_selectedZones);

  // Emergency & After-Hours Preferences
  bool _acceptEmergencyJobs = true;
  bool get acceptEmergencyJobs => _acceptEmergencyJobs;

  double _emergencyMultiplier = 1.5;
  double get emergencyMultiplier => _emergencyMultiplier;

  // Extra Travel Distance Beyond Radius
  bool _allowExtraDistance = true;
  bool get allowExtraDistance => _allowExtraDistance;

  int _extraDistanceRatePerKm = 120; // LKR
  int get extraDistanceRatePerKm => _extraDistanceRatePerKm;

  // Holiday Auto-Pause
  bool _autoPauseOnHolidays = true;
  bool get autoPauseOnHolidays => _autoPauseOnHolidays;

  // ---------------------------------------------------------------------------
  // Summaries & Computed Properties
  // ---------------------------------------------------------------------------
  int get openDaysCount => _schedules.where((s) => s.isOpen).length;

  String get workingHoursSummary {
    final openList = _schedules.where((s) => s.isOpen).toList();
    if (openList.isEmpty) return 'Currently Unavailable (All Days Closed)';
    if (openList.length == 7) return '7 Days a Week (Mon - Sun)';
    if (openList.length == 6 && !_schedules[6].isOpen) {
      return 'Mon - Sat (8:00 AM - 6:00 PM)';
    }
    if (openList.length == 5 && !_schedules[5].isOpen && !_schedules[6].isOpen) {
      return 'Mon - Fri (8:00 AM - 6:00 PM)';
    }
    return '${openList.length} days / week active';
  }

  String get coverageSummary {
    return '${_radiusKm.toInt()} km Radius';
  }

  void updateBaseCoordinates(double lat, double lng, {String? locationName}) {
    _baseLatitude = lat;
    _baseLongitude = lng;
    if (locationName != null && locationName.trim().isNotEmpty) {
      _baseLocation = locationName.trim();
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Mutators
  // ---------------------------------------------------------------------------
  void toggleAvailability(bool value) {
    _isAvailableNow = value;
    notifyListeners();
  }

  void toggleDay(String dayKey, bool isOpen) {
    final index = _schedules.indexWhere((s) => s.dayKey == dayKey);
    if (index != -1) {
      _schedules[index] = _schedules[index].copyWith(isOpen: isOpen);
      notifyListeners();
    }
  }

  void updateHours(String dayKey, TimeOfDay open, TimeOfDay close) {
    final index = _schedules.indexWhere((s) => s.dayKey == dayKey);
    if (index != -1) {
      _schedules[index] = _schedules[index].copyWith(
        openTime: open,
        closeTime: close,
      );
      notifyListeners();
    }
  }

  void applyHoursToAllOpen(TimeOfDay open, TimeOfDay close) {
    for (int i = 0; i < _schedules.length; i++) {
      if (_schedules[i].isOpen) {
        _schedules[i] = _schedules[i].copyWith(
          openTime: open,
          closeTime: close,
        );
      }
    }
    notifyListeners();
  }

  void applyPreset(SchedulePreset preset) {
    switch (preset) {
      case SchedulePreset.standardWeekdays:
        for (int i = 0; i < _schedules.length; i++) {
          final isWeekday = i < 5;
          _schedules[i] = _schedules[i].copyWith(
            isOpen: isWeekday,
            openTime: const TimeOfDay(hour: 8, minute: 0),
            closeTime: const TimeOfDay(hour: 18, minute: 0),
          );
        }
        break;
      case SchedulePreset.sixDays:
        for (int i = 0; i < _schedules.length; i++) {
          final isMonSat = i < 6;
          _schedules[i] = _schedules[i].copyWith(
            isOpen: isMonSat,
            openTime: const TimeOfDay(hour: 8, minute: 0),
            closeTime: const TimeOfDay(hour: 18, minute: 0),
          );
        }
        break;
      case SchedulePreset.fullWeek:
        for (int i = 0; i < _schedules.length; i++) {
          _schedules[i] = _schedules[i].copyWith(
            isOpen: true,
            openTime: const TimeOfDay(hour: 8, minute: 0),
            closeTime: const TimeOfDay(hour: 20, minute: 0),
          );
        }
        break;
      case SchedulePreset.morningShift:
        for (int i = 0; i < _schedules.length; i++) {
          final isMonSat = i < 6;
          _schedules[i] = _schedules[i].copyWith(
            isOpen: isMonSat,
            openTime: const TimeOfDay(hour: 7, minute: 0),
            closeTime: const TimeOfDay(hour: 15, minute: 0),
          );
        }
        break;
    }
    notifyListeners();
  }

  void updateBaseLocation(String location) {
    final trimmed = location.trim();
    if (trimmed.isNotEmpty) {
      _baseLocation = trimmed;
      notifyListeners();
    }
  }

  void updateRadius(double km) {
    _radiusKm = km.clamp(5.0, 60.0);
    notifyListeners();
  }

  void toggleZone(String zone) {
    if (_selectedZones.contains(zone)) {
      if (_selectedZones.length > 1) {
        _selectedZones.remove(zone);
        notifyListeners();
      }
    } else {
      _selectedZones.add(zone);
      notifyListeners();
    }
  }

  void addCustomZone(String zone) {
    final trimmed = zone.trim();
    if (trimmed.isNotEmpty) {
      if (!_catalogZones.contains(trimmed)) {
        _catalogZones.insert(0, trimmed);
      }
      _selectedZones.add(trimmed);
      notifyListeners();
    }
  }

  void setEmergencyPreferences({
    required bool accept,
    required double multiplier,
  }) {
    _acceptEmergencyJobs = accept;
    _emergencyMultiplier = multiplier;
    notifyListeners();
  }

  void setExtraDistancePreferences({
    required bool allow,
    required int ratePerKm,
  }) {
    _allowExtraDistance = allow;
    _extraDistanceRatePerKm = ratePerKm;
    notifyListeners();
  }

  void setAutoPauseHolidays(bool pause) {
    _autoPauseOnHolidays = pause;
    notifyListeners();
  }
}
