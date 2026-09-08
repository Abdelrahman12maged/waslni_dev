import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_add_private_trip_cubit.dart';
import 'dart:developer';

import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/utils/trip_security_service.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/entities/offer.dart';
import 'package:car_app/features/trips/domain/entities/trip_driver.dart';
import 'package:car_app/features/trips/domain/usecases/change_offer_status_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/change_trip_status_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/create_trip_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_offers_by_trip_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_passenger_trips_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_trip_details_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/change_passenger_status_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/make_offer_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/subscribe_trip_usecase.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/generated/l10n.dart';



import 'package:car_app/core/utils/fcm_notification_service.dart';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/features/trips/domain/usecases/update_trip_price_usecase.dart';
import 'package:car_app/core/utils/chat_channel_helper.dart';
import 'package:car_app/features/chat/data/datasources/chat_remote_datasource.dart';

/// Manages all passenger trip interactions.
class PassengerTripsCubit extends Cubit<PassengerTripsState> {
  final GetPassengerTripsUseCase _getPassengerTrips;
  final GetOffersByTripUseCase _getOffersByTrip;
  final ChangeOfferStatusUseCase _changeOfferStatus;
  final ChangeTripStatusUseCase _changeTripStatus;
  final CreateTripUseCase _createTrip;
  final GetTripDetailsUseCase _getTripDetails;
  final ChangePassengerStatusUseCase _changePassengerStatus;
  final SubscribeTripUseCase _subscribeTrip;
  final MakeOfferUseCase _makeOffer;
  final UpdateTripPriceUseCase _updateTripPrice;
  final LocalStorage _storage;
  final FcmNotificationService _fcmNotificationService;

  PassengerTripsCubit({
    required GetPassengerTripsUseCase getPassengerTrips,
    required GetOffersByTripUseCase getOffersByTrip,
    required ChangeOfferStatusUseCase changeOfferStatus,
    required ChangeTripStatusUseCase changeTripStatus,
    required CreateTripUseCase createTrip,
    required GetTripDetailsUseCase getTripDetails,
    required ChangePassengerStatusUseCase changePassengerStatus,
    required SubscribeTripUseCase subscribeTrip,
    required MakeOfferUseCase makeOffer,
    required UpdateTripPriceUseCase updateTripPrice,
    required LocalStorage storage,
    required FcmNotificationService fcmNotificationService,
  })  : _getPassengerTrips = getPassengerTrips,
        _getOffersByTrip = getOffersByTrip,
        _changeOfferStatus = changeOfferStatus,
        _changeTripStatus = changeTripStatus,
        _createTrip = createTrip,
        _getTripDetails = getTripDetails,
        _changePassengerStatus = changePassengerStatus,
        _subscribeTrip = subscribeTrip,
        _makeOffer = makeOffer,
        _updateTripPrice = updateTripPrice,
        _storage = storage,
        _fcmNotificationService = fcmNotificationService,
        super(const PassengerTripsInitial());

  static PassengerTripsCubit of(BuildContext context) =>
      BlocProvider.of<PassengerTripsCubit>(context);

  static PassengerTripsCubit get(BuildContext context) => of(context);

  // ─── Typed Trip Lists ───────────────────────────────────────────────────
  List<Trip> TripsListByTypeCurrentPrivete = [];
  List<Trip> TripsListByTypeCompletedPrivete = [];
  List<Trip> TripsListByTypeSuspendedPrivete = [];
  List<Trip> TripsListByTypeCanceledPrivete = [];

  List<Trip> TripsListByTypeCurrentShared = [];
  List<Trip> TripsListByTypeCompletedShared = [];
  List<Trip> TripsListByTypeSuspendedShared = [];
  List<Trip> TripsListByTypeCanceledShared = [];

  List<Offer> OfferListUser = [];
  Map AcceptedOffer = {};



  int get _userId =>
      int.tryParse(_storage.read(key: 'userid')?.toString() ?? '') ??
      int.tryParse(_storage.read(key: 'user_id')?.toString() ?? '') ??
      0;

  // ─── Load Trips ───────────────────────────────────────────────────────────
  Future<void> getPassengerTripsByTypes({bool isLoading = true}) => loadPassengerTrips();

  Future<void> loadPassengerTrips() async {
    emit(const PassengerTripsLoading());

    final result = await _getPassengerTrips(_userId);
    result.fold(
      (failure) {
        log(failure.message, name: 'PassengerTripsCubit.loadPassengerTrips');
        emit(PassengerTripsError(failure.message));
      },
      (trips) {
        // Sort newest trips first
        trips.sort((a, b) => b.id.compareTo(a.id));

        TripsListByTypeCurrentPrivete = [];
        TripsListByTypeCompletedPrivete = [];
        TripsListByTypeSuspendedPrivete = [];
        TripsListByTypeCanceledPrivete = [];

        TripsListByTypeCurrentShared = [];
        TripsListByTypeCompletedShared = [];
        TripsListByTypeSuspendedShared = [];
        TripsListByTypeCanceledShared = [];

        for (final trip in trips) {
          final isPrivate = trip.type == TripType.private;

          switch (trip.status) {
            case TripStatus.open:
            case TripStatus.accepted:
              if (trip.isStale) {
                isPrivate
                    ? TripsListByTypeCanceledPrivete.add(trip)
                    : TripsListByTypeCanceledShared.add(trip);
              } else {
                isPrivate
                    ? TripsListByTypeCurrentPrivete.add(trip)
                    : TripsListByTypeCurrentShared.add(trip);
              }
              break;
            case TripStatus.completed:
              isPrivate
                  ? TripsListByTypeCompletedPrivete.add(trip)
                  : TripsListByTypeCompletedShared.add(trip);
              break;
            case TripStatus.suspended:
              isPrivate
                  ? TripsListByTypeSuspendedPrivete.add(trip)
                  : TripsListByTypeSuspendedShared.add(trip);
              break;
            case TripStatus.canceled:
            case TripStatus.closed:
              isPrivate
                  ? TripsListByTypeCanceledPrivete.add(trip)
                  : TripsListByTypeCanceledShared.add(trip);
              break;
          }
        }

        // Sync active ongoing trip with LocalStorage
        Trip? activeOngoingTrip;
        for (final trip in trips) {
          if (trip.status == TripStatus.accepted && !trip.isStale && TripSecurityService.isPreTripTrackingActive(trip)) {
            activeOngoingTrip = trip;
            break;
          }
        }
        if (activeOngoingTrip != null) {
          TripSecurityService.saveActiveTrip(_storage, activeOngoingTrip);
        }

        emit(_categorize(trips));
      },
    );
  }

  /// Categorizes all trips into 8 buckets.
  PassengerTripsLoaded _categorize(List<Trip> trips) {
    final currentPrivate = <Trip>[];
    final completedPrivate = <Trip>[];
    final suspendedPrivate = <Trip>[];
    final canceledPrivate = <Trip>[];

    final currentShared = <Trip>[];
    final completedShared = <Trip>[];
    final suspendedShared = <Trip>[];
    final canceledShared = <Trip>[];

    for (final trip in trips) {
      final isPrivate = trip.type == TripType.private;

      switch (trip.status) {
        case TripStatus.open:
        case TripStatus.accepted:
          isPrivate ? currentPrivate.add(trip) : currentShared.add(trip);
          break;
        case TripStatus.completed:
          isPrivate ? completedPrivate.add(trip) : completedShared.add(trip);
          break;
        case TripStatus.suspended:
          isPrivate ? suspendedPrivate.add(trip) : suspendedShared.add(trip);
          break;
        case TripStatus.canceled:
        case TripStatus.closed:
          isPrivate ? canceledPrivate.add(trip) : canceledShared.add(trip);
          break;
      }
    }

    return PassengerTripsLoaded(
      currentPrivate: currentPrivate,
      completedPrivate: completedPrivate,
      suspendedPrivate: suspendedPrivate,
      canceledPrivate: canceledPrivate,
      currentShared: currentShared,
      completedShared: completedShared,
      suspendedShared: suspendedShared,
      canceledShared: canceledShared,
    );
  }

  // ─── Legacy Compatibility Methods ─────────────────────────────────────────
  void getUserTrips({Function? stoploading, bool isLoading = true}) async {
    await loadPassengerTrips();
    if (stoploading != null) {
      stoploading();
    }
  }

  Future<void> subscribeTripByTripId({
    required int TripId,
    required BuildContext context,
    int seats = 1,
  }) async {
    await subscribeToSharedTrip(TripId, seats: seats);
  }

  Future<void> changeTripStatus({
    dynamic context,
    dynamic id,
    int? tripId,
    dynamic status,
    Map<String, dynamic>? tripDetails,
    dynamic stoploading,
    dynamic PassState,
  }) async {
    final resolvedTripId = tripId ?? int.tryParse(id?.toString() ?? '') ?? 0;
    final statusStr = status?.toString() ?? 'canceled';
    final result =
        await _changeTripStatus(tripId: resolvedTripId, status: statusStr);
    result.fold(
      (failure) => emit(PassengerTripsError(failure.message)),
      (_) {
        emit(const PassengerTripStatusChanged());
        loadPassengerTrips();
        if (stoploading is Function) stoploading();
        if (context is BuildContext) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  Future<void> createOffer(
    BuildContext context, {
    Function? stoploading,
    required int trip_id,
    String? note,
    required double price,
    double? percentage_added,
    required Trip trip,
  }) async {
    final userId =
        int.tryParse(_storage.read(key: 'userid')?.toString() ?? '') ??
        int.tryParse(_storage.read(key: 'user_id')?.toString() ?? '') ?? 0;
    final driverId = userId != 0
        ? userId
        : (trip.driverId ?? trip.driver?.id ?? 0);

    try {
      final result = await _makeOffer(
        offerData: {
          "driver_id": driverId,
          "trip_id": trip_id,
          "note": note ?? '',
          "price": price,
          "percentage": percentage_added ?? 0.0,
        },
      );
      result.fold(
        (failure) {
          showToast(text: failure.message, state: ToastStates.ERROR);
          emit(PassengerTripsError(failure.message));
        },
        (_) {
          if (context.mounted) {
            successDialoug(context, S.of(context).SuccessfullySent);
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) Navigator.pop(context);
            });
          }
        },
      );
    } catch (e) {
      log(e.toString(), name: "PassengerTripsCubit.createOffer");
      showToast(
          text: '${S.current.errorOccurred}: $e', state: ToastStates.ERROR);
    } finally {
      if (stoploading != null) stoploading();
    }
  }

  Future<bool> changeOfferStatus({
    int? offerId,
    dynamic id,
    dynamic status,
    dynamic context,
    dynamic stoploading,
    dynamic PassState,
    dynamic tripId,
  }) async {
    final resolvedOfferId = offerId ?? int.tryParse(id?.toString() ?? '') ?? 0;
    final statusStr = status?.toString() ?? 'pending';
    final result = await _changeOfferStatus(
      offerId: resolvedOfferId,
      status: statusStr,
      userId: _userId,
    );

    return result.fold(
      (failure) {
        emit(PassengerTripsError(failure.message));
        showToast(text: failure.message, state: ToastStates.ERROR);
        return false;
      },
      (_) async {
        if (statusStr == 'accepted' && OfferListUser.isNotEmpty) {
          Offer? acceptedOffer;
          for (final offer in OfferListUser) {
            if (offer.id == resolvedOfferId) {
              acceptedOffer = offer;
            } else if (offer.id != 0) {
              await _changeOfferStatus(
                offerId: offer.id,
                status: 'rejected',
                userId: _userId,
              );
            }
          }

          // final driverToken = acceptedOffer?.driver?.fcmToken ?? '';
          // final passengerName = _storage.read(key: 'username')?.toString() ?? 'الراكب';
          // final tId = int.tryParse(tripId?.toString() ?? '') ?? acceptedOffer?.tripId ?? 0;

          // if (driverToken.isNotEmpty) {
          //   _fcmNotificationService.notifyOfferAccepted(
          //     driverFcmToken: driverToken,
          //     passengerName: passengerName,
          //     tripId: tId,
          //   );
          // }
        }
        emit(const PassengerOfferStatusChanged());
        if (tripId != null) {
          final tId = int.tryParse(tripId.toString()) ?? 0;
          await loadOffers(tId);
        }
        if (stoploading is Function) {
          try {
            stoploading(OfferListUser, null);
          } catch (_) {
            try {
              stoploading(OfferListUser);
            } catch (_) {
              stoploading();
            }
          }
        }
        if (PassState is Function) {
          try {
            PassState(OfferListUser, null);
          } catch (_) {
            try {
              PassState(OfferListUser);
            } catch (_) {
              PassState();
            }
          }
        }
        return true;
      },
    );
  }

  Future<void> getOffersByTripId({
    int? tripId,
    dynamic id,
    dynamic stoploading,
    dynamic isLoading,
    dynamic forceRefresh,
  }) async {
    final resolvedTripId = tripId ?? int.tryParse(id?.toString() ?? '') ?? 0;
    await loadOffers(resolvedTripId);
    if (stoploading is Function) {
      try {
        stoploading(OfferListUser, null);
      } catch (_) {
        try {
          stoploading(OfferListUser);
        } catch (_) {
          stoploading();
        }
      }
    }
  }

  Future<void> changePassengerStatus(BuildContext context,
      {required int tripId,
      required int inCar,
      required Map<String, dynamic> tripDetails,
      String? passState}) async {
    await updatePassengerStatus(tripId, inCar, passState: passState);
  }

  Future<void> updateTripPrice({
    required String tripId,
    required double newPrice,
  }) async {
    try {
      final id = int.tryParse(tripId) ?? 0;
      if (id > 0) {
        await _updateTripPrice(tripId: id, newPrice: newPrice);
      }
    } catch (e) {
      log('updateTripPrice: $e', name: 'PassengerTripsCubit');
    }
  }

  // ─── Offers ─────────────────────────────────────────────────────────────────
  Future<void> loadOffers(int tripId) async {
    if (tripId <= 0) {
      OfferListUser = [];
      emit(const PassengerOffersLoaded([]));
      return;
    }
    final result = await _getOffersByTrip(tripId);
    result.fold(
      (failure) => emit(PassengerTripsError(failure.message)),
      (offers) {
        // The /offers/{id} endpoint does not include the driver object.
        // Enrich each offer with the driver from the locally-cached trip when
        // the offer's own driver field is missing.
        final tripDriver = _driverForTrip(tripId);
        final enriched = offers.map((offer) {
          if (offer.driver != null) return offer;
          if (tripDriver == null) return offer;
          return offer.copyWith(driver: tripDriver);
        }).toList();

        // Store Offer entities directly — no lossy Map conversion.
        OfferListUser = List<Offer>.from(enriched);
        emit(PassengerOffersLoaded(enriched));
      },
    );
  }

  /// Returns the driver attached to any locally-cached trip with [tripId].
  TripDriver? _driverForTrip(int tripId) {
    final allTrips = [
      ...TripsListByTypeCurrentPrivete,
      ...TripsListByTypeCurrentShared,
    ];
    try {
      return allTrips.firstWhere((t) => t.id == tripId).driver;
    } catch (_) {
      return null;
    }
  }


  Future<void> acceptOffer(int offerId, {List<Offer>? remainingOffers}) async {
    final result = await _changeOfferStatus(
      offerId: offerId,
      status: 'accepted',
      userId: _userId,
    );
    result.fold(
      (failure) => emit(PassengerTripsError(failure.message)),
      (_) async {
        // H-02: Auto-reject all other pending offers for this trip
        if (remainingOffers != null && remainingOffers.isNotEmpty) {
          for (final offer in remainingOffers) {
            if (offer.id != offerId && offer.isPending) {
              await _changeOfferStatus(
                offerId: offer.id,
                status: 'rejected',
                userId: _userId,
              );
            }
          }
        }
        emit(const PassengerOfferStatusChanged());
      },
    );
  }

  Future<void> rejectOffer(int offerId) async {
    final result = await _changeOfferStatus(
      offerId: offerId,
      status: 'rejected',
      userId: _userId,
    );
    result.fold(
      (failure) => emit(PassengerTripsError(failure.message)),
      (_) => emit(const PassengerOfferStatusChanged()),
    );
  }

  // ─── Trip Status ──────────────────────────────────────────────────────────
  /// H-11: Prevents passenger from cancelling once trip has started
  Future<void> cancelTrip(int tripId, {String? ongoingStatus}) async {
    if (ongoingStatus == 'start' ||
        ongoingStatus == 'on_the_way' ||
        ongoingStatus == 'close_to_customer' ||
        ongoingStatus == 'arrive_customer') {
      emit(PassengerTripsError(
          S.current.cannotCancelAfterTripStart));
      return;
    }

    final result = await _changeTripStatus(tripId: tripId, status: 'canceled');
    result.fold(
      (failure) => emit(PassengerTripsError(failure.message)),
      (_) {
        emit(const PassengerTripStatusChanged());
        loadPassengerTrips();
      },
    );
  }

  // ─── Create Trip ──────────────────────────────────────────────────────────
  Future<void> createNewTrip(Map<String, dynamic> tripData) async {
    emit(const PassengerTripsLoading());

    final result = await _createTrip(tripData);
    result.fold(
      (failure) => emit(PassengerTripsError(failure.message)),
      (trip) => emit(PassengerTripCreated(trip)),
    );
  }

  // ─── Refresh Trip Details ─────────────────────────────────────────────────
  Future<void> refreshTripDetails(int tripId) async {
    final result = await _getTripDetails(tripId);
    result.fold(
      (failure) => emit(PassengerTripsError(failure.message)),
      (trip) => emit(PassengerTripDetailsLoaded(trip)),
    );
  }

  Future<void> updatePassengerStatus(int tripId, int inCar,
      {String? passState}) async {
    final result = await _changePassengerStatus(
        tripId: tripId, inCar: inCar, passState: passState);
    result.fold(
      (failure) => emit(PassengerTripsError(failure.message)),
      (_) {
        emit(const PassengerTripStatusChanged());
        refreshTripDetails(tripId);
      },
    );
  }

  /// Checks seat availability and subscribes to a shared trip with the requested number of seats
  Future<void> subscribeToSharedTrip(
    int tripId, {
    int seats = 1,
    int? availableSeats,
  }) async {
    if (availableSeats != null && availableSeats <= 0) {
      emit(PassengerTripsError(
          S.current.tripSeatsFullCannotBook));
      return;
    }

    if (availableSeats != null && seats > availableSeats) {
      emit(PassengerTripsError(
          S.current.insufficientAvailableSeats));
      return;
    }

    emit(const PassengerTripsLoading());

    final result = await _subscribeTrip(tripId: tripId, seats: seats);
    result.fold(
      (failure) {
        if (failure.message.toLowerCase().contains('already subscribed') ||
            failure.message.toLowerCase().contains('already joined')) {
          emit(const PassengerTripStatusChanged());
          loadPassengerTrips();
          refreshTripDetails(tripId);
        } else {
          emit(PassengerTripsError(failure.message));
        }
      },
      (_) {
        emit(const PassengerTripStatusChanged());
        loadPassengerTrips();
        refreshTripDetails(tripId);
      },
    );
  }

  Future<bool> cancelAcceptedOfferAndReopen({
    required int tripId,
    int? offerId,
    Trip? trip,
  }) async {
    emit(const PassengerTripsLoading());
    try {
      if (offerId != null && offerId > 0) {
        await _changeOfferStatus(
          offerId: offerId,
          status: 'rejected',
          userId: _userId,
        );
      }
      await _changeTripStatus(tripId: tripId, status: 'open');
      TripSecurityService.clearActiveTrip(_storage);

      // Clean previous driver chat channel
      try {
        final dId = trip?.driverId ?? trip?.driver?.id;
        if (dId != null && dId > 0) {
          final chatId = ChatChannelHelper.privateTripChatId(tripId: tripId, driverId: dId);
          sl<ChatRemoteDataSource>().deleteChat(chatId: chatId);
        }
      } catch (_) {}

      // Reset trip driver and status in memory:
      for (int i = 0; i < TripsListByTypeCurrentPrivete.length; i++) {
        if (TripsListByTypeCurrentPrivete[i].id == tripId) {
          TripsListByTypeCurrentPrivete[i] = TripsListByTypeCurrentPrivete[i].copyWith(
            status: TripStatus.open,
            driver: null,
            driverId: null,
            approvedPrice: null,
            onGoingStatus: null,
          );
        }
      }
      for (int i = 0; i < TripsListByTypeCurrentShared.length; i++) {
        if (TripsListByTypeCurrentShared[i].id == tripId) {
          TripsListByTypeCurrentShared[i] = TripsListByTypeCurrentShared[i].copyWith(
            status: TripStatus.open,
            driver: null,
            driverId: null,
            approvedPrice: null,
            onGoingStatus: null,
          );
        }
      }

      final openTrip = (trip ?? TripsListByTypeCurrentPrivete.cast<Trip?>().firstWhere(
        (t) => t?.id == tripId,
        orElse: () => null,
      ))?.copyWith(
        status: TripStatus.open,
        driver: null,
        driverId: null,
        approvedPrice: null,
        onGoingStatus: null,
      );

      if (openTrip != null) {
        TripSecurityService.savePendingTrip(_storage, openTrip);
      }

      emit(const PassengerOfferStatusChanged());
      await loadOffers(tripId);
      loadPassengerTrips();
      return true;
    } catch (e) {
      emit(PassengerTripsError(e.toString()));
      return false;
    }
  }

  Future<bool> cancelEntireTrip(int tripId, {String? reason}) async {
    emit(const PassengerTripsLoading());
    final result = await _changeTripStatus(
      tripId: tripId,
      status: 'canceled',
      reason: reason,
    );
    return result.fold(
      (failure) {
        emit(PassengerTripsError(failure.message));
        return false;
      },
      (_) {
        TripSecurityService.clearActiveTrip(_storage);
        TripSecurityService.clearPendingTrip(_storage);
        emit(const PassengerTripStatusChanged());
        loadPassengerTrips();
        return true;
      },
    );
  }

  Future<bool> leaveSharedTrip(int tripId) async {
    emit(const PassengerTripsLoading());
    final result = await _changePassengerStatus(
      tripId: tripId,
      inCar: 0,
      passState: 'canceled',
    );
    return result.fold(
      (failure) {
        emit(PassengerTripsError(failure.message));
        showToast(text: failure.message, state: ToastStates.ERROR);
        return false;
      },
      (_) {
        TripSecurityService.clearActiveTrip(_storage);
        TripSecurityService.clearPendingTrip(_storage);
        emit(const PassengerTripStatusChanged());
        loadPassengerTrips();
        return true;
      },
    );
  }

  void userAddPrivateTrip(Map tripDetails, {required BuildContext context}) {
    PassengerAddPrivateTripCubit.get(context).createTrip(context);
  }
}
