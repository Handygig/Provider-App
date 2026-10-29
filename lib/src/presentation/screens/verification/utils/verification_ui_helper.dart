import 'package:flutter/material.dart';
import 'package:provider_app/src/domain/entities/verification/verification_entity.dart';
export 'package:provider_app/src/domain/entities/verification/verification_entity.dart';

extension VerificationStatusUiExtension on VerificationStatus {
  Color get color => VerificationUiHelper.colorForStatus(this);
  Color get backgroundColor =>
      VerificationUiHelper.backgroundColorForStatus(this);
  Color get borderColor => VerificationUiHelper.borderColorForStatus(this);
  IconData get icon => VerificationUiHelper.iconForStatus(this);
}

class VerificationUiHelper {
  static Color colorForStatus(VerificationStatus status) {
    switch (status) {
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

  static Color backgroundColorForStatus(VerificationStatus status) {
    switch (status) {
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

  static Color borderColorForStatus(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.notSubmitted:
        return const Color(0xFFFDE68A);
      case VerificationStatus.pending:
        return const Color(0xFFBFDBFE);
      case VerificationStatus.approved:
        return const Color(0xFFBBF7D0);
      case VerificationStatus.rejected:
        return const Color(0xFFFECACA);
    }
  }

  static IconData iconForStatus(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.notSubmitted:
        return Icons.upload_file_rounded;
      case VerificationStatus.pending:
        return Icons.hourglass_top_rounded;
      case VerificationStatus.approved:
        return Icons.verified_user_rounded;
      case VerificationStatus.rejected:
        return Icons.error_outline_rounded;
    }
  }
}
