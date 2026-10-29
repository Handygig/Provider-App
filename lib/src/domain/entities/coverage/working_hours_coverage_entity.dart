import 'package:equatable/equatable.dart';

class DayScheduleEntity extends Equatable {
  final String dayKey;
  final String dayName;
  final String shortName;
  final bool isOpen;
  final int openHour;
  final int openMinute;
  final int closeHour;
  final int closeMinute;

  const DayScheduleEntity({
    required this.dayKey,
    required this.dayName,
    required this.shortName,
    required this.isOpen,
    required this.openHour,
    required this.openMinute,
    required this.closeHour,
    required this.closeMinute,
  });

  String get formattedHours {
    if (!isOpen) return 'Closed';
    return '${_formatTime(openHour, openMinute)} - ${_formatTime(closeHour, closeMinute)}';
  }

  static String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  DayScheduleEntity copyWith({
    String? dayKey,
    String? dayName,
    String? shortName,
    bool? isOpen,
    int? openHour,
    int? openMinute,
    int? closeHour,
    int? closeMinute,
  }) {
    return DayScheduleEntity(
      dayKey: dayKey ?? this.dayKey,
      dayName: dayName ?? this.dayName,
      shortName: shortName ?? this.shortName,
      isOpen: isOpen ?? this.isOpen,
      openHour: openHour ?? this.openHour,
      openMinute: openMinute ?? this.openMinute,
      closeHour: closeHour ?? this.closeHour,
      closeMinute: closeMinute ?? this.closeMinute,
    );
  }

  @override
  List<Object?> get props => [
        dayKey,
        dayName,
        shortName,
        isOpen,
        openHour,
        openMinute,
        closeHour,
        closeMinute,
      ];
}

class WorkingHoursCoverageEntity extends Equatable {
  final bool isAvailableNow;
  final List<DayScheduleEntity> schedules;
  final String baseLocation;
  final double baseLatitude;
  final double baseLongitude;
  final double radiusKm;
  final List<String> catalogZones;
  final List<String> selectedZones;
  final bool acceptEmergencyJobs;
  final double emergencyMultiplier;
  final bool allowExtraDistance;
  final int extraDistanceRatePerKm;

  const WorkingHoursCoverageEntity({
    this.isAvailableNow = true,
    this.schedules = const [],
    this.baseLocation = 'Kollupitiya, Colombo 03',
    this.baseLatitude = 6.8982,
    this.baseLongitude = 79.8550,
    this.radiusKm = 20.0,
    this.catalogZones = const [
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
    ],
    this.selectedZones = const [
      'Colombo 01 - 05 (Central)',
      'Colombo 06 - 08 (Wellawatte/Borella)',
      'Dehiwala - Mount Lavinia',
      'Rajagiriya & Kotte',
      'Nugegoda & Kohuwala',
      'Battaramulla & Pelawatte',
      'Maharagama & Pannipitiya',
      'Moratuwa & Ratmalana',
    ],
    this.acceptEmergencyJobs = true,
    this.emergencyMultiplier = 1.5,
    this.allowExtraDistance = true,
    this.extraDistanceRatePerKm = 120,
  });

  WorkingHoursCoverageEntity copyWith({
    bool? isAvailableNow,
    List<DayScheduleEntity>? schedules,
    String? baseLocation,
    double? baseLatitude,
    double? baseLongitude,
    double? radiusKm,
    List<String>? catalogZones,
    List<String>? selectedZones,
    bool? acceptEmergencyJobs,
    double? emergencyMultiplier,
    bool? allowExtraDistance,
    int? extraDistanceRatePerKm,
  }) {
    return WorkingHoursCoverageEntity(
      isAvailableNow: isAvailableNow ?? this.isAvailableNow,
      schedules: schedules ?? this.schedules,
      baseLocation: baseLocation ?? this.baseLocation,
      baseLatitude: baseLatitude ?? this.baseLatitude,
      baseLongitude: baseLongitude ?? this.baseLongitude,
      radiusKm: radiusKm ?? this.radiusKm,
      catalogZones: catalogZones ?? this.catalogZones,
      selectedZones: selectedZones ?? this.selectedZones,
      acceptEmergencyJobs: acceptEmergencyJobs ?? this.acceptEmergencyJobs,
      emergencyMultiplier: emergencyMultiplier ?? this.emergencyMultiplier,
      allowExtraDistance: allowExtraDistance ?? this.allowExtraDistance,
      extraDistanceRatePerKm:
          extraDistanceRatePerKm ?? this.extraDistanceRatePerKm,
    );
  }

  @override
  List<Object?> get props => [
        isAvailableNow,
        schedules,
        baseLocation,
        baseLatitude,
        baseLongitude,
        radiusKm,
        catalogZones,
        selectedZones,
        acceptEmergencyJobs,
        emergencyMultiplier,
        allowExtraDistance,
        extraDistanceRatePerKm,
      ];
}
