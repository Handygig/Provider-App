import 'package:flutter/material.dart';
import 'package:provider_app/src/domain/entities/profile/provider_profile_entity.dart';
import 'package:provider_app/src/domain/entities/verification/verification_entity.dart';
import 'package:provider_app/src/presentation/screens/verification/utils/verification_ui_helper.dart';

export 'package:provider_app/src/domain/entities/verification/verification_entity.dart';
export 'package:provider_app/src/presentation/screens/verification/utils/verification_ui_helper.dart';

class VerificationService extends ChangeNotifier {
  static final VerificationService _instance = VerificationService._internal();
  factory VerificationService() => _instance;
  static VerificationService get instance => _instance;

  VerificationService._internal();

  VerificationStatus _status = VerificationStatus.notSubmitted;
  DateTime? _reviewedAt;
  String? _rejectionReason;

  VerificationStatus get status => _status;
  DateTime? get reviewedAt => _reviewedAt;
  String? get rejectionReason => _rejectionReason;

  bool get isApproved => _status == VerificationStatus.approved;
  bool get isPending => _status == VerificationStatus.pending;
  bool get isRejected => _status == VerificationStatus.rejected;
  bool get isNotSubmitted => _status == VerificationStatus.notSubmitted;
  String get formattedSubmittedDate => 'recently';
  String? get adminFeedback => _rejectionReason;

  void syncWithProfile(ProviderProfileEntity profile) {
    if (profile.isVerified) {
      _status = VerificationStatus.approved;
      _reviewedAt = DateTime.now();
      _rejectionReason = null;
    } else if (profile.nicNumber != null && profile.nicNumber!.isNotEmpty) {
      _status = VerificationStatus.pending;
      _rejectionReason = null;
    } else {
      _status = VerificationStatus.notSubmitted;
      _rejectionReason = null;
    }
    notifyListeners();
  }

  void submitForReview({
    required String nicNumber,
    String? nicFrontPath,
    String? nicBackPath,
    String? skillCertPath,
    String? skillName,
  }) {
    _status = VerificationStatus.pending;
    _rejectionReason = null;
    notifyListeners();
  }

  void resetToNotSubmitted() {
    _status = VerificationStatus.notSubmitted;
    _rejectionReason = null;
    notifyListeners();
  }
}
