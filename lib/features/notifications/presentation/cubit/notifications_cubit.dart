import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/notifications/domain/entities/app_notification.dart';
import 'package:car_app/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:car_app/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final LocalStorage _localStorage;

  NotificationsCubit({
    required GetNotificationsUseCase getNotificationsUseCase,
    required LocalStorage localStorage,
  })  : _getNotificationsUseCase = getNotificationsUseCase,
        _localStorage = localStorage,
        super(NotificationsInitial());

  static NotificationsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  List<AppNotification> notifications = [];

  // Backward compatibility getter
  List get NotificationsList => notifications.map((n) => {
        'id': n.id,
        'title_ar': n.titleAr,
        'title_en': n.titleEn,
        'description_ar': n.descriptionAr,
        'description_en': n.descriptionEn,
        'created_at': n.createdAt,
        'updated_at': n.updatedAt,
      }).toList();

  Future<void> getUsersNotifications({
    dynamic stoploading,
    bool isThisLoading = true,
  }) async {
    if (!isThisLoading) return;
    emit(NotificationsLoading());
    final token = _localStorage.read(key: 'usertoken') as String? ?? '';
    final result = await _getNotificationsUseCase(token);

    result.fold(
      (failure) {
        emit(NotificationsError(failure.message));
        if (stoploading != null) stoploading();
      },
      (list) {
        notifications = list;
        emit(NotificationsSuccess(list));
        if (stoploading != null) stoploading();
      },
    );
  }
}
