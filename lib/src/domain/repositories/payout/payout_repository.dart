import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/domain/entities/payout/bank_account_entity.dart';

abstract class PayoutRepository {
  Future<Either<Failure, List<BankAccountEntity>>> getBankAccounts();
  Future<Either<Failure, BankAccountEntity>> addBankAccount({
    required String bankName,
    required String branchName,
    required String accountHolderName,
    required String accountNumber,
    String? routingNumber,
    String? swiftCode,
    bool isDefault = false,
  });
  Future<Either<Failure, void>> setPrimaryBankAccount(String accountId);
  Future<Either<Failure, void>> deleteBankAccount(String accountId);
}
