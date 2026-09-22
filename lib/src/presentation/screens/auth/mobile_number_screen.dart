import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:provider_app/core/constants/app_assets.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/presentation/screens/auth/otp_verification_screen.dart';
import 'package:provider_app/src/presentation/widgets/dev_bypass_sheet.dart';

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

class MobileNumberScreen extends StatefulWidget {
  const MobileNumberScreen({super.key});

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  CountryCode _selectedCountry = CountryCode.supported.first;
  bool _isValidNumber = false;
  bool _isFocused = false;

  late AnimationController _animController;
  late Animation<Offset> _sheetSlideAnimation;
  late Animation<double> _sheetFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _contentFadeAnimation;

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

    _phoneFocusNode.addListener(() {
      setState(() {
        _isFocused = _phoneFocusNode.hasFocus;
      });
    });

    _phoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final text = _phoneController.text.replaceAll(' ', '');
    final valid = text.length >= 9 && text.length <= 10;
    if (valid != _isValidNumber) {
      setState(() {
        _isValidNumber = valid;
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

  void _handleSendCode() {
    if (!_isValidNumber) return;

    HapticFeedback.mediumImpact();
    final fullNumber = '${_selectedCountry.code} ${_phoneController.text}';

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => OtpVerificationScreen(
          phoneNumber: fullNumber,
        ),
      ),
    );
  }

  void _handleDevBypass() {
    DevBypassSheet.bypassToHome(context);
  }

  void _handleDevOptions() {
    final fullNumber = _phoneController.text.trim().isNotEmpty
        ? '${_selectedCountry.code} ${_phoneController.text.trim()}'
        : DevBypassSheet.defaultTestPhone;

    DevBypassSheet.show(
      context,
      currentPhoneNumber: fullNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.darkHeaderBg,
        body: Stack(
          children: [
            // Top Section - Header Photo Banner
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
                            Icons.phone_android_rounded,
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

            // Bottom Section - Animated White Card Sheet
            Positioned(
              top: (screenHeight * 0.33).clamp(180.0, 320.0),
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
                    child: SafeArea(
                      top: false,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: IntrinsicHeight(
                                child: SlideTransition(
                                  position: _contentSlideAnimation,
                                  child: FadeTransition(
                                    opacity: _contentFadeAnimation,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Top Grabber Pill
                                        Center(
                                          child: Container(
                                            margin: EdgeInsets.only(
                                              top: 12.h,
                                              bottom: 6.h,
                                            ),
                                            width: 38.w,
                                            height: 4.h,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE2E4DE),
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: 16.h),

                                        // Title
                                        Text(
                                          'Enter your\nMobile Number',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 30.sp,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textHeadline,
                                            height: 1.15,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),

                                        // Subtitle
                                        Text(
                                          'We will send you a 6-digit verification code to securely access your provider account.',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14.5.sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary,
                                            letterSpacing: -0.1,
                                            height: 1.35,
                                          ),
                                        ),
                                        SizedBox(height: 24.h),

                                        // Phone Input Field with Integrated Country Code Button
                                        _buildPhoneInputField(),

                                        SizedBox(height: 14.h),

                                        // Security Info Note
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.lock_outline_rounded,
                                              size: 15.r,
                                              color: AppColors.textMuted,
                                            ),
                                            SizedBox(width: 6.w),
                                            Expanded(
                                              child: Text(
                                                'We will never share your personal phone number.',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.textMuted,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const Spacer(),

                                        // Send Code Button & Dev Bypass
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 20.h,
                                            top: 16.h,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildSendCodeButton(),
                                              if (kDebugMode || !kReleaseMode) ...[
                                                SizedBox(height: 12.h),
                                                _buildDevBypassButton(),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.cardUnselectedBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: _isFocused
              ? AppColors.borderSelected
              : AppColors.borderUnselected,
          width: _isFocused ? 1.6 : 1.2,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Country Selector Segment
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showCountryPicker,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                bottomLeft: Radius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 16.h,
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
              focusNode: _phoneFocusNode,
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
                  vertical: 16.h,
                ),
              ),
              onSubmitted: (_) => _handleSendCode(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendCodeButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _isValidNumber ? _handleSendCode : null,
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
              'Send Code',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
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

  Widget _buildDevBypassButton() {
    return Container(
      width: double.infinity,
      height: 52.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(
          color: const Color(0xFFFFB74D),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26.r),
          onTap: _handleDevBypass,
          onLongPress: _handleDevOptions,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDD5),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    color: const Color(0xFFEA580C),
                    size: 18.r,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bypass to Home Page (Dev)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC2410C),
                        ),
                      ),
                      Text(
                        'Skip login & enter Provider Home Dashboard',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9A3412),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Dev Screen Jump',
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: const Color(0xFFC2410C),
                    size: 20.r,
                  ),
                  onPressed: _handleDevOptions,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
