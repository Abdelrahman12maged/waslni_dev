import 'package:flutter/material.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/shared_ongoing/passenger_shared_top_bar.dart';

/// 5-step progression timeline indicator for passenger shared trip tracking screen.
class PassengerSharedStatusSteps extends StatelessWidget {
  const PassengerSharedStatusSteps({
    super.key,
    required this.phase,
    required this.phaseColor,
  });

  final PassengerSharedTripPhase phase;
  final Color phaseColor;

  int get _activeIndex {
    switch (phase) {
      case PassengerSharedTripPhase.driverPending:
        return 0;
      case PassengerSharedTripPhase.driverOnWay:
        return 1;
      case PassengerSharedTripPhase.driverNear:
        return 2;
      case PassengerSharedTripPhase.driverArrived:
        return 3;
      case PassengerSharedTripPhase.inTrip:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      (icon: Icons.hourglass_top_rounded, label: S.of(context).waitingDriverMoveShort),
      (icon: Icons.directions_car_rounded, label: S.of(context).onTheWay),
      (icon: Icons.near_me_rounded, label: S.of(context).nearby),
      (icon: Icons.location_on_rounded, label: S.of(context).driverArrived),
      (icon: Icons.flag_rounded, label: S.of(context).inTrip),
    ];

    return Row(
      children: List.generate(steps.length, (i) {
        final done = i <= _activeIndex;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: done ? phaseColor : Colors.grey.shade100,
                        shape: BoxShape.circle,
                        boxShadow: done
                            ? [
                                BoxShadow(
                                  color: phaseColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : [],
                      ),
                      child: Icon(
                        steps[i].icon,
                        size: 18,
                        color: done ? Colors.white : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[i].label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: done ? FontWeight.w600 : FontWeight.normal,
                        color: done ? phaseColor : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 2,
                    color: i < _activeIndex ? phaseColor : Colors.grey.shade200,
                    margin: const EdgeInsets.only(bottom: 18),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
