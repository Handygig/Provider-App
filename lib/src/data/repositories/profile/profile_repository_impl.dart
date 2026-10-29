import 'package:provider_app/src/data/data_sources/remote/profile/profile_remote_data_source.dart';
import 'package:provider_app/src/domain/entities/profile/provider_dashboard_entity.dart';
import 'package:provider_app/src/domain/entities/profile/provider_profile_entity.dart';
import 'package:provider_app/src/domain/repositories/profile/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProviderProfileEntity> getProfile() => remoteDataSource.getProfile();

  @override
  Future<ProviderDashboardEntity> getDashboard() => remoteDataSource.getDashboard();

  @override
  Future<bool> toggleAvailability() => remoteDataSource.toggleAvailability();

  @override
  Future<ProviderProfileEntity> updateProfile({
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
  }) =>
      remoteDataSource.updateProfile(
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

  @override
  Future<ProviderProfileEntity> submitKyc({
    String? nicNumber,
    String? nicFrontPath,
    String? nicBackPath,
    String? skillCertPath,
    String? skillName,
  }) =>
      remoteDataSource.submitKyc(
        nicNumber: nicNumber,
        nicFrontPath: nicFrontPath,
        nicBackPath: nicBackPath,
        skillCertPath: skillCertPath,
        skillName: skillName,
      );
}
