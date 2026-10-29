import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider_app/core/usecases/usecases.dart';
import 'package:provider_app/src/domain/entities/payout/bank_account_entity.dart';
import 'package:provider_app/src/domain/usecases/payout/payout_usecases.dart';
import 'package:provider_app/src/presentation/cubits/payout/payout_state.dart';

class PayoutCubit extends Cubit<PayoutState> {
  final GetBankAccountsUseCase getBankAccountsUseCase;
  final AddBankAccountUseCase addBankAccountUseCase;
  final SetPrimaryBankAccountUseCase setPrimaryBankAccountUseCase;
  final DeleteBankAccountUseCase deleteBankAccountUseCase;

  List<BankAccountEntity> _cachedAccounts = const [];

  PayoutCubit({
    required this.getBankAccountsUseCase,
    required this.addBankAccountUseCase,
    required this.setPrimaryBankAccountUseCase,
    required this.deleteBankAccountUseCase,
  }) : super(const PayoutInitial());

  List<BankAccountEntity> get accounts => _cachedAccounts;

  BankAccountEntity? get primaryAccount {
    try {
      return _cachedAccounts.firstWhere((a) => a.isPrimary);
    } catch (_) {
      return _cachedAccounts.isNotEmpty ? _cachedAccounts.first : null;
    }
  }

  String get primaryAccountSummary {
    final primary = primaryAccount;
    if (primary == null) return 'No Bank Account Linked';
    return '${primary.bankName} ${primary.shortMasked}';
  }

  Future<void> loadAccounts({bool silent = false}) async {
    if (!silent) {
      emit(const PayoutLoading());
    }

    final result = await getBankAccountsUseCase(NoParams());
    result.fold(
      (failure) => emit(PayoutError(failure.errorMessage)),
      (accountsList) {
        _cachedAccounts = accountsList;
        emit(PayoutLoaded(
          List.unmodifiable(_cachedAccounts),
          primaryAccount: primaryAccount,
        ));
      },
    );
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
    emit(const PayoutLoading());

    final result = await addBankAccountUseCase(
      AddBankAccountParams(
        bankName: bankName,
        branchName: branchName,
        accountHolderName: accountHolderName,
        accountNumber: accountNumber,
        routingNumber: routingNumber,
        swiftCode: swiftCode,
        isDefault: isDefault,
      ),
    );

    return result.fold(
      (failure) {
        emit(PayoutError(failure.errorMessage));
        if (_cachedAccounts.isNotEmpty) {
          emit(PayoutLoaded(
            List.unmodifiable(_cachedAccounts),
            primaryAccount: primaryAccount,
          ));
        }
        return false;
      },
      (newAccount) async {
        emit(const PayoutActionSuccess('Bank account added successfully'));
        await loadAccounts(silent: true);
        return true;
      },
    );
  }

  Future<bool> setPrimaryAccount(String accountId) async {
    final previousAccounts = List<BankAccountEntity>.from(_cachedAccounts);

    _cachedAccounts = _cachedAccounts
        .map((a) => a.copyWith(isPrimary: a.id == accountId))
        .toList();
    emit(PayoutLoaded(
      List.unmodifiable(_cachedAccounts),
      primaryAccount: primaryAccount,
    ));

    final result = await setPrimaryBankAccountUseCase(accountId);
    return result.fold(
      (failure) {
        _cachedAccounts = previousAccounts;
        emit(PayoutError(failure.errorMessage));
        emit(PayoutLoaded(
          List.unmodifiable(_cachedAccounts),
          primaryAccount: primaryAccount,
        ));
        return false;
      },
      (_) {
        emit(const PayoutActionSuccess('Primary account updated successfully'));
        emit(PayoutLoaded(
          List.unmodifiable(_cachedAccounts),
          primaryAccount: primaryAccount,
        ));
        return true;
      },
    );
  }

  Future<bool> deleteAccount(String accountId) async {
    final result = await deleteBankAccountUseCase(accountId);
    return result.fold(
      (failure) {
        emit(PayoutError(failure.errorMessage));
        emit(PayoutLoaded(
          List.unmodifiable(_cachedAccounts),
          primaryAccount: primaryAccount,
        ));
        return false;
      },
      (_) async {
        _cachedAccounts =
            _cachedAccounts.where((a) => a.id != accountId).toList();
        emit(const PayoutActionSuccess('Bank account removed successfully'));
        emit(PayoutLoaded(
          List.unmodifiable(_cachedAccounts),
          primaryAccount: primaryAccount,
        ));
        return true;
      },
    );
  }
}
