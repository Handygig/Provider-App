import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_app/core/constants/app_colors.dart';
import 'package:provider_app/src/data/services/payout_service.dart';
import 'package:provider_app/src/domain/models/bank_account_model.dart';
import 'package:provider_app/src/presentation/widgets/dynamic_island_toast.dart';

class BankPayoutDetailsScreen extends StatefulWidget {
  const BankPayoutDetailsScreen({super.key});

  @override
  State<BankPayoutDetailsScreen> createState() =>
      _BankPayoutDetailsScreenState();
}

class _BankPayoutDetailsScreenState extends State<BankPayoutDetailsScreen> {
  final PayoutService _service = PayoutService.instance;

  @override
  void initState() {
    super.initState();
    _service.fetchAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final accounts = _service.accounts;
        final primaryAccount = _service.primaryAccount;

        if (_service.isLoading && accounts.isEmpty) {
          return const Scaffold(
            backgroundColor: Color(0xFFF7F8F4),
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFF7F8F4),
            body: Column(
              children: [
                // 1. Top Custom App Bar
                _buildTopAppBar(),

                // 2. Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 100.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Primary Account Hero Card
                        if (primaryAccount != null) ...[
                          _buildPrimaryCard(primaryAccount),
                          SizedBox(height: 22.h),
                        ],

                        // Linked Bank Accounts Section
                        _buildSectionHeader(
                          title: 'Linked Bank Accounts',
                          badgeCount: accounts.length,
                          actionLabel: '+ Add Bank',
                          onAction: () => _openAddEditAccountSheet(),
                        ),
                        SizedBox(height: 12.h),

                        // Accounts List or Empty State
                        if (accounts.isEmpty) ...[
                          _buildEmptyAccountsCard(),
                        ] else ...[
                          ...accounts.map(
                            (account) => Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _buildAccountTile(account),
                            ),
                          ),
                          SizedBox(height: 14.h),
                          // Add Another Bank Account Button
                          _buildAddAccountButton(),
                        ],

                        SizedBox(height: 16.h),

                        // Banking Security & Guarantee Note
                        _buildSecurityNote(),
                      ],
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

  // ---------------------------------------------------------------------------
  // 1. TOP APP BAR
  // ---------------------------------------------------------------------------
  Widget _buildTopAppBar() {
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
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
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
                      'Bank & Payout Details',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17.5.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Direct deposit earnings & payout accounts',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Quick Add Icon Button
              GestureDetector(
                onTap: () => _openAddEditAccountSheet(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4DE95),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        color: AppColors.primaryDark,
                        size: 16,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Add',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. PRIMARY ACCOUNT HERO CARD
  // ---------------------------------------------------------------------------
  Widget _buildPrimaryCard(BankAccountModel account) {
    return Container(
      width: double.infinity,
      height: 185.h,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            account.cardStartColor,
            account.cardEndColor,
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: account.cardStartColor.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Card Geometric Embellishment
          Positioned(
            right: -25.w,
            top: -25.h,
            child: Container(
              width: 140.r,
              height: 140.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: 40.w,
            bottom: -35.h,
            child: Container(
              width: 110.r,
              height: 110.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          // Card Contents
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Bank Name + Primary Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            account.bankName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4DE95),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 11,
                          color: AppColors.primaryDark,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'PRIMARY PAYOUT',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Middle: Masked Account Number
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    // Chip icon
                    Container(
                      width: 32.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2B755),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.nfc_rounded,
                          size: 16.r,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Text(
                      account.maskedAccountNumber,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Row: Holder Name & Branch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACCOUNT HOLDER',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: Colors.white60,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        account.accountHolderName.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        account.accountType.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: Colors.white60,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        account.branchName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2.5 EMPTY ACCOUNTS CARD
  // ---------------------------------------------------------------------------
  Widget _buildEmptyAccountsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE5E9DC)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: AppColors.primaryDark,
              size: 30,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'No Bank Accounts Linked',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeadline,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Link your bank account to receive automated weekly earnings and direct payouts.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () => _openAddEditAccountSheet(),
            icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            label: Text(
              'Link Bank Account',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. ACCOUNT TILE
  // ---------------------------------------------------------------------------
  Widget _buildAccountTile(BankAccountModel account) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: account.isPrimary
              ? AppColors.primary.withValues(alpha: 0.4)
              : const Color(0xFFE5E9DC),
          width: account.isPrimary ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Bank Icon Avatar
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [account.cardStartColor, account.cardEndColor],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    account.bankCode,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Bank Name & Masked Acc
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            account.bankName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textHeadline,
                            ),
                          ),
                        ),
                        if (account.isPrimary) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'Default',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1B5E20),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${account.shortMasked} • ${account.accountType} • ${account.branchName}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Options Popover Menu
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF64748B),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                onSelected: (value) async {
                  if (value == 'primary') {
                    final ok = await _service.setPrimary(account.id);
                    if (ok && mounted) {
                      DynamicIslandToast.showSuccess(
                        context,
                        'Set ${account.bankName} as Primary Payout Account',
                      );
                    }
                  } else if (value == 'edit') {
                    _openAddEditAccountSheet(existingAccount: account);
                  } else if (value == 'delete') {
                    _confirmDeleteAccount(account);
                  }
                },
                itemBuilder: (context) => [
                  if (!account.isPrimary)
                    const PopupMenuItem(
                      value: 'primary',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 18, color: Color(0xFF16A34A)),
                          SizedBox(width: 10),
                          Text('Set as Primary'),
                        ],
                      ),
                    ),
                  if (_service.accounts.length > 1)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 18, color: Colors.red),
                          SizedBox(width: 10),
                          Text(
                            'Delete Account',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Primary Selector Row
          if (!account.isPrimary) ...[
            SizedBox(height: 10.h),
            Divider(height: 1, color: const Color(0xFFF1F5F9)),
            SizedBox(height: 8.h),
            InkWell(
              onTap: () async {
                final ok = await _service.setPrimary(account.id);
                if (ok && mounted) {
                  DynamicIslandToast.showSuccess(
                    context,
                    'Set as primary payout account',
                  );
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.radio_button_unchecked_rounded,
                      size: 16.r,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Make this my primary payout account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. ADD ACCOUNT BUTTON
  // ---------------------------------------------------------------------------
  Widget _buildAddAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton.icon(
        onPressed: () => _openAddEditAccountSheet(),
        icon: const Icon(
          Icons.add_circle_outline_rounded,
          color: AppColors.primary,
          size: 20,
        ),
        label: Text(
          'Add Another Bank Account',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFC7D3B5), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. BANKING SECURITY & GUARANTEE NOTE
  // ---------------------------------------------------------------------------
  Widget _buildSecurityNote() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5E9),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFDDE6D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.security_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Bank accounts are verified and encrypted using 256-bit encryption. Handygig complies with Central Bank of Sri Lanka electronic transfer standards.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5.sp,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF3B482A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int badgeCount,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textHeadline,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E7D7),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '$badgeCount',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onAction();
          },
          child: Text(
            actionLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 7. ADD / EDIT BANK ACCOUNT BOTTOM SHEET
  // ---------------------------------------------------------------------------
  void _openAddEditAccountSheet({BankAccountModel? existingAccount}) {
    HapticFeedback.lightImpact();
    final isEditing = existingAccount != null;

    final nameCtrl = TextEditingController(
      text: existingAccount?.accountHolderName ?? '',
    );
    final accCtrl = TextEditingController(
      text: existingAccount?.accountNumber ?? '',
    );
    final branchCtrl = TextEditingController(
      text: existingAccount?.branchName ?? '',
    );
    final branchCodeCtrl = TextEditingController(
      text: existingAccount?.branchCode ?? '',
    );

    BankOption selectedBank = PayoutService.supportedBanks.firstWhere(
      (b) => b.name == (existingAccount?.bankName ?? ''),
      orElse: () => PayoutService.supportedBanks.first,
    );

    String accountType = existingAccount?.accountType ?? 'Savings';
    bool isPrimary = existingAccount?.isPrimary ?? (_service.accounts.isEmpty);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                20.w,
                14.h,
                20.w,
                MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 38.w,
                        height: 4.5.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E4DE),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Sheet Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Edit Bank Account' : 'Add Bank Account',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textHeadline,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: const Color(0xFF64748B),
                        ),
                      ],
                    ),
                    Text(
                      'Payout earnings will be deposited directly to this account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // Select Bank Dropdown / Selector
                    Text(
                      'Select Bank',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAF6),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFE2E6D5)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<BankOption>(
                          value: selectedBank,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary,
                          ),
                          items: PayoutService.supportedBanks.map((bank) {
                            return DropdownMenuItem<BankOption>(
                              value: bank,
                              child: Row(
                                children: [
                                  Container(
                                    width: 10.r,
                                    height: 10.r,
                                    decoration: BoxDecoration(
                                      color: bank.startColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    bank.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textHeadline,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedBank = val);
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Account Holder Name
                    Text(
                      'Account Holder Full Name',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    _buildInputField(
                      controller: nameCtrl,
                      hint: 'e.g. Alex Perera',
                      icon: Icons.person_outline_rounded,
                    ),
                    SizedBox(height: 14.h),

                    // Account Number
                    Text(
                      'Account Number',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    _buildInputField(
                      controller: accCtrl,
                      hint: 'e.g. 800214594210',
                      icon: Icons.numbers_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 14.h),

                    // Branch & Branch Code
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Branch Name',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textHeadline,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              _buildInputField(
                                controller: branchCtrl,
                                hint: 'e.g. Kollupitiya',
                                icon: Icons.store_rounded,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Branch Code',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textHeadline,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              _buildInputField(
                                controller: branchCodeCtrl,
                                hint: 'e.g. 042',
                                icon: Icons.pin_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Account Type (Savings / Current)
                    Text(
                      'Account Type',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHeadline,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _buildTypeChip(
                          label: 'Savings Account',
                          isSelected: accountType == 'Savings',
                          onTap: () => setModalState(() => accountType = 'Savings'),
                        ),
                        SizedBox(width: 10.w),
                        _buildTypeChip(
                          label: 'Current Account',
                          isSelected: accountType == 'Current',
                          onTap: () => setModalState(() => accountType = 'Current'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Set as Primary Toggle
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAF6),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFE2E6D5)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: isPrimary
                                ? const Color(0xFFEAB308)
                                : const Color(0xFF94A3B8),
                            size: 22,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Set as Primary Payout Account',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textHeadline,
                                  ),
                                ),
                                Text(
                                  'Automatic weekly earnings will transfer here',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.sp,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: isPrimary,
                            activeTrackColor: AppColors.primary,
                            onChanged: (val) {
                              setModalState(() => isPrimary = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Save / Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          final accNumber = accCtrl.text.trim();
                          final holderName = nameCtrl.text.trim();
                          final branch = branchCtrl.text.trim();

                          if (accNumber.isEmpty || holderName.isEmpty) {
                            DynamicIslandToast.showError(
                              context,
                              'Please enter account holder name and number',
                            );
                            return;
                          }

                          bool ok;
                          if (isEditing) {
                            ok = await _service.updateAccount(
                              id: existingAccount.id,
                              bankName: selectedBank.name,
                              branchName: branch.isNotEmpty ? branch : 'Main Branch',
                              accountHolderName: holderName,
                              accountNumber: accNumber,
                              routingNumber: branchCodeCtrl.text.trim(),
                            );
                          } else {
                            ok = await _service.addAccount(
                              bankName: selectedBank.name,
                              branchName: branch.isNotEmpty ? branch : 'Main Branch',
                              accountHolderName: holderName,
                              accountNumber: accNumber,
                              routingNumber: branchCodeCtrl.text.trim(),
                              isDefault: isPrimary,
                            );
                          }

                          if (!context.mounted) return;
                          if (ok) {
                            Navigator.pop(ctx);
                            DynamicIslandToast.showSuccess(
                              context,
                              isEditing
                                  ? 'Account details updated successfully'
                                  : 'New bank account linked successfully',
                            );
                          } else {
                            DynamicIslandToast.showError(
                              context,
                              _service.errorMessage ?? 'Failed to save account',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Save Changes' : 'Link Bank Account',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAF6),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E6D5)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textHeadline,
        ),
        decoration: InputDecoration(
          icon: Icon(icon, color: AppColors.primary, size: 18),
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12.5.sp,
            color: AppColors.textMuted,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildTypeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6EA) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFE2E6D5),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textHeadline,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 8. DELETE CONFIRMATION DIALOG
  // ---------------------------------------------------------------------------
  void _confirmDeleteAccount(BankAccountModel account) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Remove Bank Account?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textHeadline,
            ),
          ),
          content: Text(
            'Are you sure you want to unlink ${account.bankName} (${account.shortMasked}) from your provider account?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              color: AppColors.textMuted,
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
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await _service.deleteAccount(account.id);
                if (!context.mounted) return;
                if (success) {
                  DynamicIslandToast.showSuccess(
                    context,
                    'Bank account removed',
                  );
                } else {
                  DynamicIslandToast.showError(
                    context,
                    _service.errorMessage ?? 'Failed to remove account',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Remove',
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

  // ---------------------------------------------------------------------------
  // 9. PICKERS (SCHEDULE & THRESHOLD)
}

