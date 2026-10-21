import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/domain/models/job_model.dart';
import 'package:provider_app/src/presentation/screens/chat/chat_screen.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobModel job;
  final ValueChanged<JobModel>? onJobUpdated;

  const JobDetailsScreen({
    super.key,
    required this.job,
    this.onJobUpdated,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late JobModel _job;

  // Mini Map Coordinates & State
  static const LatLng _customerLocation = LatLng(6.9034, 79.8546);
  static const LatLng _providerLocation = LatLng(6.9147, 79.8653);
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _job = widget.job;
    _initMap();
  }

  void _initMap() {
    _markers.add(
      Marker(
        markerId: const MarkerId('customer_location'),
        position: _customerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: _job.customerName,
          snippet: _job.address,
        ),
      ),
    );
    _markers.add(
      Marker(
        markerId: const MarkerId('provider_location'),
        position: _providerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(
          title: 'Your Location',
          snippet: 'Current location',
        ),
      ),
    );
    _polylines.add(
      const Polyline(
        polylineId: PolylineId('route_preview'),
        points: [_providerLocation, _customerLocation],
        color: AppColors.primary,
        width: 4,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _advanceStage(
    JobCategory newStatus, {
    required String successMessage,
  }) {
    if (_job.status == newStatus) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _job.status = newStatus;
      if (newStatus == JobCategory.finished && _job.completionDate == null) {
        final now = DateTime.now();
        final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
        final period = now.hour >= 12 ? 'PM' : 'AM';
        final minute = now.minute.toString().padLeft(2, '0');
        _job.completionDate = 'Today, $hour:$minute $period';
        _job.finalRating = 5.0;
        _job.clientFeedback = 'Great service delivered on schedule!';
      }
    });

    widget.onJobUpdated?.call(_job);

    DynamicIslandToast.showSuccess(
      context,
      successMessage,
    );
  }

  void _openQuotationDialog() {
    final amountController = TextEditingController(
      text: _job.quotedAmount != null
          ? _job.quotedAmount!.toStringAsFixed(0)
          : (_job.estimatedBudget?.toStringAsFixed(0) ?? '75'),
    );
    final notesController = TextEditingController(
      text: _job.quoteNotes ?? 'Includes labor and 30-day warranty.',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24.w,
            right: 24.w,
            top: 16.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E4DE),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Submit Quotation',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Enter quotation price for ${_job.customerName}. Submitting will automatically advance this job to Pending Approval.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHeadline,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      width: 50.w,
                      alignment: Alignment.center,
                      child: Text(
                        'LKR',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    hintText: 'e.g. 85.00',
                    filled: true,
                    fillColor: AppColors.cardSelectedBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(
                        color: AppColors.borderSelected,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5.sp),
                  decoration: InputDecoration(
                    hintText: 'Notes for client (warranty, scope, etc.)...',
                    filled: true,
                    fillColor: AppColors.cardSelectedBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(
                        color: AppColors.borderUnselected,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      final val = double.tryParse(amountController.text.trim()) ??
                          _job.estimatedBudget ??
                          60.0;
                      Navigator.pop(context);
                      setState(() {
                        _job.quotedAmount = val;
                        _job.quoteNotes = notesController.text.trim();
                        _job.status = JobCategory.pendingApprove;
                      });
                      widget.onJobUpdated?.call(_job);
                      DynamicIslandToast.showSuccess(
                        context,
                        'Quote LKR ${val.toStringAsFixed(2)} sent! Auto-advanced to Pending Approval.',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBackground,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                    child: Text(
                      'Send Quote • Advance to Pending Approval',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openExtraQuotationDialog() {
    final basePrice = _job.quotedAmount ?? _job.estimatedBudget ?? 0.0;
    final extraAmountController = TextEditingController(
      text: _job.extraAmount != null && _job.extraAmount! > 0
          ? _job.extraAmount!.toStringAsFixed(0)
          : '25',
    );
    final reasonController = TextEditingController(
      text: _job.extraReason ?? 'Additional replacement parts and extra labor',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final extraVal =
                double.tryParse(extraAmountController.text.trim()) ?? 0.0;
            final newTotal = basePrice + extraVal;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24.w,
                right: 24.w,
                top: 16.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E4DE),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.post_add_rounded,
                            color: Color(0xFFEA580C),
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request Extra Quotation',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textHeadline,
                                ),
                              ),
                              Text(
                                'Ongoing Job Variation • Customer Must Approve',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8F4),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.borderUnselected),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Approved Base Quote:',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'LKR ${basePrice.toStringAsFixed(2)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textHeadline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'Additional Extra Amount (LKR)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: extraAmountController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      onChanged: (val) {
                        setSheetState(() {});
                      },
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeadline,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.add_rounded,
                            color: Color(0xFFEA580C)),
                        hintText: 'e.g. 25.00',
                        filled: true,
                        fillColor: AppColors.cardSelectedBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: const BorderSide(
                              color: AppColors.borderSelected),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'Reason for Extra Charge',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: reasonController,
                      maxLines: 2,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.sp),
                      decoration: InputDecoration(
                        hintText:
                            'e.g. Extra brass valve replacement, additional sealant and 1hr labor...',
                        filled: true,
                        fillColor: AppColors.cardSelectedBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: const BorderSide(
                              color: AppColors.borderUnselected),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('New Total (If Approved):',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600)),
                              Text('LKR ${newTotal.toStringAsFixed(2)}',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFD97706))),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  size: 15, color: Color(0xFFB45309)),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  'Customer ${_job.customerName} will receive a prompt to approve or decline this extra charge.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5.sp,
                                    color: const Color(0xFF92400E),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final extraVal = double.tryParse(
                                  extraAmountController.text.trim()) ??
                              0.0;
                          if (extraVal <= 0) {
                            DynamicIslandToast.showError(context,
                                'Please enter a valid extra amount.');
                            return;
                          }
                          Navigator.pop(context);
                          setState(() {
                            _job.extraAmount = extraVal;
                            _job.extraReason = reasonController.text.trim();
                            _job.extraStatus = ExtraApprovalStatus.pending;
                          });
                          widget.onJobUpdated?.call(_job);
                          DynamicIslandToast.showSuccess(
                            context,
                            'Extra LKR ${extraVal.toStringAsFixed(2)} requested! Sent to customer for approval.',
                          );
                        },
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          'Send Extra Request to Customer',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _simulateCustomerExtraResponse({required bool approved}) {
    HapticFeedback.mediumImpact();
    setState(() {
      _job.extraStatus =
          approved ? ExtraApprovalStatus.approved : ExtraApprovalStatus.rejected;
    });
    widget.onJobUpdated?.call(_job);

    if (approved) {
      DynamicIslandToast.showSuccess(
        context,
        'Customer approved extra LKR ${_job.extraAmount!.toStringAsFixed(2)}!',
      );
    } else {
      DynamicIslandToast.showError(
        context,
        'Customer declined extra quotation request.',
      );
    }
  }

  void _openCompletionDialog() {
    final remarksController = TextEditingController(
      text: 'Job completed according to customer specifications.',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24.w,
            right: 24.w,
            top: 16.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E4DE),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF16A34A),
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Mark Job Completed',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textHeadline,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  'Confirm that all service work for ${_job.customerName} has been performed. This will automatically finalize the job as Finished.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 14.h),
                if (_job.hasPendingExtra) ...[
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                          color: const Color(0xFFFDE68A), width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Color(0xFFD97706), size: 18),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Notice: An extra quote of +LKR ${_job.extraAmount!.toStringAsFixed(2)} is still pending customer approval. If finalized now, only the approved base LKR ${_job.quotedAmount!.toStringAsFixed(2)} will be billed.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              color: const Color(0xFF92400E),
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F4),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: AppColors.borderUnselected,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Base Service Quote:',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'LKR ${(_job.quotedAmount ?? _job.estimatedBudget ?? 0.0).toStringAsFixed(2)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textHeadline,
                            ),
                          ),
                        ],
                      ),
                      if (_job.hasApprovedExtra) ...[
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Approved Extra Work:',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                            Text(
                              '+LKR ${_job.extraAmount!.toStringAsFixed(2)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ],
                      Divider(height: 16.h, color: AppColors.borderUnselected),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Due for Settlement:',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textHeadline,
                            ),
                          ),
                          Text(
                            'LKR ${_job.totalEffectivePrice.toStringAsFixed(2)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                TextField(
                  controller: remarksController,
                  maxLines: 2,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.sp),
                  decoration: InputDecoration(
                    labelText: 'Completion Remarks (Optional)',
                    filled: true,
                    fillColor: AppColors.cardSelectedBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(
                        color: AppColors.borderUnselected,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _advanceStage(
                        JobCategory.finished,
                        successMessage:
                            'Job finalized! Stage automatically updated to Finished.',
                      );
                    },
                    icon: const Icon(Icons.verified_rounded, size: 20),
                    label: Text(
                      'Confirm & Finalize as Finished',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openInvoiceDialog() {
    final basePrice = _job.quotedAmount ?? _job.estimatedBudget ?? 0.0;
    final extraPrice = _job.hasApprovedExtra ? (_job.extraAmount ?? 0.0) : 0.0;
    final totalPrice = _job.totalEffectivePrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 28.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E4DE),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Invoice Summary',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textHeadline,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'PAID',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAF7),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.borderUnselected),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Invoice ID',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp, color: AppColors.textMuted)),
                        Text('INV-${_job.id.replaceAll('JOB-', '')}',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Divider(height: 20.h, color: AppColors.borderUnselected),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Customer',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp, color: AppColors.textMuted)),
                        Text(_job.customerName,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Divider(height: 20.h, color: AppColors.borderUnselected),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Base Service Quote',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp, color: AppColors.textMuted)),
                        Text('LKR ${basePrice.toStringAsFixed(2)}',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    if (_job.hasApprovedExtra) ...[
                      Divider(height: 20.h, color: AppColors.borderUnselected),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Approved Extra: ${_job.extraReason ?? "Parts & Labor"}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5.sp,
                                color: const Color(0xFF15803D),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '+LKR ${extraPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ],
                    Divider(height: 20.h, color: AppColors.borderUnselected),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount Paid',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp, fontWeight: FontWeight.w700)),
                        Text('LKR ${totalPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF16A34A))),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBackground,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                  child: Text(
                    'Close Invoice',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFBFB),
        body: Column(
          children: [
            // Top Dark Header
            _buildTopHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Stage Progress Pipeline Card (Auto-updated)
                    _buildStageProgressCard(),

                    SizedBox(height: 18.h),

                    // 2. Customer & Address Details Card
                    _buildCustomerCard(),

                    SizedBox(height: 18.h),

                    // 3. Service Scope & Description Card
                    _buildJobOverviewCard(),

                    SizedBox(height: 18.h),

                    // 4. Financials / Quotation Card
                    _buildFinancialsCard(),

                    SizedBox(height: 18.h),

                    // 5. Payment Method Card
                    _buildPaymentMethodCard(),

                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),

            // Bottom Action Footer Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.primaryDark,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12.h,
        left: 16.w,
        right: 20.w,
        bottom: 20.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                icon: Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18.r,
                    ),
                  ),
                ),
              ),
              Text(
                'Job Details',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _job.status.backgroundColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _job.status.badgeText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: _job.status.color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: Row(
              children: [
                Text(
                  _job.id,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD4DE95),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 4.r,
                  height: 4.r,
                  decoration: const BoxDecoration(
                    color: Colors.white38,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  _job.category,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                Text(
                  _job.distance,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
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
  // 1. AUTOMATIC STAGE PROGRESS PIPELINE CARD
  // ---------------------------------------------------------------------------
  Widget _buildStageProgressCard() {
    final currentIdx = _job.status.index;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.borderUnselected, width: 1),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.linear_scale_rounded,
                        size: 16.r,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Job Stage Progress',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textHeadline,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5E8),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFDDE6CD), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sync_rounded,
                      size: 12.r,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Auto • Step ${currentIdx + 1}/4',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 4-Step Stepper Pipeline (Read-Only)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              DynamicIslandToast.showSuccess(
                context,
                'Stages update automatically when you pass each milestone.',
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: List.generate(4, (index) {
                final category = JobCategory.values[index];
                final isPassed = index < currentIdx;
                final isCurrent = index == currentIdx;

                return Expanded(
                  child: Column(
                    children: [
                      // Node with Connecting Lines
                      SizedBox(
                        height: 34.r,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Left Connector
                            if (index > 0)
                              Positioned(
                                left: 0,
                                right: 17.r,
                                top: 15.5.r,
                                child: Container(
                                  height: 3.h,
                                  color: isPassed || isCurrent
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),

                            // Right Connector
                            if (index < 3)
                              Positioned(
                                left: 17.r,
                                right: 0,
                                top: 15.5.r,
                                child: Container(
                                  height: 3.h,
                                  color: isPassed
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),

                            // Center Circle
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: isCurrent ? 34.r : 28.r,
                              height: isCurrent ? 34.r : 28.r,
                              decoration: BoxDecoration(
                                color: isPassed
                                    ? const Color(0xFF16A34A)
                                    : isCurrent
                                        ? category.color
                                        : const Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCurrent
                                      ? Colors.white
                                      : isPassed
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFFD1D5DB),
                                  width: isCurrent ? 2.5 : 1.2,
                                ),
                                boxShadow: isCurrent
                                    ? [
                                        BoxShadow(
                                          color: category.color
                                              .withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: isPassed
                                    ? Icon(
                                        Icons.check_rounded,
                                        size: 15.r,
                                        color: Colors.white,
                                      )
                                    : isCurrent
                                        ? Icon(
                                            category.icon,
                                            size: 15.r,
                                            color: Colors.white,
                                          )
                                        : Text(
                                            '${index + 1}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5.sp,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF9CA3AF),
                                            ),
                                          ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 6.h),

                      // Label
                      Text(
                        category.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.sp,
                          fontWeight:
                              isCurrent ? FontWeight.w800 : FontWeight.w600,
                          color: isCurrent
                              ? category.color
                              : isPassed
                                  ? const Color(0xFF16A34A)
                                  : AppColors.textMuted,
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // Status Pill
                      Text(
                        isPassed
                            ? 'Passed ✓'
                            : isCurrent
                                ? 'Active'
                                : 'Pending',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.sp,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isPassed
                              ? const Color(0xFF16A34A)
                              : isCurrent
                                  ? category.color
                                  : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: 14.h),

          // Milestone Context Banner (Explaining current stage & auto-transition trigger)
          _buildMilestoneContextBanner(),
        ],
      ),
    );
  }

  Widget _buildMilestoneContextBanner() {
    Color bannerBg;
    Color bannerBorder;
    Color iconColor;
    IconData iconData;
    String stageTitle;
    String stageDesc;
    String actionHint;

    final price = _job.quotedAmount ?? _job.estimatedBudget ?? 0.0;

    switch (_job.status) {
      case JobCategory.toQuote:
        bannerBg = const Color(0xFFFFF7ED);
        bannerBorder = const Color(0xFFFFEDD5);
        iconColor = const Color(0xFFEA580C);
        iconData = Icons.edit_note_rounded;
        stageTitle = 'Stage 1: Quotation Pending';
        stageDesc =
            'Review customer request and send quote. Submitting your quotation will automatically advance this job to Pending Approval.';
        actionHint = 'Action: Submit Quotation below';
        break;

      case JobCategory.pendingApprove:
        bannerBg = const Color(0xFFFFFBEB);
        bannerBorder = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFD97706);
        iconData = Icons.hourglass_top_rounded;
        stageTitle = 'Stage 2: Awaiting Customer Approval';
        stageDesc =
            'Quote of LKR ${price.toStringAsFixed(2)} was sent. Customer is reviewing. Once approved, the job automatically shifts to Ongoing.';
        actionHint = 'Action: Client Approved • Start Job';
        break;

      case JobCategory.ongoing:
        if (_job.hasPendingExtra) {
          bannerBg = const Color(0xFFFFFBEB);
          bannerBorder = const Color(0xFFFDE68A);
          iconColor = const Color(0xFFD97706);
          iconData = Icons.hourglass_top_rounded;
          stageTitle = 'Stage 3: Ongoing • Extra Pending Approval';
          stageDesc =
              'Extra quote of +LKR ${_job.extraAmount!.toStringAsFixed(2)} for "${_job.extraReason}" requested. Awaiting customer confirmation.';
          actionHint = 'Status: Waiting for customer to accept variation';
        } else if (_job.hasApprovedExtra) {
          bannerBg = const Color(0xFFF0FDF4);
          bannerBorder = const Color(0xFFBBF7D0);
          iconColor = const Color(0xFF16A34A);
          iconData = Icons.construction_rounded;
          stageTitle = 'Stage 3: Ongoing • Extra Approved ✓';
          stageDesc =
              'Customer approved extra +LKR ${_job.extraAmount!.toStringAsFixed(2)}. New total payable is LKR ${_job.totalEffectivePrice.toStringAsFixed(2)}.';
          actionHint = 'Action: Mark Job Finished & Collect';
        } else {
          bannerBg = const Color(0xFFEFF6FF);
          bannerBorder = const Color(0xFFDBEAFE);
          iconColor = const Color(0xFF2563EB);
          iconData = Icons.construction_rounded;
          stageTitle = 'Stage 3: Service In Progress';
          stageDesc =
              'You are actively carrying out the service. You can request extra quotes if needed, or complete when finished.';
          actionHint = 'Action: Mark Job Finished & Collect';
        }
        break;

      case JobCategory.finished:
        bannerBg = const Color(0xFFF0FDF4);
        bannerBorder = const Color(0xFFDCFCE7);
        iconColor = const Color(0xFF16A34A);
        iconData = Icons.task_alt_rounded;
        stageTitle = 'Stage 4: Job Completed & Finalized';
        stageDesc =
            'All milestones successfully passed on ${_job.completionDate ?? "Today"}. Payout and feedback finalized with 5.0★ rating.';
        actionHint = 'Completed: Invoice available';
        break;
    }

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: bannerBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: 16.r, color: iconColor),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stageTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    Text(
                      'Locked',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  stageDesc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.arrow_forward_rounded,
                        size: 11.r, color: iconColor),
                    SizedBox(width: 4.w),
                    Text(
                      actionHint,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. CUSTOMER & ADDRESS DETAILS CARD
  // ---------------------------------------------------------------------------
  Widget _buildCustomerCard() {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.borderUnselected, width: 1),
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
          Text(
            'Customer Information',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeadline,
            ),
          ),
          SizedBox(height: 14.h),

          // Customer Profile Header
          Row(
            children: [
              Container(
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _job.customerName
                        .split(' ')
                        .map((n) => n.isNotEmpty ? n[0] : '')
                        .take(2)
                        .join(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _job.customerName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFEAB308), size: 16),
                        SizedBox(width: 3.w),
                        Text(
                          '${_job.customerRating} Rating',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textHeadline,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '(${_job.customerReviewsCount} jobs)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons: Phone & Chat
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      DynamicIslandToast.showSuccess(
                        context,
                        'Dialing ${_job.customerPhone}...',
                      );
                    },
                    child: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF86EFAC), width: 1),
                      ),
                      child: const Icon(
                        Icons.phone_rounded,
                        color: Color(0xFF15803D),
                        size: 19,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(job: _job),
                        ),
                      );
                    },
                    child: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 1),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: AppColors.primary,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          Divider(height: 24.h, color: AppColors.borderUnselected),

          // Address Information Box
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAF7),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.borderUnselected, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.location_on_rounded,
                      size: 18.r, color: AppColors.primary),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Location Address',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        _job.address,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textHeadline,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Distance: ${_job.distance} from your location',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Navigate',
                  icon: const Icon(Icons.directions_rounded,
                      color: AppColors.primary),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    DynamicIslandToast.showSuccess(
                      context,
                      'Launching navigation directions...',
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // ─── Interactive Mini Map Location Display ─────────────────────
          _buildMiniMapSection(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MINI MAP SECTION TO DISPLAY SERVICE LOCATION
  // ---------------------------------------------------------------------------
  Widget _buildMiniMapSection() {
    return Container(
      height: 175.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE2E6D5),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Google Map canvas
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _customerLocation,
              zoom: 14.5,
            ),
            mapType: MapType.normal,
            markers: _markers,
            polylines: _polylines,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

          // Top Info Pill
          Positioned(
            top: 10.h,
            left: 10.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.navigation_rounded,
                    size: 13.r,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${_job.distance} away • ~8 mins',
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

          // Recenter Button
          Positioned(
            top: 10.h,
            right: 10.w,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    const CameraPosition(
                      target: _customerLocation,
                      zoom: 15.0,
                    ),
                  ),
                );
              },
              child: Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  size: 16.r,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),

          // Bottom Action: Get Directions Button
          Positioned(
            bottom: 10.h,
            right: 10.w,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                DynamicIslandToast.showSuccess(
                  context,
                  'Opening navigation to ${_job.address}...',
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_rounded,
                      size: 15.r,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Get Directions',
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
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. JOB OVERVIEW & SCOPE
  // ---------------------------------------------------------------------------
  Widget _buildJobOverviewCard() {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.borderUnselected, width: 1),
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
          Text(
            'Service Scope & Request',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeadline,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            _job.serviceTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeadline,
              height: 1.25,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            _job.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5.sp,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3EB),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 16.r, color: AppColors.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _job.requestedTime,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHeadline,
                    ),
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
  // 4. FINANCIALS & QUOTATION (WITH ONGOING EXTRA APPROVAL)
  // ---------------------------------------------------------------------------
  Widget _buildFinancialsCard() {
    final hasQuote = _job.quotedAmount != null;
    final basePrice = _job.quotedAmount ?? _job.estimatedBudget ?? 0.0;
    final isOngoing = _job.status == JobCategory.ongoing;
    final totalBilled = _job.hasApprovedExtra
        ? _job.totalEffectivePrice
        : (_job.hasPendingExtra ? _job.totalWithPendingExtra : basePrice);
    final platformFee = totalBilled * 0.10;
    final netPayout = totalBilled - platformFee;

    String actionLabel = '';
    VoidCallback? actionTap;

    if (_job.status == JobCategory.toQuote) {
      actionLabel = 'Set Quote';
      actionTap = _openQuotationDialog;
    } else if (_job.status == JobCategory.pendingApprove) {
      actionLabel = 'Edit Quote';
      actionTap = _openQuotationDialog;
    } else if (isOngoing) {
      if (_job.extraStatus == ExtraApprovalStatus.none) {
        actionLabel = '+ Add Extra';
        actionTap = _openExtraQuotationDialog;
      } else if (_job.extraStatus == ExtraApprovalStatus.pending) {
        actionLabel = 'Edit Extra';
        actionTap = _openExtraQuotationDialog;
      } else if (_job.extraStatus == ExtraApprovalStatus.approved) {
        actionLabel = 'Extra Approved ✓';
        actionTap = null;
      } else if (_job.extraStatus == ExtraApprovalStatus.rejected) {
        actionLabel = 'Re-request Extra';
        actionTap = _openExtraQuotationDialog;
      }
    }

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.borderUnselected, width: 1),
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
              Text(
                'Financials & Pricing',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHeadline,
                ),
              ),
              if (actionLabel.isNotEmpty)
                GestureDetector(
                  onTap: actionTap,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: isOngoing
                          ? const Color(0xFFFFF7ED)
                          : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      actionLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: isOngoing
                            ? const Color(0xFFEA580C)
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 14.h),

          if (!hasQuote) ...[
            // ─── Unquoted State: Prices Hidden Until Quotation is Sent ───────
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAF6),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: const Color(0xFFE8ECE1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.request_quote_outlined,
                          size: 20.r,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quotation Required',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textHeadline,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Price breakdown, 10% platform charges, and your net take-home payout will be calculated once you send a quotation.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5.sp,
                                color: AppColors.textMuted,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 40.h,
                    child: ElevatedButton.icon(
                      onPressed: _openQuotationDialog,
                      icon: const Icon(Icons.send_rounded, size: 15),
                      label: Text(
                        'Send Quotation',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // ─── Detailed Price List Including Platform Charges ──────────────
            // 1. Quoted Base Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isOngoing ? 'Approved Base Service Fee' : 'Quoted Service Fee',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'LKR ${basePrice.toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHeadline,
                  ),
                ),
              ],
            ),

            // 2. Extra Charges (if any)
            if (_job.extraAmount != null && _job.extraAmount! > 0) ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Additional Extra Work:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _job.extraStatus == ExtraApprovalStatus.approved
                              ? const Color(0xFFDCFCE7)
                              : _job.extraStatus == ExtraApprovalStatus.rejected
                                  ? const Color(0xFFFEE2E2)
                                  : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          _job.extraStatus == ExtraApprovalStatus.approved
                              ? 'Approved'
                              : _job.extraStatus == ExtraApprovalStatus.rejected
                                  ? 'Declined'
                                  : 'Pending Approval',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: _job.extraStatus.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '+LKR ${_job.extraAmount!.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w800,
                      color: _job.extraStatus.color,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 8.h),

            // 3. Gross Total Billed to Client
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Client Billed:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHeadline,
                  ),
                ),
                Text(
                  'LKR ${totalBilled.toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHeadline,
                  ),
                ),
              ],
            ),

            Divider(height: 18.h, color: AppColors.borderUnselected),

            // 4. Platform Charges Breakdown (10%)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform Service Fee (10%)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                    Text(
                      'Handygig platform services & lead fee',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  '-LKR ${platformFee.toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // 5. Net Provider Earnings Card
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: const Color(0xFFBBF7D0),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Estimated Net Payout',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF15803D),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Take-home earnings after platform fee',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5.sp,
                          color: const Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'LKR ${netPayout.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ),

            if (_job.quoteNotes != null && _job.quoteNotes!.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Text(
                'Terms: ${_job.quoteNotes}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],

          // -------------------------------------------------------------------
          // Extra Approval State Alerts (When Ongoing)
          // -------------------------------------------------------------------
          if (isOngoing) ...[
            SizedBox(height: 14.h),

            // Case A: Pending Customer Approval
            if (_job.hasPendingExtra) ...[
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5.r),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF3C7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.hourglass_top_rounded,
                            size: 15,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Extra Quotation Awaiting Approval',
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
                      'Requested: +LKR ${_job.extraAmount!.toStringAsFixed(2)} for "${_job.extraReason}"',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Customer ${_job.customerName} must approve before this extra charge is finalized.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5.sp,
                        color: const Color(0xFF78350F),
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _simulateCustomerExtraResponse(
                                approved: true),
                            icon: const Icon(Icons.check_rounded, size: 14),
                            label: Text(
                              'Customer Approves ✓',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        OutlinedButton(
                          onPressed: () => _simulateCustomerExtraResponse(
                              approved: false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(
                                color: Color(0xFFFCA5A5), width: 1),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            'Decline ✕',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]

            // Case B: Approved by Customer
            else if (_job.hasApprovedExtra) ...[
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF16A34A), size: 18),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Approved Extra Charge (+LKR ${_job.extraAmount!.toStringAsFixed(2)})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF166534),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Scope: ${_job.extraReason}. This amount is confirmed and will be collected at completion.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5.sp,
                              color: const Color(0xFF14532D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]

            // Case C: Rejected by Customer
            else if (_job.extraStatus == ExtraApprovalStatus.rejected) ...[
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFFECACA), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cancel_rounded,
                        color: Color(0xFFDC2626), size: 18),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Customer declined the +LKR ${_job.extraAmount!.toStringAsFixed(2)} extra. Original quote remains active.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          color: const Color(0xFF991B1B),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _openExtraQuotationDialog,
                      child: Text(
                        'Re-request',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]

            // Case D: No Extra Added Yet -> Show Helper Banner
            else ...[
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAF7),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.borderUnselected, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_shopping_cart_rounded,
                        size: 18.r, color: const Color(0xFFEA580C)),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Discovered additional parts or labor needed on site?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    ElevatedButton(
                      onPressed: _openExtraQuotationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA580C),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        '+ Add Extra',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. PAYMENT METHOD CARD
  // ---------------------------------------------------------------------------
  Widget _buildPaymentMethodCard() {
    final isCash = _job.paymentMethod.toLowerCase().contains('cash');
    final isSettled = _job.status == JobCategory.finished;
    final totalPayable = _job.totalEffectivePrice;

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.borderUnselected, width: 1),
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
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      isCash ? Icons.payments_rounded : Icons.credit_card_rounded,
                      color: AppColors.primary,
                      size: 18.r,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Payment Method',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textHeadline,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isSettled
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSettled
                          ? Icons.check_circle_rounded
                          : Icons.pending_rounded,
                      size: 12.r,
                      color: isSettled
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD97706),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isSettled ? 'Settled' : 'Pay on Completion',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: isSettled
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9F5),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE8ECE1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E6D5)),
                  ),
                  child: Center(
                    child: Icon(
                      isCash
                          ? Icons.local_atm_rounded
                          : Icons.credit_card_rounded,
                      color: AppColors.primaryDark,
                      size: 20.r,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _job.paymentMethod,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textHeadline,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isCash
                            ? 'Collect LKR ${totalPayable.toStringAsFixed(2)} directly from customer upon finishing.'
                            : 'Online card payment held securely in escrow until job completion.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          color: AppColors.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.verified_user_rounded,
                size: 14.r,
                color: const Color(0xFF16A34A),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'Handygig Payment Protection: Verified provider payout guaranteed.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. BOTTOM ACTION BAR
  // ---------------------------------------------------------------------------
  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.borderUnselected, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52.h,
                child: _buildContextualActionButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextualActionButton() {
    switch (_job.status) {
      case JobCategory.toQuote:
        return ElevatedButton.icon(
          onPressed: _openQuotationDialog,
          icon: const Icon(Icons.send_rounded, size: 18),
          label: Text(
            'Submit Quotation',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonBackground,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.r),
            ),
          ),
        );

      case JobCategory.pendingApprove:
        return ElevatedButton.icon(
          onPressed: () => _advanceStage(
            JobCategory.ongoing,
            successMessage:
                'Customer approved! Stage automatically moved to Ongoing.',
          ),
          icon: const Icon(Icons.play_arrow_rounded, size: 20),
          label: Text(
            'Client Approved • Start Job',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.r),
            ),
          ),
        );

      case JobCategory.ongoing:
        return ElevatedButton.icon(
          onPressed: _openCompletionDialog,
          icon: const Icon(Icons.check_circle_rounded, size: 20),
          label: Text(
            'Mark Job Finished & Collect',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF15803D),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.r),
            ),
          ),
        );

      case JobCategory.finished:
        return OutlinedButton.icon(
          onPressed: _openInvoiceDialog,
          icon: const Icon(Icons.receipt_long_rounded, size: 18),
          label: Text(
            'View Job Invoice Receipt',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.r),
            ),
          ),
        );
    }
  }
}
