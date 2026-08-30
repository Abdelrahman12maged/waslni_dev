import 'package:car_app/generated/l10n.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/private/private_completed_trips_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/shared_completed_trips_screen.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Shows completed trips organized in two tabs: Private and Shared.
/// (This replaces the legacy UserScheduleTripsScreen whose functionality
/// was a simple UI shell for viewing archived trip history.)
class PassengerScheduleTripsScreen extends StatefulWidget {
  const PassengerScheduleTripsScreen({super.key});

  @override
  State<PassengerScheduleTripsScreen> createState() =>
      _PassengerScheduleTripsScreenState();
}

class _PassengerScheduleTripsScreenState
    extends State<PassengerScheduleTripsScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text('Schedule Trips'),
        actions: [
          IconButton(
            onPressed: () =>
                navigateTo(context, const CleanNotificationsScreen()),
            icon: FaIcon(
              FontAwesomeIcons.bell,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Tab Headers ───────────────────────────────────────────
              SizedBox(
                height: 50,
                child: TabBar(
                  physics: const NeverScrollableScrollPhysics(),
                  onTap: (value) => setState(() => _currentIndex = value),
                  isScrollable: false,
                  splashBorderRadius: BorderRadius.circular(5),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  tabs: [
                    Tab(
                      child: defaultText(
                        text: S.of(context).privateTrip,
                        textColor: _currentIndex == 0
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    Tab(
                      child: defaultText(
                        text: S.of(context).sharedTrip,
                        textColor: _currentIndex == 1
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ── Tab Views ─────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Private tab — shows completed private trips
                    ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) => privateTripContainer(
                        context: context,
                        borderColor: Colors.green,
                        onTap: () =>
                            navigateTo(
                          context,
                          const PassengerPrivateCompletedScreenClean(
                            trip: Trip(
                              id: 0,
                              createdBy: 0,
                              fromLatitude: 31.963158,
                              fromLongitude: 35.930359,
                              toLatitude: 31.963158,
                              toLongitude: 35.930359,
                              genderPreference: GenderPreference.noPreference,
                              type: TripType.private,
                              status: TripStatus.completed,
                              fromLocationName: 'Amman, Amman Street 4th Avenue',
                              toLocationName: 'Amman, Airport Road',
                              tripDatetime: '2023-07-22 08:20:00',
                              numberOfSeats: 1,
                              minimumPrice: 10.0,
                              maximumPrice: 15.0,
                            ),
                          ),
                        ),
                        timeText: '8:20 Am',
                        dateText: '22/7/2023',
                        locationText: 'Amman, Amman Street 4th Avenue',
                      ),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 15),
                      itemCount: 10,
                    ),

                    // Shared tab — shows completed shared trips
                    ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) => sharedTripContainer(
                        borderColor: Colors.green,
                        onTap: () =>
                            navigateTo(
                          context,
                          const PassengerSharedCompletedScreenClean(
                            trip: Trip(
                              id: 0,
                              createdBy: 0,
                              fromLatitude: 31.963158,
                              fromLongitude: 35.930359,
                              toLatitude: 31.963158,
                              toLongitude: 35.930359,
                              genderPreference: GenderPreference.noPreference,
                              type: TripType.shared,
                              status: TripStatus.completed,
                              fromLocationName: 'Amman, Amman Street 4th Avenue',
                              toLocationName: 'Amman, Airport Road',
                              tripDatetime: '2023-07-22 08:20:00',
                              numberOfSeats: 1,
                              minimumPrice: 5.0,
                              maximumPrice: 8.0,
                            ),
                          ),
                        ),
                        timeText: '8:20 Am',
                        dateText: '22/7/2023',
                        locationText: 'Amman, Amman Street 4th Avenue',
                      ),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 15),
                      itemCount: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
