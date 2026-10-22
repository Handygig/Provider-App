import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_assets.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/data/services/managed_services_service.dart';
import 'package:provider_app/src/data/services/notification_preferences_service.dart';
import 'package:provider_app/src/data/services/payout_service.dart';
import 'package:provider_app/src/data/services/verification_service.dart';
import 'package:provider_app/src/data/services/working_hours_coverage_service.dart';
import 'package:provider_app/src/presentation/screens/coverage/working_hours_coverage_screen.dart';
import 'package:provider_app/src/presentation/screens/notifications/notification_preferences_screen.dart';
import 'package:provider_app/src/presentation/screens/payout/bank_payout_details_screen.dart';
import 'package:provider_app/src/presentation/screens/services/managed_services_skills_screen.dart';
import 'package:provider_app/src/presentation/screens/verification/license_verification_screen.dart';
import 'package:provider_app/src/presentation/screens/welcome/welcome_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        VerificationService.instance,
        PayoutService.instance,
        ManagedServicesService.instance,
        WorkingHoursCoverageService.instance,
        NotificationPreferencesService.instance,
      ]),
      builder: (context, _) {
        final status = VerificationService.instance.status;

        return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
                        child: Center(
                          child: Text(
                            'AP',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
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
                                    'Alex Perera',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textHeadline,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const LicenseVerificationScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: status == VerificationStatus.approved
                                          ? AppColors.accentLime
                                          : status.backgroundColor,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: status.color.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      status.badgeText,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w800,
                                        color: status == VerificationStatus.approved
                                            ? AppColors.primaryDark
                                            : status.color,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '+94 77 123 4567 • Colombo, LK',
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
                    _buildStatCol('Jobs Done', '142'),
                    Container(
                        height: 30.h,
                        width: 1,
                        color: AppColors.borderUnselected),
                    _buildStatCol('Rating', '4.9 ★'),
                    Container(
                        height: 30.h,
                        width: 1,
                        color: AppColors.borderUnselected),
                    _buildStatCol('Total Earned', 'LKR 4.8k'),
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
                    icon: Icons.badge_outlined,
                    title: 'License & Verification',
                    subtitle: status == VerificationStatus.approved
                        ? 'All documents approved • Verified'
                        : (status == VerificationStatus.pending
                            ? 'Under admin review (Usually 2-24h)'
                            : 'National ID, Business registration, Skills'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LicenseVerificationScreen(),
                        ),
                      );
                    },
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 7.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: status.backgroundColor,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                            color: status.color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            status.badgeText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w800,
                              color: status.color,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: status.color,
                            size: 16.r,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildMenuTile(
                    icon: Icons.account_balance_outlined,
                    title: 'Bank & Payout Details',
                    subtitle: PayoutService.instance.primaryAccountSummary,
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6EA),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${PayoutService.instance.accounts.length} linked',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
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
                    subtitle:
                        ManagedServicesService.instance.activeServicesSummary,
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6EA),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${ManagedServicesService.instance.activeServices.length} active',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ManagedServicesSkillsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.location_on_outlined,
                    title: 'Coverage Area',
                    subtitle:
                        '${WorkingHoursCoverageService.instance.coverageSummary} • ${WorkingHoursCoverageService.instance.baseLocation}',
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6EA),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${WorkingHoursCoverageService.instance.radiusKm.toInt()}km',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const WorkingHoursCoverageScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notification Preferences',
                    subtitle:
                        NotificationPreferencesService.instance.summary,
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: NotificationPreferencesService
                                .instance.allNotificationsEnabled
                            ? const Color(0xFFEFF6EA)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        NotificationPreferencesService
                                .instance.allNotificationsEnabled
                            ? 'ON'
                            : 'MUTED',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                          color: NotificationPreferencesService
                                  .instance.allNotificationsEnabled
                              ? AppColors.primary
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const NotificationPreferencesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Partner Support',
                    subtitle: '24/7 dedicated support team',
                    onTap: () {},
                  ),
                  SizedBox(height: 16.h),

                  // Log Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const WelcomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout_rounded,
                          color: Color(0xFFEF4444), size: 20),
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
    );
  }

  Widget _buildStatCol(String label, String value) {
    return Column(
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
    );
  }
}
