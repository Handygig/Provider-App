import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/data/data_sources/remote/services/managed_services_remote_data_source.dart';
import 'package:provider_app/src/data/models/services/service_skill_model.dart';
import 'package:provider_app/src/domain/entities/services/service_skill_entity.dart';
import 'package:provider_app/src/domain/repositories/services/managed_services_repository.dart';

class ManagedServicesRepositoryImpl implements ManagedServicesRepository {
  final ManagedServicesRemoteDataSource remoteDataSource;

  ManagedServicesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ServiceSkillEntity>>> getServices() async {
    try {
      final models = await remoteDataSource.getServices();
      return Right(models);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ServiceSkillEntity>>> getAvailableCatalog() async {
    try {
      final models = await remoteDataSource.getAvailableCatalog();
      return Right(models);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ServiceSkillEntity>>> updateServices(
      List<ServiceSkillEntity> services) async {
    try {
      final models = services
          .map((s) => s is ServiceSkillModel
              ? s
              : ServiceSkillModel(
                  id: s.id,
                  title: s.title,
                  category: s.category,
                  iconName: s.iconName,
                  isEnabled: s.isEnabled,
                  experienceLevel: s.experienceLevel,
                  baseRatePerHour: s.baseRatePerHour,
                  subSkills: s.subSkills,
                  activeSubSkills: s.activeSubSkills,
                  isVerified: s.isVerified,
                  description: s.description,
                  imageUrl: s.imageUrl,
                ))
          .toList();
      final updated = await remoteDataSource.updateServices(models);
      return Right(updated);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestCustomCategory({
    required String categoryName,
    required String notes,
  }) async {
    try {
      await remoteDataSource.requestCustomCategory(
        categoryName: categoryName,
        notes: notes,
      );
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
