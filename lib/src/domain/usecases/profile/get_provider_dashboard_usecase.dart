import 'package:provider_app/src/domain/entities/profile/provider_dashboard_entity.dart';
import 'package:provider_app/src/domain/repositories/profile/profile_repository.dart';

class GetProviderDashboardUseCase {
  final ProfileRepository _repository;

  GetProviderDashboardUseCase(this._repository);

  Future<ProviderDashboardEntity> call() => _repository.getDashboard();
}
