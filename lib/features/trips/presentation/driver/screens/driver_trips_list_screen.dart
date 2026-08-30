import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_state.dart';
import 'package:car_app/features/trips/presentation/shared_widgets/trip_card_widget.dart';
import 'package:car_app/features/trips/presentation/shared_widgets/trips_list_shimmer.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Main trips screen for drivers — shows active trips with tabs for private/shared.
class DriverTripsListScreen extends StatefulWidget {
  const DriverTripsListScreen({super.key});

  @override
  State<DriverTripsListScreen> createState() => _DriverTripsListScreenState();
}

class _DriverTripsListScreenState extends State<DriverTripsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<DriverTripsCubit>().loadDriverTrips();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(S.of(context).myTrips),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(text: S.of(context).userlayouthomeprivatetrip, icon: const Icon(Icons.person, size: 18)),
            Tab(text: S.of(context).userlayouthomesharedtrip, icon: const Icon(Icons.group, size: 18)),
          ],
        ),
      ),
      body: BlocBuilder<DriverTripsCubit, DriverTripsState>(
        builder: (context, state) {
          if (state is DriverTripsLoading) {
            return const TripsListShimmer(showTabs: false);
          }

          if (state is DriverTripsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: context.read<DriverTripsCubit>().loadDriverTrips,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is! DriverTripsLoaded) return const SizedBox.shrink();

          return TabBarView(
            controller: _tabController,
            children: [
              // ── Private Tab ─────────────────────────────────────────
              _DriverTripTab(
                sections: [
                  _Section(
                    title: S.of(context).currentTrips,
                    trips: state.currentPrivate,
                    onTap: (t) => context.push(
                        '/driver/trips/private/ongoing',
                        extra: t),
                  ),
                  _Section(
                    title: S.of(context).completedTrips,
                    trips: state.completedPrivate,
                    onTap: (_) {},
                  ),
                  _Section(
                    title: S.of(context).canceledTrips,
                    trips: state.canceledPrivate,
                    onTap: (_) {},
                  ),
                ],
              ),

              // ── Shared Tab ──────────────────────────────────────────
              _DriverTripTab(
                sections: [
                  _Section(
                    title: S.of(context).currentTrips,
                    trips: state.currentShared,
                    onTap: (t) => context.push(
                        '/driver/trips/shared/ongoing',
                        extra: t),
                  ),
                  _Section(
                    title: S.of(context).completedTrips,
                    trips: state.completedShared,
                    onTap: (_) {},
                  ),
                  _Section(
                    title: S.of(context).canceledTrips,
                    trips: state.canceledShared,
                    onTap: (_) {},
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Sub widgets ──────────────────────────────────────────────────────────────

class _Section {
  final String title;
  final List<Trip> trips;
  final void Function(Trip) onTap;
  const _Section(
      {required this.title, required this.trips, required this.onTap});
}

class _DriverTripTab extends StatelessWidget {
  const _DriverTripTab({required this.sections});
  final List<_Section> sections;

  @override
  Widget build(BuildContext context) {
    final allEmpty = sections.every((s) => s.trips.isEmpty);
    if (allEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(S.of(context).noTrips, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<DriverTripsCubit>().loadDriverTrips(),
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 20),
        children: [
          for (final section in sections)
            if (section.trips.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              ...section.trips.map(
                (t) => TripCardWidget(
                  trip: t,
                  onTap: () => section.onTap(t),
                ),
              ),
            ],
        ],
      ),
    );
  }
}
