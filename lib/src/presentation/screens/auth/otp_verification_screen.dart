import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:provider_app/core/constants/app_assets.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/presentation/screens/auth/provider_details_screen.dart';
import 'package:provider_app/src/presentation/widgets/dev_bypass_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider_app/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:provider_app/src/presentation/blocs/auth/auth_event.dart';
import 'package:provider_app/src/presentation/blocs/auth/auth_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late AnimationController _animController;
  late Animation<Offset> _sheetSlideAnimation;
  late Animation<double> _sheetFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _contentFadeAnimation;

  Timer? _timer;
  int _resendCountdown = 30;
  bool _canResend = false;
  bool _isVerifying = false;
  bool _isComplete = false;

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
    _startResendTimer();

    // Focus first input automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 30;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 1) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _resendCountdown = 0;
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _checkOtpCompletion() {
    final code = _controllers.map((c) => c.text).join();
    final complete = code.length == 6;
    if (complete != _isComplete) {
      setState(() {
        _isComplete = complete;
      });
    }

    if (complete) {
      _verifyOtp();
    }
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    _checkOtpCompletion();
  }

  void _verifyOtp() {
    HapticFeedback.mediumImpact();
    final smsCode = _controllers.map((c) => c.text).join();
    context.read<AuthBloc>().add(VerifyOtpRequested(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    ));
  }

  void _bypassOtp() {
    HapticFeedback.mediumImpact();
    DevBypassSheet.bypassToHome(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                builder: (context) => ProviderDetailsScreen(
                  phoneNumber: widget.phoneNumber,
                ),
              ),
            );
          } else if (state is AuthFailure && state.operation == AuthOperation.verifyOtp) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading && state.operation == AuthOperation.verifyOtp;
          return Scaffold(
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
                    AppAssets.otpHeader,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.darkHeaderBg,
                        child: const Center(
                          child: Icon(
                            Icons.mark_email_read_rounded,
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
                                          'Enter 6-digit\nVerification Code',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 30.sp,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textHeadline,
                                            height: 1.15,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),

                                        // Subtitle with Phone Number
                                        RichText(
                                          text: TextSpan(
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14.5.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textSecondary,
                                              letterSpacing: -0.1,
                                            ),
                                            children: [
                                              const TextSpan(
                                                text: 'Code has been sent to ',
                                              ),
                                              TextSpan(
                                                text: widget.phoneNumber,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textHeadline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 28.h),

                                        // 6 OTP Input Boxes
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: List.generate(6, (index) {
                                            return _buildOtpBox(index);
                                          }),
                                        ),

                                        SizedBox(height: 24.h),

                                        // Resend Code Section
                                        Center(
                                          child: _canResend
                                              ? TextButton(
                                                  onPressed: () {
                                                    HapticFeedback
                                                        .lightImpact();
                                                    _startResendTimer();
                                                  },
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        AppColors.primary,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 16.w,
                                                      vertical: 8.h,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Resend Code',
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontSize: 14.5.sp,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppColors.primary,
                                                      decoration:
                                                          TextDecoration
                                                              .underline,
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  'Resend code in ${_resendCountdown.toString().padLeft(2, '0')}s',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.textMuted,
                                                  ),
                                                ),
                                        ),

                                        const Spacer(),

                                        // Verify Button & Dev Bypass
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 20.h,
                                            top: 16.h,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildVerifyButton(isLoading),
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
      );
    },
    ),
    );
  }

  Widget _buildOtpBox(int index) {
    final controller = _controllers[index];
    final focusNode = _focusNodes[index];
    final hasValue = controller.text.isNotEmpty;
    final isFocused = focusNode.hasFocus;

    return Container(
      width: 48.w,
      height: 56.h,
      decoration: BoxDecoration(
        color: hasValue
            ? AppColors.cardSelectedBg
            : AppColors.cardUnselectedBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isFocused
              ? AppColors.borderSelected
              : hasValue
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.borderUnselected,
          width: isFocused ? 2.0 : 1.2,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Center(
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace &&
                controller.text.isEmpty &&
                index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeadline,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (val) {
              _onDigitEntered(index, val);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: (_isComplete && !isLoading) ? _verifyOtp : null,
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
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Verify Code',
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
          onTap: _bypassOtp,
          onLongPress: _bypassOtp,
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
                        'Bypass OTP (Dev)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC2410C),
                        ),
                      ),
                      Text(
                        'Skip verification & proceed to details',
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
                  onPressed: _bypassOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
