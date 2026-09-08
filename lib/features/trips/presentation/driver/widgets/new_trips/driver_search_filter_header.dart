import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/generated/l10n.dart';

/// Search and filter header for driver new trips (Radius & Date selection).
class DriverSearchFilterHeader extends StatelessWidget {
  final DriverTripsCubit cubit;

  const DriverSearchFilterHeader({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final selectedDate = cubit.selectedDate;
    final radius = cubit.selectedRadius;

    String dateLabel = S.of(context).allDates;
    if (selectedDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final target =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

      if (target == today) {
        dateLabel = S.of(context).todayTrips;
      } else if (target == tomorrow) {
        dateLabel = S.of(context).tomorrowTrips;
      } else {
        dateLabel = DateFormat('yyyy/MM/dd', 'ar').format(selectedDate);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Radius Button
              Expanded(
                child: InkWell(
                  onTap: () => _showRadiusFilterModal(context, cubit),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.radar_rounded,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            S.of(context).radiusKm(radius.toInt()),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.tune_rounded,
                            size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Date Picker Button
              Expanded(
                child: InkWell(
                  onTap: () => _openCustomCalendarPicker(context, cubit),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedDate != null
                          ? Colors.amber.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedDate != null
                            ? Colors.amber.shade700
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                          color: selectedDate != null
                              ? Colors.amber.shade900
                              : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dateLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: selectedDate != null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: selectedDate != null
                                  ? Colors.amber.shade900
                                  : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (selectedDate != null)
                          InkWell(
                            onTap: () =>
                                cubit.updateSearchFilters(clearDate: true),
                            child: const Icon(Icons.close_rounded,
                                size: 16, color: Colors.red),
                          )
                        else
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Quick Date Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickDateChip(
                  context,
                  title: S.of(context).all,
                  isSelected: selectedDate == null,
                  onTap: () => cubit.updateSearchFilters(clearDate: true),
                ),
                const SizedBox(width: 6),
                _buildQuickDateChip(
                  context,
                  title: S.of(context).todayTrips,
                  isSelected: selectedDate != null &&
                      DateTime(selectedDate.year, selectedDate.month,
                              selectedDate.day) ==
                          DateTime(DateTime.now().year, DateTime.now().month,
                              DateTime.now().day),
                  onTap: () {
                    final now = DateTime.now();
                    cubit.updateSearchFilters(
                        date: DateTime(now.year, now.month, now.day));
                  },
                ),
                const SizedBox(width: 6),
                _buildQuickDateChip(
                  context,
                  title: S.of(context).tomorrowTrips,
                  isSelected: selectedDate != null &&
                      DateTime(selectedDate.year, selectedDate.month,
                              selectedDate.day) ==
                          DateTime(DateTime.now().year, DateTime.now().month,
                              DateTime.now().day + 1),
                  onTap: () {
                    final now = DateTime.now();
                    cubit.updateSearchFilters(
                        date: DateTime(now.year, now.month, now.day + 1));
                  },
                ),
                const SizedBox(width: 6),
                _buildQuickDateChip(
                  context,
                  title: S.of(context).specificDate,
                  isSelected: selectedDate != null &&
                      DateTime(selectedDate.year, selectedDate.month,
                              selectedDate.day) !=
                          DateTime(DateTime.now().year, DateTime.now().month,
                              DateTime.now().day) &&
                      DateTime(selectedDate.year, selectedDate.month,
                              selectedDate.day) !=
                          DateTime(DateTime.now().year, DateTime.now().month,
                              DateTime.now().day + 1),
                  onTap: () => _openCustomCalendarPicker(context, cubit),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDateChip(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  void _showRadiusFilterModal(BuildContext context, DriverTripsCubit cubit) {
    double currentRadius = cubit.selectedRadius;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 20.0,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S.of(context).searchRadiusTitle,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.of(context).searchRadiusDesc(currentRadius.toInt()),
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        S.of(context).kmUnit(currentRadius.toInt()),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Slider(
                      value: currentRadius,
                      min: 5.0,
                      max: 200.0,
                      divisions: 39,
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.grey.shade300,
                      label: S.of(context).kmUnit(currentRadius.toInt()),
                      onChanged: (val) {
                        setState(() {
                          currentRadius = val;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    // Preset radius chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [10, 25, 50, 75, 100, 150].map((r) {
                        final isSel = currentRadius.toInt() == r;
                        return ChoiceChip(
                          label: Text(S.of(context).kmUnit(r)),
                          selected: isSel,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : Colors.black87,
                            fontWeight:
                                isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                currentRadius = r.toDouble();
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          cubit.updateSearchFilters(radius: currentRadius);
                        },
                        child: Text(
                          S.of(context).applySearchRadius,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
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

  Future<void> _openCustomCalendarPicker(
      BuildContext context, DriverTripsCubit cubit) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: cubit.selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      cubit.updateSearchFilters(date: picked);
    }
  }
}
