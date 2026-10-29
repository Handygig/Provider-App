import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/domain/entities/services/service_skill_entity.dart';

abstract class ManagedServicesRepository {
  Future<Either<Failure, List<ServiceSkillEntity>>> getServices();
  Future<Either<Failure, List<ServiceSkillEntity>>> getAvailableCatalog();
  Future<Either<Failure, List<ServiceSkillEntity>>> updateServices(
      List<ServiceSkillEntity> services);
  Future<Either<Failure, void>> requestCustomCategory({
    required String categoryName,
    required String notes,
  });
}
