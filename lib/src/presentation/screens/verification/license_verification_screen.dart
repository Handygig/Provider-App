import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/core/di/service_locator.dart';
import 'package:provider_app/src/data/services/verification_service.dart';
import 'package:provider_app/src/domain/entities/profile/provider_profile_entity.dart';
import 'package:provider_app/src/presentation/cubits/profile/profile_cubit.dart';
import 'package:provider_app/src/presentation/cubits/profile/profile_state.dart';
import 'package:provider_app/src/presentation/screens/home/home_screen.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';

class LicenseVerificationScreen extends StatefulWidget {
  const LicenseVerificationScreen({super.key});

  @override
  State<LicenseVerificationScreen> createState() =>
      _LicenseVerificationScreenState();
}

class _LicenseVerificationScreenState extends State<LicenseVerificationScreen> {
  late final TextEditingController _nicController;
  late final TextEditingController _skillController;

  String? _localNicFront;
  String? _localNicBack;
  String? _localSkillCert;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nicController = TextEditingController();
    _skillController = TextEditingController();
  }

  @override
  void dispose() {
    _nicController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _populateInitialData(ProviderProfileEntity profile) {
    if (_initialized) return;
    _initialized = true;

    final kyc = profile.kyc;
    _nicController.text = profile.addressLine1 != null ? (profile.regNumber ?? kyc?.nicNumber ?? '') : (kyc?.nicNumber ?? '');
    _skillController.text = kyc?.skillName ?? '';

    _localNicFront = kyc?.nicFrontUrl;
    _localNicBack = kyc?.nicBackUrl;
    _localSkillCert = kyc?.skillCertUrl;
  }

  void _navigateToHome() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _pickImageFor({
    required String title,
    required ValueChanged<String> onSelected,
  }) async {
    HapticFeedback.lightImpact();

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
                  'Upload $title',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Take a clear photo with good lighting or select from gallery',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(ctx);
                          await _executePick(ImageSource.camera, onSelected);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6F0),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: const Color(0xFFE2E6D5)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.camera_alt_rounded,
                                  color: AppColors.primary, size: 26.r),
                              SizedBox(height: 6.h),
                              Text(
                                'Camera',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textHeadline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(ctx);
                          await _executePick(ImageSource.gallery, onSelected);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6F0),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: const Color(0xFFE2E6D5)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.photo_library_rounded,
                                  color: const Color(0xFF2563EB), size: 26.r),
                              SizedBox(height: 6.h),
                              Text(
                                'Gallery',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textHeadline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _executePick(
    ImageSource source,
    ValueChanged<String> onSelected,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (image != null) {
        onSelected(image.path);
        if (!mounted) return;
        DynamicIslandToast.showSuccess(context, 'Document photo attached');
      }
    } catch (e) {
      if (!mounted) return;
      if (source == ImageSource.camera) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1280,
          maxHeight: 1280,
          imageQuality: 85,
        );
        if (image != null) {
          onSelected(image.path);
          if (!mounted) return;
          DynamicIslandToast.showSuccess(context, 'Document photo attached from Gallery');
        }
      } else {
        DynamicIslandToast.showError(context, 'Could not access photos: $e');
      }
    }
  }

  Future<void> _submitForReview() async {
    HapticFeedback.heavyImpact();

    final nicNumber = _nicController.text.trim();
    if (nicNumber.isEmpty && (_localNicFront == null || _localNicFront!.isEmpty)) {
      DynamicIslandToast.showError(
        context,
        'Please enter your National ID number or attach document photo',
      );
      return;
    }

    final success = await context.read<ProfileCubit>().submitKyc(
      nicNumber: nicNumber.isNotEmpty ? nicNumber : null,
      nicFrontPath: _localNicFront,
      nicBackPath: _localNicBack,
      skillCertPath: _localSkillCert,
      skillName: _skillController.text.trim().isNotEmpty
          ? _skillController.text.trim()
          : null,
    );

    if (success && mounted) {
      DynamicIslandToast.showSuccess(
        context,
        'Documents submitted! Admin review in progress.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      BlocProvider.of<ProfileCubit>(context);
      return _buildWithCubit(context);
    } catch (_) {
      return BlocProvider(
        create: (_) => sl<ProfileCubit>()..loadProfile(),
        child: Builder(builder: (ctx) => _buildWithCubit(ctx)),
      );
    }
  }

  Widget _buildWithCubit(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          if (state.kycSubmitSuccess != null) {
            DynamicIslandToast.showSuccess(context, state.kycSubmitSuccess!);
          } else if (state.kycSubmitError != null) {
            DynamicIslandToast.showError(context, state.kycSubmitError!);
          }
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return const Scaffold(
            backgroundColor: Color(0xFFF7F8F4),
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is ProfileError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F8F4),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 48.r, color: const Color(0xFFDC2626)),
                  SizedBox(height: 12.h),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      color: AppColors.textHeadline,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final loaded = state as ProfileLoaded;
        final profile = loaded.profile;
        _populateInitialData(profile);

        final kyc = profile.kyc;
        final VerificationStatus status;
        if (profile.isApproved || (kyc != null && kyc.isApproved)) {
          status = VerificationStatus.approved;
        } else if (profile.isRejected || (kyc != null && kyc.isRejected)) {
          status = VerificationStatus.rejected;
        } else if (kyc != null && kyc.isPending) {
          status = VerificationStatus.pending;
        } else {
          status = VerificationStatus.notSubmitted;
        }

        final isSubmitting = loaded.isSubmittingKyc;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF7F8F4),
            body: Column(
              children: [
                // 1. Top App Bar with Shortcut to Home Page
                _buildAppBar(status),

                // 2. Scrollable Document Form Canvas
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 100.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Verification Status Banner
                        _buildStatusCard(status, kyc),

                        SizedBox(height: 18.h),

                        // Section 1: National Identity Card (NIC) / Driving License
                        _buildNicSection(status),

                        SizedBox(height: 18.h),

                        // Section 2: Trade & Professional Certificates (Optional)
                        _buildSkillSection(status),

                        SizedBox(height: 20.h),

                        // Guidelines & Trust Guarantee
                        _buildTrustNote(),
                      ],
                    ),
                  ),
                ),

                // 3. Sticky Bottom Action Bar
                _buildBottomBar(status, isSubmitting),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 1. TOP APP BAR WITH HOME SHORTCUT
  // ---------------------------------------------------------------------------
  Widget _buildAppBar(VerificationStatus status) {
    return Container(
      color: AppColors.primaryDark,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        left: 12.w,
        right: 14.w,
        bottom: 12.h,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18.r,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'License & Verification',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.5.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Provider ID & Compliance Portal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),

          // Shortcut to Home Page Button
          GestureDetector(
            onTap: _navigateToHome,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.home_rounded,
                    color: AppColors.accentLime,
                    size: 16.r,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Home',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. STATUS CARD (UNDER REVIEW / VERIFIED / ACTION REQUIRED)
  // ---------------------------------------------------------------------------
  Widget _buildStatusCard(VerificationStatus status, KycVerificationEntity? kyc) {
    IconData statusIcon;
    String title;
    String description;
    Color accentColor = status.color;
    Color bgColor = status.backgroundColor;

    switch (status) {
      case VerificationStatus.pending:
        statusIcon = Icons.hourglass_top_rounded;
        title = 'Under Admin Review';
        description =
            'Your documents have been submitted to Handygig Compliance. You cannot access customer jobs or withdraw payouts until approved by an administrator.';
        break;
      case VerificationStatus.approved:
        statusIcon = Icons.verified_rounded;
        title = 'Account Fully Verified';
        description =
            'All identification and credentials approved by admin. You have unrestricted access to all service jobs, bids, and financial payouts.';
        break;
      case VerificationStatus.rejected:
        statusIcon = Icons.error_outline_rounded;
        title = 'Action Required (Changes Requested)';
        description = kyc?.rejectionReason ??
            'Your submitted document photos did not meet compliance requirements. Please review admin feedback below and re-upload.';
        break;
      case VerificationStatus.notSubmitted:
        statusIcon = Icons.upload_file_rounded;
        title = 'Verification Incomplete';
        description =
            'To protect our customers and activate your service provider profile, please upload your National Identity Card and credentials.';
        break;
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: accentColor.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: accentColor, size: 20.r),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    Text(
                      'Status: ${status.label}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  status.badgeText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          if (status == VerificationStatus.rejected && kyc?.rejectionReason != null) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16.r, color: const Color(0xFFDC2626)),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'Admin Note: ${kyc!.rejectionReason}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (status == VerificationStatus.pending) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFDCE2D1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 13.r, color: AppColors.primary),
                  SizedBox(width: 5.w),
                  Text(
                    'Expected review within 24h',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHeadline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. NIC SECTION
  // ---------------------------------------------------------------------------
  Widget _buildNicSection(VerificationStatus status) {
    return _buildSectionCard(
      title: '1. National ID / Driving License',
      subtitle: 'Required for client safety and payment settlement authorization',
      isRequired: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NIC Number Input
          Text(
            'National ID or Passport Number',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeadline,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAF6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E6D5)),
            ),
            child: TextField(
              controller: _nicController,
              enabled: status != VerificationStatus.approved,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textHeadline,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. 199214502341 or 921452341V',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5.sp,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // 2 Upload Slots: Front & Back
          Row(
            children: [
              Expanded(
                child: _buildUploadSlot(
                  title: 'Front Side',
                  imagePath: _localNicFront,
                  isVerified: status == VerificationStatus.approved,
                  onUpload: () {
                    _pickImageFor(
                      title: 'NIC Front Side',
                      onSelected: (path) {
                        setState(() => _localNicFront = path);
                      },
                    );
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildUploadSlot(
                  title: 'Back Side',
                  imagePath: _localNicBack,
                  isVerified: status == VerificationStatus.approved,
                  onUpload: () {
                    _pickImageFor(
                      title: 'NIC Back Side',
                      onSelected: (path) {
                        setState(() => _localNicBack = path);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. SKILL CERTIFICATES SECTION
  // ---------------------------------------------------------------------------
  Widget _buildSkillSection(VerificationStatus status) {
    return _buildSectionCard(
      title: '2. Professional Skills & NVQ License',
      subtitle: 'Increases customer trust and boosts quotation acceptance rate',
      isRequired: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Certificate Title / Trade Body',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeadline,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAF6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E6D5)),
            ),
            child: TextField(
              controller: _skillController,
              enabled: status != VerificationStatus.approved,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textHeadline,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. NVQ Level 4 - Technical Certification',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5.sp,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          _buildUploadSlot(
            title: 'NVQ / Trade License Certificate',
            imagePath: _localSkillCert,
            isFullWidth: true,
            isVerified: status == VerificationStatus.approved,
            onUpload: () {
              _pickImageFor(
                title: 'Trade Certificate',
                onSelected: (path) {
                  setState(() => _localSkillCert = path);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // REUSABLE CARD WRAPPER
  // ---------------------------------------------------------------------------
  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required bool isRequired,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE5E9DC), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHeadline,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isRequired ? const Color(0xFFEFF6FF) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  isRequired ? 'Required' : 'Optional',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: isRequired ? const Color(0xFF2563EB) : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5.sp,
              color: AppColors.textMuted,
            ),
          ),
          Divider(color: const Color(0xFFEFF2E6), height: 20.h),
          child,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UPLOAD SLOT COMPONENT
  // ---------------------------------------------------------------------------
  Widget _buildUploadSlot({
    required String title,
    required String? imagePath,
    required VoidCallback onUpload,
    bool isFullWidth = false,
    bool isVerified = false,
  }) {
    final bool hasImage = imagePath != null && imagePath.isNotEmpty;
    final bool isNetwork = hasImage && (imagePath.startsWith('http://') || imagePath.startsWith('https://'));

    return GestureDetector(
      onTap: isVerified ? null : onUpload,
      child: Container(
        height: isFullWidth ? 110.h : 130.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: hasImage ? Colors.white : const Color(0xFFF9FAF6),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasImage
                ? (isVerified ? const Color(0xFF16A34A) : AppColors.primary)
                : const Color(0xFFDCE2D1),
            width: hasImage ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  isNetwork
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFF0F4E8),
                            alignment: Alignment.center,
                            child: Icon(Icons.insert_drive_file_rounded,
                                color: AppColors.primary, size: 28.r),
                          ),
                        )
                      : Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFF0F4E8),
                            alignment: Alignment.center,
                            child: Icon(Icons.insert_drive_file_rounded,
                                color: AppColors.primary, size: 28.r),
                          ),
                        ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.65),
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isVerified ? Icons.check_circle_rounded : Icons.edit_rounded,
                            color: isVerified ? const Color(0xFF4ADE80) : Colors.white,
                            size: 12.r,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            isVerified ? 'Verified' : 'Tap to replace',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.primary,
                      size: 22.r,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHeadline,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'PNG, JPG up to 5MB',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTrustNote() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5E8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFDEE5D2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_rounded,
              color: AppColors.primary, size: 18.r),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Your uploaded documents are securely encrypted and stored according to Sri Lankan data privacy standards. They are only utilized for partner compliance verification.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. BOTTOM STICKY ACTION BAR
  // ---------------------------------------------------------------------------
  Widget _buildBottomBar(VerificationStatus status, bool isSubmitting) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18.w,
        10.h,
        18.w,
        MediaQuery.of(context).padding.bottom + 10.h,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEFF2E6), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Shortcut to Home button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFDCE2D1)),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            onPressed: _navigateToHome,
            icon: const Icon(Icons.home_rounded, size: 18, color: AppColors.primary),
            label: Text(
              'Home',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textHeadline,
              ),
            ),
          ),
          SizedBox(width: 10.w),

          // Main Submit / Status Action
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: status == VerificationStatus.approved
                      ? const Color(0xFF16A34A)
                      : (status == VerificationStatus.pending
                          ? const Color(0xFF2563EB)
                          : AppColors.primary),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                onPressed: isSubmitting
                    ? null
                    : () {
                        if (status == VerificationStatus.approved) {
                          _navigateToHome();
                        } else if (status == VerificationStatus.pending) {
                          DynamicIslandToast.showSuccess(
                            context,
                            'Admin review in progress. You will be notified once approved.',
                          );
                        } else {
                          _submitForReview();
                        }
                      },
                child: isSubmitting
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            status == VerificationStatus.approved
                                ? Icons.verified_rounded
                                : (status == VerificationStatus.pending
                                    ? Icons.hourglass_top_rounded
                                    : Icons.upload_file_rounded),
                            size: 18.r,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            status == VerificationStatus.approved
                                ? 'Verified • Access Home'
                                : (status == VerificationStatus.pending
                                    ? 'Under Admin Review'
                                    : (status == VerificationStatus.rejected
                                        ? 'Re-submit Documents'
                                        : 'Submit Documents')),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
