import 'package:provider_app/src/domain/entities/profile/provider_dashboard_entity.dart';
import 'package:provider_app/src/domain/entities/profile/provider_profile_entity.dart';

abstract class ProfileRepository {
  Future<ProviderProfileEntity> getProfile();
  Future<ProviderDashboardEntity> getDashboard();
  Future<bool> toggleAvailability();
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
  });
  Future<ProviderProfileEntity> submitKyc({
    String? nicNumber,
    String? nicFrontPath,
    String? nicBackPath,
    String? skillCertPath,
    String? skillName,
  });
}
