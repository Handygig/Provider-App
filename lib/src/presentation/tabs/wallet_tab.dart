import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/core/constants/app_endpoints.dart';
import 'package:provider_app/core/di/service_locator.dart';
import 'package:provider_app/src/data/services/payout_service.dart';
import 'package:provider_app/src/presentation/screens/payout/bank_payout_details_screen.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';
import 'package:provider_app/src/data/services/provider_session_service.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  double _availableBalance = 0.0;
  double _pendingClearance = 0.0;
  double _thisMonthEarnings = 0.0;
  double _platformFeesDue = 0.0;
  double _totalCashCollected = 0.0;
  int _cashJobsCount = 0;
  String _selectedFilter = 'All';
  bool _isLoading = false;

  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _cashJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  Future<void> _fetchWalletData() async {
    setState(() => _isLoading = true);
    try {
      final dio = sl<Dio>();
      final response = await dio.get(AppEndpoints.providerWallet);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        if (mounted) {
          setState(() {
            _availableBalance = (data['available_balance'] as num?)?.toDouble() ?? 0.0;
            _pendingClearance = (data['pending_clearance'] as num?)?.toDouble() ?? 0.0;
            _thisMonthEarnings = (data['this_month_earnings'] as num?)?.toDouble() ?? 0.0;
            _platformFeesDue = (data['platform_fees_due'] as num?)?.toDouble() ?? 0.0;
            _totalCashCollected = (data['total_cash_collected'] as num?)?.toDouble() ?? 0.0;
            _cashJobsCount = (data['cash_jobs_count'] as num?)?.toInt() ?? 0;

            final rawTransactions = data['transactions'] as List<dynamic>? ?? [];
            _transactions = rawTransactions
                .map((t) => Map<String, dynamic>.from(t as Map))
                .toList();

            _cashJobs = _transactions
                .where((t) =>
                    t['paymentMode'] == 'Cash' ||
                    (t['type'] == 'earning' && (t['platformFee'] ?? 0) > 0))
                .map((t) => {
                      'jobId': t['jobId'] ?? 'JOB',
                      'service': t['title'] ?? 'Service',
                      'customer': t['customer'] ?? 'Customer',
                      'cashCollected': ((t['amount'] ?? 0) as num).toDouble(),
                      'feePercent': 10,
                      'feeDue': ((t['platformFee'] ?? 0) as num).toDouble(),
                      'date': t['date'] ?? '',
                    })
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching wallet data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    List<Map<String, dynamic>> list = _transactions;
    if (ProviderSessionService.instance.isCompanyProvider) {
      list = list
          .where((t) => t['type'] != 'fee' && t['type'] != 'payout')
          .toList();
    }
    if (_selectedFilter == 'Earnings') {
      return list.where((t) => t['type'] == 'earning').toList();
    } else if (_selectedFilter == 'Payouts') {
      return list.where((t) => t['type'] == 'payout').toList();
    } else if (_selectedFilter == 'Platform Fees') {
      return list
          .where((t) => t['type'] == 'fee' || (t['platformFee'] ?? 0.0) > 0)
          .toList();
    } else if (_selectedFilter == 'Extras') {
      return list.where((t) => t['type'] == 'extra').toList();
    }
    return list;
  }

  Future<void> _settlePlatformFees() async {
    HapticFeedback.mediumImpact();
    if (_availableBalance < _platformFeesDue) {
      DynamicIslandToast.showSuccess(
        context,
        'Insufficient balance to settle platform fees directly.',
      );
      return;
    }

    final double settledAmount = _platformFeesDue;
    try {
      final dio = sl<Dio>();
      final res = await dio.post(
        AppEndpoints.providerWalletPayFees,
        data: {'amount': settledAmount},
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        await _fetchWalletData();
        if (mounted) {
          DynamicIslandToast.showSuccess(
            context,
            'Platform fee of LKR ${settledAmount.toStringAsFixed(2)} settled to Admin!',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        DynamicIslandToast.showSuccess(
          context,
          'Failed to settle platform fee: $e',
        );
      }
    }
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
    if (!ProviderSessionService.instance.canWithdrawMoney) {
      _showCompanyWithdrawalInfo(context);
      return;
    }
    final TextEditingController amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24.h,
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
                                PayoutService.instance.primaryAccount?.bankName ?? 'Linked Bank Account',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textHeadline,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                PayoutService.instance.primaryAccount != null
                                    ? '${PayoutService.instance.primaryAccount!.shortMasked} • ${PayoutService.instance.primaryAccount!.accountType} • ${PayoutService.instance.primaryAccount!.accountHolderName}'
                                    : 'Please link a bank account for withdrawals',
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
                        () async {
                          try {
                            final dio = sl<Dio>();
                            final res = await dio.post(
                              AppEndpoints.providerPayouts,
                              data: {
                                'amount': val,
                                if (primaryBank != null)
                                  'payout_account_id': primaryBank.id,
                              },
                            );
                            if (res.statusCode == 200 || res.statusCode == 201) {
                              await _fetchWalletData();
                              if (!mounted) return;
                              DynamicIslandToast.showSuccess(
                                context,
                                'Withdrawal of LKR ${val.toStringAsFixed(2)} initiated!',
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            DynamicIslandToast.showSuccess(
                              context,
                              'Withdrawal failed: $e',
                            );
                          }
                        }();
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
    return AnimatedBuilder(
      animation: ProviderSessionService.instance,
      builder: (context, _) {
        final isCompany = ProviderSessionService.instance.isCompanyProvider;
        return Scaffold(
          backgroundColor: const Color(0xFFF7F8F3),
          appBar: AppBar(
            backgroundColor: AppColors.darkHeaderBg,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              isCompany ? 'My Earnings' : 'Wallet & Payouts',
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
          body: _isLoading && _transactions.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : RefreshIndicator(
                  onRefresh: _fetchWalletData,
                  color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
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
                                isCompany ? 'Earned Revenue' : 'Available Balance',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFBAC095),
                                ),
                              ),
                            ],
                          ),
                          if (!isCompany)
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
                                    PayoutService.instance.primaryAccountSummary,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: const Color(0xFF86EFAC).withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.business_rounded,
                                    color: const Color(0xFFD4DE95),
                                    size: 13.r,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${ProviderSessionService.instance.companyName} • Staff',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
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

                      // Quick Action Button / Notice Inside Hero Card
                      if (ProviderSessionService.instance.canWithdrawMoney)
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
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_rounded,
                                size: 17.r,
                                color: const Color(0xFFD4DE95),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Company Managed Payroll',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Direct withdrawals disabled • Paid via ${ProviderSessionService.instance.companyName}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5.sp,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 30.h,
                                child: TextButton(
                                  onPressed: () => _showCompanyWithdrawalInfo(context),
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4DE95),
                                    foregroundColor: AppColors.primaryDark,
                                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Info',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

            if (!isCompany) ...[
              SizedBox(height: 16.h),

              // ─── 3. ADMIN PLATFORM FEES (CASH PAYMENTS) CARD ───────────────
              _buildPlatformFeesCard(),
            ],

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
                children: (isCompany
                        ? ['All', 'Earnings', 'Extras']
                        : [
                            'All',
                            'Earnings',
                            'Payouts',
                            'Platform Fees',
                            'Extras'
                          ])
                    .map((filter) {
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
            if (_filteredTransactions.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: const Color(0xFFE2E6D5)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 42.r,
                      color: const Color(0xFFBAC095),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'No transactions yet',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Earnings, payouts, and fees will appear here once jobs are completed.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              )
            else
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
      ),
    );
  },
);
}

  void _showCompanyWithdrawalInfo(BuildContext context) {
    HapticFeedback.lightImpact();
    final company = ProviderSessionService.instance.companyName;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          padding: EdgeInsets.fromLTRB(22.w, 16.h, 22.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E4DE),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 18.h),
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                ),
                child: Icon(
                  Icons.lock_rounded,
                  color: const Color(0xFF2563EB),
                  size: 26.r,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Personal Withdrawals Restricted',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHeadline,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'As a Service Provider employed under $company, you have an access-controlled service provider account. You can view your earned money from completed jobs, but cannot initiate direct bank withdrawals.\n\nAll job earnings are logged and disbursed through your company\'s central corporate payroll.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    'Understood',
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
}
