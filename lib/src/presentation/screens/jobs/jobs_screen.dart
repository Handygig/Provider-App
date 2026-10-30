import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/data/services/provider_session_service.dart';
import 'package:provider_app/src/data/models/jobs/job_model.dart';
import 'package:provider_app/src/presentation/screens/jobs/utils/job_ui_helper.dart';
import 'package:provider_app/src/presentation/screens/jobs/job_details_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider_app/core/di/service_locator.dart';
import 'package:provider_app/src/presentation/cubits/jobs/jobs_cubit.dart';
import 'package:provider_app/src/presentation/cubits/jobs/jobs_state.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';

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

  // Filter state
  String _selectedCategory = 'All';
  String _selectedDateRange = 'All';
  DateTimeRange? _customDateRange;

  bool get _hasActiveFilters =>
      _selectedCategory != 'All' || _selectedDateRange != 'All';

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCategory != 'All') count++;
    if (_selectedDateRange != 'All') count++;
    return count;
  }

  List<JobModel> _jobs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialCategory.index,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    final cubitJobs = sl<JobsCubit>().jobs;
    _jobs = cubitJobs.map((j) {
      if (j is JobModel) return j;
      return JobModel.fromEntity(j);
    }).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsCubit>().loadJobs(silent: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<JobModel> _getFilteredJobs(JobCategory category) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _jobs.where((job) {
      if (job.status != category) return false;

      // 1. Search Query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matches = job.serviceTitle.toLowerCase().contains(query) ||
            job.customerName.toLowerCase().contains(query) ||
            job.id.toLowerCase().contains(query) ||
            job.address.toLowerCase().contains(query) ||
            job.category.toLowerCase().contains(query);
        if (!matches) return false;
      }

      // 2. Category filter
      if (_selectedCategory != 'All') {
        if (!job.category.toLowerCase().contains(_selectedCategory.toLowerCase())) {
          return false;
        }
      }

      // 3. Date Range filter
      if (_selectedDateRange != 'All') {
        final jDate = job.effectiveDate;
        final jobDay = DateTime(jDate.year, jDate.month, jDate.day);

        switch (_selectedDateRange) {
          case 'Today':
            if (jobDay != today) return false;
            break;
          case 'This Week':
            final weekAgo = today.subtract(const Duration(days: 7));
            if (jobDay.isBefore(weekAgo) ||
                jobDay.isAfter(today.add(const Duration(days: 1)))) {
              return false;
            }
            break;
          case 'This Month':
            if (jDate.year != now.year || jDate.month != now.month) return false;
            break;
          case 'Last Month':
            final prevMonthYear = now.month == 1 ? now.year - 1 : now.year;
            final prevMonth = now.month == 1 ? 12 : now.month - 1;
            if (jDate.year != prevMonthYear || jDate.month != prevMonth) return false;
            break;
          case 'Custom':
            if (_customDateRange != null) {
              final start = DateTime(_customDateRange!.start.year,
                  _customDateRange!.start.month, _customDateRange!.start.day);
              final end = DateTime(_customDateRange!.end.year,
                  _customDateRange!.end.month, _customDateRange!.end.day, 23, 59, 59);
              if (jDate.isBefore(start) || jDate.isAfter(end)) return false;
            }
            break;
        }
      }

      return true;
    }).toList();
  }

  int _calculateMatchesCount({
    required JobCategory category,
    required String filterCategory,
    required String filterDateRange,
    DateTimeRange? customRange,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _jobs.where((job) {
      if (job.status != category) return false;

      if (filterCategory != 'All') {
        if (!job.category.toLowerCase().contains(filterCategory.toLowerCase())) {
          return false;
        }
      }

      if (filterDateRange != 'All') {
        final jDate = job.effectiveDate;
        final jobDay = DateTime(jDate.year, jDate.month, jDate.day);

        switch (filterDateRange) {
          case 'Today':
            if (jobDay != today) return false;
            break;
          case 'This Week':
            final weekAgo = today.subtract(const Duration(days: 7));
            if (jobDay.isBefore(weekAgo) ||
                jobDay.isAfter(today.add(const Duration(days: 1)))) {
              return false;
            }
            break;
          case 'This Month':
            if (jDate.year != now.year || jDate.month != now.month) return false;
            break;
          case 'Last Month':
            final prevMonthYear = now.month == 1 ? now.year - 1 : now.year;
            final prevMonth = now.month == 1 ? 12 : now.month - 1;
            if (jDate.year != prevMonthYear || jDate.month != prevMonth) return false;
            break;
          case 'Custom':
            if (customRange != null) {
              final start = DateTime(customRange.start.year, customRange.start.month, customRange.start.day);
              final end = DateTime(customRange.end.year, customRange.end.month, customRange.end.day, 23, 59, 59);
              if (jDate.isBefore(start) || jDate.isAfter(end)) return false;
            }
            break;
        }
      }

      return true;
    }).length;
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'ac repair':
        return Icons.hvac_rounded;
      case 'electrical':
        return Icons.electrical_services_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      default:
        return Icons.handyman_rounded;
    }
  }

  int _countForCategory(JobCategory category) {
    return _jobs.where((j) => j.status == category).length;
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
          onJobDeclined: (declinedJob) {
            setState(() {
              _jobs.removeWhere((j) => j.id == declinedJob.id);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JobsCubit, JobsState>(
      listener: (context, jobsState) {
        if (jobsState is JobsLoaded) {
          setState(() {
            _jobs = jobsState.allJobs
                .map((j) => j is JobModel ? j : JobModel.fromEntity(j))
                .toList();
          });
        }
      },
      builder: (context, jobsState) {
        if (jobsState is JobsLoaded &&
            _jobs.isEmpty &&
            jobsState.allJobs.isNotEmpty) {
          _jobs = jobsState.allJobs
              .map((j) => j is JobModel ? j : JobModel.fromEntity(j))
              .toList();
        }

        final toQuoteCount = _countForCategory(JobCategory.toQuote);
        final pendingCount = _countForCategory(JobCategory.pendingApprove);
        final toStartCount = _countForCategory(JobCategory.toStart);
        final ongoingCount = _countForCategory(JobCategory.ongoing);
        final finishedCount = _countForCategory(JobCategory.finished);

        return AnimatedBuilder(
          animation: ProviderSessionService.instance,
          builder: (context, _) {
            final isCompany = ProviderSessionService.instance.isCompanyProvider;
            final companyName = ProviderSessionService.instance.companyName;

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
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'My Jobs & Quotes',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              if (isCompany) ...[
                                SizedBox(height: 2.h),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.business_rounded,
                                      size: 12.r,
                                      color: const Color(0xFFD4DE95),
                                    ),
                                    SizedBox(width: 4.w),
                                    Flexible(
                                      child: Text(
                                        '$companyName • Work Orders',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFFD4DE95),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        IconButton(
                          tooltip: 'Refresh',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints.tightFor(
                            width: 34.r,
                            height: 34.r,
                          ),
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white70,
                            size: 20,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.read<JobsCubit>().loadJobs();
                            DynamicIslandToast.showSuccess(
                              context,
                              'Jobs Refreshed',
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Stage Categories in Tile View (2-Row Responsive Grid)
                    _buildCategoryTileView(
                      toQuoteCount: toQuoteCount,
                      pendingCount: pendingCount,
                      toStartCount: toStartCount,
                      ongoingCount: ongoingCount,
                      finishedCount: finishedCount,
                    ),
                  ],
                ),
              ),

              // Company Dispatch Banner for Business staff
              if (isCompany)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: const Color(0xFFD8B4FE),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFF7E22CE),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.corporate_fare_rounded,
                          size: 13.r,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 9.w),
                      Expanded(
                        child: Text(
                          'Company Assigned Only: You receive jobs dispatched exclusively by $companyName.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B21A8),
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
                    _buildJobsList(JobCategory.toStart),
                    _buildJobsList(JobCategory.ongoing),
                    _buildJobsList(JobCategory.finished),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
      },
    );
  }

  Widget _buildCategoryTileView({
    required int toQuoteCount,
    required int pendingCount,
    required int toStartCount,
    required int ongoingCount,
    required int finishedCount,
  }) {
    return AnimatedBuilder(
      animation: _tabController.animation ?? _tabController,
      builder: (context, _) {
        final activeIndex = _tabController.animation != null
            ? _tabController.animation!.value.round()
            : _tabController.index;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: 2 tiles (To Quote & Pending Approve)
            Row(
              children: [
                _buildCategoryTile(
                  index: 0,
                  activeIndex: activeIndex,
                  title: 'To Quote',
                  count: toQuoteCount,
                  icon: Icons.request_quote_rounded,
                ),
                SizedBox(width: 8.w),
                _buildCategoryTile(
                  index: 1,
                  activeIndex: activeIndex,
                  title: 'Pending Approve',
                  count: pendingCount,
                  icon: Icons.hourglass_top_rounded,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // Row 2: 3 tiles (To Start, Ongoing, Finished)
            Row(
              children: [
                _buildCategoryTile(
                  index: 2,
                  activeIndex: activeIndex,
                  title: 'To Start',
                  count: toStartCount,
                  icon: Icons.rocket_launch_rounded,
                ),
                SizedBox(width: 8.w),
                _buildCategoryTile(
                  index: 3,
                  activeIndex: activeIndex,
                  title: 'Ongoing',
                  count: ongoingCount,
                  icon: Icons.handyman_rounded,
                ),
                SizedBox(width: 8.w),
                _buildCategoryTile(
                  index: 4,
                  activeIndex: activeIndex,
                  title: 'Finished',
                  count: finishedCount,
                  icon: Icons.check_circle_rounded,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryTile({
    required int index,
    required int activeIndex,
    required String title,
    required int count,
    required IconData icon,
  }) {
    final isSelected = activeIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _tabController.animateTo(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 44.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE4F089),
                      Color(0xFFD4DE95),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.16),
                      Colors.white.withValues(alpha: 0.06),
                    ],
                  ),
            borderRadius: BorderRadius.circular(13.r),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.2),
              width: isSelected ? 1.4 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFD4DE95).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.4),
                      blurRadius: 2,
                      offset: const Offset(0, -1),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15.r,
                color: isSelected
                    ? AppColors.primaryDark
                    : Colors.white.withValues(alpha: 0.9),
              ),
              SizedBox(width: 5.w),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? AppColors.primaryDark
                        : Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ),
              SizedBox(width: 5.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryDark.withValues(alpha: 0.16)
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? AppColors.primaryDark : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 6.h),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Search Input Field
              Expanded(
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
              ),

              SizedBox(width: 8.w),

              // Filter Action Button
              GestureDetector(
                onTap: _showFilterBottomSheet,
                child: Container(
                  height: 44.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: _hasActiveFilters ? AppColors.primary : const Color(0xFFF1F3EB),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: _hasActiveFilters
                          ? AppColors.primary
                          : AppColors.borderUnselected,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: _hasActiveFilters ? Colors.white : AppColors.primaryDark,
                        size: 18.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Filter',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: _hasActiveFilters ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      if (_hasActiveFilters) ...[
                        SizedBox(width: 5.w),
                        Container(
                          width: 18.r,
                          height: 18.r,
                          decoration: const BoxDecoration(
                            color: AppColors.accentLime,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$_activeFilterCount',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Active filter badges and quick category selector
          _buildFilterChipsBar(),
        ],
      ),
    );
  }

  Widget _buildFilterChipsBar() {
    final categories = ['All', 'Plumbing', 'AC Repair', 'Electrical', 'Cleaning'];

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active filter indicators
          if (_hasActiveFilters) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  Text(
                    'Active:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  if (_selectedCategory != 'All')
                    _buildActiveBadge(
                      label: _selectedCategory,
                      icon: _getCategoryIcon(_selectedCategory),
                      onClear: () {
                        setState(() => _selectedCategory = 'All');
                      },
                    ),
                  if (_selectedDateRange != 'All')
                    _buildActiveBadge(
                      label: _selectedDateRange == 'Custom' && _customDateRange != null
                          ? '${_customDateRange!.start.day}/${_customDateRange!.start.month} - ${_customDateRange!.end.day}/${_customDateRange!.end.month}'
                          : _selectedDateRange,
                      icon: Icons.calendar_today_rounded,
                      onClear: () {
                        setState(() {
                          _selectedDateRange = 'All';
                          _customDateRange = null;
                        });
                      },
                    ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedCategory = 'All';
                        _selectedDateRange = 'All';
                        _customDateRange = null;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Text(
                        'Clear all',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFDC2626),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
          ],

          // Quick category horizontal scrolling pill bar
          SizedBox(
            height: 30.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (context, index) => SizedBox(width: 6.w),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryDark : const Color(0xFFF3F5ED),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryDark : const Color(0xFFE2E6D5),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (cat != 'All') ...[
                          Icon(
                            _getCategoryIcon(cat),
                            size: 12.r,
                            color: isSelected ? AppColors.accentLime : AppColors.primary,
                          ),
                          SizedBox(width: 4.w),
                        ],
                        Text(
                          cat,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5.sp,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textHeadline,
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

  Widget _buildActiveBadge({
    required String label,
    IconData? icon,
    required VoidCallback onClear,
  }) {
    return Container(
      margin: EdgeInsets.only(right: 6.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11.r, color: AppColors.primary),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close_rounded,
              size: 13.r,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    HapticFeedback.lightImpact();

    String tempCategory = _selectedCategory;
    String tempDateRange = _selectedDateRange;
    DateTimeRange? tempCustomRange = _customDateRange;

    final categories = ['All', 'Plumbing', 'AC Repair', 'Electrical', 'Cleaning'];
    final dateRanges = [
      'All',
      'Today',
      'This Week',
      'This Month',
      'Last Month',
      'Custom',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final activeTab = JobCategory.values[_tabController.index];
            final previewCount = _calculateMatchesCount(
              category: activeTab,
              filterCategory: tempCategory,
              filterDateRange: tempDateRange,
              customRange: tempCustomRange,
            );

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
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
                    SizedBox(height: 14.h),

                    // Header Row: Title, Reset, Close
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                color: AppColors.primary,
                                size: 18.r,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Filter Jobs',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textHeadline,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                setSheetState(() {
                                  tempCategory = 'All';
                                  tempDateRange = 'All';
                                  tempCustomRange = null;
                                });
                              },
                              child: Text(
                                'Reset All',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(Icons.close_rounded),
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ],
                    ),

                    Divider(color: const Color(0xFFEFF2E6), height: 16.h),

                    // Section 1: Job Category Filter
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.category_outlined,
                            size: 16.r, color: AppColors.primary),
                        SizedBox(width: 6.w),
                        Text(
                          'Job Category',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textHeadline,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: categories.map((cat) {
                        final isSelected = tempCategory == cat;
                        return ChoiceChip(
                          selected: isSelected,
                          label: Text(
                            cat == 'All' ? 'All Categories' : cat,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5.sp,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textHeadline,
                            ),
                          ),
                          avatar: cat != 'All'
                              ? Icon(
                                  _getCategoryIcon(cat),
                                  size: 14.r,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary,
                                )
                              : null,
                          backgroundColor: const Color(0xFFF4F6F0),
                          selectedColor: AppColors.primary,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFE2E6D5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          onSelected: (val) {
                            HapticFeedback.selectionClick();
                            setSheetState(() {
                              tempCategory = cat;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 20.h),

                    // Section 2: Date Filter
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 16.r, color: AppColors.primary),
                        SizedBox(width: 6.w),
                        Text(
                          'Completion / Job Date',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textHeadline,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: dateRanges.map((range) {
                        final isSelected = tempDateRange == range;
                        String label = range == 'All' ? 'All Dates' : range;
                        if (range == 'Custom' && tempCustomRange != null) {
                          label =
                              '${tempCustomRange!.start.day}/${tempCustomRange!.start.month} - ${tempCustomRange!.end.day}/${tempCustomRange!.end.month}';
                        }

                        return ChoiceChip(
                          selected: isSelected,
                          label: Text(
                            label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5.sp,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textHeadline,
                            ),
                          ),
                          backgroundColor: const Color(0xFFF4F6F0),
                          selectedColor: AppColors.primary,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFE2E6D5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          onSelected: (val) async {
                            HapticFeedback.selectionClick();
                            if (range == 'Custom') {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2025),
                                lastDate: DateTime(2027),
                                initialDateRange: tempCustomRange ??
                                    DateTimeRange(
                                      start: DateTime.now()
                                          .subtract(const Duration(days: 14)),
                                      end: DateTime.now(),
                                    ),
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  tempDateRange = 'Custom';
                                  tempCustomRange = picked;
                                });
                              }
                            } else {
                              setSheetState(() {
                                tempDateRange = range;
                                tempCustomRange = null;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 24.h),

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedCategory = tempCategory;
                            _selectedDateRange = tempDateRange;
                            _customDateRange = tempCustomRange;
                          });
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          'Apply Filter ($previewCount Jobs)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            );
          },
        );
      },
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
        case JobCategory.toStart:
          priceLabel = 'Approved Quote';
          priceText = 'LKR ${job.totalEffectivePrice.toStringAsFixed(2)}';
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
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                  decoration: BoxDecoration(
                    color: job.isInstantOrder
                        ? const Color(0xFFFFF7ED)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: job.isInstantOrder
                          ? const Color(0xFFFED7AA)
                          : const Color(0xFFBFDBFE),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        job.isInstantOrder
                            ? Icons.flash_on_rounded
                            : Icons.calendar_today_rounded,
                        size: 11.r,
                        color: job.isInstantOrder
                            ? const Color(0xFFEA580C)
                            : const Color(0xFF2563EB),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        job.isInstantOrder ? 'Instant' : 'Scheduled',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                          color: job.isInstantOrder
                              ? const Color(0xFFEA580C)
                              : const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 7.w),
                Expanded(
                  child: Text(
                    job.isInstantOrder
                        ? job.requestedTime
                        : '${job.formattedScheduledDate} • ${job.effectiveTimeSlot}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // ─── 3. Customer & Location Line ─────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 14.r,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    job.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHeadline,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  width: 3.r,
                  height: 3.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFBAC095),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.location_on_outlined,
                  size: 13.r,
                  color: AppColors.textMuted,
                ),
                SizedBox(width: 2.w),
                Flexible(
                  child: Text(
                    job.distance,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                if (job.isAssignedByCompany ||
                    ProviderSessionService.instance.isCompanyProvider) ...[
                  const Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: const Color(0xFFD8B4FE),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.business_rounded,
                          size: 10.r,
                          color: const Color(0xFF7E22CE),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'Company Assigned',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B21A8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            SizedBox(height: 12.h),
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

                // Quick Action buttons on card
                if (job.status == JobCategory.pendingApprove) ...[
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        job.status = JobCategory.toStart;
                      });
                      DynamicIslandToast.showSuccess(
                        context,
                        '✓ Customer approved quote! Moved to To Start.',
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color:
                              const Color(0xFF16A34A).withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 13.r,
                            color: const Color(0xFF16A34A),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Approve Quote',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ] else if (job.status == JobCategory.toStart) ...[
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        job.status = JobCategory.ongoing;
                      });
                      DynamicIslandToast.showSuccess(
                        context,
                        'Job started! Moved to Ongoing.',
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 11.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488),
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0D9488)
                                .withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            size: 15.r,
                            color: Colors.white,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Start Job',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],

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


  Widget _buildEmptyState(JobCategory category) {
    if (_hasActiveFilters || _searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.filter_alt_off_rounded,
                  size: 30.r,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'No Matching Jobs',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHeadline,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'No jobs match your selected category or date filters in this section.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5.sp,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _selectedCategory = 'All';
                    _selectedDateRange = 'All';
                    _customDateRange = null;
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  'Reset Filters',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
      case JobCategory.toStart:
        title = 'No Jobs Ready To Start';
        subtitle =
            'When customers approve your submitted quotes, they will appear here ready to commence.';
        icon = Icons.play_circle_outline_rounded;
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
