import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/presentation/screens/auth/living_details_screen.dart';
import 'package:provider_app/src/presentation/screens/auth/provider_details_screen.dart';
import 'package:provider_app/src/presentation/screens/auth/service_assignment_screen.dart';
import 'package:provider_app/src/presentation/screens/auth/under_review_screen.dart';
import 'package:provider_app/src/presentation/screens/auth/verification_screen.dart';
import 'package:provider_app/src/presentation/screens/home/home_screen.dart';
import 'package:provider_app/src/domain/models/job_model.dart';
import 'package:provider_app/src/presentation/screens/jobs/job_details_screen.dart';
import 'package:provider_app/src/presentation/widgets/incoming_quotation_request_drawer.dart';

/// Modal bottom sheet and helpers for bypassing authentication and wizards during development.
class DevBypassSheet {
  static const String defaultTestPhone = '+94 77 123 4567';

  static void bypassToHome(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  static void bypassToJobs(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const HomeScreen(initialTabIndex: 1),
      ),
    );
  }

  static void bypassToWallet(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const HomeScreen(initialTabIndex: 2),
      ),
    );
  }

  static void bypassToIncomingQuotationDrawer(BuildContext context) {
    HapticFeedback.mediumImpact();
    final sampleJob = JobModel(
      id: 'JOB-3041',
      serviceTitle: 'Bathroom Plumbing & Fixture Fitting',
      category: 'Plumbing',
      customerName: 'Saman Kumara',
      customerPhone: '+94 77 982 1450',
      customerRating: 4.9,
      customerReviewsCount: 24,
      address: 'No 45, Alfred House Gardens, Colombo 03',
      distance: '2.4 km away',
      requestedTime: 'Inspection Today • 04:30 PM',
      description:
          'Need inspection and quotation for leaking main pipeline under the sink and bathroom mixer valve.',
      estimatedBudget: 80.00,
      status: JobCategory.toQuote,
    );

    IncomingQuotationRequestDrawer.show(context, job: sampleJob);
  }

  static void bypassToJobDetails(BuildContext context) {
    HapticFeedback.mediumImpact();
    final sampleJob = JobModel(
      id: 'JOB-3041',
      serviceTitle: 'Bathroom Plumbing & Fixture Fitting',
      category: 'Plumbing',
      customerName: 'Saman Kumara',
      customerRating: 4.9,
      address: 'No 45, Alfred House Gardens, Colombo 03',
      distance: '2.4 km away',
      requestedTime: 'Inspection Today • 04:30 PM',
      description:
          'Need inspection and quotation for leaking main pipeline and installation of 2 shower mixer units.',
      estimatedBudget: 80.00,
      status: JobCategory.toQuote,
    );

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => JobDetailsScreen(job: sampleJob),
      ),
    );
  }

  static void bypassToProviderDetails(
    BuildContext context, {
    String? phoneNumber,
  }) {
    HapticFeedback.mediumImpact();
    final targetPhone = (phoneNumber != null && phoneNumber.trim().isNotEmpty)
        ? phoneNumber.trim()
        : defaultTestPhone;

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => ProviderDetailsScreen(
          phoneNumber: targetPhone,
        ),
      ),
    );
  }

  static void bypassToLivingDetails(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const LivingDetailsScreen(
          firstName: 'Alex',
          lastName: 'Perera',
          phoneNumber: defaultTestPhone,
          email: 'alex.perera@example.com',
          providerType: 'individual',
        ),
      ),
    );
  }

  static void bypassToServiceAssignment(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const ServiceAssignmentScreen(
          firstName: 'Alex',
          lastName: 'Perera',
          phoneNumber: defaultTestPhone,
          email: 'alex.perera@example.com',
          providerType: 'individual',
          addressLine1: '123 Galle Road',
          addressLine2: 'Apt 4B',
          city: 'Colombo',
          postalCode: '00300',
        ),
      ),
    );
  }

  static void bypassToVerification(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const VerificationScreen(
          firstName: 'Alex',
          lastName: 'Perera',
          phoneNumber: defaultTestPhone,
          email: 'alex.perera@example.com',
          providerType: 'individual',
          addressLine1: '123 Galle Road',
          addressLine2: 'Apt 4B',
          city: 'Colombo',
          postalCode: '00300',
          services: ['Plumbing', 'Electrical'],
        ),
      ),
    );
  }

  static void bypassToUnderReview(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const UnderReviewScreen(
          firstName: 'Alex',
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    String? currentPhoneNumber,
  }) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E4DE),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(0xFFFFB74D),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              color: const Color(0xFFE65100),
                              size: 16.r,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'DEV MODE',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFE65100),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Quick Screen Jump',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textHeadline,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Jump directly to any screen with mock provider credentials.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildOptionTile(
                    icon: Icons.home_rounded,
                    title: 'Home Page (Provider Dashboard)',
                    subtitle: 'Direct bypass to main application home',
                    isPrimary: true,
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      bypassToHome(context);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _buildOptionTile(
                    icon: Icons.work_outline_rounded,
                    title: 'Jobs Page (4 Categories)',
                    subtitle: 'To Quote, Pending approve, Ongoing, Finished',
                    isPrimary: true,
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      bypassToJobs(context);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _buildOptionTile(
                    icon: Icons.assignment_outlined,
                    title: 'Job Details Page',
                    subtitle: 'Change status, view customer info & address',
                    isPrimary: true,
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      bypassToJobDetails(context);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _buildOptionTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Wallet & Payouts Page',
                    subtitle: 'View balance, earnings analytics & withdrawals',
                    isPrimary: true,
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      bypassToWallet(context);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _buildOptionTile(
                    icon: Icons.radar_rounded,
                    title: 'Live Quote Request (Bottom Drawer with Map)',
                    subtitle: 'Test bottom-to-top request drawer & send quote',
                    isPrimary: true,
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      bypassToIncomingQuotationDrawer(context);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _buildOptionTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Step 1: Provider Details (Registration)',
                    subtitle: 'Post-login onboarding entry screen',
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      bypassToProviderDetails(
                        context,
                        phoneNumber: currentPhoneNumber,
                      );
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _buildOptionTile(
                    icon: Icons.home_work_outlined,
                    title: 'Step 2: Living & Location Details',
                    subtitle: 'Address, city, province form',
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      bypassToLivingDetails(context);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _buildOptionTile(
                    icon: Icons.category_outlined,
                    title: 'Step 3: Service Assignment',
                    subtitle: 'Skills and category selection',
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      bypassToServiceAssignment(context);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _buildOptionTile(
                    icon: Icons.badge_outlined,
                    title: 'Step 4: Documents Verification',
                    subtitle: 'KYC & business verification form',
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      bypassToVerification(context);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _buildOptionTile(
                    icon: Icons.hourglass_top_rounded,
                    title: 'Step 5: Application Under Review',
                    subtitle: 'Final pending status screen',
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      bypassToUnderReview(context);
                    },
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      onTap: onTap,
      leading: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: isPrimary
              ? const Color(0xFFFFF3E0)
              : AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isPrimary ? const Color(0xFFE65100) : AppColors.primary,
          size: 20.r,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14.5.sp,
          fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
          color: isPrimary ? const Color(0xFFE65100) : AppColors.textHeadline,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey,
        size: 22,
      ),
    );
  }
}
