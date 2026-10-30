import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider_app/core/usecases/usecases.dart';
import 'package:provider_app/src/domain/entities/reviews/review_entity.dart';
import 'package:provider_app/src/domain/usecases/reviews/get_reviews_usecase.dart';
import 'package:provider_app/src/presentation/cubits/reviews/reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  final GetReviewsUseCase getReviewsUseCase;

  ReviewsOverviewEntity _overview = const ReviewsOverviewEntity();

  ReviewsCubit({required this.getReviewsUseCase}) : super(const ReviewsInitial());

  ReviewsOverviewEntity get overview => _overview;

  Future<void> loadReviews({bool silent = false}) async {
    if (!silent) {
      emit(const ReviewsLoading());
    }

    final result = await getReviewsUseCase(NoParams());
    result.fold(
      (failure) => emit(ReviewsError(failure.errorMessage)),
      (data) {
        _overview = data;
        emit(ReviewsLoaded(_overview));
      },
    );
  }
}
