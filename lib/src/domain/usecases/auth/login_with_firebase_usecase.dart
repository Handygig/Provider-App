import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/domain/entities/auth/auth_result_entity.dart';
import 'package:provider_app/src/domain/repositories/auth/auth_repository.dart';

class LoginWithFirebaseUsecase {
  final AuthRepository _repository;

  const LoginWithFirebaseUsecase(this._repository);

  Future<Either<Failure, AuthResultEntity>> call() {
    return _repository.loginWithCurrentFirebaseUser();
  }
}
