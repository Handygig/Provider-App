import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/data/services/verification_service.dart';
import 'package:provider_app/src/presentation/screens/home/home_screen.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';

class LicenseVerificationScreen extends StatefulWidget {
  const LicenseVerificationScreen({super.key});

  @override
  State<LicenseVerificationScreen> createState() =>
      _LicenseVerificationScreenState();
}

class _LicenseVerificationScreenState extends State<LicenseVerificationScreen> {
  final VerificationService _service = VerificationService.instance;

  late TextEditingController _nicController;
  late TextEditingController _brController;
  late TextEditingController _skillController;

  String? _localNicFront;
  String? _localNicBack;
  String? _localBrDoc;
  String? _localSkillCert;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nicController = TextEditingController(text: _service.nicNumber ?? '199214502341');
    _brController = TextEditingController(text: _service.brNumber ?? 'PV-00249182');
    _skillController = TextEditingController(text: _service.skillName ?? 'NVQ Level 4 - Plumbing & Gas Fitting');
    _localNicFront = _service.nicFrontPath;
    _localNicBack = _service.nicBackPath;
    _localBrDoc = _service.brDocPath;
    _localSkillCert = _service.skillCertPath;
  }

  @override
  void dispose() {
    _nicController.dispose();
    _brController.dispose();
    _skillController.dispose();
    super.dispose();
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
        DynamicIslandToast.showSuccess(context, 'Document uploaded successfully');
      }
    } catch (e) {
      if (!mounted) return;
      // On simulator or if camera unavailable, fallback to gallery
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

  void _submitForReview() {
    HapticFeedback.heavyImpact();
    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _service.submitDocuments(
        nicNumber: _nicController.text.trim(),
        brNumber: _brController.text.trim(),
        nicFrontPath: _localNicFront,
        nicBackPath: _localNicBack,
        brDocPath: _localBrDoc,
        skillCertPath: _localSkillCert,
      );

      setState(() => _isSubmitting = false);

      DynamicIslandToast.showSuccess(
        context,
        'Documents submitted! Admin review in progress.',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final status = _service.status;

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
                        _buildStatusCard(status),

                        SizedBox(height: 16.h),

                        // Simulation Dev Bar (For easy testing of approval lifecycle)
                        _buildDevSimulationCard(status),

                        SizedBox(height: 18.h),

                        // Section 1: National Identity Card (NIC) / Driving License
                        _buildNicSection(status),

                        SizedBox(height: 18.h),

                        // Section 2: Business Registration / Trade License
                        _buildBrSection(status),

                        SizedBox(height: 18.h),

                        // Section 3: Trade & Professional Certificates
                        _buildSkillSection(status),

                        SizedBox(height: 20.h),

                        // Guidelines & Trust Guarantee
                        _buildTrustNote(),
                      ],
                    ),
                  ),
                ),

                // 3. Sticky Bottom Action Bar
                _buildBottomBar(status),
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
  Widget _buildStatusCard(VerificationStatus status) {
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
        description = _service.adminFeedback ??
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

          if (status == VerificationStatus.pending && _service.submittedAt != null) ...[
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
                    'Submitted: ${_service.submittedAt!.hour.toString().padLeft(2, '0')}:${_service.submittedAt!.minute.toString().padLeft(2, '0')} • Expected review within 24h',
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
  // 3. ADMIN SIMULATION CARD (TESTING SWITCHER)
  // ---------------------------------------------------------------------------
  Widget _buildDevSimulationCard(VerificationStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3EB),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE0E5D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.admin_panel_settings_outlined,
                  size: 15.r, color: AppColors.primary),
              SizedBox(width: 5.w),
              Text(
                'Admin Simulation Tool (Quick Testing)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildSimulationButton(
                  label: 'Approve ✅',
                  color: const Color(0xFF16A34A),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _service.simulateAdminApproval();
                    DynamicIslandToast.showSuccess(
                        context, 'Simulated Admin Approval: Account Verified!');
                  },
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _buildSimulationButton(
                  label: 'Set Pending ⏳',
                  color: const Color(0xFF2563EB),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _service.submitDocuments();
                    DynamicIslandToast.showSuccess(
                        context, 'Simulated Under Review state');
                  },
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _buildSimulationButton(
                  label: 'Reject ❌',
                  color: const Color(0xFFDC2626),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _service.simulateAdminRejection();
                    DynamicIslandToast.showSuccess(
                        context, 'Simulated Rejection state');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. NIC SECTION
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
                        _service.setNicFront(path);
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
                        _service.setNicBack(path);
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
  // 5. BUSINESS REGISTRATION SECTION
  // ---------------------------------------------------------------------------
  Widget _buildBrSection(VerificationStatus status) {
    return _buildSectionCard(
      title: '2. Business Registration / Trade License',
      subtitle: 'Upload proof of registered business or Grama Niladhari certificate',
      isRequired: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Reg Number (Optional for sole proprietorships)',
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
              controller: _brController,
              enabled: status != VerificationStatus.approved,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textHeadline,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. PV-00249182',
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
            title: 'Business Registration Document',
            imagePath: _localBrDoc,
            isFullWidth: true,
            isVerified: status == VerificationStatus.approved,
            onUpload: () {
              _pickImageFor(
                title: 'Business Registration Document',
                onSelected: (path) {
                  setState(() => _localBrDoc = path);
                  _service.setBrDoc(path);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. SKILL CERTIFICATES SECTION
  // ---------------------------------------------------------------------------
  Widget _buildSkillSection(VerificationStatus status) {
    return _buildSectionCard(
      title: '3. Professional Skills & NVQ License',
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
                  _service.setSkillCert(path);
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
    final bool hasImage = imagePath != null;

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
                  Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF0F4E8),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.insert_drive_file_rounded,
                              color: AppColors.primary, size: 28.r),
                          SizedBox(height: 4.h),
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textHeadline,
                            ),
                          ),
                        ],
                      ),
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
                    'PNG, JPG up to 10MB',
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
  // 7. BOTTOM STICKY ACTION BAR
  // ---------------------------------------------------------------------------
  Widget _buildBottomBar(VerificationStatus status) {
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
                onPressed: _isSubmitting
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
                child: _isSubmitting
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
                                    : 'Submit Documents'),
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
