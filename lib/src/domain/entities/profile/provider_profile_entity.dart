class ServiceCategoryEntity {
  final int id;
  final String name;
  final String slug;

  const ServiceCategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
  });
}

class KycVerificationEntity {
  final String status;
  final dynamic documents;
  final String? rejectionReason;
  final String? submittedAt;
  final String? verifiedAt;

  const KycVerificationEntity({
    required this.status,
    this.documents,
    this.rejectionReason,
    this.submittedAt,
    this.verifiedAt,
  });

  bool get isApproved => status.toUpperCase() == 'APPROVED';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isRejected => status.toUpperCase() == 'REJECTED';

  String? get nicFrontUrl {
    if (documents is Map) {
      return documents['nicFront']?.toString();
    }
    return null;
  }

  String? get nicBackUrl {
    if (documents is Map) {
      return documents['nicBack']?.toString();
    }
    return null;
  }

  String? get skillCertUrl {
    if (documents is Map) {
      return documents['skillCert']?.toString();
    }
    return null;
  }

  String? get nicNumber {
    if (documents is Map) {
      return documents['nicNumber']?.toString();
    }
    return null;
  }

  String? get skillName {
    if (documents is Map) {
      return documents['skillName']?.toString();
    }
    return null;
  }
}

class ProviderProfileEntity {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final String? bio;
  final String availability;
  final bool isOnline;
  final String approvalStatus;
  final String? regNumber;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final double? latitude;
  final double? longitude;
  final double serviceRadius;
  final List<String> services;
  final List<ServiceCategoryEntity> serviceCategories;
  final KycVerificationEntity? kyc;
  final double rating;
  final int reviewsCount;
  final int completedJobsCount;

  const ProviderProfileEntity({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    this.bio,
    required this.availability,
    required this.isOnline,
    required this.approvalStatus,
    this.regNumber,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.latitude,
    this.longitude,
    required this.serviceRadius,
    this.services = const [],
    this.serviceCategories = const [],
    this.kyc,
    required this.rating,
    required this.reviewsCount,
    required this.completedJobsCount,
  });

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    if (first.isEmpty && last.isEmpty) return 'P';
    return '$first$last';
  }

  bool get isApproved => approvalStatus.toLowerCase() == 'approved';
  bool get isPending => approvalStatus.toLowerCase() == 'pending';
  bool get isRejected => approvalStatus.toLowerCase() == 'rejected';

  String get activeServicesSummary {
    if (serviceCategories.isEmpty) return 'No services configured';
    return serviceCategories.map((c) => c.name).take(3).join(', ');
  }
}
