import 'package:flutter/material.dart';
import 'package:provider_app/src/domain/entities/profile/provider_profile_entity.dart';

enum VerificationStatus {
  notSubmitted,
  pending,
  approved,
  rejected,
}

extension VerificationStatusExtension on VerificationStatus {
  String get label {
    switch (this) {
      case VerificationStatus.notSubmitted:
        return 'Not Submitted';
      case VerificationStatus.pending:
        return 'Under Admin Review';
      case VerificationStatus.approved:
        return 'Verified Partner';
      case VerificationStatus.rejected:
        return 'Action Required';
    }
  }

  String get title => label;

  String get badgeText {
    switch (this) {
      case VerificationStatus.notSubmitted:
        return 'UNVERIFIED';
      case VerificationStatus.pending:
        return 'UNDER REVIEW';
      case VerificationStatus.approved:
        return 'VERIFIED';
      case VerificationStatus.rejected:
        return 'REJECTED';
    }
  }

  Color get color {
    switch (this) {
      case VerificationStatus.notSubmitted:
        return const Color(0xFFD97706);
      case VerificationStatus.pending:
        return const Color(0xFF2563EB);
      case VerificationStatus.approved:
        return const Color(0xFF16A34A);
      case VerificationStatus.rejected:
        return const Color(0xFFDC2626);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case VerificationStatus.notSubmitted:
        return const Color(0xFFFFFBEB);
      case VerificationStatus.pending:
        return const Color(0xFFEFF6FF);
      case VerificationStatus.approved:
        return const Color(0xFFF0FDF4);
      case VerificationStatus.rejected:
        return const Color(0xFFFEF2F2);
    }
  }
}

class VerificationService extends ChangeNotifier {
  static final VerificationService _instance = VerificationService._internal();
  factory VerificationService() => _instance;
  static VerificationService get instance => _instance;

  VerificationService._internal();

  VerificationStatus _status = VerificationStatus.notSubmitted;

  String? _nicNumber;
  String? _nicFrontPath;
  String? _nicBackPath;
  String? _skillCertPath;
  String? _skillName;

  DateTime? _submittedAt;
  String? _adminFeedback;

  // Getters
  VerificationStatus get status => _status;
  bool get isApproved => _status == VerificationStatus.approved;
  bool get isPending => _status == VerificationStatus.pending;
  bool get isNotSubmitted => _status == VerificationStatus.notSubmitted;
  bool get isRejected => _status == VerificationStatus.rejected;

  String? get nicNumber => _nicNumber;
  String? get nicFrontPath => _nicFrontPath;
  String? get nicBackPath => _nicBackPath;
  String? get skillCertPath => _skillCertPath;
  String? get skillName => _skillName;
  DateTime? get submittedAt => _submittedAt;
  String? get adminFeedback => _adminFeedback;

  String get formattedSubmittedDate {
    if (_submittedAt == null) return 'recently';
    final now = DateTime.now();
    final diff = now.difference(_submittedAt!);
    if (diff.inHours < 1) {
      return '${diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }

  bool get hasNicFront => _nicFrontPath != null && _nicFrontPath!.isNotEmpty;
  bool get hasNicBack => _nicBackPath != null && _nicBackPath!.isNotEmpty;
  bool get hasSkillCert => _skillCertPath != null && _skillCertPath!.isNotEmpty;

  void syncWithProfile(ProviderProfileEntity profile) {
    if (profile.isApproved || (profile.kyc != null && profile.kyc!.isApproved)) {
      _status = VerificationStatus.approved;
    } else if (profile.isRejected || (profile.kyc != null && profile.kyc!.isRejected)) {
      _status = VerificationStatus.rejected;
      _adminFeedback = profile.kyc?.rejectionReason;
    } else if (profile.kyc != null && profile.kyc!.isPending) {
      _status = VerificationStatus.pending;
    } else {
      _status = VerificationStatus.notSubmitted;
    }

    _nicNumber = profile.addressLine1 != null ? (profile.regNumber ?? profile.kyc?.nicNumber) : profile.kyc?.nicNumber;
    _nicFrontPath = profile.kyc?.nicFrontUrl;
    _nicBackPath = profile.kyc?.nicBackUrl;
    _skillCertPath = profile.kyc?.skillCertUrl;
    _skillName = profile.kyc?.skillName;

    if (profile.kyc?.submittedAt != null) {
      _submittedAt = DateTime.tryParse(profile.kyc!.submittedAt!);
    }

    notifyListeners();
  }

  void setNicFront(String? path) {
    _nicFrontPath = path;
    notifyListeners();
  }

  void setNicBack(String? path) {
    _nicBackPath = path;
    notifyListeners();
  }

  void setSkillCert(String? path) {
    _skillCertPath = path;
    notifyListeners();
  }

  void setNicNumber(String? number) {
    _nicNumber = number;
    notifyListeners();
  }

  void setSkillName(String? name) {
    _skillName = name;
    notifyListeners();
  }

  void setStatus(VerificationStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}
