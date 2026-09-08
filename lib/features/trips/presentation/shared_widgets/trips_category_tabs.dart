import 'package:flutter/material.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/shared_widgets/trip_card_widget.dart';
import 'package:car_app/generated/l10n.dart';

const Color _mainColor = AppColors.primary;
const Color _iconsColor = AppColors.accent;

/// Reusable 4-sub-tab view (Current, Completed, Canceled, Suspended)
/// used across Private and Shared trip tabs for both Driver & Passenger.
class TripsCategoryTabs extends StatefulWidget {
  final List<Trip> currentTrips;
  final List<Trip> completedTrips;
  final List<Trip> canceledTrips;
  final List<Trip> suspendedTrips;
  final Future<void> Function() onRefresh;
  final void Function(Trip trip) onCurrentTap;
  final void Function(Trip trip) onCompletedTap;
  final void Function(Trip trip) onCanceledTap;
  final void Function(Trip trip) onSuspendedTap;
  final bool isPrivate;

  const TripsCategoryTabs({
    super.key,
    required this.currentTrips,
    required this.completedTrips,
    required this.canceledTrips,
    required this.suspendedTrips,
    required this.onRefresh,
    required this.onCurrentTap,
    required this.onCompletedTap,
    required this.onCanceledTap,
    required this.onSuspendedTap,
    required this.isPrivate,
  });

  @override
  State<TripsCategoryTabs> createState() => _TripsCategoryTabsState();
}

class _TripsCategoryTabsState extends State<TripsCategoryTabs> {
  int _selectedSubTab = 0;

  Color get _indicatorColor {
    switch (_selectedSubTab) {
      case 0:
        return _iconsColor;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      case 3:
        return Colors.orange;
      default:
        return _iconsColor;
    }
  }

  Widget _buildTripsList({
    required List<Trip> items,
    required void Function(Trip trip) onTap,
  }) {
    if (items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              S.of(context).noTrips,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final trip = items[index];
        return TripCardWidget(
          trip: trip,
          onTap: () => onTap(trip),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 10.0),
      itemCount: items.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          SizedBox(
            height: 40.0,
            child: TabBar(
              onTap: (value) {
                setState(() {
                  _selectedSubTab = value;
                });
              },
              indicatorColor: _indicatorColor,
              physics: const NeverScrollableScrollPhysics(),
              labelPadding: EdgeInsets.zero,
              labelColor: _mainColor,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(child: defaultText(text: S.of(context).currentW)),
                Tab(child: defaultText(text: S.of(context).completed)),
                Tab(child: defaultText(text: S.of(context).canceled)),
                Tab(child: defaultText(text: S.of(context).suspended)),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                RefreshIndicator(
                  onRefresh: widget.onRefresh,
                  child: _buildTripsList(
                    items: widget.currentTrips,
                    onTap: widget.onCurrentTap,
                  ),
                ),
                RefreshIndicator(
                  onRefresh: widget.onRefresh,
                  child: _buildTripsList(
                    items: widget.completedTrips,
                    onTap: widget.onCompletedTap,
                  ),
                ),
                RefreshIndicator(
                  onRefresh: widget.onRefresh,
                  child: _buildTripsList(
                    items: widget.canceledTrips,
                    onTap: widget.onCanceledTap,
                  ),
                ),
                RefreshIndicator(
                  onRefresh: widget.onRefresh,
                  child: _buildTripsList(
                    items: widget.suspendedTrips,
                    onTap: widget.onSuspendedTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
