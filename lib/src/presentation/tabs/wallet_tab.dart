import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/data/services/payout_service.dart';
import 'package:provider_app/src/presentation/screens/payout/bank_payout_details_screen.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  double _availableBalance = 1840.50;
  final double _pendingClearance = 185.00;
  final double _thisMonthEarnings = 2450.00;
  double _platformFeesDue = 42.50;
  final double _totalCashCollected = 425.00;
  final int _cashJobsCount = 3;
  String _selectedFilter = 'All';

  late List<Map<String, dynamic>> _transactions;

  final List<Map<String, dynamic>> _cashJobs = [
    {
      'jobId': 'JOB-1024',
      'service': 'Emergency Pipe Leak Repair',
      'customer': 'Sarah Jenkins',
      'cashCollected': 65.00,
      'feePercent': 10,
      'feeDue': 6.50,
      'date': 'Today, 2:45 PM',
    },
    {
      'jobId': 'JOB-1027',
      'service': 'Water Pump Motor Replacement',
      'customer': 'Chaminda Silva',
      'cashCollected': 200.00,
      'feePercent': 10,
      'feeDue': 20.00,
      'date': 'Sep 21, 2026',
    },
    {
      'jobId': 'JOB-1028',
      'service': 'Ceiling Fan & Regulator Wiring',
      'customer': 'Anuradha Jayasinghe',
      'cashCollected': 160.00,
      'feePercent': 10,
      'feeDue': 16.00,
      'date': 'Sep 20, 2026',
    },
  ];

  @override
  void initState() {
    super.initState();
    _transactions = [
      {
        'id': 'TXN-9082',
        'title': 'Emergency Pipe Leak Repair',
        'type': 'earning',
        'paymentMode': 'Cash',
        'customer': 'Sarah Jenkins',
        'jobId': 'JOB-1024',
        'amount': 65.00,
        'baseAmount': 45.00,
        'extraAmount': 20.00,
        'platformFee': 6.50,
        'netAmount': 58.50,
        'date': 'Today, 2:45 PM',
        'status': 'Completed (Cash)',
        'bank': null,
      },
      {
        'id': 'TXN-9041',
        'title': 'Withdrawal to Commercial Bank',
        'type': 'payout',
        'paymentMode': 'Bank Transfer',
        'customer': null,
        'jobId': null,
        'amount': -450.00,
        'baseAmount': 450.00,
        'extraAmount': 0.0,
        'platformFee': 0.0,
        'netAmount': -450.00,
        'date': 'Yesterday, 10:15 AM',
        'status': 'Completed',
        'bank': 'Commercial Bank •••• 4291',
      },
      {
        'id': 'TXN-8994',
        'title': 'Commercial AC Service & Filter',
        'type': 'earning',
        'paymentMode': 'Online (Escrow)',
        'customer': 'David Miller',
        'jobId': 'JOB-1025',
        'amount': 160.00,
        'baseAmount': 135.00,
        'extraAmount': 25.00,
        'platformFee': 8.00,
        'netAmount': 152.00,
        'date': 'Sep 20, 2026',
        'status': 'Completed',
        'bank': null,
      },
      {
        'id': 'TXN-8920',
        'title': 'Main Switchboard Repair',
        'type': 'earning',
        'paymentMode': 'Online (Escrow)',
        'customer': 'Nimal Perera',
        'jobId': 'JOB-1026',
        'amount': 60.00,
        'baseAmount': 60.00,
        'extraAmount': 0.0,
        'platformFee': 3.00,
        'netAmount': 57.00,
        'date': 'Sep 19, 2026',
        'status': 'Pending Clearance',
        'bank': null,
      },
      {
        'id': 'TXN-8871',
        'title': 'Extra Material Reimbursement',
        'type': 'extra',
        'paymentMode': 'Online',
        'customer': 'Sarah Jenkins',
        'jobId': 'JOB-1024',
        'amount': 20.00,
        'baseAmount': 20.00,
        'extraAmount': 20.00,
        'platformFee': 0.0,
        'netAmount': 20.00,
        'date': 'Sep 18, 2026',
        'status': 'Completed',
        'bank': null,
      },
      {
        'id': 'TXN-8812',
        'title': 'Weekly Payout Deposited',
        'type': 'payout',
        'paymentMode': 'Direct Deposit',
        'customer': null,
        'jobId': null,
        'amount': -680.00,
        'baseAmount': 680.00,
        'extraAmount': 0.0,
        'platformFee': 0.0,
        'netAmount': -680.00,
        'date': 'Sep 15, 2026',
        'status': 'Completed',
        'bank': 'Commercial Bank •••• 4291',
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == 'Earnings') {
      return _transactions.where((t) => t['type'] == 'earning').toList();
    } else if (_selectedFilter == 'Payouts') {
      return _transactions.where((t) => t['type'] == 'payout').toList();
    } else if (_selectedFilter == 'Platform Fees') {
      return _transactions
          .where((t) => t['type'] == 'fee' || (t['platformFee'] ?? 0.0) > 0)
          .toList();
    } else if (_selectedFilter == 'Extras') {
      return _transactions.where((t) => t['type'] == 'extra').toList();
    }
    return _transactions;
  }

  void _settlePlatformFees() {
    HapticFeedback.mediumImpact();
    if (_availableBalance < _platformFeesDue) {
      DynamicIslandToast.showSuccess(
        context,
        'Insufficient balance to settle platform fees directly.',
      );
      return;
    }

    final double settledAmount = _platformFeesDue;
    setState(() {
      _availableBalance -= settledAmount;
      _platformFeesDue = 0.0;
      _transactions.insert(0, {
        'id': 'TXN-${DateTime.now().millisecondsSinceEpoch % 10000}',
        'title': 'Admin Platform Fee Settlement (Cash Jobs)',
        'type': 'fee',
        'paymentMode': 'Wallet Deduction',
        'customer': null,
        'jobId': null,
        'amount': -settledAmount,
        'baseAmount': settledAmount,
        'extraAmount': 0.0,
        'platformFee': settledAmount,
        'netAmount': -settledAmount,
        'date': 'Just now',
        'status': 'Paid to Admin',
        'bank': 'Deducted from Wallet Balance',
      });
    });

    DynamicIslandToast.showSuccess(
      context,
      'Platform fee of LKR ${settledAmount.toStringAsFixed(2)} settled to Admin!',
    );
  }

  void _openCashJobsBreakdownDrawer() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E6D5),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cash Jobs Platform Fees',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textHeadline,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '10% commission due on on-site cash collections',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '$_cashJobsCount Jobs',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Summary Box
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9F3),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE4E8D7)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Total Cash Collected',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'LKR ${_totalCashCollected.toStringAsFixed(2)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textHeadline,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 36.h,
                      color: const Color(0xFFE2E6D5),
                    ),
                    Column(
                      children: [
                        Text(
                          'Admin Fee (10%)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'LKR ${_platformFeesDue.toStringAsFixed(2)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              Text(
                'Jobs Breakdown',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeadline,
                ),
              ),
              SizedBox(height: 10.h),

              // Jobs list
              ..._cashJobs.map((job) {
                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFE2E6D5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4EB),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.payments_rounded,
                          color: AppColors.primary,
                          size: 18.r,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job['service'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textHeadline,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${job['jobId']} • ${job['customer']} • ${job['date']}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+LKR ${(job['cashCollected'] as double).toStringAsFixed(2)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textHeadline,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Fee: LKR ${(job['feeDue'] as double).toStringAsFixed(2)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              SizedBox(height: 18.h),

              if (_platformFeesDue > 0)
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      _settlePlatformFees();
                    },
                    child: Text(
                      'Settle All Fees (LKR ${_platformFeesDue.toStringAsFixed(2)})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w800,
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

  void _openWithdrawModal() {
    HapticFeedback.mediumImpact();
    final TextEditingController amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
                left: 20.w,
                right: 20.w,
                top: 20.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 44.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E6D5),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Withdraw to Bank',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textHeadline,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4EB),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Max LKR ${_availableBalance.toStringAsFixed(2)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Direct transfer to your primary verified bank account.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // Destination Bank Card
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAF6),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFFE2E6D5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.account_balance_rounded,
                            color: AppColors.primary,
                            size: 20.r,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Commercial Bank of Ceylon',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textHeadline,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '•••• 4291 • Savings • Malaka Perera',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.verified_rounded,
                          color: AppColors.primary,
                          size: 18.r,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Amount input
                  Text(
                    'Enter Amount (LKR)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHeadline,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textHeadline,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 16.w, right: 8.w),
                        child: Center(
                          widthFactor: 0.0,
                          child: Text(
                            'LKR ',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      hintText: '0.00',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFBAC095),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FAF6),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E6D5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E6D5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Quick amount selector chips
                  Row(
                    children: [50, 100, 500].map((amt) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            amountController.text = amt.toString();
                            setModalState(() {});
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4EB),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: const Color(0xFFE2E6D5),
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'LKR $amt',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textHeadline,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList()
                      ..add(
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              amountController.text =
                                  _availableBalance.toStringAsFixed(2);
                              setModalState(() {});
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'All',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ),

                  SizedBox(height: 16.h),

                  // Destination Bank Account Box
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAF6),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFE2E6D5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F3E8F).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_rounded,
                            color: Color(0xFF0F3E8F),
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Deposit To Payout Account',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                PayoutService.instance.primaryAccountSummary,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textHeadline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(bottomSheetContext);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BankPayoutDetailsScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Manage',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      onPressed: () {
                        final val = double.tryParse(amountController.text);
                        if (val == null || val <= 0) {
                          DynamicIslandToast.showSuccess(
                            context,
                            'Please enter a valid amount',
                          );
                          return;
                        }
                        if (val > _availableBalance) {
                          DynamicIslandToast.showSuccess(
                            context,
                            'Amount exceeds available balance',
                          );
                          return;
                        }

                        HapticFeedback.heavyImpact();
                        Navigator.pop(bottomSheetContext);

                        final primaryBank = PayoutService.instance.primaryAccount;
                        final bankName = primaryBank?.bankName ?? 'Bank';
                        final bankSummary = PayoutService.instance.primaryAccountSummary;

                        setState(() {
                          _availableBalance -= val;
                          _transactions.insert(0, {
                            'id':
                                'TXN-${DateTime.now().millisecondsSinceEpoch % 10000}',
                            'title': 'Withdrawal to $bankName',
                            'type': 'payout',
                            'paymentMode': 'Bank Transfer',
                            'customer': null,
                            'jobId': null,
                            'amount': -val,
                            'baseAmount': val,
                            'extraAmount': 0.0,
                            'platformFee': 0.0,
                            'netAmount': -val,
                            'date': 'Just now',
                            'status': 'Processing',
                            'bank': bankSummary,
                          });
                        });

                        DynamicIslandToast.showSuccess(
                          context,
                          'Withdrawal of LKR ${val.toStringAsFixed(2)} initiated!',
                        );
                      },
                      child: Text(
                        'Confirm Withdrawal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openReceiptModal(Map<String, dynamic> tx) {
    HapticFeedback.lightImpact();
    final bool isPayout = tx['type'] == 'payout';
    final bool isFee = tx['type'] == 'fee';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 32.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E6D5),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction Receipt',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textHeadline,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: tx['status'].toString().contains('Completed') ||
                              tx['status'].toString().contains('Paid')
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: tx['status'].toString().contains('Completed') ||
                                tx['status'].toString().contains('Paid')
                            ? const Color(0xFFA7F3D0)
                            : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Text(
                      tx['status'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: tx['status'].toString().contains('Completed') ||
                                tx['status'].toString().contains('Paid')
                            ? const Color(0xFF047857)
                            : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Hero amount container
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 18.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F0),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: const Color(0xFFE2E6D5)),
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      '${tx['amount'] >= 0 ? '+' : ''}LKR ${(tx['amount'] as double).abs().toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        color: isPayout || isFee
                            ? AppColors.textHeadline
                            : const Color(0xFF16A34A),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      tx['title'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),

              // Line Items
              _buildReceiptRow('Reference ID', tx['id'] as String),
              _buildReceiptRow('Date & Time', tx['date'] as String),
              if (tx['paymentMode'] != null)
                _buildReceiptRow('Payment Method', tx['paymentMode'] as String),
              if (tx['jobId'] != null)
                _buildReceiptRow('Job Reference', tx['jobId'] as String),
              if (tx['customer'] != null)
                _buildReceiptRow('Customer', tx['customer'] as String),
              if (tx['bank'] != null)
                _buildReceiptRow('Destination / Note', tx['bank'] as String),
              if (tx['baseAmount'] != null && !isPayout && !isFee)
                _buildReceiptRow(
                  'Base Quote',
                  'LKR ${(tx['baseAmount'] as double).toStringAsFixed(2)}',
                ),
              if ((tx['extraAmount'] ?? 0.0) > 0)
                _buildReceiptRow(
                  'Extra Approved',
                  '+LKR ${(tx['extraAmount'] as double).toStringAsFixed(2)}',
                  highlightGreen: true,
                ),
              if ((tx['platformFee'] ?? 0.0) > 0)
                _buildReceiptRow(
                  'Admin Platform Fee (10%)',
                  '-LKR ${(tx['platformFee'] as double).toStringAsFixed(2)}',
                  highlightOrange: true,
                ),

              const Divider(height: 24, color: Color(0xFFE2E6D5)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isFee ? 'Total Paid to Admin' : 'Net Credited',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textHeadline,
                    ),
                  ),
                  Text(
                    'LKR ${(tx['netAmount'] as double).abs().toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: isPayout || isFee
                          ? AppColors.textHeadline
                          : const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(ctx);
                    DynamicIslandToast.showSuccess(
                      context,
                      'Receipt downloaded for #${tx['id']}',
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text(
                    'Download PDF Invoice',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
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

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool highlightGreen = false,
    bool highlightOrange = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: highlightGreen
                  ? const Color(0xFF16A34A)
                  : (highlightOrange
                      ? const Color(0xFFD97706)
                      : AppColors.textHeadline),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PLATFORM COMMISSION FEES CARD (CASH ORDERS REMITTANCE)
  // ---------------------------------------------------------------------------
  Widget _buildPlatformFeesCard() {
    final bool hasDues = _platformFeesDue > 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: hasDues ? const Color(0xFFFDE68A) : const Color(0xFFE2E6D5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: hasDues
                ? const Color(0xFFD97706).withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: hasDues
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasDues
                          ? Icons.price_check_rounded
                          : Icons.verified_rounded,
                      color: hasDues
                          ? const Color(0xFFD97706)
                          : const Color(0xFF16A34A),
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Platform Fees',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textHeadline,
                        ),
                      ),
                      Text(
                        'Cash Payment Commission (10%)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Status Tag
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: hasDues
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: hasDues
                        ? const Color(0xFFFDE68A)
                        : const Color(0xFFA7F3D0),
                  ),
                ),
                child: Text(
                  hasDues ? 'Fee Due' : 'All Settled ✓',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: hasDues
                        ? const Color(0xFFB45309)
                        : const Color(0xFF047857),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // Fee Amount Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Outstanding Platform Fee',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'LKR ${_platformFeesDue.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w900,
                      color: hasDues
                          ? const Color(0xFFD97706)
                          : const Color(0xFF16A34A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              if (hasDues)
                GestureDetector(
                  onTap: _openCashJobsBreakdownDrawer,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F0),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFE2E6D5)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$_cashJobsCount Cash Jobs',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16.r,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 12.h),

          // Explanation / Context Strip
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAF6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFECEFE4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 15.r,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    hasDues
                        ? 'Customer paid LKR ${_totalCashCollected.toStringAsFixed(2)} in cash directly to you. Remit the 10% platform fee to Admin or settle from your wallet balance.'
                        : 'No pending platform fees. Any fees from future cash orders will display here automatically.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (hasDues) ...[
            SizedBox(height: 14.h),

            // Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: _settlePlatformFees,
                    icon: const Icon(Icons.check_circle_rounded, size: 16),
                    label: Text(
                      'Pay Fee (LKR ${_platformFeesDue.toStringAsFixed(2)})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textHeadline,
                    side: const BorderSide(color: Color(0xFFDCE1D0)),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 11.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: _openCashJobsBreakdownDrawer,
                  icon: const Icon(Icons.receipt_long_rounded, size: 16),
                  label: Text(
                    'Breakdown',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F3),
      appBar: AppBar(
        backgroundColor: AppColors.darkHeaderBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Wallet & Payouts',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 19.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFFD4DE95),
            ),
            tooltip: 'Statements',
            onPressed: () {
              HapticFeedback.lightImpact();
              DynamicIslandToast.showSuccess(
                context,
                'Monthly Statement generated',
              );
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. HERO BALANCE CARD ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primary,
                  ],
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
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
                            width: 8.r,
                            height: 8.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD4DE95),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Available Balance',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFBAC095),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_rounded,
                              color: Colors.white70,
                              size: 13.r,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Commercial Bank ••4291',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  Text(
                    'LKR ${_availableBalance.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // Quick Action Button Inside Hero Card
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4DE95),
                        foregroundColor: AppColors.primaryDark,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      onPressed: _openWithdrawModal,
                      icon: Icon(
                        Icons.arrow_outward_rounded,
                        size: 18.r,
                        color: AppColors.primaryDark,
                      ),
                      label: Text(
                        'Withdraw Funds',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // ─── 2. EARNINGS METRICS ROW ──────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: const Color(0xFFE2E6D5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              color: const Color(0xFF16A34A),
                              size: 18.r,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'This Month',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '+LKR ${_thisMonthEarnings.toStringAsFixed(2)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textHeadline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: const Color(0xFFE2E6D5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.hourglass_top_rounded,
                              color: const Color(0xFFD97706),
                              size: 18.r,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Pending Escrow',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'LKR ${_pendingClearance.toStringAsFixed(2)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // ─── 3. ADMIN PLATFORM FEES (CASH PAYMENTS) CARD ───────────────
            _buildPlatformFeesCard(),

            SizedBox(height: 20.h),

            // ─── 4. TRANSACTIONS HEADER & FILTER PILLS ─────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction History',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHeadline,
                  ),
                ),
                Text(
                  '${_filteredTransactions.length} records',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  'All',
                  'Earnings',
                  'Payouts',
                  'Platform Fees',
                  'Extras'
                ].map((filter) {
                  final bool isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFE2E6D5),
                        ),
                      ),
                      child: Text(
                        filter,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5.sp,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textHeadline,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 16.h),

            // ─── 5. TRANSACTIONS LIST ──────────────────────────────────────
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredTransactions.length,
              separatorBuilder: (_, _) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final tx = _filteredTransactions[index];
                final bool isPayout = tx['type'] == 'payout';
                final bool isFee = tx['type'] == 'fee';
                final bool isExtra = tx['type'] == 'extra';
                final bool isPending = tx['status'] == 'Pending Clearance';

                IconData txIcon = Icons.arrow_downward_rounded;
                Color txColor = const Color(0xFF16A34A);
                Color txBg = const Color(0xFFECFDF5);

                if (isPayout) {
                  txIcon = Icons.arrow_upward_rounded;
                  txColor = AppColors.primaryDark;
                  txBg = const Color(0xFFF2F4EB);
                } else if (isFee) {
                  txIcon = Icons.admin_panel_settings_rounded;
                  txColor = const Color(0xFFD97706);
                  txBg = const Color(0xFFFEF3C7);
                } else if (isExtra) {
                  txIcon = Icons.post_add_rounded;
                  txColor = const Color(0xFF0284C7);
                  txBg = const Color(0xFFE0F2FE);
                } else if (isPending) {
                  txIcon = Icons.hourglass_empty_rounded;
                  txColor = const Color(0xFFD97706);
                  txBg = const Color(0xFFFFFBEB);
                }

                return GestureDetector(
                  onTap: () => _openReceiptModal(tx),
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFFE2E6D5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Leading Icon Badge
                        Container(
                          width: 44.r,
                          height: 44.r,
                          decoration: BoxDecoration(
                            color: txBg,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Icon(
                            txIcon,
                            color: txColor,
                            size: 20.r,
                          ),
                        ),
                        SizedBox(width: 12.w),

                        // Title & Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx['title'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textHeadline,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                '${tx['date']} • ${tx['customer'] ?? tx['bank'] ?? (isFee ? 'Admin Remittance' : 'Provider Wallet')}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5.sp,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),

                        // Trailing Amount & Status
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${tx['amount'] >= 0 ? '+' : ''}LKR ${(tx['amount'] as double).abs().toStringAsFixed(2)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: isPayout || isFee
                                    ? AppColors.textHeadline
                                    : (isPending
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF16A34A)),
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              tx['status'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w600,
                                color: isPending || isFee
                                    ? const Color(0xFFD97706)
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
