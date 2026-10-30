import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider_app/core/usecases/usecases.dart';
import 'package:provider_app/src/domain/entities/notifications/notification_entity.dart';
import 'package:provider_app/src/domain/usecases/notifications/notification_usecases.dart';
import 'package:provider_app/src/presentation/cubits/notifications/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;
  final DeleteNotificationUseCase deleteNotificationUseCase;

  NotificationCubit({
    required this.getNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
    required this.markAllNotificationsAsReadUseCase,
    required this.deleteNotificationUseCase,
  }) : super(const NotificationInitial());

  List<NotificationEntity> _allNotifications = [];
  String _currentFilter = 'All';

  List<NotificationEntity> get notifications => _allNotifications;
  int get unreadCount => _allNotifications.where((n) => n.isUnread).length;

  Future<void> loadNotifications({
    bool showLoading = true,
    bool refresh = false,
  }) async {
    if (showLoading && state is! NotificationLoaded) {
      emit(const NotificationLoading());
    }

    final result = await getNotificationsUseCase(null);

    result.fold(
      (failure) {
        if (state is! NotificationLoaded || refresh) {
          emit(NotificationError(failure.errorMessage));
        }
      },
      (list) {
        _allNotifications = list;
        _emitFiltered();
      },
    );
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    _emitFiltered();
  }

  void _emitFiltered() {
    List<NotificationEntity> filtered;
    switch (_currentFilter.toLowerCase()) {
      case 'unread':
        filtered = _allNotifications.where((n) => n.isUnread).toList();
        break;
      case 'jobs':
        filtered = _allNotifications.where((n) => n.actionType == 'job').toList();
        break;
      case 'finance':
        filtered =
            _allNotifications.where((n) => n.actionType == 'wallet').toList();
        break;
      case 'all':
      default:
        filtered = List.from(_allNotifications);
        break;
    }

    emit(NotificationLoaded(
      notifications: filtered,
      activeFilter: _currentFilter,
      unreadCount: unreadCount,
    ));
  }

  Future<void> markAsRead(int id) async {
    final index = _allNotifications.indexWhere((n) => n.id == id);
    if (index == -1 || _allNotifications[index].isRead) return;

    // Optimistic local update
    _allNotifications = _allNotifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    _emitFiltered();

    final result = await markNotificationAsReadUseCase(id);
    result.fold(
      (failure) {
        // In case of error, we can reload or keep optimistic state
      },
      (_) {},
    );
  }

  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;

    // Optimistic local update
    _allNotifications =
        _allNotifications.map((n) => n.copyWith(isRead: true)).toList();
    _emitFiltered();

    await markAllNotificationsAsReadUseCase(NoParams());
  }

  Future<void> deleteNotification(int id) async {
    // Optimistic local update
    _allNotifications.removeWhere((n) => n.id == id);
    _emitFiltered();

    await deleteNotificationUseCase(id);
  }
}
