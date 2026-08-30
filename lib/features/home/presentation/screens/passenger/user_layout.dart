import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:car_app/features/home/presentation/cubit/user_layout_cubit.dart';
import 'package:car_app/features/home/presentation/cubit/user_layout_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:car_app/core/widgets/exit_app_dialog.dart';

import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/utils/trip_security_service.dart';
import 'package:car_app/core/utils/rating_prompt_helper.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/private/current_private_trip_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/ongoing_shared_trip.dart';
import 'package:car_app/core/services/driver_location_tracker_service.dart';

import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_cubit.dart';

class UserLayout extends StatefulWidget {
  const UserLayout({super.key, this.currentIndex});
  final dynamic currentIndex;

  @override
  State<UserLayout> createState() => _UserLayoutState();
}

class _UserLayoutState extends State<UserLayout> {
  @override
  void initState() {
    super.initState();
    final int idx = widget.currentIndex != null
        ? (widget.currentIndex is int
            ? widget.currentIndex as int
            : (int.tryParse(widget.currentIndex.toString()) ?? 0))
        : 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        UserLayoutCubit.get(context).changeBottomScreen(idx);
      } catch (_) {}
      _checkActiveTrip();
    });
  }

  void _checkActiveTrip() {
    if (!mounted) return;
    final storage = sl<LocalStorage>();
    DriverLocationTrackerService.instance.checkAndResumeTracking(storage);
    try {
      context.read<PassengerTripsCubit>().loadPassengerTrips();
    } catch (_) {}

    final activeTrip = TripSecurityService.getActiveTrip(storage);
    final ongoingTrip = storage.read(key: 'ongoing_trip')?.toString();
    final rawTripId = storage.read(key: 'trip_id');
    final tripId = int.tryParse(rawTripId?.toString() ?? '');

    if (activeTrip != null) {
      if (TripSecurityService.isPreTripTrackingActive(activeTrip)) {
        final isPrivate = activeTrip.type == TripType.private;
        context.go(
          isPrivate
              ? AppRoutes.passengerCurrentPrivateTrip
              : AppRoutes.passengerOngoingSharedTrip,
          extra: {'trip': activeTrip, 'trip_id': activeTrip.id, 'id': activeTrip.id},
        );
        return;
      } else {
        TripSecurityService.clearActiveTrip(storage);
      }
    } else if (ongoingTrip != null && (ongoingTrip == 'shared' || ongoingTrip == 'private')) {
      final isPrivate = ongoingTrip == 'private';
      context.go(
        isPrivate
            ? AppRoutes.passengerCurrentPrivateTrip
            : AppRoutes.passengerOngoingSharedTrip,
        extra: {'trip_id': tripId, 'id': tripId},
      );
      return;
    }

    // No active ongoing trip: check if passenger has an unrated completed trip
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        RatingPromptHelper.checkAndShowPendingRating(context);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserLayoutCubit, UserLayoutStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var userLayoutCubit = UserLayoutCubit.get(context);
        int currentIndexState = widget.currentIndex ?? userLayoutCubit.currentIndex;
        List<String> usersLayoutTitles = [
          S.of(context).userlayouthometitle,
          S.of(context).userlayoutsettingstitle,
        ];

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            // If not on Home tab (0), switch to Home tab first
            if (userLayoutCubit.currentIndex != 0) {
              userLayoutCubit.changeBottomScreen(0);
              return;
            }
            final shouldExit = await showExitAppDialog(context);
            if (shouldExit) {
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.grey[200],
              title: Text(
                usersLayoutTitles[currentIndexState],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    context.push(AppRoutes.notifications);
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.bell,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () {
                context.push(AppRoutes.passengerTrips);
              },
              child: const FaIcon(FontAwesomeIcons.calendarDays, color: Colors.white),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            body: userLayoutCubit.userLayoutBottomScreens[currentIndexState],
            bottomNavigationBar: AnimatedBottomNavigationBar.builder(
              tabBuilder: (int index, bool isActive) {
                final icon = userLayoutCubit.userLayoutBottomIcons[index];
                final title = usersLayoutTitles[index];
                final color = isActive ? AppColors.primary : Colors.grey.shade600;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(icon, color: color, size: 20),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              },
              itemCount: userLayoutCubit.userLayoutBottomIcons.length,
              activeIndex: currentIndexState,
              gapLocation: GapLocation.center,
              notchSmoothness: NotchSmoothness.softEdge,
              height: 65,
              backgroundColor: Colors.white,
              leftCornerRadius: 20,
              rightCornerRadius: 20,
              onTap: (index) {
                userLayoutCubit.changeBottomScreen(index);
              },
            ),
          ),
        );
      },
    );
  }
}
