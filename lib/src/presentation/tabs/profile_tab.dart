import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_assets.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/core/di/service_locator.dart';
import 'package:provider_app/src/domain/entities/profile/provider_profile_entity.dart';
import 'package:provider_app/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:provider_app/src/presentation/blocs/auth/auth_event.dart';
import 'package:provider_app/src/presentation/cubits/profile/profile_cubit.dart';
import 'package:provider_app/src/presentation/cubits/profile/profile_state.dart';
import 'package:provider_app/src/presentation/screens/coverage/working_hours_coverage_screen.dart';
import 'package:provider_app/src/presentation/screens/notifications/notification_preferences_screen.dart';
import 'package:provider_app/src/presentation/screens/payout/bank_payout_details_screen.dart';
import 'package:provider_app/src/presentation/screens/reviews/customer_reviews_screen.dart';
import 'package:provider_app/src/presentation/screens/services/managed_services_skills_screen.dart';
import 'package:provider_app/src/presentation/screens/verification/license_verification_screen.dart';
import 'package:provider_app/src/presentation/screens/welcome/welcome_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..loadProfile(),
      child: const _ProfileTabView(),
    );
  }
}

class _ProfileTabView extends StatelessWidget {
  const _ProfileTabView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is ProfileError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48.r,
                      color: const Color(0xFFEF4444),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Failed to load profile',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context.read<ProfileCubit>().loadProfile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! ProfileLoaded) {
            return const SizedBox.shrink();
          }

          final profile = state.profile;
          final dashboard = state.dashboard;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<ProfileCubit>().loadProfile(showLoading: false),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                children: [
                  // Profile Hero Image Header with Smooth Bottom Fade
                  Stack(
                    children: [
                      // 1. Background Profile Header Image
                      SizedBox(
                        height: 280.h,
                        width: double.infinity,
                        child: Image.asset(
                          AppAssets.profileHeader,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [AppColors.primaryDark, AppColors.primary],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 80.r,
                                  color: Colors.white12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // 2. Smooth Bottom Gradient Mask
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.35, 0.72, 1.0],
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.transparent,
                                const Color(0xFFFBFBFB).withValues(alpha: 0.8),
                                const Color(0xFFFBFBFB),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 3. User Avatar and Info Overlaid
                      Positioned(
                        left: 20.w,
                        right: 20.w,
                        bottom: 12.h,
                        child: Row(
                          children: [
                            Container(
                              width: 72.r,
                              height: 72.r,
                              decoration: BoxDecoration(
                                color: AppColors.sage,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: profile.profileImageUrl != null &&
                                        profile.profileImageUrl!.isNotEmpty
                                    ? Image.network(
                                        profile.profileImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Center(
                                          child: Text(
                                            profile.initials,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 26.sp,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primaryDark,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          profile.initials,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 26.sp,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          profile.fullName.isNotEmpty
                                              ? profile.fullName
                                              : '${profile.firstName} ${profile.lastName}'.trim(),
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textHeadline,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      _buildStatusBadge(profile),
                                    ],
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    _buildSubtitle(profile),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Performance / Stats Card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    child: Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.borderUnselected,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCol('Jobs Done', '${dashboard.completedJobsCount}'),
                          Container(
                            height: 30.h,
                            width: 1,
                            color: AppColors.borderUnselected,
                          ),
                          _buildStatCol(
                            'Rating',
                            '${profile.rating.toStringAsFixed(1)} ★',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CustomerReviewsScreen(),
                                ),
                              );
                            },
                          ),
                          Container(
                            height: 30.h,
                            width: 1,
                            color: AppColors.borderUnselected,
                          ),
                          _buildStatCol('Total Earned', dashboard.formattedThisMonthEarnings),
                        ],
                      ),
                    ),
                  ),

                  // Settings & Profile Options List
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.star_rate_rounded,
                          title: 'Customer Reviews & Feedback',
                          subtitle:
                              '${profile.rating.toStringAsFixed(1)} ★ • ${profile.reviewsCount} customer ratings',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CustomerReviewsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.badge_outlined,
                          title: 'License & Verification',
                          subtitle: _buildKycSubtitle(profile),
                          onTap: () async {
                            final cubit = context.read<ProfileCubit>();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: cubit,
                                  child: const LicenseVerificationScreen(),
                                ),
                              ),
                            );
                            if (context.mounted) {
                              cubit.loadProfile(showLoading: false);
                            }
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.account_balance_outlined,
                          title: 'Bank & Payout Details',
                          subtitle: 'Direct bank accounts & withdrawals',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BankPayoutDetailsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.build_outlined,
                          title: 'Managed Services & Skills',
                          subtitle: profile.activeServicesSummary,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ManagedServicesSkillsScreen(),
                              ),
                            );
                            if (context.mounted) {
                              context.read<ProfileCubit>().loadProfile(showLoading: false);
                            }
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.location_on_outlined,
                          title: 'Coverage Area',
                          subtitle:
                              '${profile.serviceRadius.toInt()} km Radius • ${profile.city ?? profile.addressLine1 ?? 'Active Service Area'}',
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WorkingHoursCoverageScreen(),
                              ),
                            );
                            if (context.mounted) {
                              context.read<ProfileCubit>().loadProfile(showLoading: false);
                            }
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notification Preferences',
                          subtitle: 'Instant Jobs • Push Alerts • Sound',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationPreferencesScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Partner Support',
                          subtitle: '24/7 dedicated support team',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Support line: support@jobhive.com'),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Log Out Button
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: OutlinedButton.icon(
                            onPressed: () => _handleLogout(context),
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFEF4444),
                              size: 20,
                            ),
                            label: Text(
                              'Log Out of Partner Account',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFCA5A5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.r),
                              ),
                            ),
                          ),
                        ),

                        // Bottom padding for floating navigation bar
                        SizedBox(height: 120.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Log Out',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to log out of your provider account?',
          style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogoutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  String _buildSubtitle(dynamic profile) {
    final phone = profile.phone as String;
    final city = profile.city as String?;
    final country = profile.country as String?;

    final parts = <String>[];
    if (phone.isNotEmpty) parts.add(phone);
    if (city != null && city.isNotEmpty) {
      parts.add(city);
    } else if (country != null && country.isNotEmpty) {
      parts.add(country);
    }
    return parts.isEmpty ? 'Provider Account' : parts.join(' • ');
  }

  String _buildKycSubtitle(ProviderProfileEntity profile) {
    final kyc = profile.kyc;
    final hasSubmitted = kyc != null &&
        kyc.status.toUpperCase() != 'NOT_SUBMITTED' &&
        (kyc.submittedAt != null ||
            (kyc.documents is Map && (kyc.documents as Map).isNotEmpty));

    if (kyc == null || !hasSubmitted) {
      return 'Upload NIC & trade verification';
    }
    if (kyc.isApproved) {
      return 'All documents approved • Verified';
    }
    if (kyc.isPending) {
      return 'Under admin review (Usually 2-24h)';
    }
    if (kyc.isRejected) {
      return kyc.rejectionReason != null && kyc.rejectionReason!.isNotEmpty
          ? 'Rejected: ${kyc.rejectionReason}'
          : 'Document rejected • Please re-upload';
    }
    return 'Upload NIC & trade verification';
  }

  Widget _buildStatusBadge(ProviderProfileEntity profile) {
    final upper = profile.approvalStatus.toUpperCase();
    final isKycSubmitted = profile.kyc != null &&
        profile.kyc!.status.toUpperCase() != 'NOT_SUBMITTED' &&
        (profile.kyc!.submittedAt != null ||
            (profile.kyc!.documents is Map && (profile.kyc!.documents as Map).isNotEmpty));

    Color bg;
    Color border;
    Color text;
    String label;

    if (upper == 'APPROVED' || (profile.kyc != null && profile.kyc!.isApproved)) {
      bg = const Color(0xFFDCFCE7);
      border = const Color(0xFF86EFAC);
      text = const Color(0xFF166534);
      label = 'VERIFIED';
    } else if (upper == 'REJECTED' || (profile.kyc != null && profile.kyc!.isRejected)) {
      bg = const Color(0xFFFEE2E2);
      border = const Color(0xFFFCA5A5);
      text = const Color(0xFF991B1B);
      label = 'REJECTED';
    } else if (!isKycSubmitted) {
      bg = const Color(0xFFF3F4F6);
      border = const Color(0xFFD1D5DB);
      text = const Color(0xFF4B5563);
      label = 'UNVERIFIED';
    } else {
      bg = const Color(0xFFFEF3C7);
      border = const Color(0xFFFCD34D);
      text = const Color(0xFF92400E);
      label = 'UNDER REVIEW';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: text,
        ),
      ),
    );
  }

  Widget _buildStatCol(String label, String value, {VoidCallback? onTap}) {
    final col = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textHeadline,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.sp,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          child: col,
        ),
      );
    }
    return col;
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderUnselected,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: ListTile(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          leading: Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20.r,
            ),
          ),
          title: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeadline,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5.sp,
              color: AppColors.textSecondary,
            ),
          ),
          trailing: trailing ??
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
                size: 22,
              ),
        ),
      ),
    );
  }
}
