import 'package:equatable/equatable.dart';
import 'package:provider_app/src/domain/entities/reviews/review_entity.dart';

abstract class ReviewsState extends Equatable {
  const ReviewsState();

  @override
  List<Object?> get props => [];
}

class ReviewsInitial extends ReviewsState {
  const ReviewsInitial();
}

class ReviewsLoading extends ReviewsState {
  const ReviewsLoading();
}

class ReviewsLoaded extends ReviewsState {
  final ReviewsOverviewEntity overview;

  const ReviewsLoaded(this.overview);

  @override
  List<Object?> get props => [overview];
}

class ReviewsError extends ReviewsState {
  final String message;

  const ReviewsError(this.message);

  @override
  List<Object?> get props => [message];
}
