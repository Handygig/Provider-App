import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_assets.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/presentation/screens/auth/verification_screen.dart';

class ServiceAssignmentItem {
  final String id;
  final String title;
  final IconData icon;

  const ServiceAssignmentItem({
    required this.id,
    required this.title,
    required this.icon,
  });
}

class ServiceAssignmentScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String providerType;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String postalCode;

  const ServiceAssignmentScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.providerType,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.postalCode,
  });

  @override
  State<ServiceAssignmentScreen> createState() => _ServiceAssignmentScreenState();
}

class _ServiceAssignmentScreenState extends State<ServiceAssignmentScreen>
    with SingleTickerProviderStateMixin {
  final Set<String> _selectedCategories = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<ServiceAssignmentItem> _services = const [
    ServiceAssignmentItem(id: 'plumbing', title: 'Plumbing', icon: Icons.plumbing_rounded),
    ServiceAssignmentItem(id: 'electrical', title: 'Electrical', icon: Icons.electric_bolt_rounded),
    ServiceAssignmentItem(id: 'painting', title: 'Painting', icon: Icons.format_paint_rounded),
    ServiceAssignmentItem(id: 'cleaning', title: 'Cleaning', icon: Icons.cleaning_services_rounded),
    ServiceAssignmentItem(id: 'carpentry', title: 'Carpentry', icon: Icons.carpenter_rounded),
    ServiceAssignmentItem(id: 'ac_repair', title: 'AC Repair', icon: Icons.ac_unit_rounded),
    ServiceAssignmentItem(id: 'appliances', title: 'Appliance Repair', icon: Icons.kitchen_rounded),
    ServiceAssignmentItem(id: 'gardening', title: 'Gardening', icon: Icons.yard_rounded),
  ];

  late AnimationController _animController;
  late Animation<Offset> _sheetSlideAnimation;
  late Animation<double> _sheetFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _contentFadeAnimation;

  double _sheetTop = 0;
  double _defaultTop = 0;
  bool _hasCalculatedDefaultTop = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _sheetSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _sheetFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOut),
      ),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.20, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.20, 0.85, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _toggleCategory(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedCategories.contains(id)) {
        _selectedCategories.remove(id);
      } else {
        _selectedCategories.add(id);
      }
    });
  }

  void _handleContinue() {
    if (_selectedCategories.isEmpty) return;
    HapticFeedback.mediumImpact();

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => VerificationScreen(
          firstName: widget.firstName,
          lastName: widget.lastName,
          phoneNumber: widget.phoneNumber,
          email: widget.email,
          providerType: widget.providerType,
          addressLine1: widget.addressLine1,
          addressLine2: widget.addressLine2,
          city: widget.city,
          postalCode: widget.postalCode,
          services: _selectedCategories.toList(),
        ),
      ),
    );
  }

  List<ServiceAssignmentItem> get _filteredServices {
    if (_searchQuery.isEmpty) return _services;
    return _services
        .where((s) => s.title.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topSafeArea = MediaQuery.of(context).padding.top;
    final minTop = topSafeArea + 12.h;

    if (!_hasCalculatedDefaultTop) {
      _defaultTop = (screenHeight * 0.28).clamp(150.0, 260.0);
      _sheetTop = _defaultTop;
      _hasCalculatedDefaultTop = true;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.darkHeaderBg,
        body: Stack(
          children: [
            // Top Header Banner
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: (screenHeight * 0.38).clamp(200.0, 360.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    AppAssets.phoneHeader,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.darkHeaderBg,
                        child: const Center(
                          child: Icon(
                            Icons.construction_rounded,
                            size: 64,
                            color: Colors.white24,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 100.h,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.45),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top-Left Circular Back Button
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 10.h,
                  ),
                  child: Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        splashColor: AppColors.primary.withValues(alpha: 0.15),
                        highlightColor:
                            AppColors.primary.withValues(alpha: 0.08),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).maybePop();
                        },
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(left: 3.w),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18.r,
                              color: AppColors.textHeadline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Section - Expandable White Card Sheet
            Positioned(
              top: _sheetTop,
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _sheetSlideAnimation,
                child: FadeTransition(
                  opacity: _sheetFadeAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.sheetBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(36.r),
                        topRight: Radius.circular(36.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 24,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Draggable Grabber Pill
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onVerticalDragUpdate: (details) {
                            setState(() {
                              _sheetTop += details.delta.dy;
                              if (_sheetTop < minTop) _sheetTop = minTop;
                              if (_sheetTop > _defaultTop) {
                                _sheetTop = _defaultTop;
                              }
                            });
                          },
                          onVerticalDragEnd: (details) {
                            final midPoint = (minTop + _defaultTop) / 2;
                            final velocity = details.primaryVelocity ?? 0;

                            setState(() {
                              if (velocity < -300 ||
                                  (_sheetTop < midPoint && velocity <= 300)) {
                                _sheetTop = minTop;
                              } else {
                                _sheetTop = _defaultTop;
                              }
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: Center(
                              child: Container(
                                width: 38.w,
                                height: 4.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2E4DE),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Form Scroll Content
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 4.h,
                            ),
                            child: SlideTransition(
                              position: _contentSlideAnimation,
                              child: FadeTransition(
                                opacity: _contentFadeAnimation,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    Text(
                                      'Service Assignment',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 30.sp,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textHeadline,
                                        height: 1.15,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Select the service categories you provide. You can select multiple jobs.',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: 18.h),

                                    // Live Search Bar
                                    _buildSearchBar(),
                                    SizedBox(height: 20.h),

                                    // Service Grid
                                    _filteredServices.isEmpty
                                        ? _buildNoResultsView()
                                        : GridView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 14.w,
                                              mainAxisSpacing: 14.h,
                                              childAspectRatio: 1.25,
                                            ),
                                            itemCount: _filteredServices.length,
                                            itemBuilder: (context, index) {
                                              final service = _filteredServices[index];
                                              final isSelected = _selectedCategories.contains(service.id);

                                              return GestureDetector(
                                                onTap: () => _toggleCategory(service.id),
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 250),
                                                  curve: Curves.easeInOutCubic,
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? AppColors.primary
                                                        : AppColors.cardUnselectedBg,
                                                    borderRadius: BorderRadius.circular(22.r),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? AppColors.primary
                                                          : AppColors.borderUnselected,
                                                      width: 1.6,
                                                    ),
                                                    boxShadow: isSelected
                                                        ? [
                                                            BoxShadow(
                                                              color: AppColors.primary.withValues(alpha: 0.2),
                                                              blurRadius: 10,
                                                              offset: const Offset(0, 4),
                                                            ),
                                                          ]
                                                        : [
                                                            BoxShadow(
                                                              color: Colors.black.withValues(alpha: 0.01),
                                                              blurRadius: 4,
                                                              offset: const Offset(0, 2),
                                                            ),
                                                          ],
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      // Circular Active Selection indicator
                                                      Positioned(
                                                        top: 12.h,
                                                        right: 12.w,
                                                        child: AnimatedContainer(
                                                          duration: const Duration(milliseconds: 200),
                                                          width: 22.r,
                                                          height: 22.r,
                                                          decoration: BoxDecoration(
                                                            color: isSelected
                                                                ? Colors.white
                                                                : Colors.white.withValues(alpha: 0.6),
                                                            shape: BoxShape.circle,
                                                            border: Border.all(
                                                              color: isSelected
                                                                  ? Colors.white
                                                                  : AppColors.borderUnselected,
                                                              width: 1.2,
                                                            ),
                                                          ),
                                                          child: isSelected
                                                              ? Icon(
                                                                  Icons.check_rounded,
                                                                  color: AppColors.primary,
                                                                  size: 14.r,
                                                                )
                                                              : null,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: 16.w,
                                                          vertical: 16.h,
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            AnimatedContainer(
                                                              duration: const Duration(milliseconds: 200),
                                                              padding: EdgeInsets.all(8.r),
                                                              decoration: BoxDecoration(
                                                                color: isSelected
                                                                    ? Colors.white.withValues(alpha: 0.15)
                                                                    : AppColors.cardSelectedBg,
                                                                shape: BoxShape.circle,
                                                              ),
                                                              child: Icon(
                                                                service.icon,
                                                                color: isSelected
                                                                    ? Colors.white
                                                                    : AppColors.primary,
                                                                size: 26.r,
                                                              ),
                                                            ),
                                                            SizedBox(height: 12.h),
                                                            Text(
                                                              service.title,
                                                              style: GoogleFonts.plusJakartaSans(
                                                                fontSize: 15.sp,
                                                                fontWeight: FontWeight.w800,
                                                                color: isSelected
                                                                    ? Colors.white
                                                                    : AppColors.textHeadline,
                                                                letterSpacing: -0.2,
                                                              ),
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
                                    SizedBox(height: 24.h),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Static Bottom Button Bar (Non-scrolling footer)
                        Padding(
                          padding: EdgeInsets.only(
                            left: 24.w,
                            right: 24.w,
                            bottom: 24.h,
                            top: 12.h,
                          ),
                          child: SlideTransition(
                            position: _contentSlideAnimation,
                            child: FadeTransition(
                              opacity: _contentFadeAnimation,
                              child: _buildContinueButton(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardUnselectedBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderUnselected,
          width: 1.2,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 22.r,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textHeadline,
              ),
              decoration: InputDecoration(
                hintText: 'Search jobs or categories...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
              },
              child: Icon(
                Icons.clear_rounded,
                size: 20.r,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 36.h),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48.r,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 12.h),
            Text(
              'No jobs found for "$_searchQuery"',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Try typing another category name.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final hasSelection = _selectedCategories.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: hasSelection ? _handleContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBackground,
          disabledBackgroundColor: AppColors.sage.withValues(alpha: 0.4),
          foregroundColor: AppColors.buttonText,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
            ),
            SizedBox(width: 8.w),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
