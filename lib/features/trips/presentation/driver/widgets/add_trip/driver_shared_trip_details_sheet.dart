import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_shared_trip_cubit.dart';
import 'package:car_app/generated/l10n.dart';

/// Bottom sheet dialog for driver shared trip configuration (Date, Time, Gender, Notes, Seats info).
void showDriverSharedTripDetailsSheet(
  BuildContext ctx,
  DriverAddSharedTripCubit cubit, {
  required TextEditingController notesController,
}) {
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

                  // Automatic Vehicle Seats Info
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
                      _DriverGenderChip(
                        label: S.of(context).noPreference,
                        selected: cubit.gender == 'no_preference',
                        onTap: () {
                          cubit.changeGender('no_preference');
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      _DriverGenderChip(
                        label: S.of(context).maleOnly,
                        selected: cubit.gender == 'male' ||
                            cubit.gender == 'male_only',
                        onTap: () {
                          cubit.changeGender('male');
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      _DriverGenderChip(
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
                    controller: notesController,
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

class _DriverGenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DriverGenderChip({
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
