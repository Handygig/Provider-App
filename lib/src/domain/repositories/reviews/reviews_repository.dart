import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/domain/entities/reviews/review_entity.dart';

abstract class ReviewsRepository {
  Future<Either<Failure, ReviewsOverviewEntity>> getReviews();
}
