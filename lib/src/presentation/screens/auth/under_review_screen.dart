import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_colors.dart';

class UnderReviewScreen extends StatelessWidget {
  final String firstName;

  const UnderReviewScreen({
    super.key,
    required this.firstName,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Center Icon / Graphic Illustration
                Container(
                  width: 120.r,
                  height: 120.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.primary,
                        size: 64.r,
                      ),
                      Positioned(
                        bottom: 12.h,
                        right: 12.w,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.hourglass_empty_rounded,
                            color: Colors.amber.shade700,
                            size: 20.r,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                // Title
                Text(
                  'Application Under Review',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHeadline,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 14.h),

                // Subtitle / Review message
                Text(
                  'Thank you, $firstName! Your application details have been received successfully. Your account will be activated within 24 hours once our verification process is complete.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),

                // Bullet points of review steps
                Container(
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: AppColors.cardUnselectedBg,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.borderUnselected,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildStepRow(
                        icon: Icons.check_circle_rounded,
                        color: AppColors.primary,
                        title: 'Profile Details Received',
                        desc: 'Form data has been recorded',
                      ),
                      Divider(height: 24.h, color: AppColors.borderUnselected),
                      _buildStepRow(
                        icon: Icons.check_circle_rounded,
                        color: AppColors.primary,
                        title: 'Documents Uploaded',
                        desc: 'KYC/KYB credentials received',
                      ),
                      Divider(height: 24.h, color: AppColors.borderUnselected),
                      _buildStepRow(
                        icon: Icons.hourglass_top_rounded,
                        color: Colors.amber.shade700,
                        title: 'Verification Pending',
                        desc: 'Expected completion within 24h',
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // Close / Got It Button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBackground,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                    ),
                    child: Text(
                      'Got It',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeadline,
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
