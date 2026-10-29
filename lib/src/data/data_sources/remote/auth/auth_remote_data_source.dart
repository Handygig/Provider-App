import 'package:provider_app/src/data/models/auth/auth_result_model.dart';
import 'package:provider_app/src/data/models/auth/user_model.dart';
import 'package:provider_app/src/domain/entities/auth/otp_session_entity.dart';
export 'package:provider_app/core/errors/auth_exception.dart';

abstract class AuthRemoteDataSource {
  Future<OtpSessionEntity> sendOtp({
    required String phoneNumber,
    int? forceResendingToken,
  });

  Future<String> verifyOtpAndGetFirebaseIdToken({
    required String verificationId,
    required String smsCode,
  });

  Future<String> getCurrentFirebaseIdToken();

  Future<AuthResultModel> registerWithFirebase({
    required String firebaseIdToken,
  });

  Future<AuthResultModel> loginWithFirebase({
    required String firebaseIdToken,
  });

  Future<UserModel> completeProfile({
    required String bearerToken,
    required String providerType,
    required String firstName,
    required String lastName,
    required String email,
    String? regNumber,
    String? taxId,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    String? nicFrontPath,
    String? nicBackPath,
    String? brCertificatePath,
    required List<String> services,
    String? profileImagePath,
  });

  Future<void> signOutFirebase();
}
