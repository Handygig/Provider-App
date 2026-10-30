import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:provider_app/core/constants/app_colors.dart';

class NotificationEntity extends Equatable {
  final int id;
  final String title;
  final String message;
  final String type;
  final String category;
  final bool isRead;
  final int? relatedId;
  final String? relatedType;
  final String? timeString;
  final String? fullTimeString;
  final DateTime? createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.category,
    required this.isRead,
    this.relatedId,
    this.relatedType,
    this.timeString,
    this.fullTimeString,
    this.createdAt,
  });

  bool get isUnread => !isRead;

  String get timeAgo {
    if (timeString != null && timeString!.isNotEmpty) {
      return timeString!;
    }
    if (createdAt == null) return 'Recently';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${(diff.inDays / 7).floor()} weeks ago';
    }
  }

  String get fullTime {
    if (fullTimeString != null && fullTimeString!.isNotEmpty) {
      return fullTimeString!;
    }
    if (createdAt == null) return timeAgo;
    final c = createdAt!.toLocal();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[c.month - 1];
    final hour = c.hour % 12 == 0 ? 12 : c.hour % 12;
    final minute = c.minute.toString().padLeft(2, '0');
    final ampm = c.hour >= 12 ? 'PM' : 'AM';
    return '$month ${c.day}, ${c.year} • $hour:$minute $ampm';
  }

  IconData get icon {
    switch (type.toLowerCase()) {
      case 'job_request':
      case 'job':
        return Icons.near_me_rounded;
      case 'quotation':
        return Icons.check_circle_rounded;
      case 'wallet':
      case 'payout':
      case 'payment':
        return Icons.account_balance_wallet_rounded;
      case 'review':
        return Icons.star_rounded;
      case 'compliance':
      case 'verification':
        return Icons.verified_user_rounded;
      case 'system':
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color get color {
    switch (type.toLowerCase()) {
      case 'job_request':
      case 'job':
        return AppColors.primary;
      case 'quotation':
        return const Color(0xFF16A34A);
      case 'wallet':
      case 'payout':
      case 'payment':
        return AppColors.primaryDark;
      case 'review':
        return const Color(0xFFEAB308);
      case 'compliance':
      case 'verification':
        return AppColors.primary;
      case 'system':
      default:
        return AppColors.primary;
    }
  }

  String get actionType {
    switch (type.toLowerCase()) {
      case 'job_request':
      case 'job':
      case 'quotation':
        return 'job';
      case 'wallet':
      case 'payout':
      case 'payment':
        return 'wallet';
      case 'review':
        return 'review';
      case 'compliance':
      case 'verification':
        return 'profile';
      default:
        return 'system';
    }
  }

  NotificationEntity copyWith({
    int? id,
    String? title,
    String? message,
    String? type,
    String? category,
    bool? isRead,
    int? relatedId,
    String? relatedType,
    String? timeString,
    String? fullTimeString,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      timeString: timeString ?? this.timeString,
      fullTimeString: fullTimeString ?? this.fullTimeString,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        type,
        category,
        isRead,
        relatedId,
        relatedType,
        timeString,
        fullTimeString,
        createdAt,
      ];
}
