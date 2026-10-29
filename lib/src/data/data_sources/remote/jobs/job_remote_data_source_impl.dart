import 'package:dio/dio.dart';
import 'package:provider_app/core/errors/auth_exception.dart';
import 'package:provider_app/src/data/data_sources/remote/jobs/job_remote_data_source.dart';
import 'package:provider_app/src/data/models/jobs/job_model.dart';

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final Dio dio;

  // In-memory data store initialized with default seed data
  final List<JobModel> _mockJobs = [
    // 1. To Quote
    JobModel(
      id: 'JOB-3041',
      serviceTitle: 'Bathroom Plumbing & Fixture Fitting',
      category: 'Plumbing',
      customerName: 'Saman Kumara',
      customerRating: 4.9,
      customerReviewsCount: 38,
      address: 'No 45, Alfred House Gardens, Colombo 03',
      distance: '2.4 km away',
      requestedTime: 'Inspection Today • 04:30 PM',
      description:
          'Need inspection and quotation for leaking main pipeline and installation of 2 shower mixer units.',
      estimatedBudget: 80.00,
      paymentMethod: 'Cash on Delivery',
      status: JobCategory.toQuote,
    ),
    JobModel(
      id: 'JOB-3042',
      serviceTitle: 'Split AC Outdoor Compressor Gas Leak',
      category: 'AC Repair',
      customerName: 'Dilani Fernando',
      customerRating: 4.8,
      customerReviewsCount: 19,
      address: '12/4 Ward Place, Colombo 07',
      distance: '3.8 km away',
      requestedTime: 'Urgent • Needs Quote by 6 PM',
      description:
          'Inverter AC unit outdoor fan vibrating violently and low cooling efficiency. Need cost estimate for fix.',
      estimatedBudget: 65.00,
      paymentMethod: 'Credit / Debit Card',
      status: JobCategory.toQuote,
    ),
    JobModel(
      id: 'JOB-3043',
      serviceTitle: 'Electrical Sub-panel Rewiring & MCB Fix',
      category: 'Electrical',
      customerName: 'Rohan Wickremasinghe',
      customerRating: 5.0,
      customerReviewsCount: 52,
      address: '78 Nawala Road, Nugegoda',
      distance: '5.1 km away',
      requestedTime: 'Tomorrow Morning',
      description:
          'Circuit breaker trips repeatedly whenever multiple appliances are turned on. Quote needed for diagnostic & rewire.',
      estimatedBudget: 110.00,
      paymentMethod: 'Cash on Delivery',
      status: JobCategory.toQuote,
    ),

    // 2. Pending Approve
    JobModel(
      id: 'JOB-2980',
      serviceTitle: 'Kitchen Waste Drain Deep Clearing',
      category: 'Plumbing',
      customerName: 'Ayesha Mohamed',
      customerRating: 4.9,
      customerReviewsCount: 14,
      address: '88/2 Horton Place, Colombo 07',
      distance: '1.9 km away',
      requestedTime: 'Submitted 1 hour ago',
      description:
          'Commercial kitchen sink grease blockage. Submitted comprehensive estimate including high-pressure jet clearing.',
      quotedAmount: 95.00,
      quoteNotes:
          'Includes high-pressure water jetting, grease trap degreasing, and 30-day clearance guarantee.',
      status: JobCategory.pendingApprove,
    ),
    JobModel(
      id: 'JOB-2984',
      serviceTitle: 'Ceiling Fan Installation & Wiring (x3)',
      category: 'Electrical',
      customerName: 'Kavinda Perera',
      customerRating: 4.7,
      customerReviewsCount: 29,
      address: '155 Havelock Road, Colombo 05',
      distance: '4.2 km away',
      requestedTime: 'Submitted Yesterday',
      description:
          'Installation of 3 KDK ceiling fans with regulators in living and bedrooms.',
      quotedAmount: 70.00,
      quoteNotes: 'Rate covers 3 fan assemblies and wall switch replacements.',
      status: JobCategory.pendingApprove,
    ),

    // 3. To Start
    JobModel(
      id: 'JOB-2901',
      serviceTitle: 'Master Bathroom Shower Mixer Replacement',
      category: 'Plumbing',
      customerName: 'Nimal Jayawardena',
      customerRating: 4.9,
      customerReviewsCount: 42,
      address: 'No 14, Deal Place, Colombo 03',
      distance: '1.2 km away',
      requestedTime: 'Ready to Start • 10:00 AM Today',
      description:
          'Replace faulty Grohe thermostatic mixer with customer supplied unit. Customer verified quotation and confirmed time.',
      quotedAmount: 55.00,
      paymentMethod: 'In-App Online Payment',
      status: JobCategory.toStart,
    ),
    JobModel(
      id: 'JOB-2905',
      serviceTitle: 'Main Inverter AC Seasonal Chemical Wash',
      category: 'AC Repair',
      customerName: 'Anuki Senanayake',
      customerRating: 5.0,
      customerReviewsCount: 31,
      address: '22 Dharmapala Mawatha, Colombo 03',
      distance: '2.0 km away',
      requestedTime: 'Today • 02:00 PM',
      description:
          'Full indoor and outdoor unit chemical servicing for Panasonic 18000 BTU inverter unit.',
      quotedAmount: 85.00,
      paymentMethod: 'Credit / Debit Card',
      status: JobCategory.toStart,
    ),

    // 4. Ongoing
    JobModel(
      id: 'JOB-2850',
      serviceTitle: 'Overhead Water Tank Float Valve Replacement',
      category: 'Plumbing',
      customerName: 'Mahesh de Silva',
      customerRating: 4.8,
      customerReviewsCount: 63,
      address: '102 Baseline Road, Colombo 09',
      distance: '6.4 km away',
      requestedTime: 'Started at 01:15 PM',
      description:
          'Water overflow in rooftop stainless steel 1000L tank due to cracked brass ball valve mechanism.',
      quotedAmount: 65.00,
      paymentMethod: 'Cash on Delivery',
      status: JobCategory.ongoing,
    ),
    JobModel(
      id: 'JOB-2854',
      serviceTitle: 'Living Room Recessed LED Downlights & Dimmer',
      category: 'Electrical',
      customerName: 'Shamila Thilakarathne',
      customerRating: 5.0,
      customerReviewsCount: 18,
      address: '47 Cambridge Place, Colombo 07',
      distance: '2.8 km away',
      requestedTime: 'Started at 11:30 AM',
      description:
          'Installing 8 recessed warm-white ceiling spotlights with digital rotary dimmer module.',
      quotedAmount: 120.00,
      paymentMethod: 'Credit / Debit Card',
      status: JobCategory.ongoing,
    ),

    // 5. Finished
    JobModel(
      id: 'JOB-2740',
      serviceTitle: 'Pressure Pump Capacitor & Wiring Replacement',
      category: 'Plumbing',
      customerName: 'Prasanna Gunasekara',
      customerRating: 5.0,
      customerReviewsCount: 88,
      address: '210 Galle Road, Colombo 04',
      distance: '3.1 km away',
      requestedTime: 'Completed Oct 28',
      completionDate: '28 Oct 2026, 04:30 PM',
      description:
          'Diagnosed water pressure pump non-starting issue; replaced burned start capacitor and calibrated pressure switch.',
      quotedAmount: 90.00,
      finalRating: 5.0,
      clientFeedback:
          'Arrived within 20 minutes! Very clean diagnosis and pump works like brand new. Highly recommended pro.',
      paymentMethod: 'In-App Online Payment',
      status: JobCategory.finished,
    ),
    JobModel(
      id: 'JOB-2735',
      serviceTitle: 'Emergency Main Power Line Breaker Restoration',
      category: 'Electrical',
      customerName: 'Dr. Ruwan Alwis',
      customerRating: 4.9,
      customerReviewsCount: 45,
      address: '33 Barnes Place, Colombo 07',
      distance: '2.5 km away',
      requestedTime: 'Completed Oct 26',
      completionDate: '26 Oct 2026, 02:15 PM',
      description:
          'Main 63A double pole isolator melted due to terminal loose connection. Replaced with genuine Hager breaker unit.',
      quotedAmount: 140.00,
      finalRating: 5.0,
      clientFeedback:
          'Saved our clinic refrigerator during peak hours. Professional, polite, and extremely skilled.',
      paymentMethod: 'Credit / Debit Card',
      status: JobCategory.finished,
    ),
  ];

  JobRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<JobModel>> getJobs({JobCategory? category, String? query}) async {
    try {
      // Return filtered list from memory data store
      return _mockJobs.where((j) {
        if (category != null && j.status != category) return false;
        if (query != null && query.isNotEmpty) {
          final q = query.toLowerCase();
          return j.serviceTitle.toLowerCase().contains(q) ||
              j.customerName.toLowerCase().contains(q) ||
              j.category.toLowerCase().contains(q) ||
              j.id.toLowerCase().contains(q);
        }
        return true;
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> getJobById(String id) async {
    try {
      final job = _mockJobs.firstWhere(
        (j) => j.id == id,
        orElse: () => throw ServerException('Job not found: $id'),
      );
      return job;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> submitQuote({
    required String jobId,
    required double amount,
    String? notes,
  }) async {
    try {
      final index = _mockJobs.indexWhere((j) => j.id == jobId);
      if (index == -1) throw ServerException('Job not found');

      final current = _mockJobs[index];
      final updated = JobModel(
        id: current.id,
        serviceTitle: current.serviceTitle,
        category: current.category,
        customerName: current.customerName,
        customerPhone: current.customerPhone,
        customerRating: current.customerRating,
        customerReviewsCount: current.customerReviewsCount,
        address: current.address,
        city: current.city,
        distance: current.distance,
        requestedTime: 'Quote Submitted • Pending Customer Approval',
        description: current.description,
        estimatedBudget: current.estimatedBudget,
        quotedAmount: amount,
        quoteNotes: notes,
        status: JobCategory.pendingApprove,
        completionDate: current.completionDate,
        finalRating: current.finalRating,
        clientFeedback: current.clientFeedback,
        extraAmount: current.extraAmount,
        extraReason: current.extraReason,
        extraStatus: current.extraStatus,
        paymentMethod: current.paymentMethod,
        jobDate: current.jobDate,
        orderType: current.orderType,
        scheduledDate: current.scheduledDate,
        scheduledTimeSlot: current.scheduledTimeSlot,
        latitude: current.latitude,
        longitude: current.longitude,
        isCompanyAssigned: current.isCompanyAssigned,
        assignedCompanyName: current.assignedCompanyName,
        companyDispatchNote: current.companyDispatchNote,
      );

      _mockJobs[index] = updated;
      return updated;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> updateJobStatus({
    required String jobId,
    required JobCategory status,
  }) async {
    try {
      final index = _mockJobs.indexWhere((j) => j.id == jobId);
      if (index == -1) throw ServerException('Job not found');

      final current = _mockJobs[index];
      final updated = JobModel(
        id: current.id,
        serviceTitle: current.serviceTitle,
        category: current.category,
        customerName: current.customerName,
        customerPhone: current.customerPhone,
        customerRating: current.customerRating,
        customerReviewsCount: current.customerReviewsCount,
        address: current.address,
        city: current.city,
        distance: current.distance,
        requestedTime: current.requestedTime,
        description: current.description,
        estimatedBudget: current.estimatedBudget,
        quotedAmount: current.quotedAmount,
        quoteNotes: current.quoteNotes,
        status: status,
        completionDate: status == JobCategory.finished
            ? DateTime.now().toString()
            : current.completionDate,
        finalRating: current.finalRating,
        clientFeedback: current.clientFeedback,
        extraAmount: current.extraAmount,
        extraReason: current.extraReason,
        extraStatus: current.extraStatus,
        paymentMethod: current.paymentMethod,
        jobDate: current.jobDate,
        orderType: current.orderType,
        scheduledDate: current.scheduledDate,
        scheduledTimeSlot: current.scheduledTimeSlot,
        latitude: current.latitude,
        longitude: current.longitude,
        isCompanyAssigned: current.isCompanyAssigned,
        assignedCompanyName: current.assignedCompanyName,
        companyDispatchNote: current.companyDispatchNote,
      );

      _mockJobs[index] = updated;
      return updated;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> requestExtraAmount({
    required String jobId,
    required double amount,
    required String reason,
  }) async {
    try {
      final index = _mockJobs.indexWhere((j) => j.id == jobId);
      if (index == -1) throw ServerException('Job not found');

      final current = _mockJobs[index];
      final updated = JobModel(
        id: current.id,
        serviceTitle: current.serviceTitle,
        category: current.category,
        customerName: current.customerName,
        customerPhone: current.customerPhone,
        customerRating: current.customerRating,
        customerReviewsCount: current.customerReviewsCount,
        address: current.address,
        city: current.city,
        distance: current.distance,
        requestedTime: current.requestedTime,
        description: current.description,
        estimatedBudget: current.estimatedBudget,
        quotedAmount: current.quotedAmount,
        quoteNotes: current.quoteNotes,
        status: current.status,
        completionDate: current.completionDate,
        finalRating: current.finalRating,
        clientFeedback: current.clientFeedback,
        extraAmount: amount,
        extraReason: reason,
        extraStatus: ExtraApprovalStatus.pending,
        paymentMethod: current.paymentMethod,
        jobDate: current.jobDate,
        orderType: current.orderType,
        scheduledDate: current.scheduledDate,
        scheduledTimeSlot: current.scheduledTimeSlot,
        latitude: current.latitude,
        longitude: current.longitude,
        isCompanyAssigned: current.isCompanyAssigned,
        assignedCompanyName: current.assignedCompanyName,
        companyDispatchNote: current.companyDispatchNote,
      );

      _mockJobs[index] = updated;
      return updated;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> completeJob({
    required String jobId,
    double? finalRating,
    String? clientFeedback,
  }) async {
    try {
      final index = _mockJobs.indexWhere((j) => j.id == jobId);
      if (index == -1) throw ServerException('Job not found');

      final current = _mockJobs[index];
      final updated = JobModel(
        id: current.id,
        serviceTitle: current.serviceTitle,
        category: current.category,
        customerName: current.customerName,
        customerPhone: current.customerPhone,
        customerRating: current.customerRating,
        customerReviewsCount: current.customerReviewsCount,
        address: current.address,
        city: current.city,
        distance: current.distance,
        requestedTime: 'Completed Just Now',
        description: current.description,
        estimatedBudget: current.estimatedBudget,
        quotedAmount: current.quotedAmount,
        quoteNotes: current.quoteNotes,
        status: JobCategory.finished,
        completionDate: 'Today, Just Now',
        finalRating: finalRating ?? 5.0,
        clientFeedback: clientFeedback ?? 'Great job done!',
        extraAmount: current.extraAmount,
        extraReason: current.extraReason,
        extraStatus: current.extraStatus,
        paymentMethod: current.paymentMethod,
        jobDate: current.jobDate,
        orderType: current.orderType,
        scheduledDate: current.scheduledDate,
        scheduledTimeSlot: current.scheduledTimeSlot,
        latitude: current.latitude,
        longitude: current.longitude,
        isCompanyAssigned: current.isCompanyAssigned,
        assignedCompanyName: current.assignedCompanyName,
        companyDispatchNote: current.companyDispatchNote,
      );

      _mockJobs[index] = updated;
      return updated;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
