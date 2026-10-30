import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:provider_app/core/errors/auth_exception.dart';
import 'package:provider_app/core/errors/failures.dart';
import 'package:provider_app/core/services/network_service.dart';
import 'package:provider_app/src/data/data_sources/remote/notifications/notification_remote_data_source.dart';
import 'package:provider_app/src/domain/entities/notifications/notification_entity.dart';
import 'package:provider_app/src/domain/repositories/notifications/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkService? networkService;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    this.networkService,
  });

  List<NotificationEntity> _cachedNotifications = [];

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    String? type,
    String? category,
    bool? unreadOnly,
  }) async {
    if (networkService != null && !await networkService!.isConnected()) {
      if (_cachedNotifications.isNotEmpty) {
        return Right(_cachedNotifications);
      }
      return const Left(NetworkFailure(errorMessage: 'No internet connection'));
    }

    try {
      final models = await remoteDataSource.getNotifications(
        type: type,
        category: category,
        unreadOnly: unreadOnly,
      );

      _cachedNotifications = models;
      return Right(_cachedNotifications);
    } on ServerException catch (e) {
      debugPrint('⚠️ [NotificationRepositoryImpl] ServerException: ${e.message}');
      if (_cachedNotifications.isNotEmpty) {
        return Right(_cachedNotifications);
      }
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('⚠️ [NotificationRepositoryImpl] Unexpected error: $e');
      if (_cachedNotifications.isNotEmpty) {
        return Right(_cachedNotifications);
      }
      return Left(ServerFailure(e.toString(), stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int id) async {
    try {
      await remoteDataSource.markAsRead(id);

      _cachedNotifications = _cachedNotifications.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      return Left(ServerFailure(e.toString(), stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();

      _cachedNotifications = _cachedNotifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      return Left(ServerFailure(e.toString(), stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(int id) async {
    try {
      await remoteDataSource.deleteNotification(id);

      _cachedNotifications.removeWhere((n) => n.id == id);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      return Left(ServerFailure(e.toString(), stackTrace));
    }
  }
}
