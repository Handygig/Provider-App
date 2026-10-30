import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/domain/entities/reviews/review_entity.dart';
import 'package:provider_app/src/presentation/cubits/reviews/reviews_cubit.dart';
import 'package:provider_app/src/presentation/cubits/reviews/reviews_state.dart';

class CustomerReviewsScreen extends StatefulWidget {
  const CustomerReviewsScreen({super.key});

  @override
  State<CustomerReviewsScreen> createState() => _CustomerReviewsScreenState();
}

class _CustomerReviewsScreenState extends State<CustomerReviewsScreen> {
  int? _selectedStarFilter; // null means 'All'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReviewsCubit>().loadReviews();
      }
    });
  }

  Future<void> _refresh() async {
    HapticFeedback.lightImpact();
    await context.read<ReviewsCubit>().loadReviews(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8F4),
        body: Column(
          children: [
            _buildTopAppBar(),
            Expanded(
              child: BlocBuilder<ReviewsCubit, ReviewsState>(
                builder: (context, state) {
                  if (state is ReviewsLoading &&
                      context.read<ReviewsCubit>().overview.reviews.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state is ReviewsError &&
                      context.read<ReviewsCubit>().overview.reviews.isEmpty) {
                    return _buildErrorState(state.message);
                  }

                  final overview = context.read<ReviewsCubit>().overview;
                  final allReviews = overview.reviews;
                  final filteredReviews = _selectedStarFilter == null
                      ? allReviews
                      : allReviews
                          .where((r) => r.rating == _selectedStarFilter)
                          .toList();

                  return RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: Colors.white,
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 40.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Overall Rating & Distribution Card
                          _buildRatingSummaryCard(overview),

                          SizedBox(height: 18.h),

                          // Star Filter Chips
                          _buildFilterChips(overview),

                          SizedBox(height: 18.h),

                          // Reviews List or Empty
                          if (filteredReviews.isEmpty)
                            _buildEmptyState()
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredReviews.length,
                              separatorBuilder: (_, _) =>
                                  SizedBox(height: 12.h),
                              itemBuilder: (context, index) {
                                final review = filteredReviews[index];
                                return _buildReviewCard(review);
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Customer Reviews',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Feedback and ratings from completed service orders',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSummaryCard(ReviewsOverviewEntity overview) {
    final total = overview.totalReviews;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE2E6D5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Left Column: Big score & stars
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Text(
                      overview.averageRating.toStringAsFixed(1),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 44.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textHeadline,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        return Icon(
                          starIndex <= overview.averageRating.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFEAB308),
                          size: 20.r,
                        );
                      }),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '$total ${total == 1 ? 'Review' : 'Reviews'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 90.h,
                width: 1,
                color: const Color(0xFFE5E9DC),
                margin: EdgeInsets.symmetric(horizontal: 14.w),
              ),

              // Right Column: Star distribution breakdown bars
              Expanded(
                flex: 6,
                child: Column(
                  children: List.generate(5, (index) {
                    final starNumber = 5 - index;
                    final count = overview.ratingDistribution[starNumber] ?? 0;
                    final double fraction =
                        total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Row(
                        children: [
                          Text(
                            '$starNumber',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textHeadline,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Icon(
                            Icons.star_rounded,
                            size: 13.r,
                            color: const Color(0xFFEAB308),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: LinearProgressIndicator(
                                value: fraction,
                                minHeight: 6.h,
                                backgroundColor: const Color(0xFFEFF2E6),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SizedBox(
                            width: 22.w,
                            child: Text(
                              '$count',
                              textAlign: TextAlign.end,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ReviewsOverviewEntity overview) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChip(
            label: 'All (${overview.totalReviews})',
            isSelected: _selectedStarFilter == null,
            onTap: () {
              setState(() => _selectedStarFilter = null);
            },
          ),
          ...List.generate(5, (index) {
            final star = 5 - index;
            final count = overview.ratingDistribution[star] ?? 0;
            return Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: _buildChip(
                label: '$star ★ ($count)',
                isSelected: _selectedStarFilter == star,
                onTap: () {
                  setState(() => _selectedStarFilter = star);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : const Color(0xFFD6E0C8),
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textHeadline,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(ReviewEntity review) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE5E9DC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Avatar, Name, Service badge, and Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: const Color(0xFFF0F4E8),
                backgroundImage: review.customerImage != null
                    ? NetworkImage(review.customerImage!)
                    : null,
                child: review.customerImage == null
                    ? Text(
                        review.customerName.isNotEmpty
                            ? review.customerName[0].toUpperCase()
                            : 'C',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customerName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            review.service,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (review.formattedDate.isNotEmpty) ...[
                          SizedBox(width: 6.w),
                          Text(
                            '• ${review.formattedDate}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Star rating badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9C3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14.r,
                      color: const Color(0xFFCA8A04),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '${review.rating}.0',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF854D0E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Comment body
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              review.comment!.trim(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                height: 1.45,
                color: const Color(0xFF334155),
              ),
            ),
          ] else ...[
            SizedBox(height: 10.h),
            Text(
              'No written review provided.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontStyle: FontStyle.italic,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE5E9DC)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F6EB),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_outline_rounded,
              size: 32.r,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            _selectedStarFilter == null
                ? 'No Customer Reviews Yet'
                : 'No $_selectedStarFilter-Star Reviews Found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeadline,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _selectedStarFilter == null
                ? 'Complete service jobs to earn ratings and client testimonials from happy customers.'
                : 'No reviews found matching the selected star filter.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
          if (_selectedStarFilter != null) ...[
            SizedBox(height: 14.h),
            TextButton(
              onPressed: () => setState(() => _selectedStarFilter = null),
              child: Text(
                'Show All Reviews',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 44.r,
              color: Colors.redAccent,
            ),
            SizedBox(height: 12.h),
            Text(
              'Failed to load reviews',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textHeadline,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () => context.read<ReviewsCubit>().loadReviews(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
