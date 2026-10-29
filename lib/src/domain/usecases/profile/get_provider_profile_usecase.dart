import 'package:provider_app/src/domain/entities/profile/provider_profile_entity.dart';
import 'package:provider_app/src/domain/repositories/profile/profile_repository.dart';

class GetProviderProfileUseCase {
  final ProfileRepository _repository;

  GetProviderProfileUseCase(this._repository);

  Future<ProviderProfileEntity> call() => _repository.getProfile();
}
