import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/domain/entities/auth/auth_result_entity.dart';
import 'package:provider_app/src/domain/entities/auth/otp_session_entity.dart';
import 'package:provider_app/src/domain/entities/auth/user_entity.dart';
import 'package:provider_app/src/domain/repositories/auth/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, OtpSessionEntity>> sendOtp({
    required String phoneNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(OtpSessionEntity(
      verificationId: 'mock-verification-id-$phoneNumber',
      forceResendingToken: 12345,
    ));
  }

  @override
  Future<Either<Failure, OtpSessionEntity>> resendOtp({
    required String phoneNumber,
    required int? forceResendingToken,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(OtpSessionEntity(
      verificationId: 'mock-verification-id-$phoneNumber',
      forceResendingToken: forceResendingToken ?? 12345,
    ));
  }

  @override
  Future<Either<Failure, AuthResultEntity>> verifyOtpAndRegister({
    required String verificationId,
    required String smsCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    const user = UserEntity(
      id: 1,
      phoneNumber: '+94771234567',
      isProfileComplete: false,
    );
    return const Right(AuthResultEntity(
      token: 'mock-jwt-token',
      user: user,
      isNewUser: true,
      isProfileComplete: false,
    ));
  }

  @override
  Future<Either<Failure, AuthResultEntity>> loginWithCurrentFirebaseUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    const user = UserEntity(
      id: 1,
      phoneNumber: '+94771234567',
      isProfileComplete: true,
    );
    return const Right(AuthResultEntity(
      token: 'mock-jwt-token',
      user: user,
      isNewUser: false,
      isProfileComplete: true,
    ));
  }

  @override
  Future<Either<Failure, UserEntity>> completeProfile({
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
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(UserEntity(
      id: 1,
      providerType: providerType,
      firstName: firstName,
      lastName: lastName,
      email: email,
      regNumber: regNumber,
      taxId: taxId,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      nicFront: nicFrontPath,
      nicBack: nicBackPath,
      brCertificate: brCertificatePath,
      services: services,
      profileImage: profileImagePath,
      isProfileComplete: true,
    ));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right(null);
  }
}
