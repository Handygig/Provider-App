import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/domain/models/job_model.dart';
import 'package:provider_app/src/data/services/working_hours_coverage_service.dart';
import 'package:provider_app/src/presentation/screens/jobs/job_details_screen.dart';
import 'package:provider_app/src/presentation/screens/jobs/jobs_screen.dart';
import 'package:provider_app/src/presentation/tabs/alerts_tab.dart';
import 'package:provider_app/src/presentation/tabs/profile_tab.dart';
import 'package:provider_app/src/presentation/tabs/wallet_tab.dart';
import 'package:provider_app/src/data/services/verification_service.dart';
import 'package:provider_app/src/presentation/screens/verification/license_verification_screen.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';

class HomeScreen extends StatefulWidget {
  final int initialTabIndex;

  const HomeScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late int _currentIndex;
  bool _isOnline = true;
  late PageController _projectPageController;
  int _selectedProjectIndex = 0;
  GoogleMapController? _mapController;

  // Top Drawer Collapsible Animation & Measurement
  late AnimationController _topDrawerController;
  late Animation<double> _drawerAnimation;
  double _headerMeasuredHeight = 295.0;
  final GlobalKey _headerKey = GlobalKey();

  final List<Map<String, dynamic>> _projectsToStart = [
    {
      'id': 'JOB-1024',
      'serviceTitle': 'Emergency Pipe Leak Repair',
      'category': 'Plumbing',
      'customerName': 'Sarah Jenkins',
      'customerPhone': '+94 77 982 1450',
      'customerRating': 4.9,
      'address': 'No 18, Galle Road, Kollupitiya, Colombo 03',
      'distance': '2.1 km away',
      'requestedTime': 'Ready to Start • Immediate',
      'description':
          'Main pipeline burst under kitchen sink. Water flooding kitchen floor, requires pipe joint fix and stop-cock replacement.',
      'price': 65.00,
      'lat': 6.9147,
      'lng': 79.8528,
      'urgencyBadge': 'Ready to Start',
    },
    {
      'id': 'JOB-1025',
      'serviceTitle': 'Split AC Compressor Gas Leak',
      'category': 'AC Repair',
      'customerName': 'David Miller',
      'customerPhone': '+94 71 432 8900',
      'customerRating': 4.8,
      'address': '12/4 Ward Place, Colombo 07',
      'distance': '3.4 km away',
      'requestedTime': 'Scheduled Today • 3:30 PM',
      'description':
          'Inverter AC unit outdoor fan vibrating violently. Needs nitrogen leak test and R32 refrigerant gas top-up.',
      'price': 85.00,
      'lat': 6.9175,
      'lng': 79.8710,
      'urgencyBadge': 'Scheduled Today',
    },
    {
      'id': 'JOB-1026',
      'serviceTitle': 'Main Switchboard Breaker Trip Fix',
      'category': 'Electrical',
      'customerName': 'Priya Sharma',
      'customerPhone': '+94 76 890 1234',
      'customerRating': 5.0,
      'address': 'Duplication Road, Bambalapitiya, Colombo 04',
      'distance': '1.8 km away',
      'requestedTime': 'Scheduled Today • 5:00 PM',
      'description':
          'Circuit breaker trips when high-power appliances run. Isolate faulty kitchen wiring and replace 32A MCB.',
      'price': 55.00,
      'lat': 6.8920,
      'lng': 79.8580,
      'urgencyBadge': 'Upcoming Today',
    },
    {
      'id': 'JOB-1027',
      'serviceTitle': 'Water Booster Pump Motor Servicing',
      'category': 'Plumbing',
      'customerName': 'Dr. Mohan Lal',
      'customerPhone': '+94 77 123 4567',
      'customerRating': 5.0,
      'address': 'Rosmead Place, Colombo 07',
      'distance': '2.8 km away',
      'requestedTime': 'Tomorrow • 9:00 AM',
      'description':
          'Pressure sensor replacement and capacitor swap on automatic booster pump.',
      'price': 90.00,
      'lat': 6.9160,
      'lng': 79.8740,
      'urgencyBadge': 'Tomorrow',
    },
  ];

  int _simulatedRequestIndex = 0;

  final List<Map<String, dynamic>> _simulationTemplates = [
    {
      'service': 'Emergency Pipe Leak Repair',
      'category': 'Plumbing',
      'customer': 'Sarah Jenkins',
      'rating': 4.9,
      'distance': '2.1 km away',
      'location': 'No 18, Galle Road, Kollupitiya, Colombo 03',
      'price': 65.00,
      'urgency': 'Immediate',
      'time': 'Needs help now',
      'description':
          'Urgent kitchen main pipeline burst under sink. Water flooding kitchen floor, requires quick inspection & price quotation.',
    },
    {
      'service': 'Split AC Outdoor Compressor Gas Leak',
      'category': 'AC Repair',
      'customer': 'David Miller',
      'rating': 4.8,
      'distance': '3.4 km away',
      'location': '12/4 Ward Place, Colombo 07',
      'price': 85.00,
      'urgency': 'Scheduled',
      'time': 'Within 2 hours',
      'description':
          'Inverter AC unit outdoor fan vibrating violently and low cooling efficiency. Need cost estimate for nitrogen leak test and gas refill.',
    },
    {
      'service': 'Main Switchboard Breaker Trip & Sparks',
      'category': 'Electrical',
      'customer': 'Priya Sharma',
      'rating': 5.0,
      'distance': '1.8 km away',
      'location': 'Duplication Road, Bambalapitiya, Colombo 04',
      'price': 55.00,
      'urgency': 'Urgent',
      'time': 'Immediate Assistance',
      'description':
          'Main 63A RCCB trips repeatedly with burning smell from distribution board. Urgent diagnostic required.',
    },
    {
      'service': 'Water Pressure Booster Pump Inspection',
      'category': 'Plumbing',
      'customer': 'Nimal Perera',
      'rating': 4.9,
      'distance': '4.1 km away',
      'location': '78 Nawala Road, Rajagiriya',
      'price': 90.00,
      'urgency': 'Today',
      'time': 'Today, 4:00 PM',
      'description':
          'Rooftop booster pump not starting automatically when taps open. Motor hums loudly.',
    },
  ];

  void _simulateIncomingJobRequest() {
    HapticFeedback.heavyImpact();
    final template =
        _simulationTemplates[_simulatedRequestIndex % _simulationTemplates.length];
    _simulatedRequestIndex++;

    final newId = 'JOB-${1000 + DateTime.now().millisecondsSinceEpoch % 9000}';
    final offset = (_simulatedRequestIndex % 5) * 0.003;
    final newProject = {
      'id': newId,
      'serviceTitle': template['service'] as String,
      'category': template['category'] as String,
      'customerName': template['customer'] as String,
      'customerPhone': '+94 77 982 1450',
      'customerRating': (template['rating'] as num).toDouble(),
      'address': template['location'] as String,
      'distance': template['distance'] as String,
      'requestedTime': template['time'] as String,
      'description': template['description'] as String,
      'price': (template['price'] as num).toDouble(),
      'lat': 6.9100 + offset,
      'lng': 79.8600 + offset,
      'urgencyBadge': 'New Request',
    };

    setState(() {
      _projectsToStart.insert(0, newProject);
      _selectedProjectIndex = 0;
    });

    DynamicIslandToast.showSuccess(
      context,
      '⚡ New project on map: ${template['service']}',
    );

    if (_projectPageController.hasClients) {
      _projectPageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    _panToProject(0);
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    _projectPageController = PageController(viewportFraction: 0.92);
    _topDrawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: 1.0, // Open by default
    );
    _drawerAnimation = CurvedAnimation(
      parent: _topDrawerController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _topDrawerController.dispose();
    _projectPageController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _toggleTopDrawer() {
    HapticFeedback.lightImpact();
    if (_topDrawerController.isCompleted || _topDrawerController.value > 0.5) {
      _topDrawerController.reverse();
    } else {
      _topDrawerController.forward();
    }
  }

  void _expandTopDrawer() {
    if (_topDrawerController.value < 1.0) {
      HapticFeedback.lightImpact();
      _topDrawerController.forward();
    }
  }

  void _onDrawerVerticalDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    final totalHeight =
        _headerMeasuredHeight > 0 ? _headerMeasuredHeight : 295.0;
    _topDrawerController.value =
        (_topDrawerController.value + (delta / totalHeight)).clamp(0.0, 1.0);
  }

  void _onDrawerVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -300) {
      // Swiped up vigorously -> collapse drawer
      _topDrawerController.reverse();
    } else if (velocity > 300) {
      // Swiped down vigorously -> open drawer
      _topDrawerController.forward();
    } else {
      // Settle based on threshold
      if (_topDrawerController.value < 0.6) {
        _topDrawerController.reverse();
      } else {
        _topDrawerController.forward();
      }
    }
  }

  void _onTabSelected(int index) {
    if ((index == 1 || index == 2) && !VerificationService.instance.isApproved) {
      _showVerificationLockedModal(
        context,
        pageName: index == 1 ? 'Jobs' : 'Wallet',
      );
      return;
    }

    if (_currentIndex != index) {
      HapticFeedback.mediumImpact();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showVerificationLockedModal(
    BuildContext context, {
    required String pageName,
  }) {
    HapticFeedback.heavyImpact();
    final status = VerificationService.instance.status;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
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
          padding: EdgeInsets.fromLTRB(22.w, 14.h, 22.w, 34.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38.w,
                height: 4.5.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E4DE),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 22.h),
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFDE68A), width: 2),
                ),
                child: Center(
                  child: Icon(
                    Icons.lock_rounded,
                    size: 30.r,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '$pageName Locked',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHeadline,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                status == VerificationStatus.pending
                    ? 'Your identity documents are currently under admin review. Once an administrator approves your account, you will have full access to $pageName.'
                    : 'To access $pageName, you must upload your National ID and credentials (Business Registration is optional) for admin review and approval.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5.sp,
                  height: 1.5,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: status.backgroundColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: status.color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      status == VerificationStatus.pending
                          ? Icons.schedule_rounded
                          : Icons.error_outline_rounded,
                      size: 16.r,
                      color: status.color,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Status: ${status.title}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: status.color,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LicenseVerificationScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified_user_rounded,
                      color: Colors.white, size: 20),
                  label: Text(
                    status == VerificationStatus.pending
                        ? 'Check Verification Details'
                        : 'Upload Documents Now',
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
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                height: 46.h,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => _currentIndex = 0);
                  },
                  icon: const Icon(Icons.home_rounded,
                      color: AppColors.primary, size: 18),
                  label: Text(
                    'Return to Home Page',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
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

  void _toggleOnlineStatus(bool value) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isOnline = value;
    });

    DynamicIslandToast.showSuccess(
      context,
      _isOnline ? 'You are Online & Ready' : 'You are now Offline',
    );
  }

  void _panToProject(int index) {
    if (index >= 0 && index < _projectsToStart.length) {
      final project = _projectsToStart[index];
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              project['lat'] as double,
              project['lng'] as double,
            ),
            zoom: 14.5,
          ),
        ),
      );
    }
  }

  void _onProjectSelected(int index) {
    setState(() {
      _selectedProjectIndex = index;
    });
    if (_projectPageController.hasClients) {
      _projectPageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
    _panToProject(index);
  }

  void _recenterToCurrentProject() {
    _panToProject(_selectedProjectIndex);
  }

  void _startProject(Map<String, dynamic> project) {
    if (!VerificationService.instance.isApproved) {
      _showVerificationLockedModal(
        context,
        pageName: 'Starting Projects',
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final job = JobModel(
      id: project['id'] as String,
      serviceTitle: project['serviceTitle'] as String,
      category: project['category'] as String,
      customerName: project['customerName'] as String,
      customerPhone: project['customerPhone'] as String,
      customerRating: (project['customerRating'] as num).toDouble(),
      customerReviewsCount: 28,
      address: project['address'] as String,
      distance: project['distance'] as String,
      requestedTime: project['requestedTime'] as String,
      description: project['description'] as String,
      estimatedBudget: (project['price'] as num).toDouble(),
      quotedAmount: (project['price'] as num).toDouble(),
      status: JobCategory.toStart,
    );

    DynamicIslandToast.showSuccess(
      context,
      '🚀 Starting project: ${project['serviceTitle']}',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailsScreen(job: job),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return const Color(0xFF0284C7);
      case 'ac repair':
      case 'hvac':
        return AppColors.primary;
      case 'electrical':
        return const Color(0xFFD97706);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: VerificationService.instance,
      builder: (context, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF7F8F3),
            body: Stack(
              children: [
                // Active Tab View (Home, Jobs, Wallet, Alerts, Profile)
                IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildHomeTab(),
                    const JobsScreen(),
                    const WalletTab(),
                    const AlertsTab(),
                    const ProfileTab(),
                  ],
                ),

                // Floating Light Mode Custom Curvature Bottom Navigation Bar (Customer-App parity)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildCustomBottomNavigationBar(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeTab() {
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final collapsedOffset = safeAreaTop + 54.h;
    final expandedOffset = _headerMeasuredHeight + 12.h;

    return AnimatedBuilder(
      animation: _drawerAnimation,
      builder: (context, _) {
        final animValue = _drawerAnimation.value;
        final currentMapTopOffset =
            collapsedOffset + (expandedOffset - collapsedOffset) * animValue;
        final drawerTop = -(_headerMeasuredHeight * (1.0 - animValue));

        return Stack(
          children: [
            // 1. Interactive Google Map showing Projects to be Started (Full Screen)
            Positioned.fill(
              child: _buildProjectsMapView(
                topOverlayOffset: currentMapTopOffset,
              ),
            ),

            // 2. Mini Floating Status Trigger Pill (Fades in when drawer is collapsed)
            if (animValue < 0.95)
              Positioned(
                top: safeAreaTop + 8.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Opacity(
                    opacity: (1.0 - (animValue / 0.95)).clamp(0.0, 1.0),
                    child: _buildMiniDrawerTrigger(),
                  ),
                ),
              ),

            // 3. Collapsible Top Drawer Header (Dark green container with online toggle and earnings)
            Positioned(
              top: drawerTop,
              left: 0,
              right: 0,
              child: _buildTopHeader(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMiniDrawerTrigger() {
    return GestureDetector(
      onTap: _expandTopDrawer,
      onVerticalDragUpdate: _onDrawerVerticalDragUpdate,
      onVerticalDragEnd: _onDrawerVerticalDragEnd,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: AppColors.darkHeaderBg.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini Avatar
            Container(
              width: 26.r,
              height: 26.r,
              decoration: BoxDecoration(
                color: AppColors.sage,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  'AP',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Online status dot
            Container(
              width: 7.r,
              height: 7.r,
              decoration: BoxDecoration(
                color: _isOnline
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFF9CA3AF),
                shape: BoxShape.circle,
                boxShadow: _isOnline
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4ADE80).withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              _isOnline ? 'Online' : 'Offline',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              width: 1,
              height: 12.h,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            SizedBox(width: 10.w),
            Text(
              'LKR 180.00',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFD4DE95),
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white70,
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStatusBanner() {
    final service = VerificationService.instance;
    final status = service.status;

    // Hide container after user is verified
    if (status == VerificationStatus.approved) {
      return const SizedBox.shrink();
    }

    Color bg;
    Color border;
    Color titleColor;
    IconData icon;
    String badgeText;
    String heading;
    String description;
    String actionText;

    switch (status) {
      case VerificationStatus.notSubmitted:
        bg = const Color(0xFFFEF3C7);
        border = const Color(0xFFFDE68A);
        titleColor = const Color(0xFF92400E);
        icon = Icons.warning_amber_rounded;
        badgeText = 'ACTION REQUIRED';
        heading = 'Account Verification Incomplete';
        description =
            'Upload your National ID and credentials (BR optional) to unlock all pages & start taking jobs.';
        actionText = 'Upload Documents Now';
        break;
      case VerificationStatus.pending:
        bg = const Color(0xFFEFF6FF);
        border = const Color(0xFFBFDBFE);
        titleColor = const Color(0xFF1E40AF);
        icon = Icons.hourglass_top_rounded;
        badgeText = 'UNDER ADMIN REVIEW';
        heading = 'Verification in Progress';
        description =
            'Your identity documents were submitted on ${service.formattedSubmittedDate}. Full platform access will unlock as soon as admin approves.';
        actionText = 'View Submission & Status';
        break;
      case VerificationStatus.rejected:
        bg = const Color(0xFFFEF2F2);
        border = const Color(0xFFFECACA);
        titleColor = const Color(0xFF991B1B);
        icon = Icons.error_outline_rounded;
        badgeText = 'RESUBMISSION NEEDED';
        heading = 'Verification Needs Attention';
        description = (service.adminFeedback != null &&
                service.adminFeedback!.isNotEmpty)
            ? 'Admin note: "${service.adminFeedback}"'
            : 'Please review and resubmit your documents.';
        actionText = 'Update & Resubmit Documents';
        break;
      case VerificationStatus.approved:
        bg = const Color(0xFFF0FDF4);
        border = const Color(0xFFBBF7D0);
        titleColor = const Color(0xFF166534);
        icon = Icons.verified_user_rounded;
        badgeText = 'VERIFIED PARTNER';
        heading = 'Identity & License Verified';
        description =
            'Your partner documents are approved by admin. Full platform access is unlocked.';
        actionText = 'View Verified Credentials';
        break;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LicenseVerificationScreen(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: titleColor, size: 18.r),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: titleColor,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13.r,
                  color: titleColor.withValues(alpha: 0.6),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              heading,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: titleColor.withValues(alpha: 0.85),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Text(
                  actionText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.arrow_right_alt_rounded, size: 16.r, color: titleColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final rb = _headerKey.currentContext?.findRenderObject() as RenderBox?;
      if (rb != null && rb.hasSize) {
        if ((rb.size.height - _headerMeasuredHeight).abs() > 1.5) {
          setState(() {
            _headerMeasuredHeight = rb.size.height;
          });
        }
      }
    });

    return GestureDetector(
      key: _headerKey,
      behavior: HitTestBehavior.translucent,
      onVerticalDragUpdate: _onDrawerVerticalDragUpdate,
      onVerticalDragEnd: _onDrawerVerticalDragEnd,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkHeaderBg,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28.r),
            bottomRight: Radius.circular(28.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Top Bar with Avatar, Name, Pro Badge
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: AppColors.sage,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'AP',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Greeting & Pro Badge
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
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4DE95),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'PRO',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            // Verification Status Pill in Top Header
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
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: VerificationService.instance.isApproved
                                      ? AppColors.accentLime
                                      : VerificationService.instance.status.backgroundColor,
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(
                                    color: VerificationService.instance.status.color
                                        .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      VerificationService.instance.isApproved
                                          ? Icons.check_circle_rounded
                                          : (VerificationService.instance.status ==
                                                  VerificationStatus.pending
                                              ? Icons.schedule_rounded
                                              : Icons.error_outline_rounded),
                                      size: 10.r,
                                      color: VerificationService.instance.isApproved
                                          ? AppColors.primaryDark
                                          : VerificationService.instance.status.color,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      VerificationService.instance.status.badgeText,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: VerificationService.instance.isApproved
                                            ? AppColors.primaryDark
                                            : VerificationService.instance.status.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Handyman & Electrical Specialist',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dev Simulate Request Button
                  GestureDetector(
                    onTap: _simulateIncomingJobRequest,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4DE95),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFD4DE95).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            color: AppColors.primaryDark,
                            size: 15.r,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Simulate',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // Bell Notification Icon
                  GestureDetector(
                    onTap: () => _onTabSelected(2),
                    child: Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Online / Offline Status Switch Banner
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10.r,
                      height: 10.r,
                      decoration: BoxDecoration(
                        color: _isOnline
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFF9CA3AF),
                        shape: BoxShape.circle,
                        boxShadow: _isOnline
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF4ADE80)
                                      .withValues(alpha: 0.6),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOnline ? 'Online & Available' : 'Offline',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _isOnline
                                ? 'Receiving real-time job requests'
                                : 'Toggle on to accept jobs',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 0.85,
                      child: CupertinoSwitch(
                        value: _isOnline,
                        activeTrackColor: const Color(0xFFD4DE95),
                        thumbColor: _isOnline
                            ? AppColors.primaryDark
                            : Colors.white,
                        onChanged: _toggleOnlineStatus,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // Today's Earnings Section inside Top Container
              _buildHeaderEarningsCard(),

              // Verification Status Banner inside Top Drawer (if not verified)
              if (!VerificationService.instance.isApproved) ...[
                SizedBox(height: 12.h),
                _buildVerificationStatusBanner(),
              ],

              SizedBox(height: 12.h),

              // Interactive Drag Handle Pill with Swipe-up hint
              GestureDetector(
                onTap: _toggleTopDrawer,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 20.w),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44.w,
                          height: 4.5.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: Colors.white.withValues(alpha: 0.6),
                              size: 15.r,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Swipe up to tuck away',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.65),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildHeaderEarningsCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Earnings',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'LKR 180.00',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4DE95),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '+18%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              DynamicIslandToast.showSuccess(
                context,
                'Payout initiated: LKR 180.00',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4DE95),
              foregroundColor: AppColors.primaryDark,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            ),
            icon: const Icon(Icons.account_balance_wallet_outlined, size: 16),
            label: Text(
              'Payout',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsMapView({double topOverlayOffset = 14.0}) {
    final baseLat = WorkingHoursCoverageService.instance.baseLatitude;
    final baseLng = WorkingHoursCoverageService.instance.baseLongitude;

    return Stack(
      children: [
        // 1. Google Map Canvas
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _projectsToStart.isNotEmpty
                  ? LatLng(
                      _projectsToStart[_selectedProjectIndex]['lat'] as double,
                      _projectsToStart[_selectedProjectIndex]['lng'] as double,
                    )
                  : LatLng(baseLat, baseLng),
              zoom: 14.0,
            ),
            mapType: MapType.normal,
            markers: _buildMapMarkers(),
            circles: {
              Circle(
                circleId: const CircleId('provider_coverage_area'),
                center: LatLng(baseLat, baseLng),
                radius: 4000,
                fillColor: AppColors.primary.withValues(alpha: 0.08),
                strokeColor: AppColors.primaryDark.withValues(alpha: 0.35),
                strokeWidth: 1,
              ),
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
        ),

        // 2. Top Map Overlay (Projects Pill Badge & Recenter Button)
        Positioned(
          top: topOverlayOffset,
          left: 16.w,
          right: 16.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Projects count indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFFE2E6D5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Text(
                      '${_projectsToStart.length} Projects to Start',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textHeadline,
                      ),
                    ),
                  ],
                ),
              ),

              // Recenter map button
              GestureDetector(
                onTap: _recenterToCurrentProject,
                child: Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE2E6D5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.my_location_rounded,
                    size: 18.r,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. Floating Project Card Slider (Above Bottom Navigation Bar)
        if (_projectsToStart.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 105.h,
            child: SizedBox(
              height: 185.h,
              child: PageView.builder(
                controller: _projectPageController,
                itemCount: _projectsToStart.length,
                onPageChanged: (index) {
                  setState(() => _selectedProjectIndex = index);
                  _panToProject(index);
                },
                itemBuilder: (context, index) {
                  final project = _projectsToStart[index];
                  final isSelected = index == _selectedProjectIndex;
                  return _buildProjectCardItem(project, index, isSelected);
                },
              ),
            ),
          ),
      ],
    );
  }

  Set<Marker> _buildMapMarkers() {
    final markers = <Marker>{};
    final baseLat = WorkingHoursCoverageService.instance.baseLatitude;
    final baseLng = WorkingHoursCoverageService.instance.baseLongitude;

    // Provider Location Marker
    markers.add(
      Marker(
        markerId: const MarkerId('provider_location_marker'),
        position: LatLng(baseLat, baseLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: const InfoWindow(
          title: 'Your Location',
          snippet: 'Alex Perera (Ready)',
        ),
      ),
    );

    // Projects to Start Markers
    for (int i = 0; i < _projectsToStart.length; i++) {
      final p = _projectsToStart[i];
      final isSelected = i == _selectedProjectIndex;
      markers.add(
        Marker(
          markerId: MarkerId(p['id'] as String),
          position: LatLng(p['lat'] as double, p['lng'] as double),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: p['serviceTitle'] as String,
            snippet:
                '${p['customerName']} • LKR ${(p['price'] as double).toStringAsFixed(2)}',
          ),
          onTap: () => _onProjectSelected(i),
        ),
      );
    }

    return markers;
  }

  Widget _buildProjectCardItem(
    Map<String, dynamic> project,
    int index,
    bool isSelected,
  ) {
    final categoryColor = _getCategoryColor(project['category'] as String);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFE8ECE1),
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Row: Category Pill, Urgency Badge, Price
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  project['category'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: categoryColor,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5.r,
                      height: 5.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFF166534),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      project['urgencyBadge'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'LKR ${(project['price'] as double).toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHeadline,
                ),
              ),
            ],
          ),

          // Title
          Text(
            project['serviceTitle'] as String,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeadline,
            ),
          ),

          // Customer & Location
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14.r,
                color: AppColors.textMuted,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  '${project['distance']} • ${project['address']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                '${project['customerName']} (${project['customerRating']}★)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          // Action Button Row
          Row(
            children: [
              // Page index indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${index + 1}/${_projectsToStart.length}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: SizedBox(
                  height: 38.h,
                  child: ElevatedButton(
                    onPressed: () => _startProject(project),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBackground,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Start Project',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        const Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // ---------------------------------------------------------------------------
  // FLOATING LIGHT MODE NAVBAR (4 ITEMS: HOME, JOBS, ALERTS, PROFILE)
  // ---------------------------------------------------------------------------
  Widget _buildCustomBottomNavigationBar() {
    final double barHeight = 64.h;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        bottom: bottomPadding > 0 ? bottomPadding - 4 : 12.h,
      ),
      child: Container(
        height: barHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: const Color(0xFFE8ECE1).withValues(alpha: 0.9),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'Home',
                icon: Icons.home_rounded,
              ),
              _buildNavItem(
                index: 1,
                label: 'Jobs',
                icon: Icons.grid_view_rounded,
              ),
              _buildNavItem(
                index: 2,
                label: 'Wallet',
                icon: Icons.account_balance_wallet_rounded,
              ),
              _buildNavItem(
                index: 3,
                label: 'Alerts',
                icon: Icons.notifications_rounded,
              ),
              _buildNavItem(
                index: 4,
                label: 'Profile',
                icon: Icons.person_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _currentIndex == index;
    final bool isLocked =
        (index == 1 || index == 2) && !VerificationService.instance.isApproved;
    final Color activeColor = AppColors.primary;
    final Color inactiveColor =
        isLocked ? const Color(0xFFB4B9AC) : const Color(0xFF9CA09A);

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 54.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Icon(
                    icon,
                    size: 22.r,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
                if (isLocked)
                  Positioned(
                    right: -6.w,
                    top: -3.h,
                    child: Container(
                      padding: EdgeInsets.all(2.5.r),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD97706),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 8.5.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5.sp,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            // Active indicator dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: EdgeInsets.only(top: 2.5.h),
              width: isSelected ? 4.r : 0,
              height: isSelected ? 4.r : 0,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
