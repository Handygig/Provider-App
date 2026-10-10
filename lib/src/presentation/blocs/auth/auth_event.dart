import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

class SendOtpRequested extends AuthEvent {
  final String phoneNumber;

  const SendOtpRequested(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class ResendOtpRequested extends AuthEvent {
  final String phoneNumber;
  final int? forceResendingToken;

  const ResendOtpRequested({
    required this.phoneNumber,
    required this.forceResendingToken,
  });

  @override
  List<Object?> get props => [phoneNumber, forceResendingToken];
}

class VerifyOtpRequested extends AuthEvent {
  final String verificationId;
  final String smsCode;

  const VerifyOtpRequested({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object?> get props => [verificationId, smsCode];
}

class LoginWithFirebaseRequested extends AuthEvent {
  const LoginWithFirebaseRequested();
}

class CompleteProfileRequested extends AuthEvent {
  final String providerType;
  final String firstName;
  final String lastName;
  final String email;
  final String? regNumber;
  final String? taxId;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String? nicFrontPath;
  final String? nicBackPath;
  final String? brCertificatePath;
  final List<String> services;
  final String? profileImagePath;

  const CompleteProfileRequested({
    required this.providerType,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.regNumber,
    this.taxId,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.nicFrontPath,
    this.nicBackPath,
    this.brCertificatePath,
    required this.services,
    this.profileImagePath,
  });

  @override
  List<Object?> get props => [
    providerType,
    firstName,
    lastName,
    email,
    regNumber,
    taxId,
    addressLine1,
    addressLine2,
    city,
    state,
    postalCode,
    country,
    nicFrontPath,
    nicBackPath,
    brCertificatePath,
    services,
    profileImagePath,
  ];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
