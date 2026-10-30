import 'package:provider_app/src/domain/entities/reviews/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    super.assignmentId,
    required super.customerName,
    super.customerImage,
    required super.service,
    required super.rating,
    required super.ratingFormatted,
    super.comment,
    super.createdAt,
    required super.formattedDate,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      assignmentId: json['assignment_id'] is int
          ? json['assignment_id'] as int
          : int.tryParse(json['assignment_id']?.toString() ?? ''),
      customerName: json['customer_name']?.toString() ?? 'Customer',
      customerImage: json['customer_image']?.toString(),
      service: json['service']?.toString() ?? 'Service',
      rating: json['rating'] is int
          ? json['rating'] as int
          : (json['rating'] as num?)?.toInt() ?? 5,
      ratingFormatted: json['rating_formatted']?.toString() ?? '${json['rating'] ?? 5}.0 ★',
      comment: json['comment']?.toString(),
      createdAt: json['created_at']?.toString(),
      formattedDate: json['formatted_date']?.toString() ?? '',
    );
  }
}

class ReviewsOverviewModel extends ReviewsOverviewEntity {
  const ReviewsOverviewModel({
    super.averageRating = 5.0,
    super.totalReviews = 0,
    super.ratingDistribution = const {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
    super.reviews = const [],
  });

  factory ReviewsOverviewModel.fromJson(Map<String, dynamic> json) {
    final rawReviews = json['data'] as List<dynamic>? ?? [];
    final reviews = rawReviews
        .whereType<Map<String, dynamic>>()
        .map((r) => ReviewModel.fromJson(r))
        .toList();

    final rawDist = json['rating_distribution'] as Map<String, dynamic>? ?? {};
    final Map<int, int> distribution = {};
    for (int star = 1; star <= 5; star++) {
      final val = rawDist[star.toString()];
      distribution[star] = val is num ? val.toInt() : int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    return ReviewsOverviewModel(
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 5.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? reviews.length,
      ratingDistribution: distribution,
      reviews: reviews,
    );
  }
}
