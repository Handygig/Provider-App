import 'package:flutter/material.dart';

class ServiceSkillModel {
  final String id;
  final String title;
  final String category;
  final IconData icon;
  final Color primaryColor;
  final bool isEnabled;
  final String experienceLevel; // 'Beginner' | 'Intermediate' | 'Expert / Master'
  final double baseRatePerHour; // in LKR
  final List<String> subSkills;
  final List<String> activeSubSkills;
  final bool isVerified;

  const ServiceSkillModel({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    this.primaryColor = const Color(0xFF4A5528),
    this.isEnabled = false,
    this.experienceLevel = 'Expert / Master',
    this.baseRatePerHour = 2500.0,
    this.subSkills = const [],
    this.activeSubSkills = const [],
    this.isVerified = false,
  });

  ServiceSkillModel copyWith({
    String? id,
    String? title,
    String? category,
    IconData? icon,
    Color? primaryColor,
    bool? isEnabled,
    String? experienceLevel,
    double? baseRatePerHour,
    List<String>? subSkills,
    List<String>? activeSubSkills,
    bool? isVerified,
  }) {
    return ServiceSkillModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      primaryColor: primaryColor ?? this.primaryColor,
      isEnabled: isEnabled ?? this.isEnabled,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      baseRatePerHour: baseRatePerHour ?? this.baseRatePerHour,
      subSkills: subSkills ?? this.subSkills,
      activeSubSkills: activeSubSkills ?? this.activeSubSkills,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
