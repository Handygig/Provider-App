import 'package:flutter/material.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/domain/entities/jobs/job_entity.dart';
export 'package:provider_app/src/domain/entities/jobs/job_entity.dart';

extension JobCategoryUiExtension on JobCategory {
  Color get color {
    switch (this) {
      case JobCategory.toQuote:
        return const Color(0xFFEA580C);
      case JobCategory.pendingApprove:
        return const Color(0xFF2563EB);
      case JobCategory.toStart:
        return const Color(0xFF0D9488);
      case JobCategory.ongoing:
        return const Color(0xFF16A34A);
      case JobCategory.finished:
        return const Color(0xFF7C3AED);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case JobCategory.toQuote:
        return const Color(0xFFFFF7ED);
      case JobCategory.pendingApprove:
        return const Color(0xFFEFF6FF);
      case JobCategory.toStart:
        return const Color(0xFFF0FDFA);
      case JobCategory.ongoing:
        return const Color(0xFFF0FDF4);
      case JobCategory.finished:
        return const Color(0xFFF5F3FF);
    }
  }

  IconData get icon {
    switch (this) {
      case JobCategory.toQuote:
        return Icons.request_quote_rounded;
      case JobCategory.pendingApprove:
        return Icons.hourglass_top_rounded;
      case JobCategory.toStart:
        return Icons.play_circle_outline_rounded;
      case JobCategory.ongoing:
        return Icons.handyman_rounded;
      case JobCategory.finished:
        return Icons.verified_rounded;
    }
  }
}

extension ExtraApprovalStatusUiExtension on ExtraApprovalStatus {
  Color get color {
    switch (this) {
      case ExtraApprovalStatus.none:
        return AppColors.textMuted;
      case ExtraApprovalStatus.pending:
        return const Color(0xFFD97706);
      case ExtraApprovalStatus.approved:
        return const Color(0xFF16A34A);
      case ExtraApprovalStatus.rejected:
        return const Color(0xFFDC2626);
    }
  }
}

extension OrderTypeUiExtension on OrderType {
  Color get color {
    switch (this) {
      case OrderType.instant:
        return const Color(0xFFEA580C);
      case OrderType.scheduled:
        return const Color(0xFF2563EB);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case OrderType.instant:
        return const Color(0xFFFFF7ED);
      case OrderType.scheduled:
        return const Color(0xFFEFF6FF);
    }
  }
}

extension JobEntityUiExtension on JobEntity {
  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'ac repair':
      case 'hvac':
        return Icons.hvac_rounded;
      case 'electrical':
        return Icons.electrical_services_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      default:
        return Icons.handyman_rounded;
    }
  }

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return const Color(0xFF0284C7);
      case 'ac repair':
      case 'hvac':
        return AppColors.primary;
      case 'electrical':
        return const Color(0xFFD97706);
      default:
        return AppColors.primary;
    }
  }
}
