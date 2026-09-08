import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/services/driver_location_tracker_service.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/theme/colors.dart';
import 'package:car_app/core/utils/trip_security_service.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/widgets/exit_app_dialog.dart';
import 'package:car_app/features/driver_documents/presentation/screens/driver_documents_screen.dart';
import 'package:car_app/features/home/presentation/cubit/driver_home_cubit.dart';
import 'package:car_app/features/home/presentation/cubit/driver_layout_cubit.dart';
import 'package:car_app/features/home/presentation/cubit/driver_layout_cubit_state.dart';
import 'package:car_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/screens/shared/new_shared_trip.dart';
import 'package:car_app/generated/l10n.dart';

class DriverLayoutView extends StatefulWidget {
  final dynamic currentIndex;

  const DriverLayoutView({super.key, this.currentIndex});

  @override
  State<DriverLayoutView> createState() => _DriverLayoutViewState();
}

class _DriverLayoutViewState extends State<DriverLayoutView> {
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
        DriverLayoutCubit.get(context).changeBottomScreen(idx);
        if (idx == 1) {
          context.read<DriverTripsCubit>().loadDriverTrips();
        } else if (idx == 0) {
          context.read<DriverHomeCubit>().loadHomeData();
        }
      } catch (_) {}
      _initDriverTracking();
    });
  }

  @override
  void didUpdateWidget(covariant DriverLayoutView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != null) {
      final int idx = widget.currentIndex is int
          ? widget.currentIndex as int
          : (int.tryParse(widget.currentIndex.toString()) ?? 0);
      try {
        DriverLayoutCubit.get(context).changeBottomScreen(idx);
        if (idx == 1) {
          context.read<DriverTripsCubit>().loadDriverTrips();
        }
      } catch (_) {}
    }
  }

  void _initDriverTracking() {
    if (!mounted) return;
    final storage = di.sl<LocalStorage>();
    DriverLocationTrackerService.instance.checkAndResumeTracking(storage);
    try {
      context.read<DriverTripsCubit>().loadDriverTrips();
    } catch (_) {}

    try {
      final currentPath = GoRouterState.of(context).matchedLocation;
      if (currentPath != AppRoutes.driverHome) {
        return;
      }
    } catch (_) {}

    final activeTrip = TripSecurityService.getActiveTrip(storage);
    if (activeTrip != null &&
        TripSecurityService.isPreTripTrackingActive(activeTrip)) {
      final isPrivate = activeTrip.type == TripType.private;
      context.go(
        isPrivate
            ? AppRoutes.driverOngoingPrivateTrip
            : AppRoutes.driverOngoingSharedTrip,
        extra: {
          'trip': activeTrip,
          'trip_id': activeTrip.id,
          'id': activeTrip.id
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverLayoutCubit, DriverLayoutStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var driverLayoutCubit = DriverLayoutCubit.get(context);
        List<String> driverLayoutTitles = [
          S.of(context).userlayouthometitle,
          S.of(context).myTrips,
          S.of(context).chat,
          S.of(context).userlayoutsettingstitle,
        ];
        final int currentIndexState = driverLayoutCubit.currentIndex;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (driverLayoutCubit.currentIndex != 0) {
              driverLayoutCubit.changeBottomScreen(0);
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
                driverLayoutTitles[currentIndexState],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    navigateTo(context, CleanNotificationsScreen());
                  },
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: mainColor,
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                final storage = di.sl<LocalStorage>();
                final isActive = (storage.read(key: 'driver_kyc_active')
                        as String?) ==
                    'true';
                if (!isActive) {
                  _showKycBlockedDialog(context);
                  return;
                }
                navigateTo(context, const AddNewSharedTripDriver());
              },
              child: const FaIcon(
                FontAwesomeIcons.squarePlus,
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            body: driverLayoutCubit
                .driverLayoutBottomScreens[currentIndexState],
            bottomNavigationBar: AnimatedBottomNavigationBar.builder(
              tabBuilder: (int index, bool isActive) {
                final icon =
                    driverLayoutCubit.driverLayoutBottomIcons[index];
                final title = driverLayoutTitles[index];
                final color = isActive ? mainColor : Colors.grey.shade600;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      icon,
                      size: 20,
                      color: color,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              },
              itemCount:
                  driverLayoutCubit.driverLayoutBottomIcons.length,
              activeIndex: currentIndexState,
              gapLocation: GapLocation.center,
              notchSmoothness: NotchSmoothness.verySmoothEdge,
              height: 65,
              backgroundColor: Colors.white,
              leftCornerRadius: 20,
              rightCornerRadius: 20,
              onTap: (index) {
                if (index != currentIndexState) {
                  driverLayoutCubit.changeBottomScreen(index);
                  if (index == 1) {
                    context.read<DriverTripsCubit>().loadDriverTrips();
                  } else if (index == 0) {
                    DriverHomeCubit.of(context).loadHomeData();
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }
}

void _showKycBlockedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      icon: const Icon(Icons.verified_user_outlined,
          color: Colors.amber, size: 40),
      title: Text(
        S.of(context).kycRequiredTitle,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        S.of(context).kycRequiredMessage,
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(S.of(context).no),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            navigateTo(context, const DriverDocumentsScreen());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: Text(
            S.of(context).goToDocuments,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
