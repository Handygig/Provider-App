import 'package:flutter/material.dart';

class DaySchedule {
  final String dayKey;
  final String dayName;
  final String shortName;
  final bool isOpen;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;

  const DaySchedule({
    required this.dayKey,
    required this.dayName,
    required this.shortName,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
  });

  String get formattedHours {
    if (!isOpen) return 'Closed';
    return '${_formatTime(openTime)} - ${_formatTime(closeTime)}';
  }

  static String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  DaySchedule copyWith({
    String? dayKey,
    String? dayName,
    String? shortName,
    bool? isOpen,
    TimeOfDay? openTime,
    TimeOfDay? closeTime,
  }) {
    return DaySchedule(
      dayKey: dayKey ?? this.dayKey,
      dayName: dayName ?? this.dayName,
      shortName: shortName ?? this.shortName,
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }
}
