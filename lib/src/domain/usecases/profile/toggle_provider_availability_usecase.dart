import 'package:provider_app/src/domain/repositories/profile/profile_repository.dart';

class ToggleProviderAvailabilityUseCase {
  final ProfileRepository _repository;

  ToggleProviderAvailabilityUseCase(this._repository);

  Future<bool> call() => _repository.toggleAvailability();
}
