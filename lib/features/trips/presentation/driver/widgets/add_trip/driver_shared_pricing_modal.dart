import 'package:flutter/material.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/chat/presentation/screens/trip_chat_screen.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_shared_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/widgets/new_trips/driver_trip_card_item.dart';
import 'package:car_app/generated/l10n.dart';

/// Shows the post-creation pricing dialog and routes to Trip Chat once confirmed.
void showDriverSharedPricingAndChatModal(
  BuildContext context,
  Trip trip,
  DriverAddSharedTripCubit cubit, {
  required TextEditingController notesController,
}) {
  final minVal = (trip.minimumPrice > 0) ? trip.minimumPrice : 1.0;
  final maxVal = (trip.maximumPrice > 0 && trip.maximumPrice >= minVal)
      ? trip.maximumPrice
      : (minVal * 3);

  double selectedPrice =
      trip.approvedPrice ?? ((minVal + maxVal) / 2);
  if (selectedPrice < minVal) selectedPrice = minVal;
  if (selectedPrice > maxVal) selectedPrice = maxVal;

  final priceController = TextEditingController(
      text: selectedPrice.toStringAsFixed(1));
  bool isSubmitting = false;

  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalCtx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final double parsedMin = minVal;
          final double parsedMax = maxVal;
          final int seatCount =
              cubit.numberOfSeats > 0 ? cubit.numberOfSeats : 4;
          final double perSeatPrice = selectedPrice / seatCount;

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              await confirmCancelDriverSharedTrip(
                context: context,
                cubit: cubit,
                trip: trip,
                modalCtx: modalCtx,
              );
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
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

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
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
                          onPressed: () => confirmCancelDriverSharedTrip(
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
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 14,
                                      color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    trip.tripDatetime.isNotEmpty
                                        ? trip.tripDatetime
                                            .split('T')
                                            .first
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
                        color: AppColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
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
                                  AppColors.primary.withOpacity(0.15),
                              thumbColor: AppColors.primary,
                              overlayColor:
                                  AppColors.primary.withOpacity(0.12),
                              trackHeight: 6,
                            ),
                            child: Slider(
                              value: selectedPrice.clamp(
                                  parsedMin, parsedMax),
                              min: parsedMin,
                              max: parsedMax,
                              divisions: ((parsedMax - parsedMin) * 2)
                                  .round()
                                  .clamp(1, 100),
                              label:
                                  '${selectedPrice.toStringAsFixed(1)} ${S.of(context).jod}',
                              onChanged: (val) {
                                setModalState(() {
                                  selectedPrice = double.parse(
                                      val.toStringAsFixed(1));
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
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
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
                        border:
                            Border.all(color: Colors.blueGrey.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.groups_rounded,
                              color: Colors.blueGrey.shade700, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S
                                      .of(context)
                                      .passengerShareOnComplete(
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
                                    text: S
                                        .of(context)
                                        .offerCannotBeLessThanMin(
                                            '${parsedMin.toStringAsFixed(1)} ${S.of(context).jod}'),
                                    state: ToastStates.ERROR,
                                  );
                                  return;
                                }
                                if (selectedPrice > parsedMax + 0.01) {
                                  showToast(
                                    text: S
                                        .of(context)
                                        .offerCannotExceedMax(
                                            '${parsedMax.toStringAsFixed(1)} ${S.of(context).jod}'),
                                    state: ToastStates.ERROR,
                                  );
                                  return;
                                }

                                setModalState(() => isSubmitting = true);

                                final success =
                                    await cubit.submitTripPrice(
                                  trip: trip,
                                  price: selectedPrice,
                                  note: notesController.text.trim(),
                                );

                                if (!context.mounted) return;
                                setModalState(
                                    () => isSubmitting = false);

                                if (success) {
                                  Navigator.pop(modalCtx);
                                  showToast(
                                    text: S
                                        .of(context)
                                        .priceSetEnteringChat,
                                    state: ToastStates.SUCESS,
                                  );

                                  final storage =
                                      di.sl<LocalStorage>();
                                  String dName = storage
                                          .read(key: 'username')
                                          ?.toString() ??
                                      storage
                                          .read(key: 'name')
                                          ?.toString() ??
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
                                    text: S
                                        .of(context)
                                        .failedToSendPriceOffer,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                      Icons
                                          .chat_bubble_outline_rounded,
                                      color: Colors.white),
                                  const SizedBox(width: 10),
                                  Text(
                                    S
                                        .of(context)
                                        .confirmPriceAndStartWaiting,
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
                            : () => confirmCancelDriverSharedTrip(
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

Future<bool> confirmCancelDriverSharedTrip({
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
