import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/domain/entities/auth/user_entity.dart';
import 'package:provider_app/src/domain/repositories/auth/auth_repository.dart';

class CompleteProfileUseCase {
  final AuthRepository repository;

  CompleteProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute({
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
  }) {
    return repository.completeProfile(
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
      nicFrontPath: nicFrontPath,
      nicBackPath: nicBackPath,
      brCertificatePath: brCertificatePath,
      services: services,
      profileImagePath: profileImagePath,
    );
  }
}
