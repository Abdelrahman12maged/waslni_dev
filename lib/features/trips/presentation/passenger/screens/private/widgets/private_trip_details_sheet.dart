import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_add_private_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_add_private_trip_state.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Trip Details Bottom Sheet (Cleaned: No Notes, No Proposed Fare, No Auto Accept)
// ─────────────────────────────────────────────────────────────────────────────
class TripDetailsSheet extends StatefulWidget {
  final PassengerAddPrivateTripCubit cubit;
  final VoidCallback onEditStart;
  final VoidCallback onEditDestination;

  const TripDetailsSheet({
    super.key,
    required this.cubit,
    required this.onEditStart,
    required this.onEditDestination,
  });

  @override
  State<TripDetailsSheet> createState() => _TripDetailsSheetState();
}

class _TripDetailsSheetState extends State<TripDetailsSheet> {
  bool _dateTimeSelected = true;

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.cubit.selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.cubit.selectedDateTime),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    final combinedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    widget.cubit.chooseTripDateTime(combinedDateTime);
    setState(() => _dateTimeSelected = true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PassengerAddPrivateTripCubit,
        PassengerAddPrivateTripState>(
      listener: (ctx, state) {
        if (state is PassengerAddPrivateTripErrorState) {
          showToast(text: state.error, state: ToastStates.ERROR);
        }
      },
      builder: (ctx, state) {
        final cubit = widget.cubit;

        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.45,
          maxChildSize: 0.90,
          builder: (_, scrollCtrl) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title row
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                  child: Row(
                    children: [
                      Text(
                        S.of(context).tripDetails,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.grey.shade500,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    children: [
                      // ── Route Summary ─────────────────────────────
                      _RouteSummaryCard(
                        cubit: cubit,
                        onEditStart: widget.onEditStart,
                        onEditDestination: widget.onEditDestination,
                      ),
                      const SizedBox(height: 22),

                      // ── Date & Time ───────────────────────────────
                      _SectionLabel(
                          label: S.of(context).dateTimeLabel,
                          icon: Icons.calendar_month),
                      const SizedBox(height: 10),
                      _DateTimeTile(
                        selected: _dateTimeSelected,
                        day: cubit.selectedDay,
                        date: cubit.selecteddate,
                        time: _dateTimeSelected
                            ? '${cubit.hourController.text}:${cubit.minutesController.text} ${cubit.periodController.text}'
                            : null,
                        onTap: _pickDateTime,
                      ),
                      const SizedBox(height: 22),

                      // ── Gender Preference ─────────────────────────
                      _SectionLabel(
                          label: S.of(context).genderPreferenceLabel,
                          icon: Icons.people_alt_outlined),
                      const SizedBox(height: 10),
                      _GenderSelector(cubit: cubit),
                      const SizedBox(height: 28),

                      // ── Confirm / Search For Offers Button ─────────
                      ConditionalBuilder(
                        condition:
                            state is! PassengerAddPrivateTripLoadingState,
                        fallback: (_) => Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          ),
                        ),
                        builder: (_) => SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (state is PassengerAddPrivateTripLoadingState)
                                ? null
                                : () {
                                    if (!_dateTimeSelected) {
                                      showToast(
                                        text: S.of(ctx).pleaseSelectDateTime,
                                        state: ToastStates.WARNING,
                                      );
                                      return;
                                    }
                                    cubit.createTrip(ctx);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 3,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_rounded,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  S.of(context).searchForOffersButton,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom + 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
        ],
      );
}

class _RouteSummaryCard extends StatelessWidget {
  final PassengerAddPrivateTripCubit cubit;
  final VoidCallback? onEditStart;
  final VoidCallback? onEditDestination;

  const _RouteSummaryCard({
    required this.cubit,
    this.onEditStart,
    this.onEditDestination,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            _RouteDetailRow(
              icon: Icons.trip_origin,
              color: AppColors.primary,
              title: S.of(context).startingLocation,
              subtitle:
                  (cubit.startLocationResult?.displayName.isNotEmpty == true)
                      ? cubit.startLocationResult!.displayName
                      : (cubit.startLocationController.text.isNotEmpty
                          ? cubit.startLocationController.text
                          : S.of(context).pickupPoint),
              onEdit: onEditStart,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 9),
              child: Column(
                children: List.generate(
                  4,
                  (_) => Container(
                    width: 2,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            _RouteDetailRow(
              icon: Icons.flag_rounded,
              color: const Color(0xFF1B5E20),
              title: S.of(context).destinationLocation,
              subtitle:
                  (cubit.destinationLocationResult?.displayName.isNotEmpty ==
                          true)
                      ? cubit.destinationLocationResult!.displayName
                      : (cubit.destinationLocationController.text.isNotEmpty
                          ? cubit.destinationLocationController.text
                          : S.of(context).destinationPoint),
              onEdit: onEditDestination,
            ),
          ],
        ),
      );
}

class _RouteDetailRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onEdit;

  const _RouteDetailRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: color,
              onPressed: onEdit,
              tooltip: S.of(context).edit,
            ),
        ],
      );
}

class _DateTimeTile extends StatelessWidget {
  final bool selected;
  final String day;
  final String date;
  final String? time;
  final VoidCallback onTap;

  const _DateTimeTile({
    required this.selected,
    required this.day,
    required this.date,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.grey.shade200,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.access_time_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: selected
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$day, $date',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF222222),
                            ),
                          ),
                          if (time != null)
                            Text(
                              time!,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      )
                    : Text(
                        S.of(context).pleaseSelectDateTime,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 14),
                      ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: Colors.grey.shade400, size: 15),
            ],
          ),
        ),
      );
}

class _GenderSelector extends StatelessWidget {
  final PassengerAddPrivateTripCubit cubit;
  const _GenderSelector({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final opts = [
      {
        'key': 'no_preference',
        'label': S.of(context).noPreference,
        'icon': Icons.people_rounded
      },
      {
        'key': 'male',
        'label': S.of(context).maleOnly,
        'icon': Icons.male_rounded
      },
      {
        'key': 'female',
        'label': S.of(context).femaleOnly,
        'icon': Icons.female_rounded
      },
    ];

    return Row(
      children: opts
          .map(
            (o) => Expanded(
              child: GestureDetector(
                onTap: () => cubit.changeGender(o['key'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: o == opts.last ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: cubit.gender == o['key']
                        ? AppColors.primary
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: cubit.gender == o['key']
                          ? AppColors.primary
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        o['icon'] as IconData,
                        color: cubit.gender == o['key']
                            ? Colors.white
                            : Colors.grey.shade500,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        o['label'] as String,
                        style: TextStyle(
                          color: cubit.gender == o['key']
                              ? Colors.white
                              : Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: cubit.gender == o['key']
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
