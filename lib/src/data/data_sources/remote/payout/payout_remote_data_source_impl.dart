import 'package:dio/dio.dart';
import 'package:provider_app/core/constants/app_endpoints.dart';
import 'package:provider_app/core/errors/auth_exception.dart';
import 'package:provider_app/src/data/data_sources/remote/payout/payout_remote_data_source.dart';
import 'package:provider_app/src/data/models/payout/bank_account_model.dart';

class PayoutRemoteDataSourceImpl implements PayoutRemoteDataSource {
  final Dio dio;

  PayoutRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BankAccountModel>> getBankAccounts() async {
    try {
      final response = await dio.get(AppEndpoints.providerPayoutAccounts);
      final dynamic body = response.data;
      final List<dynamic> list;
      if (body is Map<String, dynamic> && body['data'] is List) {
        list = body['data'] as List<dynamic>;
      } else if (body is List) {
        list = body;
      } else {
        list = [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => BankAccountModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ?? 'Failed to fetch bank accounts',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BankAccountModel> addBankAccount({
    required String bankName,
    required String branchName,
    required String accountHolderName,
    required String accountNumber,
    String? routingNumber,
    String? swiftCode,
    bool isDefault = false,
  }) async {
    try {
      final payload = {
        'bank_name': bankName,
        'branch_name': branchName,
        'account_holder_name': accountHolderName,
        'account_number': accountNumber,
        if (routingNumber != null && routingNumber.isNotEmpty)
          'routing_number': routingNumber,
        if (swiftCode != null && swiftCode.isNotEmpty) 'swift_code': swiftCode,
        'is_default': isDefault,
      };

      final response = await dio.post(
        AppEndpoints.providerPayoutAccounts,
        data: payload,
      );

      final dynamic data = response.data is Map<String, dynamic> &&
              response.data['data'] != null
          ? response.data['data']
          : response.data;

      if (data is Map<String, dynamic>) {
        return BankAccountModel.fromJson(data);
      }

      return BankAccountModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bankName: bankName,
        bankCode: BankAccountModel.deriveBankCode(bankName),
        accountHolderName: accountHolderName,
        accountNumber: accountNumber,
        branchName: branchName,
        branchCode: routingNumber ?? '',
        isPrimary: isDefault,
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ?? 'Failed to add bank account',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> setPrimaryBankAccount(String accountId) async {
    try {
      await dio.put('${AppEndpoints.providerPayoutAccounts}/$accountId/default');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ?? 'Failed to set primary bank account',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteBankAccount(String accountId) async {
    try {
      await dio.delete('${AppEndpoints.providerPayoutAccounts}/$accountId');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message']?.toString() ?? 'Failed to delete bank account',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
