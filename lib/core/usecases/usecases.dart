import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';

abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams {}
