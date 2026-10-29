import 'package:equatable/equatable.dart';

class ServiceSkillEntity extends Equatable {
  final String id;
  final String title;
  final String category;
  final String iconName;
  final bool isEnabled;
  final String experienceLevel; // 'Beginner' | 'Intermediate' | 'Expert / Master'
  final double baseRatePerHour; // in LKR
  final List<String> subSkills;
  final List<String> activeSubSkills;
  final bool isVerified;
  final String? description;
  final String? imageUrl;

  const ServiceSkillEntity({
    required this.id,
    required this.title,
    required this.category,
    this.iconName = 'handyman',
    this.isEnabled = false,
    this.experienceLevel = 'Expert / Master',
    this.baseRatePerHour = 2500.0,
    this.subSkills = const [],
    this.activeSubSkills = const [],
    this.isVerified = false,
    this.description,
    this.imageUrl,
  });

  ServiceSkillEntity copyWith({
    String? id,
    String? title,
    String? category,
    String? iconName,
    bool? isEnabled,
    String? experienceLevel,
    double? baseRatePerHour,
    List<String>? subSkills,
    List<String>? activeSubSkills,
    bool? isVerified,
    String? description,
    String? imageUrl,
  }) {
    return ServiceSkillEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      isEnabled: isEnabled ?? this.isEnabled,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      baseRatePerHour: baseRatePerHour ?? this.baseRatePerHour,
      subSkills: subSkills ?? this.subSkills,
      activeSubSkills: activeSubSkills ?? this.activeSubSkills,
      isVerified: isVerified ?? this.isVerified,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        iconName,
        isEnabled,
        experienceLevel,
        baseRatePerHour,
        subSkills,
        activeSubSkills,
        isVerified,
        description,
        imageUrl,
      ];
}
