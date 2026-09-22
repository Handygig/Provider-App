import 'package:flutter/material.dart';
import 'package:provider_app/core/constants/app_colors.dart';

enum JobCategory {
  toQuote,
  pendingApprove,
  ongoing,
  finished,
}

extension JobCategoryExtension on JobCategory {
  String get label {
    switch (this) {
      case JobCategory.toQuote:
        return 'To Quote';
      case JobCategory.pendingApprove:
        return 'Pending approve';
      case JobCategory.ongoing:
        return 'Ongoing';
      case JobCategory.finished:
        return 'Finished';
    }
  }

  String get badgeText {
    switch (this) {
      case JobCategory.toQuote:
        return 'Needs Quote';
      case JobCategory.pendingApprove:
        return 'Pending Approval';
      case JobCategory.ongoing:
        return 'In Progress';
      case JobCategory.finished:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case JobCategory.toQuote:
        return const Color(0xFFEA580C);
      case JobCategory.pendingApprove:
        return const Color(0xFF2563EB);
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
      case JobCategory.ongoing:
        return Icons.handyman_rounded;
      case JobCategory.finished:
        return Icons.verified_rounded;
    }
  }
}

enum ExtraApprovalStatus {
  none,
  pending,
  approved,
  rejected,
}

extension ExtraApprovalStatusExtension on ExtraApprovalStatus {
  String get label {
    switch (this) {
      case ExtraApprovalStatus.none:
        return 'None';
      case ExtraApprovalStatus.pending:
        return 'Pending Customer Approval';
      case ExtraApprovalStatus.approved:
        return 'Approved by Customer';
      case ExtraApprovalStatus.rejected:
        return 'Declined by Customer';
    }
  }

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

class JobModel {
  final String id;
  final String serviceTitle;
  final String category;
  final String customerName;
  final String customerPhone;
  final double customerRating;
  final int customerReviewsCount;
  final String address;
  final String city;
  final String distance;
  final String requestedTime;
  final String description;
  final double? estimatedBudget;
  double? quotedAmount;
  String? quoteNotes;
  JobCategory status;
  String? completionDate;
  double? finalRating;
  String? clientFeedback;
  double? extraAmount;
  String? extraReason;
  ExtraApprovalStatus extraStatus;

  JobModel({
    required this.id,
    required this.serviceTitle,
    required this.category,
    required this.customerName,
    this.customerPhone = '+94 77 982 1450',
    required this.customerRating,
    this.customerReviewsCount = 24,
    required this.address,
    this.city = 'Colombo',
    required this.distance,
    required this.requestedTime,
    required this.description,
    this.estimatedBudget,
    this.quotedAmount,
    this.quoteNotes,
    required this.status,
    this.completionDate,
    this.finalRating,
    this.clientFeedback,
    this.extraAmount,
    this.extraReason,
    this.extraStatus = ExtraApprovalStatus.none,
  });

  double get totalEffectivePrice =>
      (quotedAmount ?? estimatedBudget ?? 0.0) +
      (extraStatus == ExtraApprovalStatus.approved ? (extraAmount ?? 0.0) : 0.0);

  double get totalWithPendingExtra =>
      (quotedAmount ?? estimatedBudget ?? 0.0) + (extraAmount ?? 0.0);

  bool get hasPendingExtra =>
      extraStatus == ExtraApprovalStatus.pending &&
      extraAmount != null &&
      extraAmount! > 0;

  bool get hasApprovedExtra =>
      extraStatus == ExtraApprovalStatus.approved &&
      extraAmount != null &&
      extraAmount! > 0;

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
