import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider_app/core/constants/app_assets.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/presentation/screens/auth/under_review_screen.dart';
import 'package:provider_app/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:provider_app/src/presentation/blocs/auth/auth_event.dart';
import 'package:provider_app/src/presentation/blocs/auth/auth_state.dart';

class VerificationScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String providerType;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String postalCode;
  final List<String> services;

  const VerificationScreen({
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
    required this.services,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  // Document state
  String? _nicFrontName;
  String? _nicFrontPath;
  String? _nicBackName;
  String? _nicBackPath;

  bool _isUploadingFront = false;
  bool _isUploadingBack = false;

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
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _formValid = _nicFrontName != null && _nicBackName != null;
    });
  }

  Future<void> _pickDocument(String docType) async {
    HapticFeedback.lightImpact();
    setState(() {
      if (docType == 'front') _isUploadingFront = true;
      if (docType == 'back') _isUploadingBack = true;
    });
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (file == null) return;

      setState(() {
        if (docType == 'front') {
          _nicFrontPath = file.path;
          _nicFrontName = file.name;
        } else if (docType == 'back') {
          _nicBackPath = file.path;
          _nicBackName = file.name;
        }
      });
      _validateForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick document: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          if (docType == 'front') _isUploadingFront = false;
          if (docType == 'back') _isUploadingBack = false;
        });
      }
    }
  }

  void _removeDoc(String docType) {
    HapticFeedback.selectionClick();
    setState(() {
      if (docType == 'front') {
        _nicFrontName = null;
        _nicFrontPath = null;
      } else if (docType == 'back') {
        _nicBackName = null;
        _nicBackPath = null;
      }
    });
    _validateForm();
  }

  void _handleContinue() {
    if (!_formValid) return;
    HapticFeedback.mediumImpact();

    context.read<AuthBloc>().add(
      CompleteProfileRequested(
        providerType: 'individual',
        firstName: widget.firstName,
        lastName: widget.lastName,
        email: widget.email,
        regNumber: null,
        taxId: null,
        addressLine1: widget.addressLine1,
        addressLine2: widget.addressLine2,
        city: widget.city,
        state: 'Not Provided',
        postalCode: widget.postalCode,
        country: 'Sri Lanka',
        nicFrontPath: _nicFrontPath,
        nicBackPath: _nicBackPath,
        brCertificatePath: null,
        services: widget.services,
        profileImagePath: null,
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
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthProfileCompleted) {
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                builder: (context) => UnderReviewScreen(
                  firstName: widget.firstName,
                ),
              ),
            );
          } else if (state is AuthFailure && state.operation == AuthOperation.completeProfile) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading && state.operation == AuthOperation.completeProfile;
          return Scaffold(
        backgroundColor: AppColors.darkHeaderBg,
        body: Stack(
          children: [
            // Top Header Banner Photo
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
                            Icons.security_rounded,
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
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    Text(
                                      'KYC Verification',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 30.sp,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textHeadline,
                                        height: 1.15,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),

                                    // Description
                                    Text(
                                      'Please upload clear photos of your National Identity Card (NIC) front and back for verification.',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                    SizedBox(height: 24.h),

                                    // NIC Front Card
                                    Text(
                                      'ID Card Front Image',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textHeadline,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    _buildUploadCard(
                                      fileName: _nicFrontName,
                                      isUploading: _isUploadingFront,
                                      onTap: () => _pickDocument('front'),
                                      onRemove: () => _removeDoc('front'),
                                      label: 'Tap to upload NIC front image',
                                    ),
                                    SizedBox(height: 20.h),

                                    // NIC Back Card
                                    Text(
                                      'ID Card Back Image',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textHeadline,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    _buildUploadCard(
                                      fileName: _nicBackName,
                                      isUploading: _isUploadingBack,
                                      onTap: () => _pickDocument('back'),
                                      onRemove: () => _removeDoc('back'),
                                      label: 'Tap to upload NIC back image',
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
                              child: _buildContinueButton(isLoading),
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
      );
    },
    ),
    );
  }

  Widget _buildUploadCard({
    required String? fileName,
    required bool isUploading,
    required VoidCallback onTap,
    required VoidCallback onRemove,
    required String label,
  }) {
    final hasFile = fileName != null;

    return GestureDetector(
      onTap: isUploading || hasFile ? null : onTap,
      child: Container(
        height: 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: hasFile
              ? AppColors.cardSelectedBg
              : AppColors.cardUnselectedBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: hasFile
                ? AppColors.borderSelected
                : AppColors.borderUnselected,
            width: 1.5,
            style: hasFile ? BorderStyle.solid : BorderStyle.solid, // Custom dashed borders can be simulated with dotted lines
          ),
        ),
        child: isUploading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Uploading document...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : hasFile
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Icon(
                          Icons.file_present_rounded,
                          color: AppColors.primary,
                          size: 36.r,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                fileName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textHeadline,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Ready to submit',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red.shade600,
                            size: 22.r,
                          ),
                          onPressed: onRemove,
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          color: AppColors.textSecondary,
                          size: 32.r,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Max file size: 5 MB',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildContinueButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: (_formValid && !isLoading) ? _handleContinue : null,
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
                    'Finish',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.1,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ],
              ),
      ),
    );
  }
}
