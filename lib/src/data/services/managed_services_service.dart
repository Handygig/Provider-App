import 'package:flutter/material.dart';
import 'package:provider_app/core/di/service_locator.dart';
import 'package:provider_app/src/data/models/services/service_skill_model.dart';
import 'package:provider_app/src/domain/entities/profile/provider_profile_entity.dart';
import 'package:provider_app/src/presentation/cubits/services/managed_services_cubit.dart';

export 'package:provider_app/src/presentation/screens/services/utils/service_ui_helper.dart';

class ManagedServicesService extends ChangeNotifier {
  static final ManagedServicesService _instance =
      ManagedServicesService._internal();
  factory ManagedServicesService() => _instance;
  static ManagedServicesService get instance => _instance;

  ManagedServicesService._internal();

  ManagedServicesCubit get _cubit => sl<ManagedServicesCubit>();

  bool get isLoading => false;
  bool get isSaving => false;
  String? get errorMessage => null;

  List<ServiceSkillModel> get allServices => _cubit.allServices.map((s) {
        if (s is ServiceSkillModel) return s;
        return ServiceSkillModel(
          id: s.id,
          title: s.title,
          category: s.category,
          iconName: s.iconName,
          isEnabled: s.isEnabled,
          experienceLevel: s.experienceLevel,
          baseRatePerHour: s.baseRatePerHour,
          subSkills: s.subSkills,
          activeSubSkills: s.activeSubSkills,
          isVerified: s.isVerified,
          description: s.description,
          imageUrl: s.imageUrl,
        );
      }).toList();

  List<ServiceSkillModel> get activeServices =>
      allServices.where((s) => s.isEnabled).toList();

  List<ServiceSkillModel> get availableCatalog => _cubit.catalog.map((s) {
        if (s is ServiceSkillModel) return s;
        return ServiceSkillModel(
          id: s.id,
          title: s.title,
          category: s.category,
          iconName: s.iconName,
          isEnabled: s.isEnabled,
          experienceLevel: s.experienceLevel,
          baseRatePerHour: s.baseRatePerHour,
          subSkills: s.subSkills,
          activeSubSkills: s.activeSubSkills,
          isVerified: s.isVerified,
          description: s.description,
          imageUrl: s.imageUrl,
        );
      }).toList();

  List<String> get customSpecialties => const [];
  List<Map<String, dynamic>> get requestedCategories => const [];

  String get activeServicesSummary => _cubit.activeServicesSummary;

  void syncWithProfile(ProviderProfileEntity profile) {
    if (profile.services.isNotEmpty) {
      _cubit.loadServices(silent: true);
    }
  }

  Future<void> fetchServices() async {
    await _cubit.loadServices();
    notifyListeners();
  }

  Future<void> fetchCatalog() async {
    await _cubit.loadCatalog();
    notifyListeners();
  }

  Future<void> toggleService(String serviceId, bool isEnabled) async {
    await _cubit.toggleService(serviceId, isEnabled);
    notifyListeners();
  }

  void toggleSubSkill(String serviceId, String subSkill) {
    final list = allServices;
    final index = list.indexWhere((s) => s.id == serviceId);
    if (index != -1) {
      final current = list[index];
      final active = Set<String>.from(current.activeSubSkills);
      if (active.contains(subSkill)) {
        active.remove(subSkill);
      } else {
        active.add(subSkill);
      }
      final updated = List<ServiceSkillModel>.from(list);
      updated[index] = current.copyWith(activeSubSkills: active.toList());
      _cubit.saveServices(updated);
      notifyListeners();
    }
  }

  void removeService(String serviceId) {
    final updated = allServices.where((s) => s.id != serviceId).toList();
    _cubit.saveServices(updated);
    notifyListeners();
  }

  void removeCustomSpecialty(String specialty) {
    notifyListeners();
  }

  Future<bool> saveServices() async {
    await _cubit.saveServices(_cubit.allServices);
    notifyListeners();
    return true;
  }

  void addPredefinedService(ServiceSkillModel service) {
    if (!isServiceAdded(service.title)) {
      final updated = List<ServiceSkillModel>.from(allServices)
        ..add(service.copyWith(isEnabled: true));
      _cubit.saveServices(updated);
      notifyListeners();
    }
  }

  Future<bool> requestNewCategory({
    required String name,
    String? description,
    String? experienceYears,
  }) async {
    final notes = [
      if (description != null && description.isNotEmpty) description,
      if (experienceYears != null && experienceYears.isNotEmpty)
        'Experience: $experienceYears',
    ].join('\n');
    return requestCustomCategory(name: name, notes: notes);
  }

  void addCustomSpecialty(String specialty) {
    notifyListeners();
  }

  void updateExperience(String serviceId, String exp) {
    final list = allServices;
    final index = list.indexWhere((s) => s.id == serviceId);
    if (index != -1) {
      final current = list[index];
      final updated = List<ServiceSkillModel>.from(list);
      updated[index] = current.copyWith(experienceLevel: exp);
      _cubit.saveServices(updated);
      notifyListeners();
    }
  }

  bool isServiceAdded(String title) {
    return allServices
        .any((s) => s.title.toLowerCase() == title.toLowerCase());
  }

  Future<void> updateServiceRate(String serviceId, double newRate) async {
    await _cubit.updateServiceRate(serviceId, newRate);
    notifyListeners();
  }

  Future<bool> requestCustomCategory({
    required String name,
    required String notes,
  }) async {
    final res = await _cubit.requestCategory(name: name, notes: notes);
    notifyListeners();
    return res;
  }
}
