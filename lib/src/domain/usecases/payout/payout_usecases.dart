import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/core/usecases/usecases.dart';
import 'package:provider_app/src/domain/entities/payout/bank_account_entity.dart';
import 'package:provider_app/src/domain/repositories/payout/payout_repository.dart';

class GetBankAccountsUseCase implements UseCase<List<BankAccountEntity>, NoParams> {
  final PayoutRepository _repository;

  GetBankAccountsUseCase(this._repository);

  @override
  Future<Either<Failure, List<BankAccountEntity>>> call(NoParams params) {
    return _repository.getBankAccounts();
  }
}

class AddBankAccountParams {
  final String bankName;
  final String branchName;
  final String accountHolderName;
  final String accountNumber;
  final String? routingNumber;
  final String? swiftCode;
  final bool isDefault;

  const AddBankAccountParams({
    required this.bankName,
    required this.branchName,
    required this.accountHolderName,
    required this.accountNumber,
    this.routingNumber,
    this.swiftCode,
    this.isDefault = false,
  });
}

class AddBankAccountUseCase implements UseCase<BankAccountEntity, AddBankAccountParams> {
  final PayoutRepository _repository;

  AddBankAccountUseCase(this._repository);

  @override
  Future<Either<Failure, BankAccountEntity>> call(AddBankAccountParams params) {
    return _repository.addBankAccount(
      bankName: params.bankName,
      branchName: params.branchName,
      accountHolderName: params.accountHolderName,
      accountNumber: params.accountNumber,
      routingNumber: params.routingNumber,
      swiftCode: params.swiftCode,
      isDefault: params.isDefault,
    );
  }
}

class SetPrimaryBankAccountUseCase implements UseCase<void, String> {
  final PayoutRepository _repository;

  SetPrimaryBankAccountUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String accountId) {
    return _repository.setPrimaryBankAccount(accountId);
  }
}

class DeleteBankAccountUseCase implements UseCase<void, String> {
  final PayoutRepository _repository;

  DeleteBankAccountUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String accountId) {
    return _repository.deleteBankAccount(accountId);
  }
}
