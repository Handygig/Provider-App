import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/core/usecases/usecases.dart';
import 'package:provider_app/src/domain/entities/reviews/review_entity.dart';
import 'package:provider_app/src/domain/repositories/reviews/reviews_repository.dart';

class GetReviewsUseCase implements UseCase<ReviewsOverviewEntity, NoParams> {
  final ReviewsRepository repository;

  GetReviewsUseCase({required this.repository});

  @override
  Future<Either<Failure, ReviewsOverviewEntity>> call(NoParams params) {
    return repository.getReviews();
  }
}
