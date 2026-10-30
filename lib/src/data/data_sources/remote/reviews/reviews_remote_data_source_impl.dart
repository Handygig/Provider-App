import 'package:dio/dio.dart';
import 'package:provider_app/core/constants/app_endpoints.dart';
import 'package:provider_app/core/errors/auth_exception.dart';
import 'package:provider_app/src/data/data_sources/remote/reviews/reviews_remote_data_source.dart';
import 'package:provider_app/src/data/models/reviews/review_model.dart';

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  final Dio dio;

  ReviewsRemoteDataSourceImpl({required this.dio});

  @override
  Future<ReviewsOverviewModel> getReviews() async {
    try {
      final response = await dio.get(AppEndpoints.providerReviews);
      final dynamic body = response.data;
      if (body is Map<String, dynamic>) {
        return ReviewsOverviewModel.fromJson(body);
      }
      return const ReviewsOverviewModel();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ?? 'Failed to load reviews',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
