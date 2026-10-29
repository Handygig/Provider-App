import 'package:equatable/equatable.dart';

enum JobCategory {
  toQuote,
  pendingApprove,
  toStart,
  ongoing,
  finished,
}

extension JobCategoryExtension on JobCategory {
  String get label {
    switch (this) {
      case JobCategory.toQuote:
        return 'To Quote';
      case JobCategory.pendingApprove:
        return 'Pending approve';
      case JobCategory.toStart:
        return 'To Start';
      case JobCategory.ongoing:
        return 'Ongoing';
      case JobCategory.finished:
        return 'Finished';
    }
  }

  String get badgeText {
    switch (this) {
      case JobCategory.toQuote:
        return 'Needs Quote';
      case JobCategory.pendingApprove:
        return 'Pending Approval';
      case JobCategory.toStart:
        return 'Ready to Start';
      case JobCategory.ongoing:
        return 'In Progress';
      case JobCategory.finished:
        return 'Completed';
    }
  }
}

enum ExtraApprovalStatus {
  none,
  pending,
  approved,
  rejected,
}

extension ExtraApprovalStatusExtension on ExtraApprovalStatus {
  String get label {
    switch (this) {
      case ExtraApprovalStatus.none:
        return 'None';
      case ExtraApprovalStatus.pending:
        return 'Pending Customer Approval';
      case ExtraApprovalStatus.approved:
        return 'Approved by Customer';
      case ExtraApprovalStatus.rejected:
        return 'Declined by Customer';
    }
  }
}

enum OrderType {
  instant,
  scheduled,
}

extension OrderTypeExtension on OrderType {
  String get label {
    switch (this) {
      case OrderType.instant:
        return 'Instant Order';
      case OrderType.scheduled:
        return 'Scheduled Booking';
    }
  }

  String get badgeText {
    switch (this) {
      case OrderType.instant:
        return 'INSTANT ORDER';
      case OrderType.scheduled:
        return 'SCHEDULED BOOKING';
    }
  }
}

class JobEntity extends Equatable {
  final String id;
  final String serviceTitle;
  final String category;
  final String customerName;
  final String customerPhone;
  final double customerRating;
  final int customerReviewsCount;
  final String address;
  final String city;
  final String distance;
  final String requestedTime;
  final String description;
  final double? estimatedBudget;
  final double? quotedAmount;
  final String? quoteNotes;
  final JobCategory status;
  final String? completionDate;
  final double? finalRating;
  final String? clientFeedback;
  final double? extraAmount;
  final String? extraReason;
  final ExtraApprovalStatus extraStatus;
  final String paymentMethod;
  final DateTime? jobDate;
  final OrderType? orderType;
  final DateTime? scheduledDate;
  final String? scheduledTimeSlot;
  final double? latitude;
  final double? longitude;
  final bool isCompanyAssigned;
  final String? assignedCompanyName;
  final String? companyDispatchNote;

  const JobEntity({
    required this.id,
    required this.serviceTitle,
    required this.category,
    required this.customerName,
    this.customerPhone = '+94 77 982 1450',
    required this.customerRating,
    this.customerReviewsCount = 24,
    required this.address,
    this.city = 'Colombo',
    required this.distance,
    required this.requestedTime,
    required this.description,
    this.estimatedBudget,
    this.quotedAmount,
    this.quoteNotes,
    required this.status,
    this.completionDate,
    this.finalRating,
    this.clientFeedback,
    this.extraAmount,
    this.extraReason,
    this.extraStatus = ExtraApprovalStatus.none,
    this.paymentMethod = 'Cash on Delivery',
    this.jobDate,
    this.orderType,
    this.scheduledDate,
    this.scheduledTimeSlot,
    this.latitude,
    this.longitude,
    this.isCompanyAssigned = false,
    this.assignedCompanyName,
    this.companyDispatchNote,
  });

  bool get isAssignedByCompany =>
      isCompanyAssigned || assignedCompanyName != null;
  String get effectiveCompanyName =>
      assignedCompanyName ?? 'Apex Home Solutions Pvt Ltd';

  double get effectiveLatitude => latitude ?? 6.9034;
  double get effectiveLongitude => longitude ?? 79.8546;

  OrderType get effectiveOrderType {
    if (orderType != null) return orderType!;
    final lower = requestedTime.toLowerCase();
    if (lower.contains('immediate') ||
        lower.contains('instant') ||
        lower.contains('urgent') ||
        lower.contains('asap') ||
        lower.contains('now')) {
      return OrderType.instant;
    }
    return OrderType.scheduled;
  }

  bool get isInstantOrder => effectiveOrderType == OrderType.instant;
  bool get isScheduled => effectiveOrderType == OrderType.scheduled;

  DateTime get effectiveScheduledDate =>
      scheduledDate ?? jobDate ?? DateTime.now().add(const Duration(days: 1));

  String get formattedScheduledDate {
    final d = effectiveScheduledDate;
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final weekday = weekdays[d.weekday - 1];
    final month = months[d.month - 1];
    return '$weekday, ${d.day} $month ${d.year}';
  }

  String get effectiveTimeSlot {
    if (scheduledTimeSlot != null && scheduledTimeSlot!.isNotEmpty) {
      return scheduledTimeSlot!;
    }
    if (requestedTime.contains('•')) {
      return requestedTime.split('•').last.trim();
    }
    return requestedTime;
  }

  String get countdownBadge {
    if (isInstantOrder) {
      return 'Dispatch ASAP • Expected within ~30 mins';
    }
    final now = DateTime.now();
    final d = effectiveScheduledDate;
    final diffDays = DateTime(d.year, d.month, d.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (diffDays == 0) {
      return 'Scheduled Today • In a few hours';
    } else if (diffDays == 1) {
      return 'Scheduled for Tomorrow';
    } else if (diffDays > 1) {
      return 'Scheduled in $diffDays days';
    } else {
      return 'Scheduled Appointment';
    }
  }

  DateTime get effectiveDate => jobDate ?? DateTime.now();

  double get totalEffectivePrice =>
      (quotedAmount ?? estimatedBudget ?? 0.0) +
      (extraStatus == ExtraApprovalStatus.approved ? (extraAmount ?? 0.0) : 0.0);

  double get totalWithPendingExtra =>
      (quotedAmount ?? estimatedBudget ?? 0.0) + (extraAmount ?? 0.0);

  bool get hasPendingExtra =>
      extraStatus == ExtraApprovalStatus.pending &&
      extraAmount != null &&
      extraAmount! > 0;

  bool get hasApprovedExtra =>
      extraStatus == ExtraApprovalStatus.approved &&
      extraAmount != null &&
      extraAmount! > 0;

  JobEntity copyWith({
    String? id,
    String? serviceTitle,
    String? category,
    String? customerName,
    String? customerPhone,
    double? customerRating,
    int? customerReviewsCount,
    String? address,
    String? city,
    String? distance,
    String? requestedTime,
    String? description,
    double? estimatedBudget,
    double? quotedAmount,
    String? quoteNotes,
    JobCategory? status,
    String? completionDate,
    double? finalRating,
    String? clientFeedback,
    double? extraAmount,
    String? extraReason,
    ExtraApprovalStatus? extraStatus,
    String? paymentMethod,
    DateTime? jobDate,
    OrderType? orderType,
    DateTime? scheduledDate,
    String? scheduledTimeSlot,
    double? latitude,
    double? longitude,
    bool? isCompanyAssigned,
    String? assignedCompanyName,
    String? companyDispatchNote,
  }) {
    return JobEntity(
      id: id ?? this.id,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      category: category ?? this.category,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerRating: customerRating ?? this.customerRating,
      customerReviewsCount:
          customerReviewsCount ?? this.customerReviewsCount,
      address: address ?? this.address,
      city: city ?? this.city,
      distance: distance ?? this.distance,
      requestedTime: requestedTime ?? this.requestedTime,
      description: description ?? this.description,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      quotedAmount: quotedAmount ?? this.quotedAmount,
      quoteNotes: quoteNotes ?? this.quoteNotes,
      status: status ?? this.status,
      completionDate: completionDate ?? this.completionDate,
      finalRating: finalRating ?? this.finalRating,
      clientFeedback: clientFeedback ?? this.clientFeedback,
      extraAmount: extraAmount ?? this.extraAmount,
      extraReason: extraReason ?? this.extraReason,
      extraStatus: extraStatus ?? this.extraStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      jobDate: jobDate ?? this.jobDate,
      orderType: orderType ?? this.orderType,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTimeSlot: scheduledTimeSlot ?? this.scheduledTimeSlot,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isCompanyAssigned: isCompanyAssigned ?? this.isCompanyAssigned,
      assignedCompanyName: assignedCompanyName ?? this.assignedCompanyName,
      companyDispatchNote: companyDispatchNote ?? this.companyDispatchNote,
    );
  }

  @override
  List<Object?> get props => [
        id,
        serviceTitle,
        category,
        customerName,
        customerPhone,
        customerRating,
        customerReviewsCount,
        address,
        city,
        distance,
        requestedTime,
        description,
        estimatedBudget,
        quotedAmount,
        quoteNotes,
        status,
        completionDate,
        finalRating,
        clientFeedback,
        extraAmount,
        extraReason,
        extraStatus,
        paymentMethod,
        jobDate,
        orderType,
        scheduledDate,
        scheduledTimeSlot,
        latitude,
        longitude,
        isCompanyAssigned,
        assignedCompanyName,
        companyDispatchNote,
      ];
}
