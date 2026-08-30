import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/settings/domain/entities/saved_location.dart';
import 'package:car_app/features/settings/domain/usecases/get_saved_locations_usecase.dart';
import 'package:car_app/features/settings/domain/usecases/add_saved_location_usecase.dart';
import 'package:car_app/features/settings/domain/usecases/delete_saved_location_usecase.dart';
import 'package:car_app/features/settings/presentation/cubit/saved_locations_state.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SavedLocationsCubit extends Cubit<SavedLocationsState> {
  final GetSavedLocationsUseCase _getSavedLocationsUseCase;
  final AddSavedLocationUseCase _addSavedLocationUseCase;
  final DeleteSavedLocationUseCase _deleteSavedLocationUseCase;
  final LocalStorage _localStorage;

  SavedLocationsCubit({
    required GetSavedLocationsUseCase getSavedLocationsUseCase,
    required AddSavedLocationUseCase addSavedLocationUseCase,
    required DeleteSavedLocationUseCase deleteSavedLocationUseCase,
    required LocalStorage localStorage,
  })  : _getSavedLocationsUseCase = getSavedLocationsUseCase,
        _addSavedLocationUseCase = addSavedLocationUseCase,
        _deleteSavedLocationUseCase = deleteSavedLocationUseCase,
        _localStorage = localStorage,
        super(SavedLocationsInitial());

  static SavedLocationsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  List<SavedLocation> savedLocationsList = [];

  // Saved Location Creation State properties
  bool isBottomSheetShown = false;
  LatLng destLocation = const LatLng(31.963158, 35.930359);
  Set<Marker> userAddLocationMarker = {};
  List<Placemark> userAddLocationplacemarks = [];
  TextEditingController startLocationController = TextEditingController();

  void changeBottomSheetShow() {
    isBottomSheetShown = !isBottomSheetShown;
    emit(SaveLocationSuccess()); // Emit temporary state to refresh UI
  }

  void removeMarkers() {
    userAddLocationMarker.clear();
  }

  Future<void> getAddressFromLatLng() async {
    try {
      userAddLocationplacemarks = await Geocoding().placemarkFromCoordinates(
        destLocation.latitude,
        destLocation.longitude,
      );
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
  }

  Future<void> setStartAndDestinationLocation() async {
    if (userAddLocationplacemarks.isNotEmpty) {
      startLocationController.text =
          '${userAddLocationplacemarks[0].subLocality ?? ''}, ${userAddLocationplacemarks[0].street ?? ''}';
    }
    userAddLocationMarker
        .removeWhere((marker) => marker.markerId.value == "useraddlocation");

    userAddLocationMarker.add(
      Marker(
        markerId: const MarkerId("useraddlocation"),
        position: destLocation,
        icon: BitmapDescriptor.defaultMarker,
      ),
    );

    emit(SaveLocationSuccess());
  }

  Future<void> getSavedLocations() async {
    emit(SavedLocationsLoading());
    final token = _localStorage.read(key: 'usertoken') as String? ?? '';
    final result = await _getSavedLocationsUseCase(token);

    result.fold(
      (failure) => emit(SavedLocationsError(failure.message)),
      (locations) {
        savedLocationsList = locations;
        emit(SavedLocationsSuccess(locations));
      },
    );
  }

  Future<void> userSaveLocation({String? customName}) async {
    emit(SaveLocationLoading());
    final token = _localStorage.read(key: 'usertoken') as String? ?? '';
    final defaultGeocoded = userAddLocationplacemarks.isNotEmpty
        ? '${userAddLocationplacemarks[0].subLocality ?? ''}, ${userAddLocationplacemarks[0].street ?? ''}'.trim()
        : '';
    final locationName = (customName != null && customName.trim().isNotEmpty)
        ? customName.trim()
        : (defaultGeocoded.isNotEmpty ? defaultGeocoded : S.current.savedLocationDefault);

    final result = await _addSavedLocationUseCase(
      name: locationName,
      latitude: destLocation.latitude.toString(),
      longitude: destLocation.longitude.toString(),
      token: token,
    );

    result.fold(
      (failure) => emit(SaveLocationError(failure.message)),
      (_) {
        emit(SaveLocationSuccess());
        emit(SaveLocationSuccessSnackBarState());
      },
    );
  }

  Future<void> deleteSavedLocation(int id) async {
    final token = _localStorage.read(key: 'usertoken') as String? ?? '';
    final result = await _deleteSavedLocationUseCase(id, token);

    result.fold(
      (failure) => emit(SavedLocationsError(failure.message)),
      (_) => getSavedLocations(),
    );
  }
}
