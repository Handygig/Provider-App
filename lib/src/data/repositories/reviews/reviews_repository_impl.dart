import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/auth_exception.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/data/data_sources/remote/reviews/reviews_remote_data_source.dart';
import 'package:provider_app/src/domain/entities/reviews/review_entity.dart';
import 'package:provider_app/src/domain/repositories/reviews/reviews_repository.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsRemoteDataSource remoteDataSource;

  ReviewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ReviewsOverviewEntity>> getReviews() async {
    try {
      final result = await remoteDataSource.getReviews();
      return Right(result);
    } on ServerException catch (e) {
      return Left(APIFailure(errorMessage: e.message));
    } catch (e) {
      return Left(APIFailure(errorMessage: e.toString()));
    }
  }
}
