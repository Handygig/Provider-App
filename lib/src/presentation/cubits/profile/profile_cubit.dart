import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider_app/src/data/services/verification_service.dart';
import 'package:provider_app/src/domain/usecases/profile/get_provider_dashboard_usecase.dart';
import 'package:provider_app/src/domain/usecases/profile/get_provider_profile_usecase.dart';
import 'package:provider_app/src/domain/usecases/profile/submit_provider_kyc_usecase.dart';
import 'package:provider_app/src/domain/usecases/profile/toggle_provider_availability_usecase.dart';
import 'package:provider_app/src/presentation/cubits/profile/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProviderProfileUseCase _getProfileUseCase;
  final GetProviderDashboardUseCase _getDashboardUseCase;
  final ToggleProviderAvailabilityUseCase _toggleAvailabilityUseCase;
  final SubmitProviderKycUseCase _submitProviderKycUseCase;

  ProfileCubit({
    required GetProviderProfileUseCase getProfileUseCase,
    required GetProviderDashboardUseCase getDashboardUseCase,
    required ToggleProviderAvailabilityUseCase toggleAvailabilityUseCase,
    required SubmitProviderKycUseCase submitProviderKycUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _getDashboardUseCase = getDashboardUseCase,
        _toggleAvailabilityUseCase = toggleAvailabilityUseCase,
        _submitProviderKycUseCase = submitProviderKycUseCase,
        super(const ProfileInitial());

  Future<void> loadProfile({bool showLoading = true}) async {
    if (showLoading) {
      emit(const ProfileLoading());
    }

    try {
      final results = await Future.wait([
        _getProfileUseCase(),
        _getDashboardUseCase(),
      ]);

      final profile = results[0] as dynamic;
      final dashboard = results[1] as dynamic;

      VerificationService.instance.syncWithProfile(profile);

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
      await _toggleAvailabilityUseCase();
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
      final updatedProfile = await _submitProviderKycUseCase(
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
}
