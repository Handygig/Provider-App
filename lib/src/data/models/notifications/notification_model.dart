import 'package:provider_app/src/domain/entities/notifications/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.category,
    required super.isRead,
    super.relatedId,
    super.relatedType,
    super.timeString,
    super.fullTimeString,
    super.createdAt,
  });

  static int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? fallback;
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['created_at'] != null) {
      try {
        parsedDate = DateTime.parse(json['created_at'].toString());
      } catch (_) {}
    }

    final String rawType = (json['type'] ?? 'system').toString().toLowerCase();

    String category = json['category']?.toString() ?? '';
    if (category.isEmpty) {
      switch (rawType) {
        case 'job_request':
        case 'job':
          category = 'Job Inquiries';
          break;
        case 'quotation':
          category = 'Quotations';
          break;
        case 'wallet':
        case 'payout':
        case 'payment':
          category = 'Finance & Wallet';
          break;
        case 'review':
          category = 'Ratings & Reviews';
          break;
        default:
          category = 'Security & Compliance';
          break;
      }
    }

    final bool readStatus = json['is_read'] == true ||
        json['is_read'] == 1 ||
        json['is_read'] == '1' ||
        (json['isUnread'] == false);

    return NotificationModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      message: (json['message'] ?? json['body'])?.toString() ?? '',
      type: rawType,
      category: category,
      isRead: readStatus,
      relatedId: json['related_id'] != null ? _parseInt(json['related_id']) : null,
      relatedType: json['related_type']?.toString(),
      timeString: json['time']?.toString(),
      fullTimeString: json['fullTime']?.toString(),
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'category': category,
      'is_read': isRead,
      'related_id': relatedId,
      'related_type': relatedType,
      'time': timeString,
      'fullTime': fullTimeString,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
