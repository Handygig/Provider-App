import 'package:flutter/material.dart';
import 'package:provider_app/src/domain/entities/services/service_skill_entity.dart';
export 'package:provider_app/src/domain/entities/services/service_skill_entity.dart';

extension ServiceSkillEntityUiExtension on ServiceSkillEntity {
  IconData get icon => ServiceUiHelper.iconForCategory(category);
  Color get primaryColor => ServiceUiHelper.colorForCategory(category);
}

class ServiceUiHelper {
  static IconData iconForCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('plumb')) return Icons.plumbing_rounded;
    if (lower.contains('electr')) return Icons.bolt_rounded;
    if (lower.contains('ac') || lower.contains('condition')) {
      return Icons.ac_unit_rounded;
    }
    if (lower.contains('carpent')) return Icons.carpenter_rounded;
    if (lower.contains('paint')) return Icons.format_paint_rounded;
    if (lower.contains('appliance')) return Icons.microwave_rounded;
    if (lower.contains('clean')) return Icons.cleaning_services_rounded;
    return Icons.handyman_rounded;
  }

  static Color colorForCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('plumb')) return const Color(0xFF0284C7);
    if (lower.contains('electr')) return const Color(0xFFD97706);
    if (lower.contains('ac') || lower.contains('condition')) {
      return const Color(0xFF2563EB);
    }
    if (lower.contains('carpent')) return const Color(0xFF854D0E);
    if (lower.contains('paint')) return const Color(0xFF7C3AED);
    if (lower.contains('clean')) return const Color(0xFF0D9488);
    return const Color(0xFF4A5528);
  }
}
