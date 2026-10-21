import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/domain/models/job_model.dart';
import 'package:provider_app/src/presentation/screens/jobs/jobs_screen.dart';
import 'package:provider_app/src/presentation/tabs/alerts_tab.dart';
import 'package:provider_app/src/presentation/tabs/profile_tab.dart';
import 'package:provider_app/src/presentation/tabs/wallet_tab.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';
import 'package:provider_app/src/presentation/widgets/incoming_quotation_request_drawer.dart';

class HomeScreen extends StatefulWidget {
  final int initialTabIndex;

  const HomeScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  bool _isOnline = true;

  final List<Map<String, dynamic>> _jobRequests = [
    {
      'id': 'JOB-1024',
      'service': 'Emergency Pipe Leak Repair',
      'category': 'Plumbing',
      'customer': 'Sarah Jenkins',
      'rating': 4.9,
      'distance': '2.1 km away',
      'location': 'Colombo 03, Kollupitiya',
      'price': 45.00,
      'urgency': 'Immediate',
      'time': 'Needs help now',
    },
    {
      'id': 'JOB-1025',
      'service': 'AC Master Filter Clean & Gas Topup',
      'category': 'AC Repair',
      'customer': 'David Miller',
      'rating': 4.8,
      'distance': '4.5 km away',
      'location': 'Colombo 07, Cinnamon Gardens',
      'price': 75.00,
      'urgency': 'Scheduled',
      'time': 'Today, 5:30 PM',
    },
    {
      'id': 'JOB-1026',
      'service': 'Main Switchboard Breaker Trip Fix',
      'category': 'Electrical',
      'customer': 'Nimal Perera',
      'rating': 5.0,
      'distance': '3.2 km away',
      'location': 'Rajagiriya, Welikada',
      'price': 60.00,
      'urgency': 'Urgent',
      'time': 'Within 2 hours',
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
    final rawJob = {
      'id': newId,
      'service': template['service'],
      'category': template['category'],
      'customer': template['customer'],
      'rating': template['rating'],
      'distance': template['distance'],
      'location': template['location'],
      'price': template['price'],
      'urgency': template['urgency'],
      'time': template['time'],
    };

    setState(() {
      _jobRequests.insert(0, rawJob);
    });

    DynamicIslandToast.showSuccess(
      context,
      '⚡ Incoming request from ${template['customer']}!',
    );

    final job = JobModel(
      id: newId,
      serviceTitle: template['service'] as String,
      category: template['category'] as String,
      customerName: template['customer'] as String,
      customerPhone: '+94 77 982 1450',
      customerRating: (template['rating'] as num).toDouble(),
      customerReviewsCount: 32,
      address: template['location'] as String,
      distance: template['distance'] as String,
      requestedTime: template['time'] as String,
      description: template['description'] as String,
      estimatedBudget: (template['price'] as num).toDouble(),
      status: JobCategory.toQuote,
    );

    // Slide up bottom sheet with Google Map and customer location
    IncomingQuotationRequestDrawer.show(
      context,
      job: job,
      onQuoteSent: (updatedJob) {
        setState(() {
          _jobRequests.removeWhere((item) => item['id'] == newId);
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      HapticFeedback.mediumImpact();
      setState(() {
        _currentIndex = index;
      });
    }
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

  void _acceptJob(int index) {
    HapticFeedback.mediumImpact();
    final rawJob = _jobRequests[index];
    final job = JobModel(
      id: rawJob['id'] as String,
      serviceTitle: rawJob['service'] as String,
      category: rawJob['category'] as String,
      customerName: rawJob['customer'] as String,
      customerPhone: '+94 77 982 1450',
      customerRating: (rawJob['rating'] as num).toDouble(),
      customerReviewsCount: 28,
      address: rawJob['location'] as String,
      distance: rawJob['distance'] as String,
      requestedTime: rawJob['time'] as String,
      description:
          'Customer requested an emergency inspection and quotation for ${rawJob['service']} in ${rawJob['location']}.',
      estimatedBudget: (rawJob['price'] as num).toDouble(),
      status: JobCategory.toQuote,
    );

    IncomingQuotationRequestDrawer.show(
      context,
      job: job,
      onQuoteSent: (updatedJob) {
        setState(() {
          if (index < _jobRequests.length) {
            _jobRequests.removeAt(index);
          }
        });
      },
    );
  }

  void _declineJob(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _jobRequests.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
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
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App Header Sliver
        SliverToBoxAdapter(
          child: _buildTopHeader(),
        ),

        // Quick Stats Strip
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: _buildStatsGrid(),
          ),
        ),

        // Live Incoming Quotation Request Banner with Google Map Trigger
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
            child: GestureDetector(
              onTap: () {
                final job = JobModel(
                  id: 'JOB-1024',
                  serviceTitle: 'Emergency Pipe Leak Repair',
                  category: 'Plumbing',
                  customerName: 'Sarah Jenkins',
                  customerPhone: '+94 77 982 1450',
                  customerRating: 4.9,
                  customerReviewsCount: 32,
                  address: 'No 18, Galle Road, Kollupitiya, Colombo 03',
                  distance: '2.1 km away',
                  requestedTime: 'Immediate Assistance',
                  description:
                      'Urgent kitchen main pipeline burst under sink. Water flooding kitchen floor, requires quick inspection & price quotation.',
                  estimatedBudget: 65.00,
                  status: JobCategory.toQuote,
                );
                IncomingQuotationRequestDrawer.show(context, job: job);
              },
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3D4127), Color(0xFF535B27)],
                  ),
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3D4127).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4DE95).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.radar_rounded,
                        color: Color(0xFFD4DE95),
                        size: 22,
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
                                width: 7.r,
                                height: 7.r,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD4DE95),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                'NEW INCOMING QUOTE REQUEST',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFD4DE95),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Sarah Jenkins • Pipe Leak (2.1 km)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4DE95),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        'View Map →',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Section Title: Available Requests
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Live Requests',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${_jobRequests.length} Near You',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _simulateIncomingJobRequest,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D4127).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFF3D4127).withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 14.r,
                          color: AppColors.primaryDark,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Simulate Request',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Job Requests List
        if (_jobRequests.isEmpty)
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(20.w),
              padding: EdgeInsets.all(28.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.borderUnselected,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.primary,
                    size: 48.r,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'All caught up!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHeadline,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Stay online to receive instant notifications when new jobs arrive in your area.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: _buildJobCard(_jobRequests[index], index),
                );
              },
              childCount: _jobRequests.length,
            ),
          ),


        // Bottom space for floating curvature navigation bar
        SliverToBoxAdapter(
          child: SizedBox(height: 120.h),
        ),
      ],
    );
  }

  Widget _buildTopHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkHeaderBg,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
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

              SizedBox(height: 20.h),

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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.borderUnselected,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Earnings',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
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
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textHeadline,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '+18%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF166534),
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
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                ),
                icon:
                    const Icon(Icons.account_balance_wallet_outlined, size: 18),
                label: Text(
                  'Payout',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 24.h, color: AppColors.borderUnselected),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Completed', '4 Jobs', Icons.done_all_rounded,
                  onTap: () => _onTabSelected(1)),
              Container(
                height: 24.h,
                width: 1,
                color: AppColors.borderUnselected,
              ),
              _buildStatItem('Rating', '4.9 ★', Icons.star_rate_rounded),
              Container(
                height: 24.h,
                width: 1,
                color: AppColors.borderUnselected,
              ),
              _buildStatItem('Acceptance', '96%', Icons.thumb_up_alt_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15.r, color: AppColors.primary),
              SizedBox(width: 4.w),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeadline,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
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
      padding: EdgeInsets.all(18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  job['category'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Text(
                'LKR ${(job['price'] as double).toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHeadline,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            job['service'] as String,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeadline,
              height: 1.25,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16.r,
                color: AppColors.textMuted,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  '${job['distance']} • ${job['location']}',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16.r,
                color: const Color(0xFFE65100),
              ),
              SizedBox(width: 4.w),
              Text(
                job['time'] as String,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE65100),
                ),
              ),
              const Spacer(),
              Text(
                'Customer: ${job['customer']} (${job['rating']}★)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () => _declineJob(index),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    'Decline',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _acceptJob(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBackground,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Accept Job',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
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
    final Color activeColor = AppColors.primary;
    final Color inactiveColor = const Color(0xFF9CA09A);

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 54.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
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
