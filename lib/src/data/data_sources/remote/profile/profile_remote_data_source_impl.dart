import 'package:dio/dio.dart';
import 'package:provider_app/core/constants/app_endpoints.dart';
import 'package:provider_app/src/data/data_sources/remote/profile/profile_remote_data_source.dart';
import 'package:provider_app/src/data/models/profile/provider_dashboard_model.dart';
import 'package:provider_app/src/data/models/profile/provider_profile_model.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProviderProfileModel> getProfile() async {
    try {
      final response = await dio.get(AppEndpoints.providerProfile);
      final dynamic body = response.data;
      if (body is Map<String, dynamic>) {
        final data = body['data'] ?? body['provider'];
        if (data is Map<String, dynamic>) {
          return ProviderProfileModel.fromJson(data);
        }
      }
      throw Exception('Invalid profile response structure');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Failed to load profile';
      throw Exception(msg);
    }
  }

  @override
  Future<ProviderDashboardModel> getDashboard() async {
    try {
      final response = await dio.get(AppEndpoints.providerDashboard);
      final dynamic body = response.data;
      if (body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          return ProviderDashboardModel.fromJson(data);
        }
      }
      throw Exception('Invalid dashboard response structure');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Failed to load dashboard overview';
      throw Exception(msg);
    }
  }

  @override
  Future<bool> toggleAvailability() async {
    try {
      final response = await dio.post(AppEndpoints.providerStatus);
      final dynamic body = response.data;
      if (body is Map<String, dynamic>) {
        return body['is_online'] == true || body['availability'] == 'available';
      }
      return false;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Failed to toggle availability';
      throw Exception(msg);
    }
  }

  @override
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
  }) async {
    try {
      final Map<String, dynamic> map = {};
      if (firstName != null) map['first_name'] = firstName;
      if (lastName != null) map['last_name'] = lastName;
      if (email != null) map['email'] = email;
      if (phone != null) map['phone'] = phone;
      if (bio != null) map['bio'] = bio;
      if (addressLine1 != null) map['address_line1'] = addressLine1;
      if (addressLine2 != null) map['address_line2'] = addressLine2;
      if (city != null) map['city'] = city;
      if (state != null) map['state'] = state;
      if (postalCode != null) map['postal_code'] = postalCode;
      if (country != null) map['country'] = country;
      if (latitude != null) map['latitude'] = latitude;
      if (longitude != null) map['longitude'] = longitude;
      if (serviceRadius != null) map['service_radius'] = serviceRadius;
      if (services != null) {
        for (int i = 0; i < services.length; i++) {
          map['services[$i]'] = services[i];
        }
      }

      dynamic dataToSend;
      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        map['profile_image'] = await MultipartFile.fromFile(profileImagePath);
        dataToSend = FormData.fromMap(map);
      } else {
        dataToSend = FormData.fromMap(map);
      }

      final response = await dio.put(
        AppEndpoints.providerProfile,
        data: dataToSend,
      );

      final dynamic body = response.data;
      if (body is Map<String, dynamic>) {
        final data = body['data'] ?? body['provider'];
        if (data is Map<String, dynamic>) {
          return ProviderProfileModel.fromJson(data);
        }
      }
      return await getProfile();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Failed to update profile';
      throw Exception(msg);
    }
  }

  @override
  Future<ProviderProfileModel> submitKyc({
    String? nicNumber,
    String? nicFrontPath,
    String? nicBackPath,
    String? skillCertPath,
    String? skillName,
  }) async {
    try {
      final map = <String, dynamic>{};
      if (nicNumber != null && nicNumber.isNotEmpty) {
        map['nic_number'] = nicNumber;
      }
      if (skillName != null && skillName.isNotEmpty) {
        map['skill_name'] = skillName;
      }
      if (nicFrontPath != null && nicFrontPath.isNotEmpty && !nicFrontPath.startsWith('http')) {
        map['nic_front'] = await MultipartFile.fromFile(nicFrontPath);
      }
      if (nicBackPath != null && nicBackPath.isNotEmpty && !nicBackPath.startsWith('http')) {
        map['nic_back'] = await MultipartFile.fromFile(nicBackPath);
      }
      if (skillCertPath != null && skillCertPath.isNotEmpty && !skillCertPath.startsWith('http')) {
        map['skill_cert'] = await MultipartFile.fromFile(skillCertPath);
      }

      final formData = FormData.fromMap(map);
      final response = await dio.post(
        AppEndpoints.providerKyc,
        data: formData,
      );

      final dynamic body = response.data;
      if (body is Map<String, dynamic>) {
        final data = body['data'] ?? body['provider'];
        if (data is Map<String, dynamic>) {
          return ProviderProfileModel.fromJson(data);
        }
      }
      return await getProfile();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.response?.data?['errors']?.toString() ?? e.message ?? 'Failed to submit KYC documents';
      throw Exception(msg);
    }
  }
}
