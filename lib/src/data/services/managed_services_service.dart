import 'package:flutter/material.dart';
import 'package:provider_app/src/domain/models/service_skill_model.dart';

class ManagedServicesService extends ChangeNotifier {
  static final ManagedServicesService _instance =
      ManagedServicesService._internal();
  factory ManagedServicesService() => _instance;
  static ManagedServicesService get instance => _instance;

  ManagedServicesService._internal();

  // All pre-defined service categories supported on the Handygig Platform
  static const List<ServiceSkillModel> predefinedCatalog = [
    ServiceSkillModel(
      id: 'plumbing',
      title: 'Plumbing & Water Systems',
      category: 'Plumbing',
      icon: Icons.plumbing_rounded,
      primaryColor: Color(0xFF0284C7),
      isEnabled: true,
      experienceLevel: 'Expert / Master (8+ yrs)',
      subSkills: [
        'Pipe Leak Repair',
        'Drain Unclogging',
        'Bathroom Fittings',
        'Water Pump Motor Fix',
        'Geyser & Water Heater',
        'Sump Tank Clean',
      ],
      activeSubSkills: [
        'Pipe Leak Repair',
        'Drain Unclogging',
        'Bathroom Fittings',
        'Water Pump Motor Fix',
      ],
      isVerified: true,
    ),
    ServiceSkillModel(
      id: 'ac_repair',
      title: 'AC Repair & Servicing',
      category: 'AC Repair',
      icon: Icons.ac_unit_rounded,
      primaryColor: Color(0xFF0D9488),
      isEnabled: true,
      experienceLevel: 'Specialist (5+ yrs)',
      subSkills: [
        'Master Filter Cleaning',
        'Gas Topup (R32/R410A)',
        'PCB Board Repair',
        'Inverter AC Diagnosis',
        'Full Unit Installation',
        'Water Leakage Fix',
      ],
      activeSubSkills: [
        'Master Filter Cleaning',
        'Gas Topup (R32/R410A)',
        'Inverter AC Diagnosis',
      ],
      isVerified: true,
    ),
    ServiceSkillModel(
      id: 'electrical',
      title: 'Electrical & Power Systems',
      category: 'Electrical',
      icon: Icons.electric_bolt_rounded,
      primaryColor: Color(0xFFD97706),
      isEnabled: true,
      experienceLevel: 'Certified Wireman (7+ yrs)',
      subSkills: [
        'Breaker / Trip Box Fix',
        'Short Circuit Repair',
        'Ceiling Fan & Lights',
        '3-Phase Industrial Line',
        'Inverter & Backup Battery',
        'Socket & Switchboard Wiring',
      ],
      activeSubSkills: [
        'Breaker / Trip Box Fix',
        'Short Circuit Repair',
        'Ceiling Fan & Lights',
        'Socket & Switchboard Wiring',
      ],
      isVerified: true,
    ),
    ServiceSkillModel(
      id: 'carpentry',
      title: 'Carpentry & Woodwork',
      category: 'Carpentry',
      icon: Icons.carpenter_rounded,
      primaryColor: Color(0xFF92400E),
      isEnabled: false,
      experienceLevel: 'Intermediate (3+ yrs)',
      subSkills: [
        'Furniture Assembly',
        'Door Lock & Hinges',
        'Custom Cabinets',
        'Wood Polish & Varnish',
        'Roof Timber Repairs',
      ],
      activeSubSkills: [
        'Furniture Assembly',
        'Door Lock & Hinges',
      ],
      isVerified: false,
    ),
    ServiceSkillModel(
      id: 'painting',
      title: 'Painting & Waterproofing',
      category: 'Painting',
      icon: Icons.format_paint_rounded,
      primaryColor: Color(0xFF7C3AED),
      isEnabled: false,
      experienceLevel: 'Journeyman (4+ yrs)',
      subSkills: [
        'Interior Emulsion Paint',
        'Exterior Weather Shield',
        'Wall Crack & Putty Fill',
        'Roof Waterproofing Membrane',
      ],
      activeSubSkills: [
        'Interior Emulsion Paint',
        'Wall Crack & Putty Fill',
      ],
      isVerified: false,
    ),
    ServiceSkillModel(
      id: 'appliances',
      title: 'Home Appliances Repair',
      category: 'Appliances',
      icon: Icons.kitchen_rounded,
      primaryColor: Color(0xFFE11D48),
      isEnabled: false,
      experienceLevel: 'Specialist (4+ yrs)',
      subSkills: [
        'Washing Machine Drum & Motor',
        'Refrigerator Cooling Repair',
        'Microwave Oven Repair',
        'Induction Cooker Fix',
      ],
      activeSubSkills: [
        'Washing Machine Drum & Motor',
      ],
      isVerified: false,
    ),
    ServiceSkillModel(
      id: 'cleaning',
      title: 'Deep Cleaning & Sanitization',
      category: 'Cleaning',
      icon: Icons.cleaning_services_rounded,
      primaryColor: Color(0xFF059669),
      isEnabled: false,
      experienceLevel: 'Professional Team',
      subSkills: [
        'Full House Deep Clean',
        'Sofa & Mattress Shampoo',
        'Post-Construction Clean',
        'Kitchen Grease & Exhaust Clean',
      ],
      activeSubSkills: [
        'Full House Deep Clean',
      ],
      isVerified: false,
    ),
    ServiceSkillModel(
      id: 'gardening',
      title: 'Gardening & Landscaping',
      category: 'Gardening',
      icon: Icons.yard_rounded,
      primaryColor: Color(0xFF15803D),
      isEnabled: false,
      experienceLevel: 'Experienced (3+ yrs)',
      subSkills: [
        'Lawn Mowing & Edging',
        'Tree Pruning & Trimming',
        'Garden Pest & Fertilizer',
        'Sprinkler & Irrigation Setup',
      ],
      activeSubSkills: [
        'Lawn Mowing & Edging',
      ],
      isVerified: false,
    ),
    ServiceSkillModel(
      id: 'cctv_security',
      title: 'CCTV & Smart Security',
      category: 'Security Systems',
      icon: Icons.videocam_rounded,
      primaryColor: Color(0xFF475569),
      isEnabled: false,
      experienceLevel: 'Certified Installer',
      subSkills: [
        'IP & HD Camera Setup',
        'DVR/NVR Network Config',
        'Smart Video Doorbell',
        'Intruder Alarm Sensors',
      ],
      activeSubSkills: [
        'IP & HD Camera Setup',
      ],
      isVerified: false,
    ),
    ServiceSkillModel(
      id: 'pest_control',
      title: 'Pest Control & Fumigation',
      category: 'Pest Control',
      icon: Icons.pest_control_rounded,
      primaryColor: Color(0xFFB45309),
      isEnabled: false,
      experienceLevel: 'Licensed Operator',
      subSkills: [
        'Termite Treatment Barrier',
        'Bedbug Heat Treatment',
        'Cockroach & Ant Gel Baits',
        'Rodent Proofing',
      ],
      activeSubSkills: [
        'Termite Treatment Barrier',
      ],
      isVerified: false,
    ),
    ServiceSkillModel(
      id: 'solar_pv',
      title: 'Solar PV & Inverters',
      category: 'Solar Energy',
      icon: Icons.solar_power_rounded,
      primaryColor: Color(0xFFEAB308),
      isEnabled: false,
      experienceLevel: 'Solar Pro (5+ yrs)',
      subSkills: [
        'On-Grid & Hybrid Inverters',
        'Solar Rooftop Panel Mount',
        'Lithium Battery Storage',
        'CEB Net-Metering Wiring',
      ],
      activeSubSkills: [
        'On-Grid & Hybrid Inverters',
      ],
      isVerified: false,
    ),
    ServiceSkillModel(
      id: 'masonry_tiling',
      title: 'Masonry, Tiling & Plastering',
      category: 'Masonry',
      icon: Icons.foundation_rounded,
      primaryColor: Color(0xFF78716C),
      isEnabled: false,
      experienceLevel: 'Master Mason (10+ yrs)',
      subSkills: [
        'Floor & Wall Tile Laying',
        'Bathroom Re-Grouting',
        'Brickwork & Wall Repair',
        'Plastering & Skimming',
      ],
      activeSubSkills: [
        'Floor & Wall Tile Laying',
      ],
      isVerified: false,
    ),
  ];

  // Currently managed services by this provider (initializes with 3 active)
  late final List<ServiceSkillModel> _services = [
    predefinedCatalog[0].copyWith(isEnabled: true), // Plumbing
    predefinedCatalog[1].copyWith(isEnabled: true), // AC Repair
    predefinedCatalog[2].copyWith(isEnabled: true), // Electrical
  ];

  final List<String> _customSpecialties = [
    'Emergency 24/7 Callout',
    'NVQ Level 4 Certified',
    'Industrial 3-Phase Wireman',
    'German Fitting Tools',
  ];

  // Requests sent to admin for brand new categories
  final List<Map<String, dynamic>> _requestedCategories = [];

  // Getters
  List<ServiceSkillModel> get allServices => List.unmodifiable(_services);

  List<ServiceSkillModel> get activeServices =>
      _services.where((s) => s.isEnabled).toList();

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

  // Check if a category is already added by ID
  bool isServiceAdded(String id) {
    return _services.any((s) => s.id == id);
  }

  // Actions
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
      _services[index] =
          _services[index].copyWith(experienceLevel: experience);
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
      'id': 'REQ-${DateTime.now().millisecondsSinceEpoch % 10000}',
      'name': name.trim(),
      'description': description.trim(),
      'experienceYears': experienceYears.trim(),
      'date': 'Just now',
      'status': 'Pending Admin Review',
    });
    notifyListeners();
  }
}
