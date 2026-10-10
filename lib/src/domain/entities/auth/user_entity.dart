class UserEntity {
  final int? id;
  final String? providerType;
  final String? phoneNumber;
  final String? firebaseUid;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? regNumber;
  final String? taxId;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? nicFront;
  final String? nicBack;
  final String? brCertificate;
  final List<String> services;
  final String? profileImage;
  final bool isProfileComplete;

  const UserEntity({
    this.id,
    this.providerType,
    this.phoneNumber,
    this.firebaseUid,
    this.firstName,
    this.lastName,
    this.email,
    this.regNumber,
    this.taxId,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.nicFront,
    this.nicBack,
    this.brCertificate,
    this.services = const [],
    this.profileImage,
    required this.isProfileComplete,
  });

  String get fullName {
    return [firstName, lastName]
        .where((value) => value != null && value.trim().isNotEmpty)
        .map((value) => value!.trim())
        .join(' ');
  }
}
