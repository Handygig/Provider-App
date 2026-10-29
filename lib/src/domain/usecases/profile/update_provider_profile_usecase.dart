import 'package:provider_app/src/domain/entities/profile/provider_profile_entity.dart';
import 'package:provider_app/src/domain/repositories/profile/profile_repository.dart';

class UpdateProviderProfileUseCase {
  final ProfileRepository repository;

  UpdateProviderProfileUseCase({required this.repository});

  Future<ProviderProfileEntity> call({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? bio,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    double? latitude,
    double? longitude,
    double? serviceRadius,
    List<String>? services,
    String? profileImagePath,
  }) {
    return repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      bio: bio,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      latitude: latitude,
      longitude: longitude,
      serviceRadius: serviceRadius,
      services: services,
      profileImagePath: profileImagePath,
    );
  }
}
