import 'package:equatable/equatable.dart';

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
}

class VerificationDetailsEntity extends Equatable {
  final VerificationStatus status;
  final String? nicNumber;
  final String? nicFrontUrl;
  final String? nicBackUrl;
  final String? skillCertUrl;
  final String? skillName;
  final String? rejectionReason;
  final DateTime? reviewedAt;

  const VerificationDetailsEntity({
    this.status = VerificationStatus.notSubmitted,
    this.nicNumber,
    this.nicFrontUrl,
    this.nicBackUrl,
    this.skillCertUrl,
    this.skillName,
    this.rejectionReason,
    this.reviewedAt,
  });

  bool get isApproved => status == VerificationStatus.approved;
  bool get isPending => status == VerificationStatus.pending;
  bool get isRejected => status == VerificationStatus.rejected;
  bool get isNotSubmitted => status == VerificationStatus.notSubmitted;

  @override
  List<Object?> get props => [
        status,
        nicNumber,
        nicFrontUrl,
        nicBackUrl,
        skillCertUrl,
        skillName,
        rejectionReason,
        reviewedAt,
      ];
}
