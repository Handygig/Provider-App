import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider_app/core/constants/app_endpoints.dart';
import 'package:provider_app/core/di/service_locator.dart';
import 'package:provider_app/src/domain/entities/profile/provider_profile_entity.dart';
import 'package:provider_app/src/domain/models/service_skill_model.dart';
import 'package:provider_app/src/domain/usecases/profile/get_provider_profile_usecase.dart';
import 'package:provider_app/src/domain/usecases/profile/update_provider_profile_usecase.dart';

class ManagedServicesService extends ChangeNotifier {
  static final ManagedServicesService _instance =
      ManagedServicesService._internal();
  factory ManagedServicesService() => _instance;
  static ManagedServicesService get instance => _instance;

  ManagedServicesService._internal();

  Dio get _dio => sl<Dio>();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  // Active / managed services for this provider (synced with profile / API)
  List<ServiceSkillModel> _services = [];

  // Available service categories catalog fetched from the API (/service-categories)
  List<ServiceSkillModel> _availableCatalog = [];

  // Custom highlights & specialties added by provider
  final List<String> _customSpecialties = [];

  // Custom category requests submitted to admin
  final List<Map<String, dynamic>> _requestedCategories = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  List<ServiceSkillModel> get allServices => List.unmodifiable(_services);

  List<ServiceSkillModel> get activeServices =>
      _services.where((s) => s.isEnabled).toList();

  List<ServiceSkillModel> get availableCatalog =>
      List.unmodifiable(_availableCatalog.isNotEmpty ? _availableCatalog : _defaultFallbackCatalog);

  List<String> get customSpecialties =>
      List.unmodifiable(_customSpecialties);

  List<Map<String, dynamic>> get requestedCategories =>
      List.unmodifiable(_requestedCategories);

  String get activeServicesSummary {
    final activeTitles =
        activeServices.map((s) => s.category).toList();
    if (activeTitles.isEmpty) return 'No Active Services';
    return activeTitles.join(', ');
  }

  bool isServiceAdded(String id) {
    return _services.any((s) => s.id == id || s.category.toLowerCase() == id.toLowerCase());
  }

  // ---------------------------------------------------------------------------
  // API INTEGRATIONS
  // ---------------------------------------------------------------------------

  /// Fetches platform service categories & services from the API
  Future<void> fetchCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch categories
      final catResponse = await _dio.get(AppEndpoints.serviceCategories);
      final dynamic catBody = catResponse.data;
      final List<dynamic> catList;
      if (catBody is Map<String, dynamic> && catBody['data'] is List) {
        catList = catBody['data'] as List<dynamic>;
      } else if (catBody is List) {
        catList = catBody;
      } else {
        catList = [];
      }

      // 2. Fetch sub-services if available
      Map<int, List<String>> servicesByCategory = {};
      try {
        final subResponse = await _dio.get(AppEndpoints.services);
        final dynamic subBody = subResponse.data;
        final List<dynamic> subList;
        if (subBody is Map<String, dynamic> && subBody['data'] is List) {
          subList = subBody['data'] as List<dynamic>;
        } else if (subBody is List) {
          subList = subBody;
        } else {
          subList = [];
        }

        for (final item in subList.whereType<Map<String, dynamic>>()) {
          final catId = item['category_id'] is int
              ? item['category_id'] as int
              : int.tryParse(item['category_id']?.toString() ?? '0') ?? 0;
          final name = item['title']?.toString() ?? item['name']?.toString() ?? '';
          if (catId > 0 && name.isNotEmpty) {
            servicesByCategory.putIfAbsent(catId, () => []).add(name);
          }
        }
      } catch (_) {
        // Services endpoint optional, fall back to category services or defaults
      }

      // 3. Transform to ServiceSkillModel catalog
      final List<ServiceSkillModel> catalog = [];
      for (final item in catList.whereType<Map<String, dynamic>>()) {
        final id = item['id']?.toString() ?? '';
        final catIdInt = int.tryParse(id) ?? 0;
        final name = item['name']?.toString() ?? item['service_name']?.toString() ?? 'Service';
        final desc = item['description']?.toString();
        final img = item['image_url']?.toString() ?? item['image']?.toString();

        // Extract subskills from /services or item['services'] or standard fallback
        List<String> subSkills = servicesByCategory[catIdInt] ?? [];
        if (subSkills.isEmpty && item['services'] is List) {
          subSkills = (item['services'] as List)
              .map((s) => s is Map ? (s['title'] ?? s['name'])?.toString() ?? '' : s.toString())
              .where((s) => s.isNotEmpty)
              .toList();
        }
        if (subSkills.isEmpty) {
          subSkills = _getDefaultSubSkillsFor(name);
        }

        catalog.add(
          ServiceSkillModel(
            id: id,
            title: name,
            category: name,
            icon: _getCategoryIcon(name),
            primaryColor: _getCategoryColor(name),
            isEnabled: false,
            experienceLevel: 'Expert / Master (5+ yrs)',
            subSkills: subSkills,
            activeSubSkills: List.from(subSkills),
            description: desc,
            imageUrl: img,
          ),
        );
      }

      if (catalog.isNotEmpty) {
        _availableCatalog = catalog;

        // Enrich existing _services if they lack subskills
        for (int i = 0; i < _services.length; i++) {
          final existing = _services[i];
          final match = _availableCatalog.firstWhere(
            (c) => c.id == existing.id || c.category.toLowerCase() == existing.category.toLowerCase(),
            orElse: () => existing,
          );
          if (match != existing && existing.subSkills.isEmpty) {
            _services[i] = existing.copyWith(
              subSkills: match.subSkills,
              activeSubSkills: existing.activeSubSkills.isNotEmpty ? existing.activeSubSkills : match.subSkills,
              description: match.description,
              imageUrl: match.imageUrl,
            );
          }
        }
      }

      // If active services haven't been populated from profile, fetch profile now
      if (_services.isEmpty) {
        try {
          final getProfile = sl<GetProviderProfileUseCase>();
          final profile = await getProfile();
          syncWithProfile(profile);
        } catch (_) {
          // Profile fetch optional / offline fallback
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (_availableCatalog.isEmpty) {
        _availableCatalog = List.from(_defaultFallbackCatalog);
      }
      notifyListeners();
    }
  }

  /// Synchronizes local managed services with provider profile from backend
  void syncWithProfile(ProviderProfileEntity profile) {
    if (profile.serviceCategories.isEmpty && profile.services.isEmpty) {
      return;
    }

    final existingMap = {for (var s in _services) s.id: s};
    final List<ServiceSkillModel> synced = [];

    for (final cat in profile.serviceCategories) {
      final catId = cat.id.toString();
      final existing = existingMap[catId];
      if (existing != null) {
        synced.add(existing.copyWith(isEnabled: true, isVerified: profile.isApproved));
      } else {
        final catalogMatch = _availableCatalog.firstWhere(
          (c) => c.id == catId || c.category.toLowerCase() == cat.name.toLowerCase(),
          orElse: () => _buildSkillModelFromCategory(
            id: catId,
            name: cat.name,
            isEnabled: true,
            isVerified: profile.isApproved,
          ),
        );
        synced.add(catalogMatch.copyWith(
          id: catId,
          isEnabled: true,
          isVerified: profile.isApproved,
        ));
      }
    }

    // Keep any newly added services that the provider modified locally before saving
    for (final s in _services) {
      if (!synced.any((item) => item.id == s.id)) {
        synced.add(s);
      }
    }

    _services = synced;
    notifyListeners();
  }

  /// Saves the active service categories back to the backend profile via API
  Future<bool> saveServices() async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final activeIds = _services
          .where((s) => s.isEnabled)
          .map((s) => s.id)
          .toList();

      final updateUseCase = sl<UpdateProviderProfileUseCase>();
      final updatedProfile = await updateUseCase(services: activeIds);

      syncWithProfile(updatedProfile);

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSaving = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // LOCAL STATE ACTIONS
  // ---------------------------------------------------------------------------

  void addPredefinedService(ServiceSkillModel predefined) {
    if (!isServiceAdded(predefined.id)) {
      _services.add(predefined.copyWith(isEnabled: true));
      notifyListeners();
    }
  }

  void removeService(String id) {
    _services.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void toggleService(String id, bool isEnabled) {
    final index = _services.indexWhere((s) => s.id == id);
    if (index != -1) {
      _services[index] = _services[index].copyWith(isEnabled: isEnabled);
      notifyListeners();
    }
  }

  void toggleSubSkill(String serviceId, String subSkill) {
    final index = _services.indexWhere((s) => s.id == serviceId);
    if (index != -1) {
      final current = List<String>.from(_services[index].activeSubSkills);
      if (current.contains(subSkill)) {
        current.remove(subSkill);
      } else {
        current.add(subSkill);
      }
      _services[index] = _services[index].copyWith(activeSubSkills: current);
      notifyListeners();
    }
  }

  void updateExperience(String serviceId, String experience) {
    final index = _services.indexWhere((s) => s.id == serviceId);
    if (index != -1) {
      _services[index] = _services[index].copyWith(experienceLevel: experience);
      notifyListeners();
    }
  }

  void addCustomSpecialty(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isNotEmpty && !_customSpecialties.contains(trimmed)) {
      _customSpecialties.add(trimmed);
      notifyListeners();
    }
  }

  void removeCustomSpecialty(String tag) {
    _customSpecialties.remove(tag);
    notifyListeners();
  }

  void requestNewCategory({
    required String name,
    required String description,
    required String experienceYears,
  }) {
    _requestedCategories.add({
      'id': 'REQ-${DateTime.now().millisecondsSinceEpoch % 100000}',
      'name': name.trim(),
      'description': description.trim(),
      'experienceYears': experienceYears.trim(),
      'date': 'Submitted recently',
      'status': 'Pending Admin Review',
    });
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // HELPERS & THEME MAPPING
  // ---------------------------------------------------------------------------

  ServiceSkillModel _buildSkillModelFromCategory({
    required String id,
    required String name,
    required bool isEnabled,
    bool isVerified = false,
  }) {
    final subSkills = _getDefaultSubSkillsFor(name);
    return ServiceSkillModel(
      id: id,
      title: name,
      category: name,
      icon: _getCategoryIcon(name),
      primaryColor: _getCategoryColor(name),
      isEnabled: isEnabled,
      experienceLevel: 'Expert / Master (5+ yrs)',
      subSkills: subSkills,
      activeSubSkills: List.from(subSkills),
      isVerified: isVerified,
    );
  }

  static IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('plumb')) return Icons.plumbing_rounded;
    if (lower.contains('electr')) return Icons.electric_bolt_rounded;
    if (lower.contains('paint')) return Icons.format_paint_rounded;
    if (lower.contains('clean')) return Icons.cleaning_services_rounded;
    if (lower.contains('carpent') || lower.contains('wood')) return Icons.carpenter_rounded;
    if (lower.contains('ac') || lower.contains('hvac') || lower.contains('air') || lower.contains('cool')) {
      return Icons.ac_unit_rounded;
    }
    if (lower.contains('appliance') || lower.contains('refrigerat') || lower.contains('kitchen')) {
      return Icons.kitchen_rounded;
    }
    if (lower.contains('garden') || lower.contains('lawn')) return Icons.yard_rounded;
    if (lower.contains('mason') || lower.contains('tile') || lower.contains('plaster')) {
      return Icons.foundation_rounded;
    }
    if (lower.contains('secur') || lower.contains('cctv') || lower.contains('alarm')) {
      return Icons.security_rounded;
    }
    if (lower.contains('pest')) return Icons.pest_control_rounded;
    if (lower.contains('roof')) return Icons.roofing_rounded;
    if (lower.contains('auto') || lower.contains('mechanic')) return Icons.directions_car_rounded;
    if (lower.contains('solar')) return Icons.solar_power_rounded;
    return Icons.handyman_rounded;
  }

  static Color _getCategoryColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('plumb')) return const Color(0xFF0284C7);
    if (lower.contains('electr')) return const Color(0xFFD97706);
    if (lower.contains('paint')) return const Color(0xFF7C3AED);
    if (lower.contains('clean')) return const Color(0xFF059669);
    if (lower.contains('carpent') || lower.contains('wood')) return const Color(0xFF92400E);
    if (lower.contains('ac') || lower.contains('hvac') || lower.contains('air')) return const Color(0xFF0D9488);
    if (lower.contains('appliance')) return const Color(0xFFE11D48);
    if (lower.contains('garden')) return const Color(0xFF15803D);
    if (lower.contains('mason')) return const Color(0xFF78716C);
    if (lower.contains('secur')) return const Color(0xFF475569);
    if (lower.contains('pest')) return const Color(0xFFB91C1C);
    if (lower.contains('solar')) return const Color(0xFFCA8A04);
    return const Color(0xFF4A5528);
  }

  static List<String> _getDefaultSubSkillsFor(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('plumb')) {
      return ['Pipe Leak Repair', 'Drain Unclogging', 'Bathroom Fittings', 'Water Pump Fix'];
    }
    if (lower.contains('electr')) {
      return ['Wiring Safety Check', 'Circuit Breakers', 'Switchboard Repair', 'Light & Fan Fixtures'];
    }
    if (lower.contains('paint')) {
      return ['Interior Wall Painting', 'Exterior Painting', 'Wall Putty & Prep', 'Waterproofing'];
    }
    if (lower.contains('clean')) {
      return ['Deep Cleaning', 'Sanitization', 'Floor Scrubbing', 'Kitchen Deep Clean'];
    }
    if (lower.contains('carpent') || lower.contains('wood')) {
      return ['Furniture Assembly', 'Door Locks & Hinges', 'Wood Polish', 'Custom Woodwork'];
    }
    if (lower.contains('ac') || lower.contains('hvac')) {
      return ['Filter Cleaning', 'Gas Top-up', 'Inverter AC Diagnosis', 'Full Unit Service'];
    }
    if (lower.contains('appliance')) {
      return ['Washing Machine Repair', 'Refrigerator Repair', 'Microwave Repair', 'Oven Diagnostics'];
    }
    if (lower.contains('garden')) {
      return ['Lawn Mowing', 'Hedge Trimming', 'Weed Removal', 'Garden Maintenance'];
    }
    if (lower.contains('mason')) {
      return ['Tile Laying', 'Wall Plastering', 'Grouting & Crack Fix', 'Brickwork'];
    }
    if (lower.contains('secur')) {
      return ['CCTV Installation', 'Smart Lock Setup', 'Alarm Inspection', 'Camera Wiring'];
    }
    return ['General Service', 'Inspection & Diagnosis', 'Repairs & Installation', 'Maintenance'];
  }

  // Standard platform categories fallback in case of network unavailability
  static final List<ServiceSkillModel> _defaultFallbackCatalog = [
    ServiceSkillModel(
      id: '1',
      title: 'Cleaning',
      category: 'Cleaning',
      icon: Icons.cleaning_services_rounded,
      primaryColor: const Color(0xFF059669),
      subSkills: _getDefaultSubSkillsFor('Cleaning'),
      activeSubSkills: _getDefaultSubSkillsFor('Cleaning'),
    ),
    ServiceSkillModel(
      id: '2',
      title: 'Plumbing',
      category: 'Plumbing',
      icon: Icons.plumbing_rounded,
      primaryColor: const Color(0xFF0284C7),
      subSkills: _getDefaultSubSkillsFor('Plumbing'),
      activeSubSkills: _getDefaultSubSkillsFor('Plumbing'),
    ),
    ServiceSkillModel(
      id: '3',
      title: 'Electrical',
      category: 'Electrical',
      icon: Icons.electric_bolt_rounded,
      primaryColor: const Color(0xFFD97706),
      subSkills: _getDefaultSubSkillsFor('Electrical'),
      activeSubSkills: _getDefaultSubSkillsFor('Electrical'),
    ),
    ServiceSkillModel(
      id: '4',
      title: 'Painting',
      category: 'Painting',
      icon: Icons.format_paint_rounded,
      primaryColor: const Color(0xFF7C3AED),
      subSkills: _getDefaultSubSkillsFor('Painting'),
      activeSubSkills: _getDefaultSubSkillsFor('Painting'),
    ),
    ServiceSkillModel(
      id: '5',
      title: 'Gardening',
      category: 'Gardening',
      icon: Icons.yard_rounded,
      primaryColor: const Color(0xFF15803D),
      subSkills: _getDefaultSubSkillsFor('Gardening'),
      activeSubSkills: _getDefaultSubSkillsFor('Gardening'),
    ),
    ServiceSkillModel(
      id: '6',
      title: 'Appliances',
      category: 'Appliances',
      icon: Icons.kitchen_rounded,
      primaryColor: const Color(0xFFE11D48),
      subSkills: _getDefaultSubSkillsFor('Appliances'),
      activeSubSkills: _getDefaultSubSkillsFor('Appliances'),
    ),
    ServiceSkillModel(
      id: '7',
      title: 'HVAC',
      category: 'HVAC',
      icon: Icons.ac_unit_rounded,
      primaryColor: const Color(0xFF0D9488),
      subSkills: _getDefaultSubSkillsFor('HVAC'),
      activeSubSkills: _getDefaultSubSkillsFor('HVAC'),
    ),
    ServiceSkillModel(
      id: '8',
      title: 'Security',
      category: 'Security',
      icon: Icons.security_rounded,
      primaryColor: const Color(0xFF475569),
      subSkills: _getDefaultSubSkillsFor('Security'),
      activeSubSkills: _getDefaultSubSkillsFor('Security'),
    ),
  ];
}
