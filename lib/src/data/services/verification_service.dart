import 'package:flutter/material.dart';

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

  // Initial state: Start in 'pending' review so the user immediately experiences
  // the under-review status on the Home page and the access restriction.
  VerificationStatus _status = VerificationStatus.pending;

  String? _nicNumber = '199214502341';
  String? _nicFrontPath;
  String? _nicBackPath;
  String? _brDocPath;
  String? _brNumber = 'PV-00249182';
  String? _skillCertPath;
  String? _skillName = 'NVQ Level 4 - Plumbing & Gas Fitting';

  DateTime? _submittedAt = DateTime.now().subtract(const Duration(hours: 3));
  String? _adminFeedback =
      'Your documents are being verified by Handygig Compliance Team. Standard turnaround is 2-24 hours.';

  // Getters
  VerificationStatus get status => _status;
  bool get isApproved => _status == VerificationStatus.approved;
  bool get isPending => _status == VerificationStatus.pending;
  bool get isNotSubmitted => _status == VerificationStatus.notSubmitted;
  bool get isRejected => _status == VerificationStatus.rejected;

  String? get nicNumber => _nicNumber;
  String? get nicFrontPath => _nicFrontPath;
  String? get nicBackPath => _nicBackPath;
  String? get brDocPath => _brDocPath;
  String? get brNumber => _brNumber;
  String? get skillCertPath => _skillCertPath;
  String? get skillName => _skillName;
  DateTime? get submittedAt => _submittedAt;
  String? get adminFeedback => _adminFeedback;

  bool get hasNicFront => _nicFrontPath != null || _status == VerificationStatus.pending;
  bool get hasNicBack => _nicBackPath != null || _status == VerificationStatus.pending;
  bool get hasBrDoc => _brDocPath != null || _status == VerificationStatus.pending;
  bool get hasSkillCert => _skillCertPath != null || _status == VerificationStatus.pending;

  void setNicFront(String? path) {
    _nicFrontPath = path;
    notifyListeners();
  }

  void setNicBack(String? path) {
    _nicBackPath = path;
    notifyListeners();
  }

  void setBrDoc(String? path) {
    _brDocPath = path;
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

  void setBrNumber(String? number) {
    _brNumber = number;
    notifyListeners();
  }

  void submitDocuments({
    String? nicNumber,
    String? brNumber,
    String? nicFrontPath,
    String? nicBackPath,
    String? brDocPath,
    String? skillCertPath,
  }) {
    if (nicNumber != null) _nicNumber = nicNumber;
    if (brNumber != null) _brNumber = brNumber;
    if (nicFrontPath != null) _nicFrontPath = nicFrontPath;
    if (nicBackPath != null) _nicBackPath = nicBackPath;
    if (brDocPath != null) _brDocPath = brDocPath;
    if (skillCertPath != null) _skillCertPath = skillCertPath;

    _status = VerificationStatus.pending;
    _submittedAt = DateTime.now();
    _adminFeedback =
        'Your documents are being verified by Handygig Compliance Team. Standard turnaround is 2-24 hours.';
    notifyListeners();
  }

  // Simulation controls for testing/demoing all states
  void simulateAdminApproval() {
    _status = VerificationStatus.approved;
    _adminFeedback =
        'Congratulations! All documents verified and approved. You now have full access to all features.';
    notifyListeners();
  }

  void simulateAdminRejection([String? reason]) {
    _status = VerificationStatus.rejected;
    _adminFeedback = reason ??
        'NIC back photo was blurry and illegible. Please re-upload a clear high-resolution photo with all 4 corners visible.';
    notifyListeners();
  }

  void simulateResetToNotSubmitted() {
    _status = VerificationStatus.notSubmitted;
    _submittedAt = null;
    _adminFeedback = null;
    notifyListeners();
  }

  void setStatus(VerificationStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}
