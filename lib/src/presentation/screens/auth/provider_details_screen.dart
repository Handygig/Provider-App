import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_assets.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/presentation/screens/auth/living_details_screen.dart';

class CountryCode {
  final String flag;
  final String name;
  final String code;

  const CountryCode({
    required this.flag,
    required this.name,
    required this.code,
  });

  static const List<CountryCode> supported = [
    CountryCode(flag: '🇱🇰', name: 'Sri Lanka', code: '+94'),
    CountryCode(flag: '🇺🇸', name: 'United States', code: '+1'),
    CountryCode(flag: '🇬🇧', name: 'United Kingdom', code: '+44'),
    CountryCode(flag: '🇮🇳', name: 'India', code: '+91'),
    CountryCode(flag: '🇦🇺', name: 'Australia', code: '+61'),
    CountryCode(flag: '🇸🇬', name: 'Singapore', code: '+65'),
    CountryCode(flag: '🇦🇪', name: 'UAE', code: '+971'),
  ];
}

class ProviderDetailsScreen extends StatefulWidget {
  final String? phoneNumber;

  const ProviderDetailsScreen({
    super.key,
    this.phoneNumber,
  });

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  CountryCode _selectedCountry = CountryCode.supported.first;
  bool _formValid = false;

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

    if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
      final cleanPhone = widget.phoneNumber!.replaceAll(' ', '');
      bool found = false;
      for (var country in CountryCode.supported) {
        if (cleanPhone.startsWith(country.code)) {
          _selectedCountry = country;
          _phoneController.text = cleanPhone.substring(country.code.length);
          found = true;
          break;
        }
      }
      if (!found) {
        _phoneController.text = widget.phoneNumber!;
      }
    }

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

    _firstNameController.addListener(_validateForm);
    _lastNameController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _emailController.addListener(_validateForm);

    _validateForm();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();

    _animController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final isValidEmail = emailRegex.hasMatch(email);
    final isValidPhone = phone.length >= 9;

    final valid = firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        isValidPhone &&
        isValidEmail;

    if (valid != _formValid) {
      setState(() {
        _formValid = valid;
      });
    }
  }

  void _showCountryPicker() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
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
                SizedBox(height: 16.h),
                Text(
                  'Select Country / Region',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: 12.h),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: CountryCode.supported.length,
                    separatorBuilder: (_, index) => Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    itemBuilder: (context, index) {
                      final country = CountryCode.supported[index];
                      final isSelected = country.code == _selectedCountry.code;

                      return ListTile(
                        onTap: () {
                          setState(() {
                            _selectedCountry = country;
                          });
                          _validateForm();
                          Navigator.pop(context);
                        },
                        leading: Text(
                          country.flag,
                          style: TextStyle(fontSize: 24.sp),
                        ),
                        title: Text(
                          country.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              country.code,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (isSelected) ...[
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 20.r,
                              ),
                            ],
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
      },
    );
  }

  void _handleImagePicker() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile image selection',
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleContinue() {
    if (!_formValid) return;
    HapticFeedback.mediumImpact();

    final fullNumber = '${_selectedCountry.code} ${_phoneController.text.trim()}';

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => LivingDetailsScreen(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: fullNumber,
          email: _emailController.text.trim(),
          providerType: 'individual',
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
                            Icons.badge_rounded,
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
                                        'Provider\nProfile Setup',
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
                                        'Enter your details to complete your provider account setup.',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: 18.h),

                                      // Profile Photo Uploader (At the top of the form)
                                      Center(
                                        child: _buildImagePicker(),
                                      ),
                                      SizedBox(height: 20.h),

                                      // Name Field Row (2 Columns: First Name & Last Name)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInputField(
                                              controller: _firstNameController,
                                              focusNode: _firstNameFocus,
                                              nextFocus: _lastNameFocus,
                                              label: 'First Name',
                                              hint: 'e.g. Nimal',
                                              icon: Icons.person_outline_rounded,
                                            ),
                                          ),
                                          SizedBox(width: 14.w),
                                          Expanded(
                                            child: _buildInputField(
                                              controller: _lastNameController,
                                              focusNode: _lastNameFocus,
                                              nextFocus: _phoneFocus,
                                              label: 'Last Name',
                                              hint: 'e.g. Perera',
                                              icon: Icons.person_outline_rounded,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16.h),

                                      // Phone Number Field (with integrated country code selector)
                                      Text(
                                        'Phone Number',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textHeadline,
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      _buildPhoneInputField(),
                                      SizedBox(height: 16.h),

                                      // Email Address Field
                                      _buildInputField(
                                        controller: _emailController,
                                        focusNode: _emailFocus,
                                        nextFocus: null,
                                        label: 'Email Address',
                                        hint: 'e.g. pro@jobhive.com',
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        icon: Icons.mail_outline_rounded,
                                      ),
                                      SizedBox(height: 16.h),
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

  Widget _buildPhoneInputField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardUnselectedBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _phoneFocus.hasFocus
              ? AppColors.borderSelected
              : AppColors.borderUnselected,
          width: _phoneFocus.hasFocus ? 1.6 : 1.2,
        ),
      ),
      child: Row(
        children: [
          // Country Selector Segment
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showCountryPicker,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                bottomLeft: Radius.circular(16.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 14.h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry.flag,
                      style: TextStyle(fontSize: 20.sp),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _selectedCountry.code,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18.r,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Divider Line
          Container(
            height: 28.h,
            width: 1,
            color: AppColors.borderUnselected,
          ),

          // Phone Number Input
          Expanded(
            child: TextField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                hintText: '7X XXX XXXX',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 14.h,
                ),
              ),
              onSubmitted: (_) {
                _emailFocus.requestFocus();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _handleImagePicker,
      child: Stack(
        children: [
          Container(
            width: 88.r,
            height: 88.r,
            decoration: BoxDecoration(
              color: AppColors.cardUnselectedBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderUnselected,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.person_rounded,
              size: 44.r,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_a_photo_rounded,
                size: 13.r,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _formValid ? _handleContinue : null,
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
