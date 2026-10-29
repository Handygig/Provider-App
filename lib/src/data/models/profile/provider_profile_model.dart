import 'package:provider_app/src/domain/entities/profile/provider_profile_entity.dart';

class ServiceCategoryModel extends ServiceCategoryEntity {
  const ServiceCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }
}

class KycVerificationModel extends KycVerificationEntity {
  const KycVerificationModel({
    required super.status,
    super.documents,
    super.rejectionReason,
    super.submittedAt,
    super.verifiedAt,
  });

  factory KycVerificationModel.fromJson(Map<String, dynamic> json) {
    return KycVerificationModel(
      status: json['status']?.toString() ?? 'PENDING',
      documents: json['documents'],
      rejectionReason: json['rejection_reason']?.toString(),
      submittedAt: json['submitted_at']?.toString(),
      verifiedAt: json['verified_at']?.toString(),
    );
  }
}

class ProviderProfileModel extends ProviderProfileEntity {
  const ProviderProfileModel({
    required super.id,
    required super.userId,
    required super.firstName,
    required super.lastName,
    required super.fullName,
    required super.email,
    required super.phone,
    super.profileImageUrl,
    super.bio,
    required super.availability,
    required super.isOnline,
    required super.approvalStatus,
    super.addressLine1,
    super.addressLine2,
    super.city,
    super.state,
    super.postalCode,
    super.country,
    super.latitude,
    super.longitude,
    required super.serviceRadius,
    super.services,
    super.serviceCategories,
    super.kyc,
    required super.rating,
    required super.reviewsCount,
    required super.completedJobsCount,
  });

  factory ProviderProfileModel.fromJson(Map<String, dynamic> json) {
    final categoriesJson = json['service_categories'] as List<dynamic>?;
    final categories = categoriesJson != null
        ? categoriesJson
            .map((c) => ServiceCategoryModel.fromJson(c as Map<String, dynamic>))
            .toList()
        : <ServiceCategoryModel>[];

    final servicesList = json['services'] as List<dynamic>?;
    final services = servicesList != null
        ? servicesList.map((s) => s.toString()).toList()
        : <String>[];

    final kycJson = json['kyc'] as Map<String, dynamic>?;

    return ProviderProfileModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      fullName: json['full_name']?.toString() ??
          '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phone_number']?.toString() ?? '',
      profileImageUrl: json['profile_image_url']?.toString() ?? json['profile_image']?.toString(),
      bio: json['bio']?.toString(),
      availability: json['availability']?.toString() ?? 'available',
      isOnline: json['is_online'] == true || (json['availability'] ?? 'available') == 'available',
      approvalStatus: json['approval_status']?.toString() ?? 'pending',
      addressLine1: json['address_line1']?.toString(),
      addressLine2: json['address_line2']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      postalCode: json['postal_code']?.toString(),
      country: json['country']?.toString() ?? 'Sri Lanka',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      serviceRadius: json['service_radius'] != null
          ? double.tryParse(json['service_radius'].toString()) ?? 25.0
          : 25.0,
      services: services,
      serviceCategories: categories,
      kyc: kycJson != null ? KycVerificationModel.fromJson(kycJson) : null,
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) ?? 5.0 : 5.0,
      reviewsCount: json['reviews_count'] is int
          ? json['reviews_count']
          : int.tryParse(json['reviews_count']?.toString() ?? '0') ?? 0,
      completedJobsCount: json['completed_jobs_count'] is int
          ? json['completed_jobs_count']
          : int.tryParse(json['completed_jobs_count']?.toString() ?? '0') ?? 0,
    );
  }
}
