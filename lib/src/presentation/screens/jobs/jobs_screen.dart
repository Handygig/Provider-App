import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/domain/models/job_model.dart';
import 'package:provider_app/src/presentation/screens/jobs/job_details_screen.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';
import 'package:provider_app/src/presentation/widgets/incoming_quotation_request_drawer.dart';

class JobsScreen extends StatefulWidget {
  final JobCategory initialCategory;

  const JobsScreen({
    super.key,
    this.initialCategory = JobCategory.toQuote,
  });

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late List<JobModel> _jobs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialCategory.index,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    _jobs = [
      // 1. To Quote
      JobModel(
        id: 'JOB-3041',
        serviceTitle: 'Bathroom Plumbing & Fixture Fitting',
        category: 'Plumbing',
        customerName: 'Saman Kumara',
        customerRating: 4.9,
        customerReviewsCount: 38,
        address: 'No 45, Alfred House Gardens, Colombo 03',
        distance: '2.4 km away',
        requestedTime: 'Inspection Today • 04:30 PM',
        description:
            'Need inspection and quotation for leaking main pipeline and installation of 2 shower mixer units.',
        estimatedBudget: 80.00,
        paymentMethod: 'Cash on Delivery',
        status: JobCategory.toQuote,
      ),
      JobModel(
        id: 'JOB-3042',
        serviceTitle: 'Split AC Outdoor Compressor Gas Leak',
        category: 'AC Repair',
        customerName: 'Dilani Fernando',
        customerRating: 4.8,
        customerReviewsCount: 19,
        address: '12/4 Ward Place, Colombo 07',
        distance: '3.8 km away',
        requestedTime: 'Urgent • Needs Quote by 6 PM',
        description:
            'Inverter AC unit outdoor fan vibrating violently and low cooling efficiency. Need cost estimate for fix.',
        estimatedBudget: 65.00,
        paymentMethod: 'Credit / Debit Card',
        status: JobCategory.toQuote,
      ),
      JobModel(
        id: 'JOB-3043',
        serviceTitle: 'Electrical Sub-panel Rewiring & MCB Fix',
        category: 'Electrical',
        customerName: 'Rohan Wickremasinghe',
        customerRating: 5.0,
        customerReviewsCount: 52,
        address: '78 Nawala Road, Nugegoda',
        distance: '5.1 km away',
        requestedTime: 'Tomorrow Morning',
        description:
            'Circuit breaker trips repeatedly whenever multiple appliances are turned on. Quote needed for diagnostic & rewire.',
        estimatedBudget: 110.00,
        paymentMethod: 'Cash on Delivery',
        status: JobCategory.toQuote,
      ),

      // 2. Pending Approve
      JobModel(
        id: 'JOB-2980',
        serviceTitle: 'Kitchen Waste Drain Deep Clearing',
        category: 'Plumbing',
        customerName: 'Ayesha Mohamed',
        customerRating: 4.9,
        customerReviewsCount: 14,
        address: 'Bambalapitiya Flats, Colombo 04',
        distance: '1.8 km away',
        requestedTime: 'Quoted 2 hrs ago • Awaiting Customer',
        description:
            'Deep chemical clearing with replacement of rubber trap and sink connector joints.',
        quotedAmount: 55.00,
        quoteNotes: 'Includes material costs and 30-day service warranty.',
        paymentMethod: 'Cash on Delivery',
        status: JobCategory.pendingApprove,
      ),
      JobModel(
        id: 'JOB-2977',
        serviceTitle: 'Commercial Inverter AC Full Service',
        category: 'AC Repair',
        customerName: 'Apex Office Hub',
        customerRating: 4.7,
        customerReviewsCount: 89,
        address: 'Duplication Road, Colombo 03',
        distance: '3.0 km away',
        requestedTime: 'Quoted Yesterday • Customer Reviewing',
        description:
            'Chemical coil wash, blower cleaning, electrical contact check, and R32 refrigerant gas charge.',
        quotedAmount: 135.00,
        quoteNotes: 'Quoted for 2 technicians, scheduled for Saturday.',
        paymentMethod: 'Credit / Debit Card',
        status: JobCategory.pendingApprove,
      ),

      // 3. Ongoing
      JobModel(
        id: 'JOB-2950',
        serviceTitle: 'Water Pressure Pump Motor Servicing',
        category: 'Plumbing',
        customerName: 'Dr. Mohan Lal',
        customerRating: 5.0,
        customerReviewsCount: 22,
        address: 'Rosmead Place, Colombo 07',
        distance: '1.2 km away',
        requestedTime: 'In Progress • Started at 2:00 PM',
        description:
            'Pressure sensor replacement and capacitor swap on automatic booster pump.',
        quotedAmount: 90.00,
        extraAmount: 25.00,
        extraReason: 'Replacement brass pressure sensor valve & sealant',
        extraStatus: ExtraApprovalStatus.pending,
        status: JobCategory.ongoing,
      ),
      JobModel(
        id: 'JOB-2944',
        serviceTitle: 'LED Recessed Ceiling Downlights Setup',
        category: 'Electrical',
        customerName: 'Chathurika Silva',
        customerRating: 4.8,
        customerReviewsCount: 31,
        address: 'Baseline Road, Colombo 09',
        distance: '4.2 km away',
        requestedTime: 'En Route • Arriving in 15 mins',
        description:
            'Drilling ceiling points, running conceal wires and installing smart dimmer toggle switches.',
        quotedAmount: 120.00,
        status: JobCategory.ongoing,
      ),

      // 4. Finished
      JobModel(
        id: 'JOB-2891',
        serviceTitle: 'Emergency Water Tank Float Valve Replacement',
        category: 'Plumbing',
        customerName: 'Praveen Jayasuriya',
        customerRating: 5.0,
        customerReviewsCount: 15,
        address: 'Havelock Town, Colombo 05',
        distance: '2.7 km away',
        requestedTime: 'Completed Yesterday',
        description:
            'Replaced brass high-pressure ball valve and overflow discharge pipe.',
        quotedAmount: 48.00,
        status: JobCategory.finished,
        completionDate: 'Sep 21, 2026',
        finalRating: 5.0,
        clientFeedback:
            'Super quick response and fixed the overflow within 30 minutes! Highly recommended.',
      ),
      JobModel(
        id: 'JOB-2860',
        serviceTitle: 'Split Unit Gas Leak Brazing & Vacuuming',
        category: 'AC Repair',
        customerName: 'Mahesh De Mel',
        customerRating: 4.9,
        customerReviewsCount: 44,
        address: 'Thimbirigasyaya Road, Colombo 05',
        distance: '3.5 km away',
        requestedTime: 'Completed Sep 19',
        description:
            'Copper joint brazing, nitrogen pressure test, vacuum and R410A refrigerant filling.',
        quotedAmount: 85.00,
        status: JobCategory.finished,
        completionDate: 'Sep 19, 2026',
        finalRating: 4.9,
        clientFeedback:
            'Very professional technician. The cooling is fantastic now.',
      ),
      JobModel(
        id: 'JOB-2820',
        serviceTitle: 'Tripping MCB Replacement & Earth Relay Test',
        category: 'Electrical',
        customerName: 'Kavinda Perera',
        customerRating: 5.0,
        customerReviewsCount: 29,
        address: 'Stanley Thilakarathne Mawatha, Nugegoda',
        distance: '6.0 km away',
        requestedTime: 'Completed Sep 15',
        description:
            'Replaced faulty 32A double pole breaker and tested RCCB trip response threshold.',
        quotedAmount: 65.00,
        status: JobCategory.finished,
        completionDate: 'Sep 15, 2026',
        finalRating: 5.0,
        clientFeedback: 'Solved our electrical trip issue instantly.',
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<JobModel> _getFilteredJobs(JobCategory category) {
    return _jobs.where((job) {
      if (job.status != category) return false;
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return job.serviceTitle.toLowerCase().contains(query) ||
          job.customerName.toLowerCase().contains(query) ||
          job.id.toLowerCase().contains(query) ||
          job.address.toLowerCase().contains(query) ||
          job.category.toLowerCase().contains(query);
    }).toList();
  }

  int _countForCategory(JobCategory category) {
    return _jobs.where((j) => j.status == category).length;
  }

  int _simulatedRequestIndex = 0;

  final List<Map<String, dynamic>> _jobSimulationTemplates = [
    {
      'title': 'Emergency Pipe Leak & Tap Fix',
      'category': 'Plumbing',
      'customer': 'Sarah Jenkins',
      'rating': 4.9,
      'address': 'No 18, Galle Road, Kollupitiya, Colombo 03',
      'distance': '2.4 km away',
      'time': 'Inspection Now • Urgent',
      'desc':
          'Urgent kitchen pipeline leak under sink. Water flooding kitchen floor, requires quick on-site inspection and price quotation.',
      'budget': 65.00,
    },
    {
      'title': 'AC Compressor Gas Leak & Nitrogen Test',
      'category': 'AC Repair',
      'customer': 'David Miller',
      'rating': 4.8,
      'address': '12/4 Ward Place, Colombo 07',
      'distance': '3.4 km away',
      'time': 'Within 2 hours',
      'desc':
          'Inverter AC unit outdoor fan vibrating violently and low cooling efficiency. Need cost estimate for nitrogen leak test and gas refill.',
      'budget': 85.00,
    },
    {
      'title': 'Main Switchboard Breaker Trip & Sparks',
      'category': 'Electrical',
      'customer': 'Priya Sharma',
      'rating': 5.0,
      'address': 'Duplication Road, Bambalapitiya, Colombo 04',
      'distance': '1.8 km away',
      'time': 'Immediate Assistance',
      'desc':
          'Main 63A RCCB trips repeatedly with burning smell from distribution board. Urgent diagnostic required.',
      'budget': 55.00,
    },
  ];

  void _simulateJobRequest() {
    HapticFeedback.heavyImpact();
    final template =
        _jobSimulationTemplates[_simulatedRequestIndex % _jobSimulationTemplates.length];
    _simulatedRequestIndex++;

    final newId = 'JOB-${3000 + DateTime.now().millisecondsSinceEpoch % 7000}';

    final simulatedJob = JobModel(
      id: newId,
      serviceTitle: template['title'] as String,
      category: template['category'] as String,
      customerName: template['customer'] as String,
      customerPhone: '+94 77 982 1450',
      customerRating: (template['rating'] as num).toDouble(),
      customerReviewsCount: 32,
      address: template['address'] as String,
      distance: template['distance'] as String,
      requestedTime: template['time'] as String,
      description: template['desc'] as String,
      estimatedBudget: (template['budget'] as num).toDouble(),
      status: JobCategory.toQuote,
    );

    setState(() {
      _jobs.insert(0, simulatedJob);
    });

    _tabController.animateTo(0);

    DynamicIslandToast.showSuccess(
      context,
      '⚡ Simulated request: ${simulatedJob.customerName}',
    );

    IncomingQuotationRequestDrawer.show(
      context,
      job: simulatedJob,
      onQuoteSent: (updatedJob) {
        setState(() {
          final idx = _jobs.indexWhere((j) => j.id == updatedJob.id);
          if (idx != -1) {
            _jobs[idx] = updatedJob;
          }
        });
      },
    );
  }

  void _openJobDetails(JobModel job) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JobDetailsScreen(
          job: job,
          onJobUpdated: (updatedJob) {
            setState(() {
              final index = _jobs.indexWhere((j) => j.id == updatedJob.id);
              if (index != -1) {
                _jobs[index] = updatedJob;
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final toQuoteCount = _countForCategory(JobCategory.toQuote);
    final pendingCount = _countForCategory(JobCategory.pendingApprove);
    final ongoingCount = _countForCategory(JobCategory.ongoing);
    final finishedCount = _countForCategory(JobCategory.finished);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: Column(
        children: [
          // Header Section with Dark Olive background & Frosted Glass Tab Bar
          Container(
            width: double.infinity,
            color: AppColors.primaryDark,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16.h,
              left: 20.w,
              right: 20.w,
              bottom: 18.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Jobs & Quotes',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _simulateJobRequest,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4DE95),
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD4DE95)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 6,
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
                                  size: 14.r,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'Simulate',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        IconButton(
                          tooltip: 'Refresh',
                          icon: const Icon(Icons.refresh_rounded,
                              color: Colors.white70),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {});
                            DynamicIslandToast.showSuccess(
                              context,
                              'Jobs Refreshed',
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 14.h),

                // Pill Tab Bar with Liquid Glass Effect (Customer-App parity)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.25),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 2.h),
                        indicator: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.accentLime.withValues(alpha: 0.95),
                              AppColors.accentLime,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.4),
                              blurRadius: 1,
                              offset: const Offset(0, -1),
                            ),
                          ],
                        ),
                        labelColor: AppColors.primaryDark,
                        unselectedLabelColor:
                            Colors.white.withValues(alpha: 0.85),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        dividerColor: Colors.transparent,
                        tabs: [
                          Tab(text: 'To Quote ($toQuoteCount)'),
                          Tab(text: 'Pending approve ($pendingCount)'),
                          Tab(text: 'Ongoing ($ongoingCount)'),
                          Tab(text: 'Finished ($finishedCount)'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          _buildSearchBar(),

          // Content TabBarView with Summarized Cards
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildJobsList(JobCategory.toQuote),
                _buildJobsList(JobCategory.pendingApprove),
                _buildJobsList(JobCategory.ongoing),
                _buildJobsList(JobCategory.finished),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 8.h),
      color: Colors.white,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3EB),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.borderUnselected,
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {
              _searchQuery = val.trim();
            });
          },
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5.sp,
            color: AppColors.textHeadline,
          ),
          decoration: InputDecoration(
            hintText: 'Search by client, service or job ID...',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              color: AppColors.textMuted,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          ),
        ),
      ),
    );
  }

  Widget _buildJobsList(JobCategory category) {
    final list = _getFilteredJobs(category);

    if (list.isEmpty) {
      return _buildEmptyState(category);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 120.h),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildSummarizedJobCard(list[index]);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // REDESIGNED USER-FRIENDLY JOB CARD WITH SERVICE STATUS MAP
  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  // REDESIGNED SIMPLE & CLEAN SERVICE CARD WITH SEE DETAILS BUTTON
  // ---------------------------------------------------------------------------
  Widget _buildSummarizedJobCard(JobModel job) {
    final int currentStep = job.status.index; // 0: To Quote, 1: Pending, 2: Ongoing, 3: Finished
    final bool hasQuoted = job.quotedAmount != null;
    final String? priceText;
    final String? priceLabel;

    if (hasQuoted) {
      switch (job.status) {
        case JobCategory.toQuote:
          priceLabel = 'Sent Quote';
          priceText = 'LKR ${job.quotedAmount!.toStringAsFixed(2)}';
          break;
        case JobCategory.pendingApprove:
          priceLabel = 'Sent Quote';
          priceText = 'LKR ${job.quotedAmount!.toStringAsFixed(2)}';
          break;
        case JobCategory.ongoing:
          priceLabel = 'Total Job Value';
          priceText = 'LKR ${job.totalEffectivePrice.toStringAsFixed(2)}';
          break;
        case JobCategory.finished:
          priceLabel = 'Total Settled';
          priceText = 'LKR ${job.totalEffectivePrice.toStringAsFixed(2)}';
          break;
      }
    } else {
      priceLabel = null;
      priceText = null;
    }

    final initials = job.customerName
        .trim()
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join();

    final isCash = job.paymentMethod.toLowerCase().contains('cash');

    return GestureDetector(
      onTap: () => _openJobDetails(job),
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFE5E9DC),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. Header: Category Tag & Status Badge ──────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: job.categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            job.categoryIcon,
                            size: 13.r,
                            color: job.categoryColor,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            job.category,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                              color: job.categoryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3EB),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        job.id,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),

                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: job.status.backgroundColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: job.status.color.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        job.status.icon,
                        size: 12.r,
                        color: job.status.color,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        job.status.badgeText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: job.status.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // ─── 2. Service Title & Schedule ─────────────────────────────
            Text(
              job.serviceTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textHeadline,
                height: 1.25,
              ),
            ),
            SizedBox(height: 5.h),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 13.r,
                  color: AppColors.primary,
                ),
                SizedBox(width: 5.w),
                Text(
                  job.requestedTime,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // ─── 3. Unified Customer, Location & Payment Info ────────────
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9F3),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFE9ECE0),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Customer & Distance Row
                  Row(
                    children: [
                      Container(
                        width: 24.r,
                        height: 24.r,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials.isNotEmpty ? initials : 'C',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          job.customerName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textHeadline,
                          ),
                        ),
                      ),
                      // Rating
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 13.r,
                            color: const Color(0xFFD97706),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            job.customerRating.toStringAsFixed(1),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '• ${job.distance}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 13.r,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          job.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 5.h),

                  // Payment Method
                  Row(
                    children: [
                      Icon(
                        isCash
                            ? Icons.payments_outlined
                            : Icons.credit_card_outlined,
                        size: 13.r,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Payment: ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        job.paymentMethod,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textHeadline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // ─── 4. Sleek Progress Stepper Bar ───────────────────────────
            _buildCardServiceStatusMap(job, currentStep),

            SizedBox(height: 10.h),

            // ─── 5. Divider ──────────────────────────────────────────────
            const Divider(height: 1, color: Color(0xFFEFF2E5)),

            SizedBox(height: 10.h),

            // ─── 6. Footer: Pricing & Action Buttons ─────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price display (hidden until provider has quoted)
                if (hasQuoted && priceLabel != null && priceText != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          priceLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                priceText,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15.5.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF16A34A),
                                ),
                              ),
                            ),
                            if (job.hasPendingExtra) ...[
                              SizedBox(width: 4.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 1.5.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  '+LKR ${job.extraAmount!.toStringAsFixed(0)} ⏳',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFD97706),
                                  ),
                                ),
                              ),
                            ] else if (job.hasApprovedExtra) ...[
                              SizedBox(width: 4.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 1.5.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  '+LKR ${job.extraAmount!.toStringAsFixed(0)} ✓',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  const Spacer(),

                SizedBox(width: 8.w),

                // "See Details" Button
                GestureDetector(
                  onTap: () => _openJobDetails(job),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'See Details',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14.r,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SLEEK MINIMAL PROGRESS INDICATOR
  // ---------------------------------------------------------------------------
  Widget _buildCardServiceStatusMap(JobModel job, int currentStep) {
    const stageNames = ['Quote', 'Approval', 'Ongoing', 'Finished'];
    final activeStageName = stageNames[currentStep.clamp(0, 3)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            Text(
              'Stage ${currentStep + 1} of 4 • $activeStageName',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w700,
                color: job.status.color,
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        Row(
          children: List.generate(4, (index) {
            final isPassed = index < currentStep;
            final isCurrent = index == currentStep;
            final isFilled = isPassed || isCurrent;

            return Expanded(
              child: Container(
                height: 4.h,
                margin: EdgeInsets.only(right: index < 3 ? 4.w : 0),
                decoration: BoxDecoration(
                  color: isFilled
                      ? (isCurrent ? job.status.color : const Color(0xFF16A34A))
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }


  Widget _buildEmptyState(JobCategory category) {
    String title;
    String subtitle;
    IconData icon;

    switch (category) {
      case JobCategory.toQuote:
        title = 'No Requests To Quote';
        subtitle =
            'New customer inquiries requiring quotes will show up here automatically.';
        icon = Icons.request_quote_outlined;
        break;
      case JobCategory.pendingApprove:
        title = 'No Pending Approvals';
        subtitle =
            'When you submit quotes to customers, they will remain here until approved.';
        icon = Icons.hourglass_empty_rounded;
        break;
      case JobCategory.ongoing:
        title = 'No Ongoing Jobs';
        subtitle =
            'Jobs accepted by clients ready for execution will appear here.';
        icon = Icons.handyman_outlined;
        break;
      case JobCategory.finished:
        title = 'No Finished Jobs Yet';
        subtitle =
            'Your successfully completed jobs and client ratings will be recorded here.';
        icon = Icons.verified_outlined;
        break;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68.r,
              height: 68.r,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32.r,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.5.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textHeadline,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
