import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_assets.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/presentation/screens/auth/service_assignment_screen.dart';

class LivingDetailsScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String providerType;
  final String? regNumber;
  final String? taxId;

  const LivingDetailsScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.providerType,
    this.regNumber,
    this.taxId,
  });

  @override
  State<LivingDetailsScreen> createState() => _LivingDetailsScreenState();
}

class _LivingDetailsScreenState extends State<LivingDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  final FocusNode _addressLine1Focus = FocusNode();
  final FocusNode _addressLine2Focus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _postalCodeFocus = FocusNode();

  String? _selectedProvince;
  String? _selectedDistrict;

  bool _formValid = false;

  late AnimationController _animController;
  late Animation<Offset> _sheetSlideAnimation;
  late Animation<double> _sheetFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _contentFadeAnimation;

  double _sheetTop = 0;
  double _defaultTop = 0;
  bool _hasCalculatedDefaultTop = false;

  // Province and District Mock Data
  final Map<String, List<String>> _districtsByProvince = {
    'Western': ['Colombo', 'Gampaha', 'Kalutara'],
    'Central': ['Kandy', 'Matale', 'Nuwara Eliya'],
    'Southern': ['Galle', 'Matara', 'Hambantota'],
    'Northern': ['Jaffna', 'Kilinochchi', 'Mannar', 'Vavuniya', 'Mullaitivu'],
    'Eastern': ['Trincomalee', 'Batticaloa', 'Ampara'],
    'North Western': ['Kurunegala', 'Puttalam'],
    'North Central': ['Anuradhapura', 'Polonnaruwa'],
    'Uva': ['Badulla', 'Moneragala'],
    'Sabaragamuwa': ['Ratnapura', 'Kegalle'],
  };

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

    _addressLine1Controller.addListener(_validateForm);
    _addressLine2Controller.addListener(_validateForm);
    _cityController.addListener(_validateForm);
    _postalCodeController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();

    _addressLine1Focus.dispose();
    _addressLine2Focus.dispose();
    _cityFocus.dispose();
    _postalCodeFocus.dispose();

    _animController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final address1 = _addressLine1Controller.text.trim();
    final city = _cityController.text.trim();
    final postalCode = _postalCodeController.text.trim();

    setState(() {
      _formValid = address1.isNotEmpty &&
          city.isNotEmpty &&
          postalCode.isNotEmpty &&
          _selectedProvince != null &&
          _selectedDistrict != null;
    });
  }

  void _handleSubmit() {
    if (!_formValid) return;
    HapticFeedback.mediumImpact();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceAssignmentScreen(
          firstName: widget.firstName,
          lastName: widget.lastName,
          phoneNumber: widget.phoneNumber,
          email: widget.email,
          providerType: widget.providerType,
          regNumber: widget.regNumber,
          taxId: widget.taxId,
          addressLine1: _addressLine1Controller.text.trim(),
          addressLine2: _addressLine2Controller.text.trim(),
          city: _cityController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
        ),
      ),
    );
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
            // Top Header Photo
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: (screenHeight * 0.38).clamp(200.0, 360.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    AppAssets.profileHeader,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.darkHeaderBg,
                        child: const Center(
                          child: Icon(
                            Icons.home_work_rounded,
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
                        // Draggable Pill Area
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
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title
                                      Text(
                                        'Living Details',
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
                                        'Provide your residential address details to complete registration.',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: 20.h),

                                      // Address Line 1
                                      _buildInputField(
                                        controller: _addressLine1Controller,
                                        focusNode: _addressLine1Focus,
                                        nextFocus: _addressLine2Focus,
                                        label: 'Address Line 1',
                                        hint: 'e.g. No. 45, Temple Road',
                                        icon: Icons.home_outlined,
                                      ),
                                      SizedBox(height: 16.h),

                                      // Address Line 2
                                      _buildInputField(
                                        controller: _addressLine2Controller,
                                        focusNode: _addressLine2Focus,
                                        nextFocus: _cityFocus,
                                        label: 'Address Line 2',
                                        hint: 'e.g. Kirulapone',
                                        icon: Icons.location_on_outlined,
                                      ),
                                      SizedBox(height: 16.h),

                                      // City & Postal Code (Row)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInputField(
                                              controller: _cityController,
                                              focusNode: _cityFocus,
                                              nextFocus: _postalCodeFocus,
                                              label: 'City',
                                              hint: 'e.g. Colombo',
                                              icon: Icons.location_city_outlined,
                                            ),
                                          ),
                                          SizedBox(width: 14.w),
                                          Expanded(
                                            child: _buildInputField(
                                              controller: _postalCodeController,
                                              focusNode: _postalCodeFocus,
                                              label: 'Postal Code',
                                              hint: 'e.g. 00600',
                                              keyboardType: TextInputType.number,
                                              icon: Icons.markunread_mailbox_outlined,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16.h),

                                      // Province Selector
                                      _buildDropdownField(
                                        label: 'Province',
                                        value: _selectedProvince,
                                        hint: 'Select Province',
                                        items: _districtsByProvince.keys.toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            _selectedProvince = val;
                                            _selectedDistrict = null;
                                          });
                                          _validateForm();
                                        },
                                      ),
                                      SizedBox(height: 16.h),

                                      // District Selector
                                      _buildDropdownField(
                                        label: 'District',
                                        value: _selectedDistrict,
                                        hint: 'Select District',
                                        items: _selectedProvince != null
                                            ? (_districtsByProvince[_selectedProvince] ?? [])
                                            : [],
                                        onChanged: _selectedProvince != null
                                            ? (val) {
                                                setState(() {
                                                  _selectedDistrict = val;
                                                });
                                                _validateForm();
                                              }
                                            : null,
                                      ),
                                      SizedBox(height: 24.h),
                                    ],
                                  ),
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
                              child: _buildSubmitButton(),
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeadline,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.cardUnselectedBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.borderUnselected,
              width: 1.2,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hint,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                ),
              ),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textHeadline,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardUnselectedBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: focusNode.hasFocus
                  ? AppColors.borderSelected
                  : AppColors.borderUnselected,
              width: focusNode.hasFocus ? 1.6 : 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: nextFocus != null
                ? TextInputAction.next
                : TextInputAction.done,
            onSubmitted: (_) {
              if (nextFocus != null) {
                nextFocus.requestFocus();
              } else {
                focusNode.unfocus();
              }
            },
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                icon,
                size: 20.r,
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _formValid ? _handleSubmit : null,
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
