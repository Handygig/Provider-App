import 'package:provider_app/src/data/models/profile/provider_dashboard_model.dart';
import 'package:provider_app/src/data/models/profile/provider_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProviderProfileModel> getProfile();
  Future<ProviderDashboardModel> getDashboard();
  Future<bool> toggleAvailability();
  Future<ProviderProfileModel> updateProfile({
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
  Future<ProviderProfileModel> submitKyc({
    String? nicNumber,
    String? nicFrontPath,
    String? nicBackPath,
    String? skillCertPath,
    String? skillName,
  });
}
