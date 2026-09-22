import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_colors.dart';

class RadarTab extends StatelessWidget {
  final VoidCallback? onBackToHome;

  const RadarTab({super.key, this.onBackToHome});

  @override
  Widget build(BuildContext context) {
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
          if (onBackToHome != null)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: onBackToHome,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 120.h),
        child: Column(
          children: [
            // Animated Pulsing Radar Graphic
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primaryDark, Color(0xFF282B1A)],
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
                        width: 130.r,
                        height: 130.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accentLime.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                      ),
                      Container(
                        width: 90.r,
                        height: 90.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accentLime.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                      ),
                      Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: BoxDecoration(
                          color: AppColors.accentLime,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentLime.withValues(alpha: 0.6),
                              blurRadius: 18,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.radar_rounded,
                          color: AppColors.primaryDark,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Scanning 10 km Radius',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Broadcasting your active availability to nearby clients seeking Plumbing, AC, and Electrical services.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5.sp,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Job Opportunities',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHeadline,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'HIGH DEMAND',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            _buildOpportunityCard(
              title: 'Emergency Bathroom Water Pipe Leak',
              customer: 'Chamari Atapattu • Colombo 03',
              distance: '1.4 km',
              estPay: '\$55 - \$80',
              urgency: 'Needs arrival in 30 mins',
            ),
            SizedBox(height: 10.h),
            _buildOpportunityCard(
              title: 'AC Indoor Unit Dripping Water',
              customer: 'Sanjaya Silva • Colombo 04',
              distance: '2.8 km',
              estPay: '\$45 - \$65',
              urgency: 'Scheduled for this evening',
            ),
            SizedBox(height: 10.h),
            _buildOpportunityCard(
              title: 'Main Distribution Box Breaker Replacement',
              customer: 'Niluka Perera • Rajagiriya',
              distance: '3.6 km',
              estPay: '\$70 - \$110',
              urgency: 'Flexible today',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunityCard({
    required String title,
    required String customer,
    required String distance,
    required String estPay,
    required String urgency,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  fontSize: 18.sp,
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
                  distance,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeadline,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            customer,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  size: 14.r, color: const Color(0xFFE65100)),
              SizedBox(width: 4.w),
              Text(
                urgency,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE65100),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
