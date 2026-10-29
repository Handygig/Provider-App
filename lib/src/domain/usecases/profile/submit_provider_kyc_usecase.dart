import 'package:provider_app/src/domain/entities/profile/provider_profile_entity.dart';
import 'package:provider_app/src/domain/repositories/profile/profile_repository.dart';

class SubmitProviderKycUseCase {
  final ProfileRepository repository;

  SubmitProviderKycUseCase({required this.repository});

  Future<ProviderProfileEntity> call({
    String? nicNumber,
    String? nicFrontPath,
    String? nicBackPath,
    String? skillCertPath,
    String? skillName,
  }) {
    return repository.submitKyc(
      nicNumber: nicNumber,
      nicFrontPath: nicFrontPath,
      nicBackPath: nicBackPath,
      skillCertPath: skillCertPath,
      skillName: skillName,
    );
  }
}
