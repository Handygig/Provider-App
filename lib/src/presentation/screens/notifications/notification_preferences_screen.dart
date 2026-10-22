import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/data/services/notification_preferences_service.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final NotificationPreferencesService _service =
      NotificationPreferencesService.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final allEnabled = _service.allNotificationsEnabled;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF7F8F4),
            body: Column(
              children: [
                // 1. Top Custom App Bar
                _buildTopAppBar(allEnabled),

                // 2. Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 90.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Master Hero Toggle Card
                        _buildMasterHeroCard(allEnabled),

                        SizedBox(height: 18.h),

                        // Section 1: Push Notifications (Client & Job Alerts)
                        _buildSectionHeader(
                          title: 'Job & Client Alerts (Push)',
                          subtitle: 'Real-time notifications sent to your device',
                          icon: Icons.notifications_active_rounded,
                        ),
                        SizedBox(height: 10.h),
                        _buildContainer(
                          children: [
                            _buildToggleTile(
                              title: 'New Job Quotation Requests',
                              subtitle:
                                  'Immediate alert when a nearby client needs service',
                              value: _service.newJobRequests && allEnabled,
                              enabled: allEnabled,
                              onChanged: _service.toggleNewJobRequests,
                              isFirst: true,
                            ),
                            _buildToggleTile(
                              title: 'Customer Messages & Chat',
                              subtitle:
                                  'Direct messages, job inquiries & photo attachments',
                              value: _service.clientMessages && allEnabled,
                              enabled: allEnabled,
                              onChanged: _service.toggleClientMessages,
                            ),
                            _buildToggleTile(
                              title: 'Schedule & Job Reminders',
                              subtitle:
                                  'Alerts 1 hour & 15 minutes before confirmed jobs',
                              value:
                                  _service.jobScheduleReminders && allEnabled,
                              enabled: allEnabled,
                              onChanged: _service.toggleJobScheduleReminders,
                            ),
                            _buildToggleTile(
                              title: 'Payment & Payout Alerts',
                              subtitle:
                                  'When client pays or earnings are deposited to your bank',
                              value:
                                  _service.payoutAndPaymentAlerts && allEnabled,
                              enabled: allEnabled,
                              onChanged: _service.togglePayoutAndPaymentAlerts,
                            ),
                            _buildToggleTile(
                              title: 'Verification & Account Security',
                              subtitle:
                                  'Certificate approvals, login alerts and updates',
                              value:
                                  _service.systemSecurityAlerts && allEnabled,
                              enabled: allEnabled,
                              onChanged: _service.toggleSystemSecurityAlerts,
                              isLast: true,
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),

                        // Section 2: Sound & Alert Behavior
                        _buildSectionHeader(
                          title: 'Sound & Alert Behavior',
                          subtitle: 'Make sure you hear incoming job requests',
                          icon: Icons.volume_up_rounded,
                        ),
                        SizedBox(height: 10.h),
                        _buildContainer(
                          children: [
                            _buildToggleTile(
                              title: 'Loud Alarm for New Jobs',
                              subtitle:
                                  'Overrides silent mode to ring loudly when a new request arrives',
                              value: _service.loudJobAlarmMode && allEnabled,
                              enabled: allEnabled,
                              badgeText: 'RECOMMENDED',
                              onChanged: _service.toggleLoudJobAlarmMode,
                              isFirst: true,
                            ),
                            _buildToggleTile(
                              title: 'In-App Haptic Vibrations',
                              subtitle: 'Gentle tactile feedback when tapping',
                              value: _service.hapticFeedbackEnabled,
                              enabled: allEnabled,
                              onChanged: _service.toggleHapticFeedback,
                            ),
                            _buildNavigationTile(
                              title: 'Job Alert Ringtone',
                              subtitle: _service.alertRingtone,
                              icon: Icons.music_note_rounded,
                              onTap: allEnabled ? _showRingtonePicker : null,
                              isLast: true,
                            ),
                          ],
                        ),



                        SizedBox(height: 20.h),

                        // Reset to Defaults Button
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _service.resetToDefaults();
                              DynamicIslandToast.showSuccess(
                                context,
                                'Notification preferences reset to default',
                              );
                            },
                            icon: const Icon(
                              Icons.restore_rounded,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                            label: Text(
                              'Reset All Settings to Default',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Sticky Bottom Save Bar
                _buildBottomSaveBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 1. TOP APP BAR
  // ---------------------------------------------------------------------------
  Widget _buildTopAppBar(bool allEnabled) {
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
                      'Notifications & Alerts',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      allEnabled
                          ? 'Instant job alerts & SMS backup active'
                          : 'All notifications currently paused',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: allEnabled
                      ? const Color(0xFFD4DE95)
                      : const Color(0xFFEF4444).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  allEnabled ? 'ACTIVE' : 'MUTED',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    color: allEnabled
                        ? AppColors.primaryDark
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. MASTER HERO CARD
  // ---------------------------------------------------------------------------
  Widget _buildMasterHeroCard(bool allEnabled) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: allEnabled
              ? [const Color(0xFF38431E), const Color(0xFF4F5C2B)]
              : [const Color(0xFF475569), const Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: (allEnabled
                    ? const Color(0xFF38431E)
                    : const Color(0xFF334155))
                .withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              allEnabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: allEnabled
                  ? const Color(0xFFD4DE95)
                  : Colors.white70,
              size: 24.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allEnabled
                      ? 'All Alerts Active'
                      : 'All Notifications Paused',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  allEnabled
                      ? 'You will receive immediate alerts for new requests'
                      : 'You will not receive any sounds, banners, or SMS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    color: Colors.white70,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: allEnabled,
            activeTrackColor: const Color(0xFFD4DE95),
            activeThumbColor: AppColors.primaryDark,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              _service.toggleAllNotifications(val);
              DynamicIslandToast.showSuccess(
                context,
                val ? 'All notifications resumed' : 'Notifications paused',
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. SECTION HEADERS & CONTAINERS
  // ---------------------------------------------------------------------------
  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: const BoxDecoration(
            color: Color(0xFFF3F6EB),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHeadline,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE5E9DC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
    String? badgeText,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 12.w, 12.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: enabled
                                  ? AppColors.textHeadline
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                        if (badgeText != null) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              badgeText,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                activeTrackColor: AppColors.primary,
                onChanged: enabled
                    ? (val) {
                        HapticFeedback.lightImpact();
                        onChanged(val);
                      }
                    : null,
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Color(0xFFF1F5E9),
          ),
      ],
    );
  }

  Widget _buildNavigationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 14.h),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textHeadline,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
          if (!isLast)
            const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Color(0xFFF1F5E9),
            ),
        ],
      ),
    );
  }


  // ---------------------------------------------------------------------------
  // 5. RINGTONE PICKER MODAL
  // ---------------------------------------------------------------------------
  void _showRingtonePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38.w,
                    height: 4.5.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCDFD8),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'Select Job Alert Ringtone',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'This sound will play when clients request instant quotations',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 12.h),
                ...NotificationPreferencesService.availableRingtones.map((tone) {
                  final isSelected = _service.alertRingtone == tone;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isSelected
                          ? Icons.play_circle_fill_rounded
                          : Icons.play_circle_outline_rounded,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    title: Text(
                      tone,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5.sp,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textHeadline,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                          )
                        : null,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _service.setAlertRingtone(tone);
                      Navigator.pop(ctx);
                      DynamicIslandToast.showSuccess(
                        context,
                        'Alert ringtone set to $tone',
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 6. STICKY BOTTOM SAVE BAR
  // ---------------------------------------------------------------------------
  Widget _buildBottomSaveBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE5E9DC))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            DynamicIslandToast.showSuccess(
              context,
              'Notification preferences saved successfully!',
            );
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 20,
          ),
          label: Text(
            'Save Preferences',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      ),
    );
  }
}
