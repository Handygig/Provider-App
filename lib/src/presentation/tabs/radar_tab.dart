import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/data/models/jobs/job_model.dart';
import 'package:provider_app/src/presentation/cubits/coverage/coverage_cubit.dart';
import 'package:provider_app/src/presentation/cubits/coverage/coverage_state.dart';
import 'package:provider_app/src/presentation/cubits/jobs/jobs_cubit.dart';
import 'package:provider_app/src/presentation/cubits/jobs/jobs_state.dart';
import 'package:provider_app/src/presentation/screens/coverage/working_hours_coverage_screen.dart';
import 'package:provider_app/src/presentation/screens/jobs/job_details_screen.dart';

class RadarTab extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const RadarTab({super.key, this.onBackToHome});

  @override
  State<RadarTab> createState() => _RadarTabState();
}

class _RadarTabState extends State<RadarTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<JobsCubit>().loadJobs(silent: true);
        context.read<CoverageCubit>().loadCoverage(silent: true);
      }
    });
  }

  Future<void> _refresh() async {
    HapticFeedback.lightImpact();
    await Future.wait([
      context.read<JobsCubit>().loadJobs(silent: true),
      context.read<CoverageCubit>().loadCoverage(silent: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoverageCubit, CoverageState>(
      builder: (context, coverageState) {
        final coverage = context.read<CoverageCubit>().coverage;
        final isOnline = coverage.isAvailableNow;
        final radiusKm = coverage.radiusKm.toInt();

        return Scaffold(
          backgroundColor: const Color(0xFFFBFBFB),
          appBar: AppBar(
            backgroundColor: AppColors.darkHeaderBg,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const Icon(Icons.radar_rounded, color: Color(0xFFD4DE95)),
                SizedBox(width: 10.w),
                Text(
                  'Live Job Radar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Configure Coverage Area',
                icon: const Icon(Icons.tune_rounded, color: Color(0xFFD4DE95)),
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WorkingHoursCoverageScreen(),
                    ),
                  );
                  if (context.mounted) {
                    _refresh();
                  }
                },
              ),
              if (widget.onBackToHome != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: widget.onBackToHome,
                ),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: Colors.white,
            onRefresh: _refresh,
            child: BlocBuilder<JobsCubit, JobsState>(
              builder: (context, jobsState) {
                final allJobs = context.read<JobsCubit>().jobs;
                final toQuoteJobs = allJobs
                    .where((j) => j.status == JobCategory.toQuote)
                    .toList();
                final isLoading = jobsState is JobsLoading && allJobs.isEmpty;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 120.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animated / Status Radar Card
                      _buildRadarScannerCard(
                        isOnline: isOnline,
                        radiusKm: radiusKm,
                        baseLocation: coverage.baseLocation,
                      ),

                      SizedBox(height: 24.h),

                      // Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Nearby Opportunities',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textHeadline,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              if (toQuoteJobs.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    '${toQuoteJobs.length}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (isOnline)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                'ACTIVE SCANNING',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF15803D),
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 14.h),

                      // List or Empty / Loading State
                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        )
                      else if (toQuoteJobs.isEmpty)
                        _buildEmptyRadarState(
                          isOnline: isOnline,
                          radiusKm: radiusKm,
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: toQuoteJobs.length,
                          separatorBuilder: (_, _) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final job = toQuoteJobs[index];
                            return _buildOpportunityCard(job);
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadarScannerCard({
    required bool isOnline,
    required int radiusKm,
    required String baseLocation,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isOnline
              ? const [AppColors.primaryDark, Color(0xFF282B1A)]
              : const [Color(0xFF334155), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (isOnline ? AppColors.accentLime : Colors.white)
                        .withValues(alpha: 0.18),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 84.r,
                height: 84.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (isOnline ? AppColors.accentLime : Colors.white)
                        .withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.accentLime : const Color(0xFF64748B),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isOnline ? AppColors.accentLime : Colors.black)
                          .withValues(alpha: 0.5),
                      blurRadius: 16,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  isOnline ? Icons.radar_rounded : Icons.sensors_off_rounded,
                  color: isOnline ? AppColors.primaryDark : Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            isOnline ? 'Scanning $radiusKm km Radius' : 'Radar Paused (Offline)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            isOnline
                ? 'Broadcasting your live availability to clients in $baseLocation within $radiusKm km.'
                : 'Turn on your radar to discover incoming client requests in real-time.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WorkingHoursCoverageScreen(),
                    ),
                  );
                  if (context.mounted) {
                    _refresh();
                  }
                },
                icon: const Icon(Icons.map_outlined, color: Colors.white, size: 16),
                label: Text(
                  'Adjust Coverage',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                ),
              ),
              SizedBox(width: 10.w),
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.read<CoverageCubit>().toggleLiveRadar(!isOnline);
                },
                icon: Icon(
                  isOnline ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: isOnline ? Colors.white : AppColors.primaryDark,
                  size: 16,
                ),
                label: Text(
                  isOnline ? 'Go Offline' : 'Go Online',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: isOnline ? Colors.white : AppColors.primaryDark,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOnline
                      ? Colors.white.withValues(alpha: 0.15)
                      : AppColors.accentLime,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRadarState({
    required bool isOnline,
    required int radiusKm,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderUnselected),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6EB),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              size: 32.r,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            isOnline
                ? 'No Pending Requests In Range'
                : 'Live Radar Currently Paused',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeadline,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            isOnline
                ? 'New requests within your $radiusKm km radius will pop up here live. Pull down to refresh anytime.'
                : 'Turn your live radar on above to receive nearby customer repair and maintenance requests.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          OutlinedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
            label: Text(
              'Refresh Radar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5A7)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(JobEntity job) {
    final estPay = job.estimatedBudget != null && job.estimatedBudget! > 0
        ? 'LKR ${job.estimatedBudget!.toInt()}'
        : 'Quote Requested';
    final distanceText = job.distance.isNotEmpty ? job.distance : 'Nearby';
    final urgencyText = job.requestedTime.isNotEmpty
        ? job.requestedTime
        : (job.effectiveOrderType == OrderType.instant
            ? 'Urgent arrival requested'
            : 'Scheduled service');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: () async {
          HapticFeedback.lightImpact();
          final jobModel = job is JobModel ? job : JobModel.fromEntity(job);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JobDetailsScreen(job: jobModel),
            ),
          );
          if (mounted) {
            context.read<JobsCubit>().loadJobs(silent: true);
          }
        },
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: AppColors.borderUnselected,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    estPay,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      distanceText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                job.serviceTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeadline,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${job.customerName} • ${job.address.isNotEmpty ? job.address : job.city}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14.r,
                        color: const Color(0xFFE65100),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        urgencyText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'View & Bid',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16.r,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
