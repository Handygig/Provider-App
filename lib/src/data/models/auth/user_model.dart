import 'package:provider_app/src/domain/entities/auth/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.id,
    super.providerType,
    super.phoneNumber,
    super.firebaseUid,
    super.firstName,
    super.lastName,
    super.email,
    super.regNumber,
    super.taxId,
    super.addressLine1,
    super.addressLine2,
    super.city,
    super.state,
    super.postalCode,
    super.country,
    super.nicFront,
    super.nicBack,
    super.brCertificate,
    super.services = const [],
    super.profileImage,
    required super.isProfileComplete,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] is Map
        ? Map<String, dynamic>.from(json['provider'] as Map)
        : const <String, dynamic>{};

    final rawComplete = json['is_profile_complete'];
    final inferredComplete =
        _hasText(json['first_name']) &&
        _hasText(json['last_name']) &&
        _hasText(json['email']);

    List<String> parsedServices = [];
    if (json['services'] is List) {
      parsedServices = (json['services'] as List).map((e) => e.toString()).toList();
    } else if (provider['services'] is List) {
      parsedServices = (provider['services'] as List).map((e) => e.toString()).toList();
    }

    return UserModel(
      id: _asInt(json['id']),
      providerType: _asString(json['provider_type'] ?? provider['provider_type']),
      phoneNumber: _asString(json['phone_number'] ?? json['phone']),
      firebaseUid: _asString(json['firebase_uid']),
      firstName: _asString(json['first_name']),
      lastName: _asString(json['last_name']),
      email: _asString(json['email']),
      regNumber: _asString(json['reg_number'] ?? provider['reg_number']),
      taxId: _asString(json['tax_id'] ?? provider['tax_id']),
      addressLine1: _asString(json['address_line1'] ?? provider['address_line1']),
      addressLine2: _asString(json['address_line2'] ?? provider['address_line2']),
      city: _asString(json['city'] ?? provider['city']),
      state: _asString(json['state'] ?? provider['state']),
      postalCode: _asString(json['postal_code'] ?? provider['postal_code']),
      country: _asString(json['country'] ?? provider['country']),
      nicFront: _asString(json['nic_front'] ?? provider['nic_front']),
      nicBack: _asString(json['nic_back'] ?? provider['nic_back']),
      brCertificate: _asString(json['br_certificate'] ?? provider['br_certificate']),
      services: parsedServices,
      profileImage: _asString(json['profile_image_url'] ?? json['profile_image']),
      isProfileComplete: rawComplete is bool
          ? rawComplete
          : rawComplete is num
          ? rawComplete != 0
          : inferredComplete,
    );
  }

  static bool _hasText(dynamic value) {
    return value != null && value.toString().trim().isNotEmpty;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
