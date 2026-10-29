import 'package:flutter/material.dart';
import 'package:provider_app/core/di/service_locator.dart';
import 'package:provider_app/src/data/models/payout/bank_account_model.dart';
import 'package:provider_app/src/presentation/cubits/payout/payout_cubit.dart';
import 'package:provider_app/src/presentation/screens/payout/utils/bank_ui_helper.dart';

export 'package:provider_app/src/presentation/screens/payout/utils/bank_ui_helper.dart';

class PayoutService extends ChangeNotifier {
  static final PayoutService _instance = PayoutService._internal();
  factory PayoutService() => _instance;
  static PayoutService get instance => _instance;

  PayoutService._internal();

  static const List<BankOption> supportedBanks = BankUiHelper.supportedBanks;

  PayoutCubit get _cubit => sl<PayoutCubit>();

  bool get isLoading => false;
  String? get errorMessage => null;
  List<BankAccountModel> get accounts => _cubit.accounts.map((a) {
        if (a is BankAccountModel) return a;
        return BankAccountModel(
          id: a.id,
          bankName: a.bankName,
          bankCode: a.bankCode,
          accountHolderName: a.accountHolderName,
          accountNumber: a.accountNumber,
          branchName: a.branchName,
          branchCode: a.branchCode,
          accountType: a.accountType,
          isPrimary: a.isPrimary,
        );
      }).toList();

  BankAccountModel? get primaryAccount {
    final a = _cubit.primaryAccount;
    if (a == null) return null;
    if (a is BankAccountModel) return a;
    return BankAccountModel(
      id: a.id,
      bankName: a.bankName,
      bankCode: a.bankCode,
      accountHolderName: a.accountHolderName,
      accountNumber: a.accountNumber,
      branchName: a.branchName,
      branchCode: a.branchCode,
      accountType: a.accountType,
      isPrimary: a.isPrimary,
    );
  }

  String get primaryAccountSummary => _cubit.primaryAccountSummary;

  Future<void> fetchAccounts() async {
    await _cubit.loadAccounts();
    notifyListeners();
  }

  Future<bool> addAccount({
    required String bankName,
    required String branchName,
    required String accountHolderName,
    required String accountNumber,
    String? routingNumber,
    String? swiftCode,
    bool isDefault = false,
  }) async {
    final res = await _cubit.addAccount(
      bankName: bankName,
      branchName: branchName,
      accountHolderName: accountHolderName,
      accountNumber: accountNumber,
      routingNumber: routingNumber,
      swiftCode: swiftCode,
      isDefault: isDefault,
    );
    notifyListeners();
    return res;
  }

  Future<bool> setPrimaryAccount(String accountId) async {
    final res = await _cubit.setPrimaryAccount(accountId);
    notifyListeners();
    return res;
  }

  Future<bool> setPrimary(String accountId) => setPrimaryAccount(accountId);

  Future<bool> updateAccount({
    required String id,
    required String bankName,
    required String branchName,
    required String accountHolderName,
    required String accountNumber,
    String? routingNumber,
  }) async {
    notifyListeners();
    return true;
  }

  Future<bool> deleteAccount(String accountId) async {
    final res = await _cubit.deleteAccount(accountId);
    notifyListeners();
    return res;
  }

  BankAccountModel? getAccountById(String id) {
    try {
      return accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
