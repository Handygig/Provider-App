import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/data/services/working_hours_coverage_service.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';

typedef CoverageAreaScreen = WorkingHoursCoverageScreen;

class WorkingHoursCoverageScreen extends StatefulWidget {
  const WorkingHoursCoverageScreen({super.key});

  @override
  State<WorkingHoursCoverageScreen> createState() =>
      _WorkingHoursCoverageScreenState();
}

class _WorkingHoursCoverageScreenState
    extends State<WorkingHoursCoverageScreen> {
  final WorkingHoursCoverageService _service =
      WorkingHoursCoverageService.instance;

  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  double _calculateZoom(double radiusKm) {
    if (radiusKm <= 7) return 13.0;
    if (radiusKm <= 14) return 12.0;
    if (radiusKm <= 22) return 11.2;
    if (radiusKm <= 35) return 10.3;
    return 9.6;
  }

  void _recenterMap() {
    final target = LatLng(_service.baseLatitude, _service.baseLongitude);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        target,
        _calculateZoom(_service.radiusKm),
      ),
    );
  }

  void _onRadiusChanged(double val) {
    _service.updateRadius(val);
    final target = LatLng(_service.baseLatitude, _service.baseLongitude);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        target,
        _calculateZoom(val),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final radius = _service.radiusKm.toInt();
        final baseLatLng =
            LatLng(_service.baseLatitude, _service.baseLongitude);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF7F8F4),
            body: Column(
              children: [
                // 1. Top Custom App Bar
                _buildTopAppBar(radiusKm: radius),

                // 2. Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 90.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live Radar Toggle Card
                        _buildLiveRadarCard(),

                        SizedBox(height: 16.h),

                        // Interactive Map Radius Card
                        _buildMapRadiusCard(baseLatLng, radius),

                        SizedBox(height: 16.h),

                        // Base Starting Location Card
                        _buildBaseLocationCard(),
                      ],
                    ),
                  ),
                ),

                // 3. Sticky Bottom Save Bar
                _buildBottomSaveBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 1. TOP APP BAR
  // ---------------------------------------------------------------------------
  Widget _buildTopAppBar({required int radiusKm}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Coverage Area',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${radiusKm}km Radius • ${_service.baseLocation}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 9.w,
                  vertical: 5.h,
                ),
                decoration: BoxDecoration(
                  color: _service.isAvailableNow
                      ? const Color(0xFFD4DE95)
                      : const Color(0xFFEF4444).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.r,
                      height: 7.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _service.isAvailableNow
                            ? AppColors.primaryDark
                            : const Color(0xFFEF4444),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      _service.isAvailableNow ? 'ON RADAR' : 'OFFLINE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w900,
                        color: _service.isAvailableNow
                            ? AppColors.primaryDark
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. LIVE RADAR CARD
  // ---------------------------------------------------------------------------
  Widget _buildLiveRadarCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _service.isAvailableNow
              ? [const Color(0xFF38431E), const Color(0xFF4F5C2B)]
              : [const Color(0xFF475569), const Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: (_service.isAvailableNow
                    ? const Color(0xFF38431E)
                    : const Color(0xFF334155))
                .withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _service.isAvailableNow
                  ? Icons.sensors_rounded
                  : Icons.sensors_off_rounded,
              color: _service.isAvailableNow
                  ? const Color(0xFFD4DE95)
                  : Colors.white70,
              size: 24.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _service.isAvailableNow
                      ? 'Live on Client Radar'
                      : 'Radar Paused (Offline)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _service.isAvailableNow
                      ? 'Clients in your coverage radius can send job requests'
                      : 'You will not appear on nearby searches right now',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    color: Colors.white70,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _service.isAvailableNow,
            activeTrackColor: const Color(0xFFD4DE95),
            activeThumbColor: AppColors.primaryDark,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              _service.toggleAvailability(val);
              DynamicIslandToast.showSuccess(
                context,
                val ? 'Live Radar Activated' : 'Radar Paused',
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. MAP RADIUS CARD
  // ---------------------------------------------------------------------------
  Widget _buildMapRadiusCard(LatLng baseLatLng, int radius) {
    final radiusMeters = _service.radiusKm * 1000;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE5E9DC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(7.r),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F6EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.map_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coverage Map & Radius',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textHeadline,
                          ),
                        ),
                        Text(
                          'Clients inside this green circle can hire you',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '$radius km',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFD4DE95),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Google Map Container
          Container(
            height: 310.h,
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: const Color(0xFFE2E6D5)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: baseLatLng,
                    zoom: _calculateZoom(_service.radiusKm),
                  ),
                  mapType: MapType.normal,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  circles: {
                    Circle(
                      circleId: const CircleId('coverage_radius_circle'),
                      center: baseLatLng,
                      radius: radiusMeters,
                      fillColor: AppColors.primary.withValues(alpha: 0.18),
                      strokeColor: AppColors.primaryDark,
                      strokeWidth: 2,
                    ),
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('base_marker'),
                      position: baseLatLng,
                      draggable: true,
                      onDragEnd: (newPos) {
                        _service.updateBaseCoordinates(
                          newPos.latitude,
                          newPos.longitude,
                        );
                      },
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                      infoWindow: InfoWindow(
                        title: 'Starting Base',
                        snippet: _service.baseLocation,
                      ),
                    ),
                  },
                  onTap: (tappedPos) {
                    HapticFeedback.lightImpact();
                    _service.updateBaseCoordinates(
                      tappedPos.latitude,
                      tappedPos.longitude,
                    );
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLng(tappedPos),
                    );
                  },
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),

                // Top Floating Base Info Pill
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  right: 60.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(14.r),
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
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                          size: 15,
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Text(
                            'Center: ${_service.baseLocation}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textHeadline,
                            ),
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
                  child: FloatingActionButton.small(
                    heroTag: 'recenter_map',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _recenterMap();
                    },
                    backgroundColor: Colors.white,
                    elevation: 3,
                    child: const Icon(
                      Icons.my_location_rounded,
                      color: AppColors.primaryDark,
                      size: 18,
                    ),
                  ),
                ),

                // Hint at bottom of map
                Positioned(
                  bottom: 10.h,
                  left: 12.w,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'Tap anywhere on map or drag pin to reposition center',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Preset Radius Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Radius Selection',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [5, 10, 15, 20, 30, 50].map((km) {
                    final isSelected = radius == km;
                    return InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _onRadiusChanged(km.toDouble());
                      },
                      borderRadius: BorderRadius.circular(10.r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryDark
                              : const Color(0xFFF4F6F0),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryDark
                                : const Color(0xFFD6E2C5),
                            width: isSelected ? 1.4 : 1.0,
                          ),
                        ),
                        child: Text(
                          '$km km',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5.sp,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textHeadline,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // Slider
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: const Color(0xFFE2E6D5),
                thumbColor: AppColors.primaryDark,
                overlayColor: AppColors.primary.withValues(alpha: 0.15),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                trackHeight: 6,
              ),
              child: Slider(
                value: _service.radiusKm,
                min: 5,
                max: 50,
                divisions: 9, // 5km steps
                onChanged: _onRadiusChanged,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '5 km (Local)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  '25 km (Standard)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  '50 km (Metro Wide)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    color: AppColors.textMuted,
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
  // 4. BASE LOCATION CARD
  // ---------------------------------------------------------------------------
  Widget _buildBaseLocationCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE5E9DC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.home_work_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Base Starting Point',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _service.baseLocation,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Radius circle is measured outwards from this location',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showEditBaseLocationDialog,
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }


  // ---------------------------------------------------------------------------
  // 6. STICKY BOTTOM SAVE BAR
  // ---------------------------------------------------------------------------
  Widget _buildBottomSaveBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE5E9DC))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            DynamicIslandToast.showSuccess(
              context,
              'Coverage radius of ${_service.radiusKm.toInt()} km saved!',
            );
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 20,
          ),
          label: Text(
            'Save Coverage Area',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. EDIT BASE LOCATION DIALOG
  // ---------------------------------------------------------------------------
  void _showEditBaseLocationDialog() {
    final locationCtrl =
        TextEditingController(text: _service.baseLocation);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Edit Base Location',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeadline,
            ),
          ),
          content: TextField(
            controller: locationCtrl,
            autofocus: true,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. Kollupitiya, Colombo 03',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                color: AppColors.textMuted,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFE2E6D5)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final loc = locationCtrl.text.trim();
                if (loc.isNotEmpty) {
                  _service.updateBaseLocation(loc);
                  DynamicIslandToast.showSuccess(
                    context,
                    'Base location updated',
                  );
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Save Location',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
