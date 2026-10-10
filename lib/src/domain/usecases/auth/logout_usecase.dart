import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/domain/repositories/auth/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository _repository;

  const LogoutUsecase(this._repository);

  Future<Either<Failure, void>> call() => _repository.logout();
}
