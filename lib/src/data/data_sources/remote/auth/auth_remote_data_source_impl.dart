// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider_app/core/constants/app_endpoints.dart';
// Note: We assume device_name_service.dart exists or will be added.
import 'package:provider_app/core/services/device_name_service.dart';
import 'package:provider_app/src/data/data_sources/remote/auth/auth_remote_data_source.dart';
import 'package:provider_app/src/data/models/auth/auth_result_model.dart';
import 'package:provider_app/src/data/models/auth/user_model.dart';
import 'package:provider_app/src/domain/entities/auth/otp_session_entity.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final Dio _dio;
  final DeviceNameService _deviceNameService;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required Dio dio,
    required DeviceNameService deviceNameService,
  })  : _firebaseAuth = firebaseAuth,
        _dio = dio,
        _deviceNameService = deviceNameService;

  @override
  Future<OtpSessionEntity> sendOtp({
    required String phoneNumber,
    int? forceResendingToken,
  }) async {
    final completer = Completer<OtpSessionEntity>();

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: forceResendingToken,
        verificationCompleted: (credential) async {},
        verificationFailed: (error) {
          if (!completer.isCompleted) {
            completer.completeError(AuthException(_firebaseMessage(error)));
          }
        },
        codeSent: (verificationId, resendToken) {
          if (!completer.isCompleted) {
            completer.complete(
              OtpSessionEntity(
                verificationId: verificationId,
                forceResendingToken: resendToken,
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          if (!completer.isCompleted) {
            completer.complete(
              OtpSessionEntity(
                verificationId: verificationId,
                forceResendingToken: forceResendingToken,
              ),
            );
          }
        },
        timeout: const Duration(seconds: 60),
      );

      return await completer.future;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_firebaseMessage(error));
    } catch (error) {
      if (error is AuthException) rethrow;
      throw const AuthException(
        'Unable to send the verification code. Please try again.',
      );
    }
  }

  @override
  Future<String> verifyOtpAndGetFirebaseIdToken({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) {
        throw const AuthException('Firebase did not return a signed-in user.');
      }

      final idToken = await user.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw const AuthException('Unable to obtain the Firebase ID token.');
      }

      return idToken;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_firebaseMessage(error));
    }
  }

  @override
  Future<String> getCurrentFirebaseIdToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException('No Firebase user is currently signed in.');
    }

    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw const AuthException('Unable to obtain the Firebase ID token.');
    }

    return idToken;
  }

  @override
  Future<AuthResultModel> registerWithFirebase({
    required String firebaseIdToken,
  }) async {
    try {
      final response = await _dio.post(
        AppEndpoints.providerRegister,
        data: {
          'firebase_token': firebaseIdToken,
          'device_name': await _deviceNameService.getDeviceName(),
        },
      );
      return AuthResultModel.fromJson(_unwrapPayload(response.data));
    } on DioException catch (error) {
      throw AuthException(_dioMessage(error));
    }
  }

  @override
  Future<AuthResultModel> loginWithFirebase({
    required String firebaseIdToken,
  }) async {
    try {
      final response = await _dio.post(
        AppEndpoints.providerLogin,
        data: {
          'firebase_token': firebaseIdToken,
          'device_name': await _deviceNameService.getDeviceName(),
        },
      );
      return AuthResultModel.fromJson(_unwrapPayload(response.data));
    } on DioException catch (error) {
      throw AuthException(_dioMessage(error));
    }
  }

  @override
  Future<UserModel> completeProfile({
    required String bearerToken,
    required String providerType,
    required String firstName,
    required String lastName,
    required String email,
    String? regNumber,
    String? taxId,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    String? nicFrontPath,
    String? nicBackPath,
    String? brCertificatePath,
    required List<String> services,
    String? profileImagePath,
  }) async {
    try {
      final fields = <String, dynamic>{
        'provider_type': providerType,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'address_line1': addressLine1,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
      };
      
      if (addressLine2 != null) fields['address_line2'] = addressLine2;
      if (regNumber != null) fields['reg_number'] = regNumber;
      if (taxId != null) fields['tax_id'] = taxId;
      
      for (int i = 0; i < services.length; i++) {
        fields['services[$i]'] = services[i];
      }

      if (profileImagePath != null && profileImagePath.trim().isNotEmpty) {
        fields['profile_image'] = await MultipartFile.fromFile(
          profileImagePath,
          filename: profileImagePath.split(RegExp(r'[/\\]')).last,
        );
      }
      
      if (nicFrontPath != null && nicFrontPath.trim().isNotEmpty) {
        fields['nic_front'] = await MultipartFile.fromFile(
          nicFrontPath,
          filename: nicFrontPath.split(RegExp(r'[/\\]')).last,
        );
      }
      
      if (nicBackPath != null && nicBackPath.trim().isNotEmpty) {
        fields['nic_back'] = await MultipartFile.fromFile(
          nicBackPath,
          filename: nicBackPath.split(RegExp(r'[/\\]')).last,
        );
      }
      
      if (brCertificatePath != null && brCertificatePath.trim().isNotEmpty) {
        fields['br_certificate'] = await MultipartFile.fromFile(
          brCertificatePath,
          filename: brCertificatePath.split(RegExp(r'[/\\]')).last,
        );
      }

      final response = await _dio.put(
        AppEndpoints.providerCompleteProfile,
        data: FormData.fromMap(fields),
        options: Options(
          headers: {
            'Authorization': 'Bearer $bearerToken',
            'Accept': 'application/json',
          },
          contentType: 'multipart/form-data',
        ),
      );

      final payload = _unwrapPayload(response.data);
      final userJson = payload['provider'] is Map
          ? Map<String, dynamic>.from(payload['provider'] as Map)
          : payload;
      return UserModel.fromJson(userJson);
    } on DioException catch (error) {
      throw AuthException(_dioMessage(error));
    }
  }

  @override
  Future<void> signOutFirebase() {
    return _firebaseAuth.signOut();
  }

  Map<String, dynamic> _unwrapPayload(dynamic raw) {
    if (raw is! Map) {
      throw const AuthException('The server returned an invalid response.');
    }

    final map = Map<String, dynamic>.from(raw);
    final nested = map['data'];
    if (nested is Map) {
      return Map<String, dynamic>.from(nested);
    }
    return map;
  }

  String _dioMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final message = map['message']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;

      final errors = map['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
          if (value != null) return value.toString();
        }
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'The server took too long to respond. Please try again.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to connect to the server. Check your internet connection.';
    }

    return 'Authentication request failed. Please try again.';
  }

  String _firebaseMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-phone-number':
        return 'Enter a valid mobile number.';
      case 'too-many-requests':
        return 'Too many verification attempts. Please try again later.';
      case 'quota-exceeded':
        return 'SMS verification quota has been exceeded.';
      case 'invalid-verification-code':
        return 'The verification code is incorrect.';
      case 'session-expired':
        return 'The verification code has expired. Request a new code.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return error.message ?? 'Firebase authentication failed.';
    }
  }
}
