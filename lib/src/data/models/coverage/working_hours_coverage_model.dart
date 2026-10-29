import 'package:provider_app/src/domain/entities/coverage/working_hours_coverage_entity.dart';

class DayScheduleModel extends DayScheduleEntity {
  const DayScheduleModel({
    required super.dayKey,
    required super.dayName,
    required super.shortName,
    required super.isOpen,
    required super.openHour,
    required super.openMinute,
    required super.closeHour,
    required super.closeMinute,
  });

  factory DayScheduleModel.fromJson(Map<String, dynamic> json) {
    return DayScheduleModel(
      dayKey: json['day_key']?.toString() ?? json['dayKey']?.toString() ?? '',
      dayName:
          json['day_name']?.toString() ?? json['dayName']?.toString() ?? '',
      shortName:
          json['short_name']?.toString() ?? json['shortName']?.toString() ?? '',
      isOpen: json['is_open'] == true || json['isOpen'] == true,
      openHour: json['open_hour'] ?? json['openHour'] ?? 8,
      openMinute: json['open_minute'] ?? json['openMinute'] ?? 0,
      closeHour: json['close_hour'] ?? json['closeHour'] ?? 18,
      closeMinute: json['close_minute'] ?? json['closeMinute'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_key': dayKey,
      'day_name': dayName,
      'short_name': shortName,
      'is_open': isOpen,
      'open_hour': openHour,
      'open_minute': openMinute,
      'close_hour': closeHour,
      'close_minute': closeMinute,
    };
  }
}

class WorkingHoursCoverageModel extends WorkingHoursCoverageEntity {
  const WorkingHoursCoverageModel({
    super.isAvailableNow = true,
    super.schedules = const [],
    super.baseLocation = 'Kollupitiya, Colombo 03',
    super.baseLatitude = 6.8982,
    super.baseLongitude = 79.8550,
    super.radiusKm = 20.0,
    super.catalogZones = const [],
    super.selectedZones = const [],
    super.acceptEmergencyJobs = true,
    super.emergencyMultiplier = 1.5,
    super.allowExtraDistance = true,
    super.extraDistanceRatePerKm = 120,
  });

  factory WorkingHoursCoverageModel.fromJson(Map<String, dynamic> json) {
    final schedList = json['schedules'] as List?;
    final schedules = schedList != null
        ? schedList
            .whereType<Map<String, dynamic>>()
            .map((s) => DayScheduleModel.fromJson(s))
            .toList()
        : const <DayScheduleModel>[];

    return WorkingHoursCoverageModel(
      isAvailableNow: json['is_available_now'] == true ||
          json['isAvailableNow'] == true ||
          json['is_online'] == true,
      schedules: schedules,
      baseLocation: json['base_location']?.toString() ??
          json['baseLocation']?.toString() ??
          'Kollupitiya, Colombo 03',
      baseLatitude: (json['base_latitude'] ?? json['baseLatitude'] ?? 6.8982)
          .toDouble(),
      baseLongitude:
          (json['base_longitude'] ?? json['baseLongitude'] ?? 79.8550)
              .toDouble(),
      radiusKm: (json['radius_km'] ?? json['radiusKm'] ?? 20.0).toDouble(),
      catalogZones: (json['catalog_zones'] ?? json['catalogZones'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      selectedZones: (json['selected_zones'] ?? json['selectedZones'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      acceptEmergencyJobs: json['accept_emergency_jobs'] == true ||
          json['acceptEmergencyJobs'] == true,
      emergencyMultiplier:
          (json['emergency_multiplier'] ?? json['emergencyMultiplier'] ?? 1.5)
              .toDouble(),
      allowExtraDistance: json['allow_extra_distance'] == true ||
          json['allowExtraDistance'] == true,
      extraDistanceRatePerKm: json['extra_distance_rate_per_km'] ??
          json['extraDistanceRatePerKm'] ??
          120,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_available_now': isAvailableNow,
      'schedules': schedules.map((s) {
        if (s is DayScheduleModel) return s.toJson();
        return DayScheduleModel(
          dayKey: s.dayKey,
          dayName: s.dayName,
          shortName: s.shortName,
          isOpen: s.isOpen,
          openHour: s.openHour,
          openMinute: s.openMinute,
          closeHour: s.closeHour,
          closeMinute: s.closeMinute,
        ).toJson();
      }).toList(),
      'base_location': baseLocation,
      'base_latitude': baseLatitude,
      'base_longitude': baseLongitude,
      'radius_km': radiusKm,
      'selected_zones': selectedZones,
      'accept_emergency_jobs': acceptEmergencyJobs,
      'emergency_multiplier': emergencyMultiplier,
      'allow_extra_distance': allowExtraDistance,
      'extra_distance_rate_per_km': extraDistanceRatePerKm,
    };
  }
}
