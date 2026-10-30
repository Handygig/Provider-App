import 'package:provider_app/src/domain/entities/jobs/job_entity.dart';
export 'package:provider_app/src/domain/entities/jobs/job_entity.dart';

// ignore: must_be_immutable
class JobModel extends JobEntity {
  JobCategory _status;
  @override
  JobCategory get status => _status;
  set status(JobCategory val) => _status = val;

  double? _quotedAmount;
  @override
  double? get quotedAmount => _quotedAmount;
  set quotedAmount(double? val) => _quotedAmount = val;

  String? _quoteNotes;
  @override
  String? get quoteNotes => _quoteNotes;
  set quoteNotes(String? val) => _quoteNotes = val;

  String? _completionDate;
  @override
  String? get completionDate => _completionDate;
  set completionDate(String? val) => _completionDate = val;

  double? _finalRating;
  @override
  double? get finalRating => _finalRating;
  set finalRating(double? val) => _finalRating = val;

  String? _clientFeedback;
  @override
  String? get clientFeedback => _clientFeedback;
  set clientFeedback(String? val) => _clientFeedback = val;

  double? _extraAmount;
  @override
  double? get extraAmount => _extraAmount;
  set extraAmount(double? val) => _extraAmount = val;

  String? _extraReason;
  @override
  String? get extraReason => _extraReason;
  set extraReason(String? val) => _extraReason = val;

  ExtraApprovalStatus _extraStatus;
  @override
  ExtraApprovalStatus get extraStatus => _extraStatus;
  set extraStatus(ExtraApprovalStatus val) => _extraStatus = val;

  // ignore: use_super_parameters
  JobModel({
    required super.id,
    required super.serviceTitle,
    required super.category,
    required super.customerName,
    super.customerPhone = '+94 77 982 1450',
    required super.customerRating,
    super.customerReviewsCount = 24,
    required super.address,
    super.city = 'Colombo',
    required super.distance,
    required super.requestedTime,
    required super.description,
    super.estimatedBudget,
    double? quotedAmount,
    String? quoteNotes,
    required JobCategory status,
    String? completionDate,
    double? finalRating,
    String? clientFeedback,
    double? extraAmount,
    String? extraReason,
    ExtraApprovalStatus extraStatus = ExtraApprovalStatus.none,
    super.paymentMethod = 'Cash on Delivery',
    super.jobDate,
    super.orderType,
    super.scheduledDate,
    super.scheduledTimeSlot,
    super.latitude,
    super.longitude,
    super.isCompanyAssigned = false,
    super.assignedCompanyName,
    super.companyDispatchNote,
  })  : _status = status,
        _quotedAmount = quotedAmount,
        _quoteNotes = quoteNotes,
        _completionDate = completionDate,
        _finalRating = finalRating,
        _clientFeedback = clientFeedback,
        _extraAmount = extraAmount,
        _extraReason = extraReason,
        _extraStatus = extraStatus,
        super(
          status: status,
          quotedAmount: quotedAmount,
          quoteNotes: quoteNotes,
          completionDate: completionDate,
          finalRating: finalRating,
          clientFeedback: clientFeedback,
          extraAmount: extraAmount,
          extraReason: extraReason,
          extraStatus: extraStatus,
        );

  factory JobModel.fromEntity(JobEntity e) {
    if (e is JobModel) return e;
    return JobModel(
      id: e.id,
      serviceTitle: e.serviceTitle,
      category: e.category,
      customerName: e.customerName,
      customerPhone: e.customerPhone,
      customerRating: e.customerRating,
      customerReviewsCount: e.customerReviewsCount,
      address: e.address,
      city: e.city,
      distance: e.distance,
      requestedTime: e.requestedTime,
      description: e.description,
      estimatedBudget: e.estimatedBudget,
      quotedAmount: e.quotedAmount,
      quoteNotes: e.quoteNotes,
      status: e.status,
      completionDate: e.completionDate,
      finalRating: e.finalRating,
      clientFeedback: e.clientFeedback,
      extraAmount: e.extraAmount,
      extraReason: e.extraReason,
      extraStatus: e.extraStatus,
      paymentMethod: e.paymentMethod,
      jobDate: e.jobDate,
      orderType: e.orderType,
      scheduledDate: e.scheduledDate,
      scheduledTimeSlot: e.scheduledTimeSlot,
      latitude: e.latitude,
      longitude: e.longitude,
      isCompanyAssigned: e.isCompanyAssigned,
      assignedCompanyName: e.assignedCompanyName,
      companyDispatchNote: e.companyDispatchNote,
    );
  }

  factory JobModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? jobReq = json['job_request'] is Map<String, dynamic>
        ? json['job_request'] as Map<String, dynamic>
        : null;

    final isQuotation = json.containsKey('quoted_price') ||
        json.containsKey('quotedAmount') ||
        json.containsKey('bidder_type') ||
        jobReq != null;

    JobCategory parseStatus(dynamic status) {
      if (status is JobCategory) return status;
      final str = status?.toString().toLowerCase() ?? '';
      if (isQuotation && (str.isEmpty || str.contains('pending') || str.contains('quote'))) {
        return JobCategory.pendingApprove;
      }
      if (str.contains('quote') || str == 'open') return JobCategory.toQuote;
      if (str.contains('approv')) return JobCategory.pendingApprove;
      if (str.contains('sched') || str.contains('start') || str.contains('assign') || str.contains('ready')) {
        return JobCategory.toStart;
      }
      if (str.contains('ongoing') || str.contains('progress') || str == 'in_progress') {
        return JobCategory.ongoing;
      }
      if (str.contains('finish') || str.contains('complete') || str == 'completed') {
        return JobCategory.finished;
      }
      return JobCategory.toQuote;
    }

    ExtraApprovalStatus parseExtraStatus(dynamic status) {
      if (status is ExtraApprovalStatus) return status;
      final str = status?.toString().toLowerCase() ?? '';
      if (str.contains('pending')) return ExtraApprovalStatus.pending;
      if (str.contains('approved')) return ExtraApprovalStatus.approved;
      if (str.contains('rejected') || str.contains('declined')) {
        return ExtraApprovalStatus.rejected;
      }
      return ExtraApprovalStatus.none;
    }

    OrderType? parseOrderType(dynamic type) {
      if (type is OrderType) return type;
      final str = type?.toString().toLowerCase() ?? '';
      if (str.contains('instant') || str.contains('now')) {
        return OrderType.instant;
      }
      if (str.contains('scheduled')) return OrderType.scheduled;
      return null;
    }

    final rawId = json['id'] ?? jobReq?['id'] ?? json['job_request_id'] ?? '';
    final idStr = rawId.toString().startsWith('JOB-')
        ? rawId.toString()
        : 'JOB-${rawId.toString().padLeft(4, '0')}';

    return JobModel(
      id: idStr,
      serviceTitle: json['service_title']?.toString() ??
          json['serviceTitle']?.toString() ??
          json['title']?.toString() ??
          jobReq?['service_title']?.toString() ??
          jobReq?['serviceTitle']?.toString() ??
          jobReq?['title']?.toString() ??
          '',
      category: json['category']?.toString() ??
          jobReq?['category']?.toString() ??
          'General',
      customerName: json['customer_name']?.toString() ??
          json['customerName']?.toString() ??
          jobReq?['customer_name']?.toString() ??
          jobReq?['customerName']?.toString() ??
          'Customer',
      customerPhone: json['customer_phone']?.toString() ??
          json['customerPhone']?.toString() ??
          jobReq?['customer_phone']?.toString() ??
          jobReq?['customerPhone']?.toString() ??
          '+94 77 982 1450',
      customerRating: (json['customer_rating'] ??
              json['customerRating'] ??
              json['rating'] ??
              jobReq?['customer_rating'] ??
              jobReq?['customerRating'] ??
              4.9)
          .toDouble(),
      customerReviewsCount: json['customer_reviews_count'] ??
          json['customerReviewsCount'] ??
          jobReq?['customer_reviews_count'] ??
          jobReq?['customerReviewsCount'] ??
          24,
      address: json['address']?.toString() ??
          jobReq?['address']?.toString() ??
          '',
      city: json['city']?.toString() ?? jobReq?['city']?.toString() ?? 'Colombo',
      distance: json['distance']?.toString() ??
          jobReq?['distance']?.toString() ??
          '2.5 km away',
      requestedTime: json['requested_time']?.toString() ??
          json['requestedTime']?.toString() ??
          jobReq?['requested_time']?.toString() ??
          jobReq?['requestedTime']?.toString() ??
          'Today',
      description: json['description']?.toString() ??
          jobReq?['description']?.toString() ??
          '',
      estimatedBudget: (json['estimated_budget'] ??
              json['estimatedBudget'] ??
              json['budget'] ??
              jobReq?['estimated_budget'] ??
              jobReq?['estimatedBudget'] ??
              jobReq?['budget'])
          ?.toDouble(),
      quotedAmount: (json['quoted_amount'] ??
              json['quotedAmount'] ??
              json['quoted_price'])
          ?.toDouble(),
      quoteNotes: json['quote_notes']?.toString() ??
          json['quoteNotes']?.toString() ??
          json['message']?.toString(),
      status: parseStatus(json['status']),
      completionDate: json['completion_date']?.toString() ??
          json['completionDate']?.toString(),
      finalRating: (json['final_rating'] ?? json['finalRating'])?.toDouble(),
      clientFeedback: json['client_feedback']?.toString() ??
          json['clientFeedback']?.toString(),
      extraAmount: (json['extra_amount'] ?? json['extraAmount'])?.toDouble(),
      extraReason: json['extra_reason']?.toString() ??
          json['extraReason']?.toString(),
      extraStatus: parseExtraStatus(json['extra_status'] ?? json['extraStatus']),
      paymentMethod: json['payment_method']?.toString() ??
          json['paymentMethod']?.toString() ??
          'Cash on Delivery',
      jobDate: json['job_date'] != null
          ? DateTime.tryParse(json['job_date'].toString())
          : null,
      orderType: parseOrderType(json['order_type'] ?? json['orderType']),
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.tryParse(json['scheduled_date'].toString())
          : null,
      scheduledTimeSlot: json['scheduled_time_slot']?.toString() ??
          json['scheduledTimeSlot']?.toString(),
      latitude: (json['latitude'] ??
              json['lat'] ??
              jobReq?['latitude'] ??
              jobReq?['lat'])
          ?.toDouble(),
      longitude: (json['longitude'] ??
              json['lng'] ??
              jobReq?['longitude'] ??
              jobReq?['lng'])
          ?.toDouble(),
      isCompanyAssigned: json['is_company_assigned'] == true ||
          json['isCompanyAssigned'] == true,
      assignedCompanyName: json['assigned_company_name']?.toString() ??
          json['assignedCompanyName']?.toString(),
      companyDispatchNote: json['company_dispatch_note']?.toString() ??
          json['companyDispatchNote']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_title': serviceTitle,
      'category': category,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_rating': customerRating,
      'customer_reviews_count': customerReviewsCount,
      'address': address,
      'city': city,
      'distance': distance,
      'requested_time': requestedTime,
      'description': description,
      'estimated_budget': estimatedBudget,
      'quoted_amount': quotedAmount,
      'quote_notes': quoteNotes,
      'status': status.name,
      'completion_date': completionDate,
      'final_rating': finalRating,
      'client_feedback': clientFeedback,
      'extra_amount': extraAmount,
      'extra_reason': extraReason,
      'extra_status': extraStatus.name,
      'payment_method': paymentMethod,
      'job_date': jobDate?.toIso8601String(),
      'order_type': orderType?.name,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'scheduled_time_slot': scheduledTimeSlot,
      'latitude': latitude,
      'longitude': longitude,
      'is_company_assigned': isCompanyAssigned,
      'assigned_company_name': assignedCompanyName,
      'company_dispatch_note': companyDispatchNote,
    };
  }
}
