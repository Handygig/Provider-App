import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider_app/src/data/services/managed_services_service.dart';
import 'package:provider_app/src/data/services/verification_service.dart';
import 'package:provider_app/src/domain/usecases/profile/get_provider_dashboard_usecase.dart';
import 'package:provider_app/src/domain/usecases/profile/get_provider_profile_usecase.dart';
import 'package:provider_app/src/domain/usecases/profile/submit_provider_kyc_usecase.dart';
import 'package:provider_app/src/domain/usecases/profile/toggle_provider_availability_usecase.dart';
import 'package:provider_app/src/domain/usecases/profile/update_provider_profile_usecase.dart';
import 'package:provider_app/src/presentation/cubits/profile/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProviderProfileUseCase getProfileUseCase;
  final GetProviderDashboardUseCase getDashboardUseCase;
  final ToggleProviderAvailabilityUseCase toggleAvailabilityUseCase;
  final SubmitProviderKycUseCase submitProviderKycUseCase;
  final UpdateProviderProfileUseCase updateProfileUseCase;

  ProfileCubit({
    required this.getProfileUseCase,
    required this.getDashboardUseCase,
    required this.toggleAvailabilityUseCase,
    required this.submitProviderKycUseCase,
    required this.updateProfileUseCase,
  }) : super(const ProfileInitial());

  Future<void> loadProfile({bool showLoading = true}) async {
    if (showLoading) {
      emit(const ProfileLoading());
    }

    try {
      final results = await Future.wait([
        getProfileUseCase(),
        getDashboardUseCase(),
      ]);

      final profile = results[0] as dynamic;
      final dashboard = results[1] as dynamic;

      VerificationService.instance.syncWithProfile(profile);
      ManagedServicesService.instance.syncWithProfile(profile);

      emit(ProfileLoaded(profile: profile, dashboard: dashboard));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> toggleAvailability() async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(currentState.copyWith(isTogglingStatus: true));

    try {
      await toggleAvailabilityUseCase();
      // Update local profile & dashboard state
      emit(currentState.copyWith(
        isTogglingStatus: false,
        profile: currentState.profile,
        dashboard: currentState.dashboard,
      ));
      // Refresh to guarantee server-side consistency
      await loadProfile(showLoading: false);
    } catch (e) {
      emit(currentState.copyWith(isTogglingStatus: false));
    }
  }

  Future<bool> submitKyc({
    String? nicNumber,
    String? nicFrontPath,
    String? nicBackPath,
    String? skillCertPath,
    String? skillName,
  }) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(
        isSubmittingKyc: true,
        kycSubmitSuccess: null,
        kycSubmitError: null,
      ));
    }

    try {
      final updatedProfile = await submitProviderKycUseCase(
        nicNumber: nicNumber,
        nicFrontPath: nicFrontPath,
        nicBackPath: nicBackPath,
        skillCertPath: skillCertPath,
        skillName: skillName,
      );

      VerificationService.instance.syncWithProfile(updatedProfile);

      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(
          isSubmittingKyc: false,
          profile: updatedProfile,
          kycSubmitSuccess: 'Documents submitted successfully. Admin review in progress.',
        ));
      }
      return true;
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(
          isSubmittingKyc: false,
          kycSubmitError: errorMsg,
        ));
      }
      return false;
    }
  }

  Future<bool> updateProfile({
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
      final updatedProfile = await updateProfileUseCase(
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

      VerificationService.instance.syncWithProfile(updatedProfile);
      ManagedServicesService.instance.syncWithProfile(updatedProfile);

      if (this.state is ProfileLoaded) {
        emit((this.state as ProfileLoaded).copyWith(profile: updatedProfile));
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
