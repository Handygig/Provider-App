import 'package:provider_app/src/domain/entities/services/service_skill_entity.dart';

class ServiceSkillModel extends ServiceSkillEntity {
  const ServiceSkillModel({
    required super.id,
    required super.title,
    required super.category,
    super.iconName = 'handyman',
    super.isEnabled = false,
    super.experienceLevel = 'Expert / Master',
    super.baseRatePerHour = 2500.0,
    super.subSkills = const [],
    super.activeSubSkills = const [],
    super.isVerified = false,
    super.description,
    super.imageUrl,
  });

  factory ServiceSkillModel.fromJson(Map<String, dynamic> json) {
    return ServiceSkillModel(
      id: json['id']?.toString() ?? '',
      title: json['name']?.toString() ??
          json['title']?.toString() ??
          json['category']?.toString() ??
          '',
      category: json['category']?.toString() ??
          json['name']?.toString() ??
          'General',
      iconName: json['icon']?.toString() ?? 'handyman',
      isEnabled: json['is_enabled'] == true ||
          json['isEnabled'] == true ||
          json['is_active'] == true,
      experienceLevel: json['experience_level']?.toString() ??
          json['experienceLevel']?.toString() ??
          'Expert / Master',
      baseRatePerHour: (json['base_rate_per_hour'] ??
              json['baseRatePerHour'] ??
              json['rate'] ??
              2500.0)
          .toDouble(),
      subSkills: (json['sub_skills'] ?? json['subSkills'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      activeSubSkills: (json['active_sub_skills'] ??
                  json['activeSubSkills'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isVerified: json['is_verified'] == true || json['isVerified'] == true,
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString() ?? json['icon_url']?.toString(),
    );
  }

  factory ServiceSkillModel.fromEntity(ServiceSkillEntity e) {
    if (e is ServiceSkillModel) return e;
    return ServiceSkillModel(
      id: e.id,
      title: e.title,
      category: e.category,
      iconName: e.iconName,
      isEnabled: e.isEnabled,
      experienceLevel: e.experienceLevel,
      baseRatePerHour: e.baseRatePerHour,
      subSkills: e.subSkills,
      activeSubSkills: e.activeSubSkills,
      isVerified: e.isVerified,
      description: e.description,
      imageUrl: e.imageUrl,
    );
  }

  @override
  ServiceSkillModel copyWith({
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
    return ServiceSkillModel(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'icon': iconName,
      'is_enabled': isEnabled,
      'experience_level': experienceLevel,
      'base_rate_per_hour': baseRatePerHour,
      'sub_skills': subSkills,
      'active_sub_skills': activeSubSkills,
      'is_verified': isVerified,
      'description': description,
      'image_url': imageUrl,
    };
  }
}
