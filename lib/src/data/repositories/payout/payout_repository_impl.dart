import 'package:dartz/dartz.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/src/data/data_sources/remote/payout/payout_remote_data_source.dart';
import 'package:provider_app/src/domain/entities/payout/bank_account_entity.dart';
import 'package:provider_app/src/domain/repositories/payout/payout_repository.dart';

class PayoutRepositoryImpl implements PayoutRepository {
  final PayoutRemoteDataSource remoteDataSource;

  PayoutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BankAccountEntity>>> getBankAccounts() async {
    try {
      final models = await remoteDataSource.getBankAccounts();
      return Right(models);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BankAccountEntity>> addBankAccount({
    required String bankName,
    required String branchName,
    required String accountHolderName,
    required String accountNumber,
    String? routingNumber,
    String? swiftCode,
    bool isDefault = false,
  }) async {
    try {
      final model = await remoteDataSource.addBankAccount(
        bankName: bankName,
        branchName: branchName,
        accountHolderName: accountHolderName,
        accountNumber: accountNumber,
        routingNumber: routingNumber,
        swiftCode: swiftCode,
        isDefault: isDefault,
      );
      return Right(model);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setPrimaryBankAccount(String accountId) async {
    try {
      await remoteDataSource.setPrimaryBankAccount(accountId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBankAccount(String accountId) async {
    try {
      await remoteDataSource.deleteBankAccount(accountId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
