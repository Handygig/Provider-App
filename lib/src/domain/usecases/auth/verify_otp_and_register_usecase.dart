import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/domain/entities/auth/auth_result_entity.dart';
import 'package:provider_app/src/domain/repositories/auth/auth_repository.dart';

class VerifyOtpAndRegisterUsecase {
  final AuthRepository _repository;

  const VerifyOtpAndRegisterUsecase(this._repository);

  Future<Either<Failure, AuthResultEntity>> call({
    required String verificationId,
    required String smsCode,
  }) {
    return _repository.verifyOtpAndRegister(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}
