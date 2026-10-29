import 'package:flutter/material.dart';
import 'package:provider_app/core/di/service_locator.dart';
import 'package:provider_app/src/domain/entities/coverage/working_hours_coverage_entity.dart';
import 'package:provider_app/src/presentation/cubits/coverage/coverage_cubit.dart';

enum SchedulePreset {
  standardWeekdays,
  sixDays,
  fullWeek,
  morningShift,
}

typedef DaySchedule = DayScheduleEntity;

class WorkingHoursCoverageService extends ChangeNotifier {
  static final WorkingHoursCoverageService _instance =
      WorkingHoursCoverageService._internal();
  factory WorkingHoursCoverageService() => _instance;
  static WorkingHoursCoverageService get instance => _instance;

  WorkingHoursCoverageService._internal();

  CoverageCubit get _cubit => sl<CoverageCubit>();

  bool get isAvailableNow => _cubit.isAvailableNow;

  List<DaySchedule> get schedules => _cubit.coverage.schedules;

  String get baseLocation => _cubit.coverage.baseLocation;
  double get baseLatitude => _cubit.coverage.baseLatitude;
  double get baseLongitude => _cubit.coverage.baseLongitude;
  double get radiusKm => _cubit.coverage.radiusKm;
  List<String> get catalogZones => _cubit.coverage.catalogZones;
  Set<String> get selectedZones => _cubit.coverage.selectedZones.toSet();

  bool get acceptEmergencyJobs => _cubit.coverage.acceptEmergencyJobs;
  double get emergencyMultiplier => _cubit.coverage.emergencyMultiplier;
  bool get allowExtraDistance => _cubit.coverage.allowExtraDistance;
  int get extraDistanceRatePerKm => _cubit.coverage.extraDistanceRatePerKm;

  void toggleLiveRadar(bool value) {
    _cubit.toggleLiveRadar(value);
    notifyListeners();
  }

  void toggleAvailability([bool? value]) {
    toggleLiveRadar(value ?? !isAvailableNow);
  }

  void updateBaseCoordinates(double lat, double lng) {
    _cubit.saveCoverage(_cubit.coverage.copyWith(
      baseLatitude: lat,
      baseLongitude: lng,
    ));
    notifyListeners();
  }

  void updateBaseLocation(String address, [double? lat, double? lng]) {
    setBaseLocation(address, lat ?? baseLatitude, lng ?? baseLongitude);
  }

  void updateSchedule(String dayKey, bool isOpen, TimeOfDay open, TimeOfDay close) {
    final updated = _cubit.coverage.schedules.map((s) {
      if (s.dayKey == dayKey) {
        return s.copyWith(
          isOpen: isOpen,
          openHour: open.hour,
          openMinute: open.minute,
          closeHour: close.hour,
          closeMinute: close.minute,
        );
      }
      return s;
    }).toList();

    _cubit.saveCoverage(_cubit.coverage.copyWith(schedules: updated));
    notifyListeners();
  }

  void updateRadius(double radius) {
    _cubit.saveCoverage(_cubit.coverage.copyWith(radiusKm: radius));
    notifyListeners();
  }

  void toggleZone(String zone) {
    final zones = Set<String>.from(_cubit.coverage.selectedZones);
    if (zones.contains(zone)) {
      zones.remove(zone);
    } else {
      zones.add(zone);
    }
    _cubit.saveCoverage(_cubit.coverage.copyWith(selectedZones: zones.toList()));
    notifyListeners();
  }

  void setBaseLocation(String address, double lat, double lng) {
    _cubit.saveCoverage(_cubit.coverage.copyWith(
      baseLocation: address,
      baseLatitude: lat,
      baseLongitude: lng,
    ));
    notifyListeners();
  }

  void setEmergencyPreferences(bool accept, double multiplier) {
    _cubit.saveCoverage(_cubit.coverage.copyWith(
      acceptEmergencyJobs: accept,
      emergencyMultiplier: multiplier,
    ));
    notifyListeners();
  }

  void setExtraDistancePreferences(bool allow, int ratePerKm) {
    _cubit.saveCoverage(_cubit.coverage.copyWith(
      allowExtraDistance: allow,
      extraDistanceRatePerKm: ratePerKm,
    ));
    notifyListeners();
  }
}
