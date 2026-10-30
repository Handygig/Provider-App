import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final int id;
  final int? assignmentId;
  final String customerName;
  final String? customerImage;
  final String service;
  final int rating;
  final String ratingFormatted;
  final String? comment;
  final String? createdAt;
  final String formattedDate;

  const ReviewEntity({
    required this.id,
    this.assignmentId,
    required this.customerName,
    this.customerImage,
    required this.service,
    required this.rating,
    required this.ratingFormatted,
    this.comment,
    this.createdAt,
    required this.formattedDate,
  });

  @override
  List<Object?> get props => [
        id,
        assignmentId,
        customerName,
        customerImage,
        service,
        rating,
        ratingFormatted,
        comment,
        createdAt,
        formattedDate,
      ];
}

class ReviewsOverviewEntity extends Equatable {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final List<ReviewEntity> reviews;

  const ReviewsOverviewEntity({
    this.averageRating = 5.0,
    this.totalReviews = 0,
    this.ratingDistribution = const {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
    this.reviews = const [],
  });

  @override
  List<Object?> get props => [
        averageRating,
        totalReviews,
        ratingDistribution,
        reviews,
      ];
}
