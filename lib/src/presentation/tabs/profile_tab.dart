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
import 'package:provider_app/src/data/services/provider_session_service.dart';

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
        ProviderSessionService.instance,
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
                                if (ProviderSessionService.instance.isIndividual)
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
                                  )
                                else
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: const Color(0xFF86EFAC),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.business_rounded,
                                          size: 11.r,
                                          color: const Color(0xFF166534),
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          'COMPANY VERIFIED',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF166534),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              ProviderSessionService.instance.isCompanyProvider
                                  ? '${ProviderSessionService.instance.companyName} • Staff ID: ${ProviderSessionService.instance.staffId}'
                                  : '+94 77 123 4567 • Colombo, LK',
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
                if (ProviderSessionService.instance.isIndividual) ...[
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
                  ),
                  _buildMenuTile(
                    icon: Icons.account_balance_outlined,
                    title: 'Bank & Payout Details',
                    subtitle: PayoutService.instance.primaryAccountSummary,
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
                ] else ...[
                  _buildCompanyAffiliationTile(context),
                  _buildCompanyAccessNotice(),
                ],
                  _buildMenuTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notification Preferences',
                    subtitle:
                        NotificationPreferencesService.instance.summary,
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

  Widget _buildCompanyAffiliationTile(BuildContext context) {
    final company = ProviderSessionService.instance.companyName;
    final staffId = ProviderSessionService.instance.staffId;

    return _buildMenuTile(
      icon: Icons.business_rounded,
      title: 'Company Affiliation',
      subtitle: '$company • Staff ID: $staffId\nCorporate managed compliance & dispatch',
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Text(
          'ACTIVE',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF166534),
          ),
        ),
      ),
      onTap: () => _showCompanyAffiliationModal(context),
    );
  }

  Widget _buildCompanyAccessNotice() {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              size: 16,
              color: Color(0xFF16A34A),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Access Controlled Organization Account',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF166534),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Personal license verification, bank account details, skills catalog, and coverage zones are managed centrally by your company administrator.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    color: const Color(0xFF1E3A1A),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCompanyAffiliationModal(BuildContext context) {
    HapticFeedback.lightImpact();
    final company = ProviderSessionService.instance.companyName;
    final staffId = ProviderSessionService.instance.staffId;
    final regNo = ProviderSessionService.instance.companyRegNo;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          padding: EdgeInsets.fromLTRB(22.w, 16.h, 22.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E4DE),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.business_rounded,
                      color: const Color(0xFF16A34A),
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textHeadline,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Business Entity • Reg: $regNo',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Divider(color: Colors.grey.shade200),
              SizedBox(height: 10.h),
              _buildCompanyDetailRow('Staff Specialist', 'Alex Perera'),
              _buildCompanyDetailRow('Staff Identifier', staffId),
              _buildCompanyDetailRow('Corporate Verification', 'Active • Verified by Handygig'),
              _buildCompanyDetailRow('Payroll Settlement', 'Direct Corporate Disbursement (Weekly)'),
              _buildCompanyDetailRow('Job Source', 'Assigned by Company Supervisor'),
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F3),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.borderUnselected),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Your account has access-controlled privileges. You can quote, start, and complete dispatched jobs. Earnings are view-only and disbursed via company payroll.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    'Close Details',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompanyDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5.sp,
                color: AppColors.textHeadline,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
