import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/data/services/managed_services_service.dart';
import 'package:provider_app/src/domain/models/service_skill_model.dart';
import 'package:provider_app/src/presentation/screens/verification/license_verification_screen.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';

class ManagedServicesSkillsScreen extends StatefulWidget {
  const ManagedServicesSkillsScreen({super.key});

  @override
  State<ManagedServicesSkillsScreen> createState() =>
      _ManagedServicesSkillsScreenState();
}

class _ManagedServicesSkillsScreenState
    extends State<ManagedServicesSkillsScreen> {
  final ManagedServicesService _service = ManagedServicesService.instance;
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _customTagCtrl = TextEditingController();
  String _searchQuery = '';

  // Expandable state for each service card
  final Set<String> _expandedServiceIds = {'plumbing', 'ac_repair', 'electrical'};

  @override
  void dispose() {
    _searchCtrl.dispose();
    _customTagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final allServices = _service.allServices;
        final activeCount = _service.activeServices.length;

        final filteredServices = allServices.where((s) {
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          final matchesTitle = s.title.toLowerCase().contains(q) ||
              s.category.toLowerCase().contains(q);
          final matchesSub =
              s.subSkills.any((sub) => sub.toLowerCase().contains(q));
          return matchesTitle || matchesSub;
        }).toList();

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF7F8F4),
            body: Column(
              children: [
                // 1. Top Custom App Bar
                _buildTopAppBar(activeCount: activeCount, totalCount: allServices.length),

                // 2. Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 100.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Broadcasting Status Hero Banner
                        _buildBroadcastBanner(activeCount),

                        SizedBox(height: 18.h),

                        // Search Bar
                        _buildSearchBar(),

                        SizedBox(height: 20.h),

                        // Section Title: Available Trade Services
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Service Categories & Trades',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textHeadline,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '$activeCount of ${allServices.length} active on radar',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: _openAddServiceSheet,
                              icon: const Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Add Service',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDark,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),

                        // List of Service Skill Cards
                        ...filteredServices.map(
                          (service) => Padding(
                            padding: EdgeInsets.only(bottom: 14.h),
                            child: _buildServiceCard(service),
                          ),
                        ),

                        // Full-width Add Service Banner Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _openAddServiceSheet,
                            icon: const Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppColors.primaryDark,
                              size: 18,
                            ),
                            label: Text(
                              'Add Another Service Category',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 13.h),
                              side: const BorderSide(
                                color: Color(0xFFC7D3AF),
                                width: 1.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              backgroundColor: const Color(0xFFF1F5E9),
                            ),
                          ),
                        ),

                        // Requested Categories (Pending Admin Review) if any
                        if (_service.requestedCategories.isNotEmpty) ...[
                          SizedBox(height: 18.h),
                          _buildRequestedCategoriesSection(),
                        ],

                        SizedBox(height: 18.h),

                        // Custom Specialties & Tags Section
                        _buildSpecialtiesSection(),

                        SizedBox(height: 20.h),

                        // Verify More Skills / License CTA
                        _buildVerificationCta(),
                      ],
                    ),
                  ),
                ),

                // 3. Sticky Bottom Save Bar
                _buildBottomSaveBar(activeCount),
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
  Widget _buildTopAppBar({required int activeCount, required int totalCount}) {
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
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
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
                      'Managed Services & Skills',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Categories you offer to clients nearby',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
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
                  color: const Color(0xFFD4DE95),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  '$activeCount of $totalCount ON',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
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
  // 2. BROADCASTING BANNER
  // ---------------------------------------------------------------------------
  Widget _buildBroadcastBanner(int activeCount) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF38431E), Color(0xFF4F5C2B)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38431E).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4DE95).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sensors_rounded,
                  color: Color(0xFFD4DE95),
                  size: 20,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Services Live on Radar',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Clients can request quotations matching these skills',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: _service.activeServices.map((s) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFFD4DE95).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(s.icon, size: 13.r, color: const Color(0xFFD4DE95)),
                    SizedBox(width: 5.w),
                    Text(
                      s.category,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. SEARCH BAR
  // ---------------------------------------------------------------------------
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E9DC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (val) => setState(() => _searchQuery = val.trim()),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textHeadline,
        ),
        decoration: InputDecoration(
          hintText: 'Search services, trades or sub-skills...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12.5.sp,
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
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. SERVICE CARD
  // ---------------------------------------------------------------------------
  Widget _buildServiceCard(ServiceSkillModel service) {
    final isExpanded = _expandedServiceIds.contains(service.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: service.isEnabled
              ? AppColors.primary.withValues(alpha: 0.45)
              : const Color(0xFFE5E9DC),
          width: service.isEnabled ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Header Row (Always Visible)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 14.h),
            child: Row(
              children: [
                // Icon Avatar
                Container(
                  width: 46.r,
                  height: 46.r,
                  decoration: BoxDecoration(
                    color: service.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: Icon(
                      service.icon,
                      color: service.primaryColor,
                      size: 24.r,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              service.title,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textHeadline,
                              ),
                            ),
                          ),
                          if (service.isVerified) ...[
                            SizedBox(width: 5.w),
                            const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF16A34A),
                              size: 15,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '${service.activeSubSkills.length} of ${service.subSkills.length} sub-skills active',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Enable / Disable Switch
                Switch.adaptive(
                  value: service.isEnabled,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    _service.toggleService(service.id, val);
                    DynamicIslandToast.showSuccess(
                      context,
                      val
                          ? '${service.category} service activated'
                          : '${service.category} service paused',
                    );
                  },
                ),
              ],
            ),
          ),

          // Expand / Collapse Bar
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                if (isExpanded) {
                  _expandedServiceIds.remove(service.id);
                } else {
                  _expandedServiceIds.add(service.id);
                }
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFBFA),
                border: Border(
                  top: BorderSide(color: Color(0xFFF1F5E9)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isExpanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 18.r,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isExpanded
                            ? 'Hide Sub-Skills'
                            : 'Customize Sub-Skills',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (service.isVerified)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'VERIFIED SKILL',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF166534),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Expanded Content Area
          if (isExpanded) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Experience Level Box (Full Width)
                  _buildMetaBox(
                    label: 'EXPERIENCE LEVEL',
                    value: service.experienceLevel,
                    icon: Icons.workspace_premium_rounded,
                    onTap: () => _showExperiencePicker(service),
                  ),

                  SizedBox(height: 14.h),

                  // Sub-Skills Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sub-Skills (Tap to toggle)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textHeadline,
                        ),
                      ),
                      Text(
                        '${service.activeSubSkills.length} active',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: service.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Sub-skills Chips (No Add Skill Button inside card)
                  Wrap(
                    spacing: 7.w,
                    runSpacing: 7.h,
                    children: service.subSkills.map((sub) {
                      final isActive = service.activeSubSkills.contains(sub);
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _service.toggleSubSkill(service.id, sub);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? service.primaryColor.withValues(alpha: 0.12)
                                : const Color(0xFFF4F6F0),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: isActive
                                  ? service.primaryColor.withValues(alpha: 0.6)
                                  : const Color(0xFFE2E6D5),
                              width: isActive ? 1.3 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isActive
                                    ? Icons.check_circle_rounded
                                    : Icons.add_circle_outline_rounded,
                                size: 13.r,
                                color: isActive
                                    ? service.primaryColor
                                    : AppColors.textMuted,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                sub,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5.sp,
                                  fontWeight: isActive
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isActive
                                      ? service.primaryColor
                                      : AppColors.textHeadline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaBox({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAF4),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5EAD9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13.r, color: AppColors.primary),
                SizedBox(width: 4.w),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textHeadline,
                    ),
                  ),
                ),
                Icon(
                  Icons.edit_outlined,
                  size: 13.r,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. REQUESTED CATEGORIES SECTION (Pending Admin Approval)
  // ---------------------------------------------------------------------------
  Widget _buildRequestedCategoriesSection() {
    final requests = _service.requestedCategories;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: Color(0xFFD97706),
                  size: 16,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Requested Categories (Pending Review)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'Admin team will verify and add these categories to the platform catalog.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5.sp,
              color: const Color(0xFFB45309),
            ),
          ),
          SizedBox(height: 10.h),
          ...requests.map((req) {
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req['name'] ?? '',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textHeadline,
                          ),
                        ),
                        if ((req['experienceYears'] ?? '').isNotEmpty)
                          Text(
                            req['experienceYears'] ?? '',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'PENDING',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. CUSTOM SPECIALTIES & TAGS SECTION
  // ---------------------------------------------------------------------------
  Widget _buildSpecialtiesSection() {
    final tags = _service.customSpecialties;

    return Container(
      padding: EdgeInsets.all(16.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F6EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Custom Specialties & Highlights',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textHeadline,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showAddSpecialtyDialog,
                child: Text(
                  '+ Add Tag',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'Visible on your public provider profile to build client trust',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5.sp,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 12.h),

          // Tag Cloud
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: tags.map((tag) {
              return Container(
                padding: EdgeInsets.fromLTRB(10.w, 5.h, 6.w, 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5E9),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFD6E2C5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _service.removeCustomSpecialty(tag);
                      },
                      child: Container(
                        padding: EdgeInsets.all(2.r),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 12,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. VERIFICATION CTA
  // ---------------------------------------------------------------------------
  Widget _buildVerificationCta() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Color(0xFF2563EB),
              size: 20,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Want Verified Skill Badges?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Upload your NVQ certifications or technical trade licenses in the License & Verification portal to earn green verified checkmarks.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    height: 1.45,
                    color: const Color(0xFF1E40AF),
                  ),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LicenseVerificationScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        'Upload Trade Certificates',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 8. BOTTOM SAVE BAR
  // ---------------------------------------------------------------------------
  Widget _buildBottomSaveBar(int activeCount) {
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
              'All $activeCount active services saved to your profile!',
            );
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 20,
          ),
          label: Text(
            'Save Active Services ($activeCount Active)',
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

  // ---------------------------------------------------------------------------
  // 9. DIALOGS, SHEETS & PICKERS
  // ---------------------------------------------------------------------------

  /// Open bottom sheet showing pre-defined service categories and option to request admin
  void _openAddServiceSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddServiceCategorySheet(
        onServiceAdded: (service) {
          _service.addPredefinedService(service);
          setState(() {
            _expandedServiceIds.add(service.id);
          });
          DynamicIslandToast.showSuccess(
            context,
            '${service.category} added to your managed services!',
          );
        },
        onRequestNewCategory: () {
          Navigator.pop(ctx);
          _showRequestCategoryDialog();
        },
      ),
    );
  }

  /// Dialog to request a new service category from admin
  void _showRequestCategoryDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final expCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          contentPadding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 14.h),
          titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.handyman_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Service Category',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    Text(
                      'Submit new trade to Handygig Admin',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6.h),
                Text(
                  'Service / Trade Name *',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: nameCtrl,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g., Solar Inverter Maintenance',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: AppColors.textMuted,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAF4),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 11.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Color(0xFFE2E6D5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Color(0xFFE2E6D5)),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Your Experience & Qualifications',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: expCtrl,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g., 6 years commercial experience, NVQ 4',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: AppColors.textMuted,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAF4),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 11.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Color(0xFFE2E6D5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Color(0xFFE2E6D5)),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Scope & Typical Jobs *',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Describe what tasks you perform so the admin can review and add sub-skills...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: AppColors.textMuted,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAF4),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 11.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Color(0xFFE2E6D5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Color(0xFFE2E6D5)),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6EB),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Admin typically reviews and adds verified categories within 24 hours.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5.sp,
                            color: AppColors.primaryDark,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final desc = descCtrl.text.trim();
                final exp = expCtrl.text.trim();
                if (name.isEmpty) {
                  DynamicIslandToast.showError(
                    context,
                    'Please enter a category name',
                  );
                  return;
                }
                HapticFeedback.mediumImpact();
                _service.requestNewCategory(
                  name: name,
                  description: desc,
                  experienceYears: exp,
                );
                Navigator.pop(ctx);
                DynamicIslandToast.showSuccess(
                  context,
                  'Request for "$name" submitted to Admin!',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Submit Request',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  void _showAddSpecialtyDialog() {
    _customTagCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Add Specialty or Certification',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeadline,
            ),
          ),
          content: TextField(
            controller: _customTagCtrl,
            autofocus: true,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. Solar Inverter Setup, 24/7 Rapid Response',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                color: AppColors.textMuted,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFE2E6D5)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final tag = _customTagCtrl.text.trim();
                if (tag.isNotEmpty) {
                  _service.addCustomSpecialty(tag);
                  DynamicIslandToast.showSuccess(context, 'Specialty added');
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Add Tag',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showExperiencePicker(ServiceSkillModel service) {
    final levels = [
      'Intermediate (2-4 yrs)',
      'Specialist (5-7 yrs)',
      'Expert / Master (8+ yrs)',
      'Certified Wireman / Trade Pro',
    ];

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
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E4DE),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'Select Experience Level',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: 10.h),
                ...levels.map((lvl) {
                  final isSelected = service.experienceLevel == lvl;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      lvl,
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
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                          )
                        : null,
                    onTap: () {
                      _service.updateExperience(service.id, lvl);
                      Navigator.pop(ctx);
                      DynamicIslandToast.showSuccess(
                        context,
                        'Experience level updated',
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
}

// -----------------------------------------------------------------------------
// 10. PRE-DEFINED CATEGORY SELECTOR BOTTOM SHEET
// -----------------------------------------------------------------------------
class _AddServiceCategorySheet extends StatefulWidget {
  final void Function(ServiceSkillModel) onServiceAdded;
  final VoidCallback onRequestNewCategory;

  const _AddServiceCategorySheet({
    required this.onServiceAdded,
    required this.onRequestNewCategory,
  });

  @override
  State<_AddServiceCategorySheet> createState() =>
      _AddServiceCategorySheetState();
}

class _AddServiceCategorySheetState extends State<_AddServiceCategorySheet> {
  final TextEditingController _filterCtrl = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _filterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = ManagedServicesService.instance;
    final allPredefined = ManagedServicesService.predefinedCatalog;

    final filtered = allPredefined.where((cat) {
      if (_filter.isEmpty) return true;
      final q = _filter.toLowerCase();
      final inTitle = cat.title.toLowerCase().contains(q);
      final inCat = cat.category.toLowerCase().contains(q);
      final inSub = cat.subSkills.any((s) => s.toLowerCase().contains(q));
      return inTitle || inCat || inSub;
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle bar
            SizedBox(height: 12.h),
            Center(
              child: Container(
                width: 40.w,
                height: 4.5.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCDFD8),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Sheet Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.category_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Service Category',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.5.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textHeadline,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Select pre-defined trade or request a new one',
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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 22),
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),

            SizedBox(height: 14.h),

            // Search Pre-defined Catalog
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8F2),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE4E8DC)),
                ),
                child: TextField(
                  controller: _filterCtrl,
                  onChanged: (val) => setState(() => _filter = val.trim()),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search pre-defined trades...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5.sp,
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    suffixIcon: _filter.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16),
                            onPressed: () {
                              _filterCtrl.clear();
                              setState(() => _filter = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 11.h),
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // "Request New Category From Admin" Banner Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6EB),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFDCE5CB)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_moderator_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Can't find your service category?",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          Text(
                            'Request custom trade category from Admin',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5.sp,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: widget.onRequestNewCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'Request',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12.h),

            const Divider(height: 1, color: Color(0xFFEEF2E6)),

            // Pre-defined Categories List
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                itemCount: filtered.length,
                separatorBuilder: (_, index) => SizedBox(height: 10.h),
                itemBuilder: (ctx, idx) {
                  final cat = filtered[idx];
                  final isAlreadyAdded = service.isServiceAdded(cat.id);

                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isAlreadyAdded
                          ? const Color(0xFFF8FAF4)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isAlreadyAdded
                            ? const Color(0xFFE2E6D5)
                            : const Color(0xFFE8ECE1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44.r,
                          height: 44.r,
                          decoration: BoxDecoration(
                            color: cat.primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            cat.icon,
                            color: cat.primaryColor,
                            size: 22.r,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textHeadline,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${cat.subSkills.length} sub-skills (${cat.subSkills.take(3).join(', ')}...)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.sp,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        if (isAlreadyAdded)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: Color(0xFF166534),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'Added',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF166534),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.pop(ctx);
                              widget.onServiceAdded(cat);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 8.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'Add',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
