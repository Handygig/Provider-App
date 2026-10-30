import 'package:provider_app/src/data/models/reviews/review_model.dart';

abstract class ReviewsRemoteDataSource {
  Future<ReviewsOverviewModel> getReviews();
}
