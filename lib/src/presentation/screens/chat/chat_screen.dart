import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/domain/models/job_model.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final String time;
  final bool isSystem;
  final String? attachment;
  final String? imagePath;
  final bool isLocation;
  final LatLng? locationCoords;
  final String? locationAddress;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.isSystem = false,
    this.attachment,
    this.imagePath,
    this.isLocation = false,
    this.locationCoords,
    this.locationAddress,
  });
}

class ChatScreen extends StatefulWidget {
  final JobModel job;

  const ChatScreen({
    super.key,
    required this.job,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late List<ChatMessage> _messages;
  bool _isTyping = false;

  final List<String> _quickReplies = [
    'I\'m on my way 🚗',
    'I have arrived 📍',
    'Arriving in 15 mins ⏱️',
    'Please send more photos 📸',
    'Quotation sent for approval 📄',
    'Job completed successfully ✅',
  ];

  @override
  void initState() {
    super.initState();
    _initMessages();
  }

  void _initMessages() {
    _messages = [
      ChatMessage(
        id: 'msg-1',
        text: 'Job request #${widget.job.id} confirmed by client.',
        isMe: false,
        time: '04:10 PM',
        isSystem: true,
      ),
      ChatMessage(
        id: 'msg-2',
        text: 'Hello! I submitted a request for ${widget.job.serviceTitle}. When would you be able to inspect the work?',
        isMe: false,
        time: '04:12 PM',
      ),
      ChatMessage(
        id: 'msg-3',
        text: 'Hello ${widget.job.customerName}! I have reviewed your request. I can visit your location around ${widget.job.requestedTime}. Does that suit you?',
        isMe: true,
        time: '04:15 PM',
      ),
      ChatMessage(
        id: 'msg-4',
        text: 'Yes, perfect! Please let me know once you are near ${widget.job.address.split(',').first}.',
        isMe: false,
        time: '04:18 PM',
      ),
      ChatMessage(
        id: 'msg-5',
        text: 'Understood. I will notify you as soon as I head out.',
        isMe: true,
        time: '04:20 PM',
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void _sendMessage([String? quickText]) {
    final text = quickText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    if (quickText == null) {
      _messageController.clear();
    }

    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
          text: text,
          isMe: true,
          time: timeStr,
        ),
      );
    });

    _scrollToBottom();

    // Simulate smart customer reply after short delay
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _isTyping = true;
      });
      _scrollToBottom();

      Future.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
              text: _generateReplyFor(text),
              isMe: false,
              time: '$hour:${(now.minute + 1).toString().padLeft(2, '0')} $period',
            ),
          );
        });
        HapticFeedback.selectionClick();
        _scrollToBottom();
      });
    });
  }

  String _generateReplyFor(String providerMessage) {
    final lower = providerMessage.toLowerCase();
    if (lower.contains('on my way') || lower.contains('arriving')) {
      return 'Great! I am at home waiting. Please call on arrival.';
    } else if (lower.contains('arrived')) {
      return 'I will open the gate right away!';
    } else if (lower.contains('quotation') || lower.contains('quote')) {
      return 'Thanks for sending the quotation! Reviewing it now.';
    } else if (lower.contains('completed')) {
      return 'Thank you for the prompt work! I will verify and confirm settlement.';
    } else if (lower.contains('photo')) {
      return 'Sure, let me take a close-up photo and send it over.';
    } else {
      return 'Got it, thank you for the update!';
    }
  }

  void _showAttachmentSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
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
                  'Share with Client',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHeadline,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAttachmentItem(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: const Color(0xFF2563EB),
                      onTap: _handleCamera,
                    ),
                    _buildAttachmentItem(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: const Color(0xFF7C3AED),
                      onTap: _handleGallery,
                    ),
                    _buildAttachmentItem(
                      icon: Icons.location_on_rounded,
                      label: 'Location',
                      color: const Color(0xFF16A34A),
                      onTap: _handleLocation,
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleCamera() async {
    Navigator.pop(context);
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (photo != null) {
        _sendImageMessage(photo.path);
      }
    } catch (e) {
      if (!mounted) return;
      // Likely iOS Simulator or camera hardware permission limitation
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 24.r),
              SizedBox(width: 8.w),
              Text(
                'Camera Hardware',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeadline,
                ),
              ),
            ],
          ),
          content: Text(
            'Camera hardware is not accessible on this device or simulator. Would you like to select a photo from your gallery instead?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _handleGallery();
              },
              child: Text(
                'Open Gallery',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handleGallery() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (image != null) {
        _sendImageMessage(image.path);
      }
    } catch (e) {
      if (!mounted) return;
      DynamicIslandToast.showError(
        context,
        'Unable to access gallery: $e',
      );
    }
  }

  void _sendImageMessage(String imagePath) {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
          text: 'Shared photo',
          isMe: true,
          time: timeStr,
          imagePath: imagePath,
        ),
      );
    });

    _scrollToBottom();

    // Smart simulated reply from customer
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _isTyping = true);
      _scrollToBottom();

      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
              text: 'Thanks for sharing the photo! I can see it clearly.',
              isMe: false,
              time: '$hour:${(now.minute + 1).toString().padLeft(2, '0')} $period',
            ),
          );
        });
        HapticFeedback.selectionClick();
        _scrollToBottom();
      });
    });
  }

  void _handleLocation() {
    Navigator.pop(context);
    const liveCoords = LatLng(6.9271, 79.8612); // Provider Location
    final locationAddress = '${widget.job.address.split(',').first}, Colombo';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.location_on_rounded,
                          color: const Color(0xFF16A34A), size: 22.r),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Share Live Location',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textHeadline,
                            ),
                          ),
                          Text(
                            locationAddress,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Interactive Map Preview
                Container(
                  height: 180.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFE2E6D5)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: liveCoords,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('current_loc'),
                        position: liveCoords,
                        infoWindow: const InfoWindow(title: 'My Current Location'),
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _sendLocationMessage(liveCoords, locationAddress);
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      'Send Current Location',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sendLocationMessage(LatLng coords, String address) {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
          text: 'Live Location Shared 📍',
          isMe: true,
          time: timeStr,
          isLocation: true,
          locationCoords: coords,
          locationAddress: address,
        ),
      );
    });

    _scrollToBottom();

    // Customer smart simulated reply
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _isTyping = true);
      _scrollToBottom();

      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
              text: 'Received your location! I can see you are on your way.',
              isMe: false,
              time: '$hour:${(now.minute + 1).toString().padLeft(2, '0')} $period',
            ),
          );
        });
        HapticFeedback.selectionClick();
        _scrollToBottom();
      });
    });
  }

  void _showImagePreview(String imagePath) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              'Photo Preview',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54.r,
            height: 54.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.r),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textHeadline,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.job.customerName
        .trim()
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8F4),
        body: Column(
          children: [
            // Top App Bar
            _buildAppBar(initials),

            // Sticky Job Overview Header
            _buildJobSummaryBar(),

            // Chat Messages Canvas
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    final msg = _messages[index];
                    if (msg.isSystem) {
                      return _buildSystemMessage(msg);
                    }
                    return _buildMessageBubble(msg);
                  },
                ),
              ),
            ),

            // Quick Reply Suggestions
            _buildQuickRepliesBar(),

            // Bottom Input Bar
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(String initials) {
    return Container(
      color: AppColors.primaryDark,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        left: 12.w,
        right: 16.w,
        bottom: 12.h,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18.r,
            ),
          ),
          SizedBox(width: 4.w),

          // Customer Avatar with Online indicator
          Stack(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials.isNotEmpty ? initials : 'C',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12.r,
                  height: 12.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryDark, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10.w),

          // Name and Online status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.job.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Online • Rating: ${widget.job.customerRating}★',
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

          // Call button
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              DynamicIslandToast.showSuccess(
                context,
                'Dialing ${widget.job.customerPhone}...',
              );
            },
            icon: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.phone_rounded,
                color: Colors.white,
                size: 18.r,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobSummaryBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3E7),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E7D8), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: widget.job.categoryColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              widget.job.category,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w800,
                color: widget.job.categoryColor,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              widget.job.serviceTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textHeadline,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
            decoration: BoxDecoration(
              color: widget.job.status.backgroundColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: widget.job.status.color.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Text(
              widget.job.status.badgeText,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: widget.job.status.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(ChatMessage msg) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE8ECE1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            msg.text,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isMe = msg.isMe;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            child: Container(
              padding: (msg.imagePath != null || msg.isLocation)
                  ? EdgeInsets.all(6.r)
                  : EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
                  bottomRight: Radius.circular(isMe ? 4.r : 16.r),
                ),
                border: isMe
                    ? null
                    : Border.all(color: const Color(0xFFE5E9DC), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // 1. Image Attachment Content
                  if (msg.imagePath != null) ...[
                    GestureDetector(
                      onTap: () => _showImagePreview(msg.imagePath!),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Stack(
                          children: [
                            Image.file(
                              File(msg.imagePath!),
                              width: 220.w,
                              height: 160.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 220.w,
                                height: 160.h,
                                color: const Color(0xFFE2E4DE),
                                alignment: Alignment.center,
                                child: Icon(Icons.broken_image_rounded,
                                    color: AppColors.textMuted, size: 32.r),
                              ),
                            ),
                            Positioned(
                              top: 8.h,
                              right: 8.w,
                              child: Container(
                                padding: EdgeInsets.all(5.r),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.fullscreen_rounded,
                                  color: Colors.white,
                                  size: 16.r,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (msg.text.isNotEmpty && msg.text != 'Shared photo') ...[
                      SizedBox(height: 6.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          msg.text,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            color: isMe ? Colors.white : AppColors.textHeadline,
                          ),
                        ),
                      ),
                    ],
                  ]
                  // 2. Location Attachment Content
                  else if (msg.isLocation && msg.locationCoords != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        width: 230.w,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 120.h,
                              width: double.infinity,
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: msg.locationCoords!,
                                  zoom: 15,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('msg_loc'),
                                    position: msg.locationCoords!,
                                  ),
                                },
                                zoomControlsEnabled: false,
                                myLocationButtonEnabled: false,
                                mapToolbarEnabled: false,
                                compassEnabled: false,
                                rotateGesturesEnabled: false,
                                scrollGesturesEnabled: false,
                                tiltGesturesEnabled: false,
                                zoomGesturesEnabled: false,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        color: const Color(0xFF16A34A),
                                        size: 16.r,
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: Text(
                                          msg.locationAddress ?? 'Live Location',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textHeadline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      DynamicIslandToast.showSuccess(
                                        context,
                                        'Launching directions to ${msg.locationAddress ?? "location"}...',
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 6.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF16A34A)
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.directions_rounded,
                                            size: 14.r,
                                            color: const Color(0xFF16A34A),
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'Open in Maps',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5.sp,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF16A34A),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
                  // 3. Regular Text Message Content
                  else ...[
                    Text(
                      msg.text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5.sp,
                        color: isMe ? Colors.white : AppColors.textHeadline,
                        height: 1.35,
                      ),
                    ),
                  ],

                  SizedBox(height: 4.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          msg.time,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.sp,
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppColors.textMuted,
                          ),
                        ),
                        if (isMe) ...[
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.done_all_rounded,
                            size: 13.r,
                            color: const Color(0xFFD4DE95),
                          ),
                        ],
                      ],
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

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE5E9DC), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.job.customerName} is typing',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(width: 6.w),
                SizedBox(
                  width: 14.r,
                  height: 14.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRepliesBar() {
    return Container(
      height: 38.h,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        itemCount: _quickReplies.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final reply = _quickReplies[index];
          return GestureDetector(
            onTap: () => _sendMessage(reply),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F0),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE0E5D7)),
              ),
              child: Center(
                child: Text(
                  reply,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHeadline,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12.w,
        8.h,
        12.w,
        MediaQuery.of(context).padding.bottom + 8.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFEFF2E6), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Attachment Button (+)
          IconButton(
            onPressed: _showAttachmentSheet,
            icon: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4EB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 22.r,
              ),
            ),
          ),
          SizedBox(width: 4.w),

          // Text Field
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8F4),
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(color: const Color(0xFFE4E8DC)),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5.sp,
                  color: AppColors.textHeadline,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message to client...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    color: AppColors.textMuted,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // Send Button
          GestureDetector(
            onTap: () => _sendMessage(),
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18.r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
