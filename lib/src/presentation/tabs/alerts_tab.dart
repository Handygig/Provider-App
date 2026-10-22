import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/domain/models/job_model.dart';
import 'package:provider_app/src/presentation/screens/jobs/job_details_screen.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';

class AlertsTab extends StatefulWidget {
  const AlertsTab({super.key});

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  String _selectedFilter = 'All';

  late List<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      {
        'id': 'ALT-101',
        'title': 'New Service Request Nearby',
        'category': 'Job Inquiries',
        'body':
            'Sarah Jenkins requested an Emergency Pipe Leak Repair (2.1 km away). Customer is looking for immediate assistance with a leaking main water valve in Kollupitiya.',
        'time': '5 mins ago',
        'fullTime': 'Today • 05:25 PM',
        'isUnread': true,
        'icon': Icons.near_me_rounded,
        'color': AppColors.primary,
        'jobId': 'JOB-1024',
        'customer': 'Sarah Jenkins',
        'service': 'Emergency Pipe Leak Repair',
        'address': 'No 18, Galle Road, Kollupitiya, Colombo 03',
        'amount': 'LKR 45.00 Est.',
        'actionType': 'job',
      },
      {
        'id': 'ALT-102',
        'title': 'Quotation Accepted by Client!',
        'category': 'Quotations',
        'body':
            'David Miller accepted your quote of LKR 135.00 for Commercial AC Service. The job has officially transitioned to "Ongoing". Please prepare tools and equipment for on-site visit.',
        'time': '1 hour ago',
        'fullTime': 'Today • 04:15 PM',
        'isUnread': true,
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF16A34A),
        'jobId': 'JOB-1025',
        'customer': 'David Miller',
        'service': 'Commercial AC Compressor Service',
        'address': 'Level 4, Orion City Park, Colombo 09',
        'amount': 'LKR 135.00 Approved',
        'actionType': 'job',
      },
      {
        'id': 'ALT-103',
        'title': 'Weekly Payout Deposited',
        'category': 'Finance & Wallet',
        'body':
            'Your weekly provider earnings of LKR 680.00 have been successfully transferred to your linked Commercial Bank account (•••• 4291). Funds should reflect within 1-2 hours.',
        'time': 'Yesterday',
        'fullTime': 'Yesterday • 10:15 AM',
        'isUnread': false,
        'icon': Icons.account_balance_wallet_rounded,
        'color': AppColors.primaryDark,
        'referenceId': 'TXN-8812',
        'amount': 'LKR 680.00 Payout',
        'bank': 'Commercial Bank •••• 4291',
        'actionType': 'wallet',
      },
      {
        'id': 'ALT-104',
        'title': 'New 5-Star Customer Review',
        'category': 'Ratings & Reviews',
        'body':
            '"Super fast response and fixed the tank overflow within 30 minutes! Very professional and polite contractor. Highly recommended." - Praveen J.',
        'time': '2 days ago',
        'fullTime': 'Sep 20, 2026 • 02:40 PM',
        'isUnread': false,
        'icon': Icons.star_rounded,
        'color': const Color(0xFFEAB308),
        'customer': 'Praveen Jayawardena',
        'rating': '5.0 ★★★★★',
        'service': 'Water Tank Overflow Repair',
        'actionType': 'review',
      },
      {
        'id': 'ALT-105',
        'title': 'Account Verification Active',
        'category': 'Security & Compliance',
        'body':
            'Your electrical contractor license has been successfully verified by the verification authority. Your verified badge is renewed and visible to all clients for 2026-2027.',
        'time': '4 days ago',
        'fullTime': 'Sep 18, 2026 • 11:30 AM',
        'isUnread': false,
        'icon': Icons.verified_user_rounded,
        'color': AppColors.primary,
        'referenceId': 'LIC-2026-EL781',
        'authority': 'National Contractors Board of Sri Lanka',
        'actionType': 'profile',
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'Unread') {
      return _notifications.where((n) => n['isUnread'] == true).toList();
    } else if (_selectedFilter == 'Jobs') {
      return _notifications.where((n) => n['actionType'] == 'job').toList();
    } else if (_selectedFilter == 'Finance') {
      return _notifications.where((n) => n['actionType'] == 'wallet').toList();
    }
    return _notifications;
  }

  int get _unreadCount =>
      _notifications.where((n) => n['isUnread'] == true).length;

  void _markAllAsRead() {
    HapticFeedback.lightImpact();
    setState(() {
      for (var item in _notifications) {
        item['isUnread'] = false;
      }
    });
    DynamicIslandToast.showSuccess(context, 'All notifications marked as read');
  }

  void _onNotificationTap(Map<String, dynamic> item) {
    HapticFeedback.mediumImpact();

    // Mark current tapped item as read
    if (item['isUnread'] == true) {
      setState(() {
        item['isUnread'] = false;
      });
    }

    _showMessageDetailsDrawer(item);
  }

  void _showMessageDetailsDrawer(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final Color itemColor = item['color'] as Color;
        final String actionType = item['actionType'] as String;

        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Top Drag Handle ─────────────────────────────────────────
              Center(
                child: Container(
                  width: 44.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E6D5),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              // ─── Header: Icon + Category + Close ─────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: itemColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: itemColor,
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F4EB),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                item['category'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '• ${item['time']}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          item['fullTime'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // ─── Title ───────────────────────────────────────────────────
              Text(
                item['title'] as String,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHeadline,
                  height: 1.25,
                ),
              ),

              SizedBox(height: 12.h),

              // ─── Full Message Body Box ───────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9F3),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFE4E8D7),
                    width: 1,
                  ),
                ),
                child: Text(
                  item['body'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textHeadline,
                    height: 1.45,
                  ),
                ),
              ),

              SizedBox(height: 14.h),

              // ─── Contextual Metadata Details ─────────────────────────────
              if (actionType == 'job') ...[
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: const Color(0xFFECEFE4),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDrawerDetailRow(
                        Icons.tag_rounded,
                        'Job Reference',
                        item['jobId'] as String,
                      ),
                      _buildDrawerDetailRow(
                        Icons.person_rounded,
                        'Customer',
                        item['customer'] as String,
                      ),
                      _buildDrawerDetailRow(
                        Icons.handyman_rounded,
                        'Service',
                        item['service'] as String,
                      ),
                      _buildDrawerDetailRow(
                        Icons.location_on_rounded,
                        'Location',
                        item['address'] as String,
                      ),
                      _buildDrawerDetailRow(
                        Icons.payments_rounded,
                        'Price / Budget',
                        item['amount'] as String,
                        isHighlighted: true,
                      ),
                    ],
                  ),
                ),
              ] else if (actionType == 'wallet') ...[
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: const Color(0xFFECEFE4),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDrawerDetailRow(
                        Icons.receipt_long_rounded,
                        'Transaction Ref',
                        item['referenceId'] as String,
                      ),
                      _buildDrawerDetailRow(
                        Icons.account_balance_rounded,
                        'Bank Account',
                        item['bank'] as String,
                      ),
                      _buildDrawerDetailRow(
                        Icons.check_circle_rounded,
                        'Transfer Status',
                        'Completed & Deposited',
                        isHighlighted: true,
                      ),
                      _buildDrawerDetailRow(
                        Icons.payments_rounded,
                        'Total Amount',
                        item['amount'] as String,
                        isHighlighted: true,
                      ),
                    ],
                  ),
                ),
              ] else if (actionType == 'review') ...[
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: const Color(0xFFECEFE4),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDrawerDetailRow(
                        Icons.person_rounded,
                        'Reviewer',
                        item['customer'] as String,
                      ),
                      _buildDrawerDetailRow(
                        Icons.star_rounded,
                        'Given Rating',
                        item['rating'] as String,
                        isHighlighted: true,
                      ),
                      _buildDrawerDetailRow(
                        Icons.handyman_rounded,
                        'Service Done',
                        item['service'] as String,
                      ),
                    ],
                  ),
                ),
              ] else if (actionType == 'profile') ...[
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: const Color(0xFFECEFE4),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDrawerDetailRow(
                        Icons.badge_rounded,
                        'License Number',
                        item['referenceId'] as String,
                      ),
                      _buildDrawerDetailRow(
                        Icons.verified_user_rounded,
                        'Issuing Authority',
                        item['authority'] as String,
                      ),
                      _buildDrawerDetailRow(
                        Icons.check_circle_rounded,
                        'Compliance',
                        'Active & Fully Certified',
                        isHighlighted: true,
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 20.h),

              // ─── Drawer Action Buttons ───────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(bottomSheetContext);

                        if (actionType == 'job') {
                          final sampleJob = JobModel(
                            id: item['jobId'] as String? ?? 'JOB-1024',
                            serviceTitle: item['service'] as String? ??
                                'Emergency Pipe Leak Repair',
                            category: 'Plumbing',
                            customerName:
                                item['customer'] as String? ?? 'Sarah Jenkins',
                            customerRating: 4.9,
                            customerReviewsCount: 32,
                            address: item['address'] as String? ??
                                'No 18, Galle Road, Kollupitiya',
                            distance: '2.1 km away',
                            requestedTime: 'Inspection Today • 05:30 PM',
                            description: item['body'] as String,
                            estimatedBudget: 45.00,
                            status: item['title'].toString().contains('Accepted')
                                ? JobCategory.toStart
                                : JobCategory.toQuote,
                            quotedAmount: item['title'].toString().contains('Accepted')
                                ? 135.00
                                : null,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JobDetailsScreen(job: sampleJob),
                            ),
                          );
                        } else if (actionType == 'wallet') {
                          DynamicIslandToast.showSuccess(
                            context,
                            'Payout #${item['referenceId']} confirmed in Wallet',
                          );
                        } else if (actionType == 'review') {
                          DynamicIslandToast.showSuccess(
                            context,
                            '5-Star review added to your public portfolio!',
                          );
                        } else {
                          DynamicIslandToast.showSuccess(
                            context,
                            'Credentials active and in good standing',
                          );
                        }
                      },
                      icon: Icon(
                        actionType == 'job'
                            ? Icons.assignment_turned_in_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 18.r,
                      ),
                      label: Text(
                        actionType == 'job'
                            ? 'Open Job Details'
                            : (actionType == 'wallet'
                                ? 'View in Wallet'
                                : 'Acknowledge'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(color: Color(0xFFDCE1D0)),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 13.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(bottomSheetContext);
                    },
                    child: Text(
                      'Dismiss',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15.r,
            color: isHighlighted ? const Color(0xFF16A34A) : AppColors.primary,
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w700,
                color: isHighlighted
                    ? const Color(0xFF16A34A)
                    : AppColors.textHeadline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredNotifications;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: AppColors.darkHeaderBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              'Provider Alerts',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 19.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            if (_unreadCount > 0) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4DE95),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$_unreadCount new',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark read',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD4DE95),
                ),
              ),
            ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // ─── Filter Pills Bar ───────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ['All', 'Unread', 'Jobs', 'Finance'].map((filter) {
                  final bool isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFF7F8F0),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFE2E6D5),
                        ),
                      ),
                      child: Text(
                        filter,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textHeadline,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ─── Notification List ──────────────────────────────────────────
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 54.r,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'No alerts found',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textHeadline,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'You are all caught up!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 120.h),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final bool isUnread = item['isUnread'] as bool;

                      return GestureDetector(
                        onTap: () => _onNotificationTap(item),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: isUnread
                                ? const Color(0xFFF7F8F0)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isUnread
                                  ? AppColors.primary.withValues(alpha: 0.35)
                                  : AppColors.borderUnselected,
                              width: isUnread ? 1.3 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isUnread ? 0.04 : 0.02,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40.r,
                                height: 40.r,
                                decoration: BoxDecoration(
                                  color: (item['color'] as Color)
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: item['color'] as Color,
                                  size: 20.r,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['title'] as String,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13.5.sp,
                                              fontWeight: isUnread
                                                  ? FontWeight.w800
                                                  : FontWeight.w700,
                                              color: AppColors.textHeadline,
                                            ),
                                          ),
                                        ),
                                        if (isUnread)
                                          Container(
                                            width: 8.r,
                                            height: 8.r,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      item['body'] as String,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5.sp,
                                        color: AppColors.textSecondary,
                                        height: 1.35,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item['time'] as String,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.sp,
                                            color: AppColors.textMuted,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'View details',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            SizedBox(width: 2.w),
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              size: 14.r,
                                              color: AppColors.primary,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
    );
  }
}
