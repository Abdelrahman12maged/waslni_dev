import 'dart:async';
import 'dart:developer';

import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/location_helper.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/chat/presentation/screens/trip_chat_screen.dart';
import 'package:car_app/features/map/domain/entities/location_result.dart';
import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:car_app/features/map/presentation/style/app_map_style.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_shared_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_shared_trip_state.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver Add Shared Trip Screen
// ─────────────────────────────────────────────────────────────────────────────
class AddNewSharedTripDriver extends StatelessWidget {
  const AddNewSharedTripDriver({super.key});

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.963158, 35.930359),
    zoom: 15,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DriverAddSharedTripCubit>(
      create: (context) => di.sl<DriverAddSharedTripCubit>(),
      child: const _AddNewSharedTripDriverContent(),
    );
  }
}

class _AddNewSharedTripDriverContent extends StatefulWidget {
  const _AddNewSharedTripDriverContent();

  @override
  State<_AddNewSharedTripDriverContent> createState() =>
      _AddNewSharedTripDriverContentState();
}

class _AddNewSharedTripDriverContentState
    extends State<_AddNewSharedTripDriverContent>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool _isLoadingLocation = false;
  LatLng? _driverLocation;

  late AnimationController _pinController;
  late Animation<double> _pinOffset;

  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _pinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pinOffset = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _pinController, curve: Curves.easeInOut),
    );
    _pinController.repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cubit = DriverAddSharedTripCubit.get(context);
        cubit.removeMarkers();
        cubit.chooseTripDateTime(DateTime.now());
        _getCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _mapController?.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation || !mounted) return;
    setState(() => _isLoadingLocation = true);
    try {
      final cubit = DriverAddSharedTripCubit.get(context);
      final latLng = await cubit.getCurrentLocation();
      if (latLng != null && mounted) {
        setState(() => _driverLocation = latLng);
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 15),
          ),
        );
      }
    } catch (e) {
      log(e.toString(), name: 'DriverGetLocationShared');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _handleSearch() async {
    if (!mounted) return;
    final cubit = DriverAddSharedTripCubit.get(context);
    final selectedResult = await showSearch<LocationResult?>(
      context: context,
      delegate: _LocationSearchDelegate(cubit: cubit),
    );

    if (selectedResult != null && mounted) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(selectedResult.latitude, selectedResult.longitude),
            zoom: 16,
          ),
        ),
      );
    }
  }

  void _showDriverSharedTripDetailsSheet(
      BuildContext ctx, DriverAddSharedTripCubit cubit) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final dateStr =
                DateFormat('yyyy-MM-dd').format(cubit.selectedDateTime);
            final timeStr =
                DateFormat('hh:mm a').format(cubit.selectedDateTime);

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Icon(Icons.groups_outlined,
                            color: AppColors.primary, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          S.of(context).userlayouthomesharedtrip,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date & Time Selectors
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: cubit.selectedDateTime,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 90)),
                              );
                              if (pickedDate != null) {
                                final newDt = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  cubit.selectedDateTime.hour,
                                  cubit.selectedDateTime.minute,
                                );
                                cubit.chooseTripDateTime(newDt);
                                setSheetState(() {});
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(dateStr,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                    cubit.selectedDateTime),
                              );
                              if (pickedTime != null) {
                                final newDt = DateTime(
                                  cubit.selectedDateTime.year,
                                  cubit.selectedDateTime.month,
                                  cubit.selectedDateTime.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                cubit.chooseTripDateTime(newDt);
                                setSheetState(() {});
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(timeStr,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Automatic Vehicle Seats Info (No manual seat picker for driver)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.airline_seat_recline_extra_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${S.of(context).numberOfSeats}: ${cubit.numberOfSeats} ${S.of(context).seats}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  S.of(context).calculatedBasedOnCapacity,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Gender Preference
                    Text(
                      S.of(context).genderPreference,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _GenderChip(
                          label: S.of(context).noPreference,
                          selected: cubit.gender == 'no_preference',
                          onTap: () {
                            cubit.changeGender('no_preference');
                            setSheetState(() {});
                          },
                        ),
                        const SizedBox(width: 8),
                        _GenderChip(
                          label: S.of(context).maleOnly,
                          selected: cubit.gender == 'male' ||
                              cubit.gender == 'male_only',
                          onTap: () {
                            cubit.changeGender('male');
                            setSheetState(() {});
                          },
                        ),
                        const SizedBox(width: 8),
                        _GenderChip(
                          label: S.of(context).femaleOnly,
                          selected: cubit.gender == 'female' ||
                              cubit.gender == 'female_only',
                          onTap: () {
                            cubit.changeGender('female');
                            setSheetState(() {});
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Notes Input
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: S.of(context).notes,
                        prefixIcon: const Icon(Icons.note_alt_outlined,
                            color: AppColors.primary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          cubit.createTrip(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          S.of(context).addNewTrip,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDriverPricingAndChatModal(
      BuildContext context, Trip trip, DriverAddSharedTripCubit cubit) {
    final double parsedMin = trip.minimumPrice > 0 ? trip.minimumPrice : 1.0;
    double parsedMax =
        trip.maximumPrice > parsedMin ? trip.maximumPrice : (parsedMin + 10.0);
    if (parsedMax <= parsedMin) {
      parsedMax = parsedMin + 5.0;
    }

    final priceController =
        TextEditingController(text: parsedMin.toStringAsFixed(0));
    double selectedPrice = parsedMin;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double perSeatPrice = cubit.numberOfSeats > 0
                ? (selectedPrice / cubit.numberOfSeats)
                : selectedPrice;

            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
                await _confirmCancelSharedTrip(
                  context: context,
                  cubit: cubit,
                  trip: trip,
                  modalCtx: modalCtx,
                );
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: EdgeInsets.fromLTRB(
                  22,
                  16,
                  22,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Success & Title Banner with Close Button
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle_rounded,
                                color: Colors.green, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(context).tripCreatedSuccess,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  S.of(context).setTotalTripPriceNotice,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.grey, size: 24),
                            onPressed: () => _confirmCancelSharedTrip(
                              context: context,
                              cubit: cubit,
                              trip: trip,
                              modalCtx: modalCtx,
                            ),
                            tooltip: S.of(context).cancelTrip,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Route Summary Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.trip_origin,
                                    color: AppColors.primary, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    cleanLocationName(trip.fromLocationName),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 7),
                              child: Row(
                                children: [
                                  Container(
                                      width: 2,
                                      height: 14,
                                      color: Colors.grey.shade300),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    color: Colors.redAccent, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    cleanLocationName(trip.toLocationName),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      trip.tripDatetime.isNotEmpty
                                          ? trip.tripDatetime.split('T').first
                                          : '',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                        Icons.airline_seat_recline_normal,
                                        size: 14,
                                        color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      S
                                          .of(context)
                                          .capacitySeats(cubit.numberOfSeats),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Price Boundaries Info
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(context).minimumPriceLabel,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${parsedMin.toStringAsFixed(1)} ${S.of(context).jod}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                                width: 1,
                                height: 28,
                                color: Colors.grey.shade300),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  S.of(context).suggestedPriceLabel,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${((parsedMin + parsedMax) / 2).toStringAsFixed(1)} ${S.of(context).jod}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                                width: 1,
                                height: 28,
                                color: Colors.grey.shade300),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  S.of(context).maximumPriceLabel,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${parsedMax.toStringAsFixed(1)} ${S.of(context).jod}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Interactive Pricing Slider & Input
                      Text(
                        S.of(context).setTotalRequiredPrice,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.primary,
                                inactiveTrackColor:
                                    AppColors.primary.withValues(alpha: 0.15),
                                thumbColor: AppColors.primary,
                                overlayColor:
                                    AppColors.primary.withValues(alpha: 0.12),
                                trackHeight: 6,
                              ),
                              child: Slider(
                                value:
                                    selectedPrice.clamp(parsedMin, parsedMax),
                                min: parsedMin,
                                max: parsedMax,
                                divisions: ((parsedMax - parsedMin) * 2)
                                    .round()
                                    .clamp(1, 100),
                                label:
                                    '${selectedPrice.toStringAsFixed(1)} ${S.of(context).jod}',
                                onChanged: (val) {
                                  setModalState(() {
                                    selectedPrice =
                                        double.parse(val.toStringAsFixed(1));
                                    priceController.text =
                                        selectedPrice.toStringAsFixed(1);
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 85,
                            height: 44,
                            child: TextField(
                              controller: priceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                suffixText: S.of(context).jod,
                                suffixStyle: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.primary, width: 1.5),
                                ),
                              ),
                              onChanged: (val) {
                                final entered = double.tryParse(val);
                                if (entered != null) {
                                  setModalState(() {
                                    selectedPrice = entered;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Per-Seat Dynamic Split Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueGrey.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.groups_rounded,
                                color: Colors.blueGrey.shade700, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).passengerShareOnComplete(
                                        cubit.numberOfSeats),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blueGrey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    S.of(context).perSeatPriceLabel(
                                        '${perSeatPrice.toStringAsFixed(2)} ${S.of(context).jod}'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.blueGrey.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Explanatory Note
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 15, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              S.of(context).splitFareExplanation,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Confirm & Enter Chat Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (selectedPrice < parsedMin - 0.01) {
                                    showToast(
                                      text: S.of(context).offerCannotBeLessThanMin(
                                          '${parsedMin.toStringAsFixed(1)} ${S.of(context).jod}'),
                                      state: ToastStates.ERROR,
                                    );
                                    return;
                                  }
                                  if (selectedPrice > parsedMax + 0.01) {
                                    showToast(
                                      text: S.of(context).offerCannotExceedMax(
                                          '${parsedMax.toStringAsFixed(1)} ${S.of(context).jod}'),
                                      state: ToastStates.ERROR,
                                    );
                                    return;
                                  }

                                  setModalState(() => isSubmitting = true);

                                  final success = await cubit.submitTripPrice(
                                    trip: trip,
                                    price: selectedPrice,
                                    note: _notesController.text.trim(),
                                  );

                                  if (!context.mounted) return;
                                  setModalState(() => isSubmitting = false);

                                  if (success) {
                                    Navigator.pop(modalCtx);
                                    showToast(
                                      text: S.of(context).priceSetEnteringChat,
                                      state: ToastStates.SUCESS,
                                    );

                                    // Extract Driver info from storage or trip
                                    final storage = di.sl<LocalStorage>();
                                    String dName = storage
                                            .read(key: 'username')
                                            ?.toString() ??
                                        storage.read(key: 'name')?.toString() ??
                                        '';
                                    String dPhone = storage
                                            .read(key: 'phone')
                                            ?.toString() ??
                                        storage
                                            .read(key: 'mobile')
                                            ?.toString() ??
                                        '';
                                    if (dName.isEmpty &&
                                        trip.driver != null &&
                                        trip.driver!.name.isNotEmpty) {
                                      dName = trip.driver!.name;
                                    }
                                    if (dPhone.isEmpty &&
                                        trip.driver != null &&
                                        trip.driver!.phone != null &&
                                        trip.driver!.phone!.isNotEmpty) {
                                      dPhone = trip.driver!.phone!;
                                    }

                                    // Enter Trip Chat Screen directly to wait for joining passengers
                                    navigateToReplacement(
                                      context,
                                      TripChatScreenClean(
                                        driverName: dName.isNotEmpty
                                            ? dName
                                            : S.of(context).driver,
                                        driverPhone: dPhone,
                                        tripFrom: cleanLocationName(
                                            trip.fromLocationName),
                                        tripTo: cleanLocationName(
                                            trip.toLocationName),
                                        tripDatetime: trip.tripDatetime,
                                        acceptedPrice: selectedPrice,
                                        tripId: trip.id,
                                        offerId: 0,
                                        tripType: 'shared',
                                        members: [
                                          if (trip.driver != null)
                                            trip.driver!.toMap(),
                                          if (trip.creator != null)
                                            trip.creator!.toMap(),
                                        ],
                                      ),
                                    );
                                  } else {
                                    showToast(
                                      text:
                                          S.of(context).failedToSendPriceOffer,
                                      state: ToastStates.ERROR,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        color: Colors.white),
                                    const SizedBox(width: 10),
                                    Text(
                                      S.of(context).confirmPriceAndStartWaiting,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Cancel Trip Option Button
                      Center(
                        child: TextButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () => _confirmCancelSharedTrip(
                                    context: context,
                                    cubit: cubit,
                                    trip: trip,
                                    modalCtx: modalCtx,
                                  ),
                          icon: Icon(Icons.cancel_outlined,
                              size: 18, color: Colors.red.shade400),
                          label: Text(
                            S.of(context).confirmCancelTrip,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _confirmCancelSharedTrip({
    required BuildContext context,
    required DriverAddSharedTripCubit cubit,
    required Trip trip,
    required BuildContext modalCtx,
  }) async {
    final bool? shouldCancel = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Text(
              S.of(context).cancelPendingTrip,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          S.of(context).cancelPendingTripConfirm,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: Text(
              S.of(context).stayToSetPrice,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              S.of(context).yesCancel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (shouldCancel == true) {
      Navigator.pop(modalCtx);
      showToast(
          text: S.of(context).orderCanceledSuccessfully,
          state: ToastStates.WARNING);
      await cubit.cancelTrip(trip.id);
      if (context.mounted) {
        showToast(
            text: S.of(context).tripCancelledSuccessfully,
            state: ToastStates.SUCESS);
        Navigator.of(context).pop();
      }
      return true;
    }
    return false;
  }

  int _step(DriverAddSharedTripCubit c) {
    if (c.startLatLng == null) return 0;
    if (c.destinationLatLng == null) return 1;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverAddSharedTripCubit, DriverAddSharedTripState>(
      listener: (ctx, state) {
        if (state is DriverAddSharedTripErrorState) {
          showToast(text: state.error, state: ToastStates.ERROR);
        } else if (state is DriverAddSharedTripSuccessState) {
          final cubit = DriverAddSharedTripCubit.get(ctx);
          final trip = state.trip;
          _showDriverPricingAndChatModal(ctx, trip, cubit);
        }
      },
      builder: (ctx, state) {
        final cubit = DriverAddSharedTripCubit.get(ctx);
        final step = _step(cubit);
        final stepColor =
            step == 0 ? AppColors.primary : const Color(0xFF1B5E20);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _CircleButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(ctx),
              ),
            ),
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1), blurRadius: 12),
                ],
              ),
              child: Text(
                S.of(context).userlayouthomesharedtrip,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              GoogleMap(
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition: AddNewSharedTripDriver._kGooglePlex,
                onMapCreated: (c) {
                  _mapController = c;
                  AppMapStyle.applyStyle(c);
                  if (_driverLocation != null) {
                    _mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: _driverLocation!, zoom: 15),
                      ),
                    );
                  }
                },
                onCameraMove: (pos) => cubit.destLocation = pos.target,
                onCameraIdle: () => cubit.getAddressFromLatLng(),
                markers: cubit.userMarkers,
              ),

              // Animated Pin
              Center(
                child: AnimatedBuilder(
                  animation: _pinOffset,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _pinOffset.value - 28),
                    child: child,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: stepColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: stepColor.withOpacity(0.45),
                              blurRadius: 16,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Icon(
                          step == 0 ? Icons.my_location : Icons.flag_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      Container(width: 2, height: 18, color: stepColor),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: stepColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top Instruction Card
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 66, 16, 0),
                  child: _DriverInstructionCard(cubit: cubit, step: step),
                ),
              ),

              // Right Fab Buttons
              Positioned(
                right: 14,
                top: MediaQuery.of(context).size.height * 0.38,
                child: Column(
                  children: [
                    _CircleButton(icon: Icons.search, onTap: _handleSearch),
                    const SizedBox(height: 10),
                    _CircleButton(
                      icon: Icons.my_location,
                      onTap: _getCurrentLocation,
                      isLoading: _isLoadingLocation,
                    ),
                  ],
                ),
              ),

              // Bottom Panel
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _DriverBottomPanel(
                  cubit: cubit,
                  step: step,
                  onConfirm: () => cubit.setStartAndDestinationLocation(),
                  onDetails: () =>
                      _showDriverSharedTripDetailsSheet(ctx, cubit),
                  onEditStart: () {
                    if (cubit.startLatLng != null) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(cubit.startLatLng!),
                      );
                    }
                    cubit.editStartLocation();
                  },
                  onEditDestination: () {
                    if (cubit.destinationLatLng != null) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(cubit.destinationLatLng!),
                      );
                    }
                    cubit.editDestinationLocation();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gender Chip
// ─────────────────────────────────────────────────────────────────────────────
class _GenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Instruction Card
// ─────────────────────────────────────────────────────────────────────────────
class _DriverInstructionCard extends StatelessWidget {
  final DriverAddSharedTripCubit cubit;
  final int step;

  const _DriverInstructionCard({required this.cubit, required this.step});

  @override
  Widget build(BuildContext context) {
    final labels = [
      S.of(context).pickupPoint,
      S.of(context).destinationPoint,
      S.of(context).pickupSelected
    ];
    final subs = [
      S.of(context).moveMapAndConfirm,
      S.of(context).moveMapAndSelectDestination,
      S.of(context).tapTripDetailsToContinue
    ];
    const icons = [
      Icons.trip_origin,
      Icons.flag_rounded,
      Icons.check_circle_outline
    ];
    final colors = [
      AppColors.primary,
      const Color(0xFF1B5E20),
      Colors.orange.shade800
    ];

    final s = step.clamp(0, 2);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(3, (i) {
              final active = i == s;
              final done = i < s;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 6,
                        decoration: BoxDecoration(
                          color: done
                              ? const Color(0xFF1B5E20)
                              : active
                                  ? colors[s]
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    if (i < 2) const SizedBox(width: 4),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors[s].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icons[s], color: colors[s], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labels[s],
                      style: TextStyle(
                        color: colors[s],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subs[s],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Panel
// ─────────────────────────────────────────────────────────────────────────────
class _DriverBottomPanel extends StatelessWidget {
  final DriverAddSharedTripCubit cubit;
  final int step;
  final VoidCallback onConfirm;
  final VoidCallback onDetails;
  final VoidCallback onEditStart;
  final VoidCallback onEditDestination;

  const _DriverBottomPanel({
    required this.cubit,
    required this.step,
    required this.onConfirm,
    required this.onDetails,
    required this.onEditStart,
    required this.onEditDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cubit.startLatLng != null) ...[
            _RouteRow(
              icon: Icons.trip_origin,
              color: AppColors.primary,
              text: cubit.startLocationController.text.isNotEmpty
                  ? cubit.startLocationController.text
                  : S.of(context).pickupSelected,
              onEdit: onEditStart,
            ),
            if (cubit.destinationLatLng != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 9),
                child: Column(
                  children: List.generate(
                    3,
                    (_) => Container(
                      width: 2,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 1.5),
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              _RouteRow(
                icon: Icons.flag_rounded,
                color: const Color(0xFF1B5E20),
                text: cubit.destinationLocationController.text.isNotEmpty
                    ? cubit.destinationLocationController.text
                    : S.of(context).destinationSelected,
                onEdit: onEditDestination,
              ),
            ],
            const SizedBox(height: 14),
          ],
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: step < 2
                ? SizedBox(
                    key: ValueKey('step_$step'),
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: cubit.currentLocationResult == null
                          ? null
                          : onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: step == 0
                            ? AppColors.primary
                            : const Color(0xFF1B5E20),
                        disabledBackgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: Icon(
                        step == 0 ? Icons.trip_origin : Icons.flag_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        step == 0
                            ? S.of(context).confirmPickupLocation
                            : S.of(context).confirmDestinationLocation,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    key: const ValueKey('details'),
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: onDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.arrow_upward_rounded,
                          color: Color(0xFF1A237E), size: 20),
                      label: Text(
                        S.of(context).tripDetails,
                        style: const TextStyle(
                          color: Color(0xFF1A237E),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback? onEdit;

  const _RouteRow({
    required this.icon,
    required this.color,
    required this.text,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: Colors.grey.shade600,
            onPressed: onEdit,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.15),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isLoading ? null : onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(icon, color: AppColors.primary, size: 20),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Location Search Delegate
// ─────────────────────────────────────────────────────────────────────────────
class _LocationSearchDelegate extends SearchDelegate<LocationResult?> {
  final DriverAddSharedTripCubit cubit;

  _LocationSearchDelegate({required this.cubit});

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSuggestions(context);

  Widget _buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return Center(
        child: Text(
          S.of(context).searchLocationHint,
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return FutureBuilder<List<PlaceSuggestion>>(
      future: cubit.searchPlaces(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final suggestions = snapshot.data ?? [];
        if (suggestions.isEmpty) {
          return Center(
            child: Text(
              S.of(context).noLocationFound,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }

        return ListView.separated(
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF5F5F5),
                child: Icon(Icons.location_on, color: AppColors.primary),
              ),
              title: Text(
                suggestion.mainText,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: suggestion.secondaryText.isNotEmpty
                  ? Text(
                      suggestion.secondaryText,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    )
                  : null,
              onTap: () async {
                final details = await cubit.getPlaceDetails(suggestion.placeId);
                if (context.mounted) {
                  close(context, details);
                }
              },
            );
          },
        );
      },
    );
  }
}
