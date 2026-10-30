import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/domain/entities/notifications/notification_entity.dart';
import 'package:provider_app/src/presentation/cubits/notifications/notification_cubit.dart';
import 'package:provider_app/src/presentation/cubits/notifications/notification_state.dart';
import 'package:provider_app/src/presentation/screens/jobs/jobs_screen.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';

class AlertsTab extends StatefulWidget {
  const AlertsTab({super.key});

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  static const List<String> _filterOptions = [
    'All',
    'Unread',
    'Jobs',
    'Finance',
  ];

  @override
  void initState() {
    super.initState();
    // Load notifications on enter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationCubit>().loadNotifications(showLoading: false);
      }
    });
  }

  void _markAllAsRead() {
    HapticFeedback.lightImpact();
    context.read<NotificationCubit>().markAllAsRead();
    DynamicIslandToast.showSuccess(context, 'All notifications marked as read');
  }

  void _onNotificationTap(NotificationEntity item) {
    HapticFeedback.mediumImpact();

    if (item.isUnread) {
      context.read<NotificationCubit>().markAsRead(item.id);
    }

    _showMessageDetailsDrawer(item);
  }

  void _showMessageDetailsDrawer(NotificationEntity item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final Color itemColor = item.color;
        final String actionType = item.actionType;

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
                      item.icon,
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
                                item.category,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '• ${item.timeAgo}',
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
                          item.fullTime,
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
                item.title,
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
                  item.message,
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
                    if (item.relatedId != null)
                      _buildDrawerDetailRow(
                        Icons.tag_rounded,
                        'Reference ID',
                        '#${item.relatedId}',
                      ),
                    _buildDrawerDetailRow(
                      Icons.category_rounded,
                      'Category',
                      item.category,
                    ),
                    _buildDrawerDetailRow(
                      Icons.info_outline_rounded,
                      'Type',
                      item.type.toUpperCase(),
                    ),
                    _buildDrawerDetailRow(
                      Icons.schedule_rounded,
                      'Received',
                      item.timeAgo,
                      isHighlighted: item.isUnread,
                    ),
                  ],
                ),
              ),

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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const JobsScreen(),
                            ),
                          );
                        } else if (actionType == 'wallet') {
                          DynamicIslandToast.showSuccess(
                            context,
                            'Confirmed in Wallet',
                          );
                        } else if (actionType == 'review') {
                          DynamicIslandToast.showSuccess(
                            context,
                            'Review recorded in provider profile',
                          );
                        } else {
                          DynamicIslandToast.showSuccess(
                            context,
                            'Alert acknowledged',
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
                            ? 'View Jobs'
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
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 13.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(bottomSheetContext);
                      context.read<NotificationCubit>().deleteNotification(item.id);
                      DynamicIslandToast.showSuccess(
                        context,
                        'Alert dismissed',
                      );
                    },
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 16.r,
                      color: const Color(0xFFDC2626),
                    ),
                    label: Text(
                      'Delete',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFDC2626),
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
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final List<NotificationEntity> notifications;
        final String activeFilter;
        final int unreadCount;
        final bool isLoading = state is NotificationLoading;
        final String? errorMessage =
            state is NotificationError ? state.message : null;

        if (state is NotificationLoaded) {
          notifications = state.notifications;
          activeFilter = state.activeFilter;
          unreadCount = state.unreadCount;
        } else {
          notifications = context.read<NotificationCubit>().notifications;
          activeFilter = 'All';
          unreadCount = context.read<NotificationCubit>().unreadCount;
        }

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
                if (unreadCount > 0) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4DE95),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '$unreadCount new',
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
              if (unreadCount > 0)
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
                    children: _filterOptions.map((filter) {
                      final bool isSelected = activeFilter.toLowerCase() ==
                          filter.toLowerCase();
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.read<NotificationCubit>().setFilter(filter);
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
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
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

              // ─── Notification List Content ──────────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => context
                      .read<NotificationCubit>()
                      .loadNotifications(refresh: true),
                  child: _buildListContent(
                    isLoading: isLoading,
                    errorMessage: errorMessage,
                    notifications: notifications,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListContent({
    required bool isLoading,
    required String? errorMessage,
    required List<NotificationEntity> notifications,
  }) {
    if (isLoading && notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 12.h),
            Text(
              'Loading notifications...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null && notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 50.r,
                color: AppColors.textMuted,
              ),
              SizedBox(height: 12.h),
              Text(
                'Could not load alerts',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeadline,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  context.read<NotificationCubit>().loadNotifications();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120.h),
          Center(
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
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 120.h),
      itemCount: notifications.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final item = notifications[index];
        final bool isUnread = item.isUnread;

        return Dismissible(
          key: Key('notif_${item.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.w),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
            ),
          ),
          onDismissed: (_) {
            context.read<NotificationCubit>().deleteNotification(item.id);
            DynamicIslandToast.showSuccess(context, 'Alert dismissed');
          },
          child: GestureDetector(
            onTap: () => _onNotificationTap(item),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: isUnread ? const Color(0xFFF7F8F0) : Colors.white,
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
                      color: item.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
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
                          item.message,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.timeAgo,
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
          ),
        );
      },
    );
  }
}
