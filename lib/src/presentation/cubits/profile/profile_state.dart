import 'package:provider_app/src/domain/entities/profile/provider_dashboard_entity.dart';
import 'package:provider_app/src/domain/entities/profile/provider_profile_entity.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProviderProfileEntity profile;
  final ProviderDashboardEntity dashboard;
  final bool isTogglingStatus;
  final bool isSubmittingKyc;
  final String? kycSubmitSuccess;
  final String? kycSubmitError;

  const ProfileLoaded({
    required this.profile,
    required this.dashboard,
    this.isTogglingStatus = false,
    this.isSubmittingKyc = false,
    this.kycSubmitSuccess,
    this.kycSubmitError,
  });

  ProfileLoaded copyWith({
    ProviderProfileEntity? profile,
    ProviderDashboardEntity? dashboard,
    bool? isTogglingStatus,
    bool? isSubmittingKyc,
    String? kycSubmitSuccess,
    String? kycSubmitError,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      dashboard: dashboard ?? this.dashboard,
      isTogglingStatus: isTogglingStatus ?? this.isTogglingStatus,
      isSubmittingKyc: isSubmittingKyc ?? this.isSubmittingKyc,
      kycSubmitSuccess: kycSubmitSuccess,
      kycSubmitError: kycSubmitError,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);
}
