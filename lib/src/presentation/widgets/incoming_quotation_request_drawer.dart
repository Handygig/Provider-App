import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/domain/models/job_model.dart';
import 'package:provider_app/src/presentation/screens/jobs/job_details_screen.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';

class IncomingQuotationRequestDrawer extends StatefulWidget {
  final JobModel job;
  final Function(JobModel updatedJob)? onQuoteSent;

  const IncomingQuotationRequestDrawer({
    super.key,
    required this.job,
    this.onQuoteSent,
  });

  static Future<void> show(
    BuildContext context, {
    required JobModel job,
    Function(JobModel updatedJob)? onQuoteSent,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => IncomingQuotationRequestDrawer(
        job: job,
        onQuoteSent: onQuoteSent,
      ),
    );
  }

  @override
  State<IncomingQuotationRequestDrawer> createState() =>
      _IncomingQuotationRequestDrawerState();
}

class _IncomingQuotationRequestDrawerState
    extends State<IncomingQuotationRequestDrawer>
    with SingleTickerProviderStateMixin {
  bool _isQuoteFormVisible = false;
  bool _isCardMinimized = false;

  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _notesController;

  // Pulse animation for the customer location pin
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Map coordinates (Colombo 03 Kollupitiya area)
  static const LatLng _customerLocation = LatLng(6.9034, 79.8546);
  static const LatLng _providerLocation = LatLng(6.9147, 79.8653);

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    final initialBudget = widget.job.estimatedBudget ?? 80.00;
    _priceController =
        TextEditingController(text: initialBudget.toStringAsFixed(0));
    _durationController = TextEditingController(text: '1 - 2 Hours');
    _notesController = TextEditingController(
      text:
          'Includes on-site diagnostic, replacement parts & 6-month service guarantee.',
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutQuad),
    );

    _initMapMarkers();
  }

  void _initMapMarkers() {
    _markers.add(
      Marker(
        markerId: const MarkerId('customer_marker'),
        position: _customerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Customer: ${widget.job.customerName}',
          snippet: widget.job.address,
        ),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('provider_marker'),
        position: _providerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(
          title: 'Your Current Location',
          snippet: '2.1 km away (~8 mins)',
        ),
      ),
    );

    _polylines.add(
      const Polyline(
        polylineId: PolylineId('route_to_customer'),
        points: [_providerLocation, _customerLocation],
        color: AppColors.primary,
        width: 4,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _recenterCustomer() {
    HapticFeedback.lightImpact();
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: _customerLocation,
          zoom: 15.0,
        ),
      ),
    );
  }

  void _handleSendQuotation() {
    final amount = double.tryParse(_priceController.text.trim());
    if (amount == null || amount <= 0) {
      DynamicIslandToast.showSuccess(
        context,
        'Please enter a valid quotation amount',
      );
      return;
    }

    HapticFeedback.heavyImpact();

    // Update job status to Pending Approval
    widget.job.quotedAmount = amount;
    widget.job.quoteNotes = _notesController.text.trim();
    widget.job.status = JobCategory.pendingApprove;

    Navigator.pop(context);

    if (widget.onQuoteSent != null) {
      widget.onQuoteSent!(widget.job);
    }

    DynamicIslandToast.showSuccess(
      context,
      'Quotation of LKR ${amount.toStringAsFixed(2)} sent! Moved to Pending Approval.',
    );

    // Option to view job details immediately
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobDetailsScreen(job: widget.job),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final totalHeight = MediaQuery.of(context).size.height * 0.94;

    return Container(
      height: totalHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ─── 1. FULL GOOGLE MAP CANVAS (Fills Entire Drawer) ────────────────
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _customerLocation,
                zoom: 15.0,
              ),
              mapType: MapType.normal,
              markers: _markers,
              polylines: _polylines,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              onMapCreated: (controller) {
                _mapController = controller;
                Future.delayed(const Duration(milliseconds: 350), () {
                  _mapController?.showMarkerInfoWindow(
                    const MarkerId('customer_marker'),
                  );
                });
              },
            ),
          ),


          // ─── 2. PROMINENT CUSTOMER LOCATION PIN MARKER ON MAP ───────────────
          Positioned(
            top: _isCardMinimized
                ? totalHeight * 0.45
                : (_isQuoteFormVisible ? totalHeight * 0.18 : totalHeight * 0.26),
            left: 0,
            right: 0,
            child: Center(
              child: _buildCustomerMapMarker(),
            ),
          ),

          // ─── 3. TOP FLOATING HEADER (Overlaid on Map) ──────────────────────
          Positioned(
            top: 12.h,
            left: 16.w,
            right: 16.w,
            child: _buildTopFloatingHeader(),
          ),

          // ─── 4. FLOATING MAP ACTION BUTTONS ────────────────────────────────
          Positioned(
            top: 76.h,
            left: 16.w,
            child: _buildDistanceEtaChip(),
          ),

          Positioned(
            top: 76.h,
            right: 16.w,
            child: _buildMapActionButtons(),
          ),

          // ─── 5. FLOATING BOTTOM CARD (Interactive & Expandable) ────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomInteractiveCard(keyboardHeight),
          ),
        ],
      ),
    );
  }

  // ─── Top Floating Header Bar ──────────────────────────────────────────────
  Widget _buildTopFloatingHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E6D5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 8.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Pulsing Live Tag
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7.r,
                          height: 7.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'LIVE QUOTE REQUEST',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF16A34A),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4EB),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      widget.job.id,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textHeadline,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Prominent Animated Customer Location Pin Marker ───────────────────────
  Widget _buildCustomerMapMarker() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating Customer Callout Badge above Pin
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFD4DE95),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26.r,
                    height: 26.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4DE95),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.job.customerName.isNotEmpty
                          ? widget.job.customerName[0]
                          : 'C',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.job.customerName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: 1.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'CUSTOMER',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.job.address,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFD4DE95),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 6.h),

            // Pulsating Red Pin with Glowing Halo
            Stack(
              alignment: Alignment.center,
              children: [
                // Concentric Animated Ripple
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 50.r,
                    height: 50.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEF4444).withValues(
                        alpha: (1.8 - _pulseAnimation.value).clamp(0.0, 0.4),
                      ),
                    ),
                  ),
                ),

                // Main Pin Core
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.5),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            // Drop Pin Tip Shadow
            Container(
              width: 10.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Distance & ETA Overlay Chip ───────────────────────────────────────────
  Widget _buildDistanceEtaChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E6D5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.navigation_rounded,
            color: AppColors.primary,
            size: 15,
          ),
          SizedBox(width: 6.w),
          Text(
            '${widget.job.distance} (~8 mins away)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeadline,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Floating Map Actions (Recenter & Toggle Full View) ────────────────────
  Widget _buildMapActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Recenter Customer Pin
        GestureDetector(
          onTap: _recenterCustomer,
          child: Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: const Color(0xFFE2E6D5)),
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
        SizedBox(height: 8.h),

        // Toggle Full Map View
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _isCardMinimized = !_isCardMinimized;
            });
          },
          child: Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: _isCardMinimized ? AppColors.primary : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: _isCardMinimized
                    ? AppColors.primary
                    : const Color(0xFFE2E6D5),
              ),
            ),
            child: Icon(
              _isCardMinimized
                  ? Icons.expand_more_rounded
                  : Icons.map_outlined,
              color: _isCardMinimized ? Colors.white : AppColors.primary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Floating Bottom Card (Customer Scope, Quote Form, CTAs) ───────────────
  Widget _buildBottomInteractiveCard(double keyboardHeight) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      constraints: BoxConstraints(
        maxHeight: _isCardMinimized
            ? 96.h
            : (_isQuoteFormVisible
                ? MediaQuery.of(context).size.height * 0.72
                : MediaQuery.of(context).size.height * 0.46),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle & Card Header Bar
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isCardMinimized = !_isCardMinimized;
              });
            },
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Center(
                child: Container(
                  width: 44.w,
                  height: 4.5.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ),

          // Collapsed / Minimized View
          if (_isCardMinimized) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 14.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.job.customerName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textHeadline,
                          ),
                        ),
                        Text(
                          '${widget.job.serviceTitle} • LKR ${(widget.job.estimatedBudget ?? 80).toStringAsFixed(0)} Est.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isCardMinimized = false;
                      });
                    },
                    child: Text(
                      'View Details',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Expanded Scrollable Card Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  0,
                  20.w,
                  keyboardHeight + 20.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Category & Time Row
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: widget.job.categoryColor
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                widget.job.categoryIcon,
                                size: 14.r,
                                color: widget.job.categoryColor,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                widget.job.category,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: widget.job.categoryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.access_time_rounded,
                          size: 14.r,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          widget.job.requestedTime,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),

                    // Service Title
                    Text(
                      widget.job.serviceTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17.5.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textHeadline,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Customer Information & Rating Card
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9F3),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFE9ECE0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38.r,
                                height: 38.r,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  widget.job.customerName.isNotEmpty
                                      ? widget.job.customerName[0]
                                      : 'C',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.job.customerName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textHeadline,
                                      ),
                                    ),
                                    Text(
                                      'Customer • ${widget.job.customerPhone}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5.sp,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 7.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: Color(0xFFD97706),
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      '${widget.job.customerRating}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFB45309),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            widget.job.description,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5.sp,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Client Expected Budget:',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                'LKR ${(widget.job.estimatedBudget ?? 80.00).toStringAsFixed(2)} Est.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Quotation Preparation Form
                    if (_isQuoteFormVisible) ...[
                      _buildQuotationInputForm(),
                      SizedBox(height: 14.h),
                    ],

                    // Action Buttons
                    if (!_isQuoteFormVisible) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                setState(() {
                                  _isQuoteFormVisible = true;
                                });
                              },
                              icon: const Icon(
                                Icons.assignment_turned_in_rounded,
                                size: 18,
                              ),
                              label: Text(
                                'Approve & Prepare Quote',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(color: Color(0xFFFCA5A5)),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 14.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                              DynamicIslandToast.showSuccess(
                                context,
                                'Quotation request declined',
                              );
                            },
                            child: Text(
                              'Decline',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              onPressed: _handleSendQuotation,
                              icon: const Icon(
                                Icons.send_rounded,
                                size: 18,
                              ),
                              label: Text(
                                'Send Quotation to Client →',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textMuted,
                              side: const BorderSide(color: Color(0xFFDCE1D0)),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 14.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _isQuoteFormVisible = false;
                              });
                            },
                            child: Text(
                              'Back',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Quotation Input Form ──────────────────────────────────────────────────
  Widget _buildQuotationInputForm() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
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
                  const Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Send Formal Quotation',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textHeadline,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _isCardMinimized = true;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 15.r,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'View Map',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Price input
          Text(
            'Your Quoted Price (LKR)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeadline,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeadline,
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 14.w, right: 6.w),
                child: Center(
                  widthFactor: 0.0,
                  child: Text(
                    'LKR ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAF6),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFE2E6D5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Quick Price Suggestion Chips
          Row(
            children: [65, 80, 95, 120].map((amt) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _priceController.text = amt.toString();
                    setState(() {});
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4EB),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: const Color(0xFFE2E6D5),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'LKR $amt',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeadline,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 12.h),

          // Estimated Duration
          Text(
            'Estimated Work Duration',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeadline,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: _durationController,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAF6),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 10.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFE2E6D5)),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Quote Inclusions / Notes
          Text(
            'Service Scope & Notes for Customer',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeadline,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: _notesController,
            maxLines: 2,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAF6),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 10.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFE2E6D5)),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Cash Platform Fee Notice
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_rounded,
                  size: 15,
                  color: Color(0xFFD97706),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'If client chooses cash payment on-site, a 10% platform fee will be payable to Admin.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFB45309),
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
}
