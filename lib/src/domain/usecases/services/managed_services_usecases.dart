import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/core/usecases/usecases.dart';
import 'package:provider_app/src/domain/entities/services/service_skill_entity.dart';
import 'package:provider_app/src/domain/repositories/services/managed_services_repository.dart';

class GetManagedServicesUseCase
    implements UseCase<List<ServiceSkillEntity>, NoParams> {
  final ManagedServicesRepository _repository;

  GetManagedServicesUseCase(this._repository);

  @override
  Future<Either<Failure, List<ServiceSkillEntity>>> call(NoParams params) {
    return _repository.getServices();
  }
}

class GetAvailableCatalogUseCase
    implements UseCase<List<ServiceSkillEntity>, NoParams> {
  final ManagedServicesRepository _repository;

  GetAvailableCatalogUseCase(this._repository);

  @override
  Future<Either<Failure, List<ServiceSkillEntity>>> call(NoParams params) {
    return _repository.getAvailableCatalog();
  }
}

class UpdateManagedServicesUseCase
    implements UseCase<List<ServiceSkillEntity>, List<ServiceSkillEntity>> {
  final ManagedServicesRepository _repository;

  UpdateManagedServicesUseCase(this._repository);

  @override
  Future<Either<Failure, List<ServiceSkillEntity>>> call(
      List<ServiceSkillEntity> params) {
    return _repository.updateServices(params);
  }
}

class RequestCustomCategoryParams {
  final String categoryName;
  final String notes;

  const RequestCustomCategoryParams({
    required this.categoryName,
    required this.notes,
  });
}

class RequestCustomCategoryUseCase
    implements UseCase<void, RequestCustomCategoryParams> {
  final ManagedServicesRepository _repository;

  RequestCustomCategoryUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RequestCustomCategoryParams params) {
    return _repository.requestCustomCategory(
      categoryName: params.categoryName,
      notes: params.notes,
    );
  }
}
