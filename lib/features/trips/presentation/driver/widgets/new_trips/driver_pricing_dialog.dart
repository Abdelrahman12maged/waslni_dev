import 'package:flutter/material.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/generated/l10n.dart';

double _safeDoubleParse(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? defaultValue;
}

/// Driver Pricing & Bidding Dialog with continuous slider and custom value input.
void showDriverPricingDialog(
  BuildContext context, {
  required int tripId,
  required dynamic maxPrice,
  required dynamic minPrice,
  required dynamic tripDetails,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      double parsedMin = _safeDoubleParse(minPrice);
      double parsedMax = _safeDoubleParse(maxPrice);
      if (parsedMin <= 0) parsedMin = 1.0;
      if (parsedMax <= 0 || parsedMax < parsedMin) {
        parsedMax = parsedMin + 10.0;
      }
      double sliderValue = parsedMin;
      int trip_id = tripId;
      var note = null;
      double price = parsedMin;
      var percentage_added = null;
      bool isSubmitting = false;
      final range = parsedMax - parsedMin;
      final divisions = (range / 0.5).clamp(1, 200).toInt();
      final priceController = TextEditingController();

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            elevation: 0.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        const Icon(Icons.local_offer_rounded,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          S.of(context).averagePrice,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Price range info row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${S.of(context).minPriceLabel} ${parsedMin.toStringAsFixed(1)} ${S.of(context).jod}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                        ),
                        Text(
                          '${S.of(context).maxPriceLabel} ${parsedMax.toStringAsFixed(1)} ${S.of(context).jod}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Large price display
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${sliderValue.toStringAsFixed(2)} ${S.of(context).jod}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor:
                            AppColors.primary.withOpacity(0.15),
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withOpacity(0.1),
                        trackHeight: 5,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10),
                        valueIndicatorColor: AppColors.primary,
                        valueIndicatorTextStyle: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      child: Slider(
                        value: sliderValue,
                        min: parsedMin,
                        max: parsedMax,
                        divisions: divisions,
                        label:
                            '${sliderValue.toStringAsFixed(2)} ${S.of(context).jod}',
                        onChanged: (val) {
                          setState(() {
                            sliderValue = val;
                            price = val;
                            priceController.text = val.toStringAsFixed(2);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).orEnterCustomValue,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: priceController,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              hintText: parsedMin.toStringAsFixed(2),
                              hintStyle:
                                  TextStyle(color: Colors.grey.shade400),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                      width: 1, color: AppColors.primary)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                      width: 1, color: AppColors.primary)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                      width: 1.5,
                                      color: AppColors.primary)),
                              suffixText: S.of(context).jod,
                              suffixStyle: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            onChanged: (value) {
                              final val = _safeDoubleParse(value);
                              if (val >= parsedMin && val <= parsedMax) {
                                setState(() {
                                  sliderValue = val;
                                  price = val;
                                });
                              } else {
                                price = val;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(S.of(context).cancel),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  final entered = double.tryParse(
                                          priceController.text.trim()) ??
                                      price;
                                  final effectivePrice =
                                      entered > 0 ? entered : sliderValue;
                                  if (effectivePrice <= 0) {
                                    showToast(
                                        text: S.of(context).pleaseEnterValue,
                                        state: ToastStates.WARNING);
                                    return;
                                  }
                                  if (parsedMax > 0 &&
                                      effectivePrice > parsedMax) {
                                    showToast(
                                        text: S.of(context)
                                            .offerCannotExceedMax(
                                                '$parsedMax ${S.of(context).jod}'),
                                        state: ToastStates.WARNING);
                                    return;
                                  }
                                  if (parsedMin > 0 &&
                                      effectivePrice < parsedMin) {
                                    showToast(
                                        text: S.of(context)
                                            .offerCannotBeLessThanMin(
                                                '$parsedMin ${S.of(context).jod}'),
                                        state: ToastStates.WARNING);
                                    return;
                                  }
                                  setState(() {
                                    isSubmitting = true;
                                  });
                                  final cubit =
                                      DriverTripsCubit.get(context);
                                  Navigator.pop(context);
                                  cubit.createOffer(
                                      context,
                                      trip_id: trip_id,
                                      note: note,
                                      price: effectivePrice,
                                      percentage_added: percentage_added,
                                      trip: tripDetails is Trip
                                          ? tripDetails
                                          : (tripDetails is Map<String, dynamic>
                                              ? Trip.fromMap(tripDetails)
                                              : Trip.fromMap({})));
                                },
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2),
                                )
                              : Text(
                                  S.of(context).send,
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                        ),
                      ],
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
