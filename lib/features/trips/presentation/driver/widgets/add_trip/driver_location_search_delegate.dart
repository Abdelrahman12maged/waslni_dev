import 'package:flutter/material.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/map/domain/entities/location_result.dart';
import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_shared_trip_cubit.dart';
import 'package:car_app/generated/l10n.dart';

/// Location Search Delegate for driver shared trip creation.
class DriverLocationSearchDelegate extends SearchDelegate<LocationResult?> {
  final DriverAddSharedTripCubit cubit;

  DriverLocationSearchDelegate({required this.cubit});

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSuggestions(context);

  Widget _buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return Center(
        child: Text(
          S.of(context).searchLocationHint,
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return FutureBuilder<List<PlaceSuggestion>>(
      future: cubit.searchPlaces(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final suggestions = snapshot.data ?? [];
        if (suggestions.isEmpty) {
          return Center(
            child: Text(
              S.of(context).noLocationFound,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }

        return ListView.separated(
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF5F5F5),
                child: Icon(Icons.location_on, color: AppColors.primary),
              ),
              title: Text(
                suggestion.mainText,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: suggestion.secondaryText.isNotEmpty
                  ? Text(
                      suggestion.secondaryText,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    )
                  : null,
              onTap: () async {
                final details = await cubit.getPlaceDetails(suggestion.placeId);
                if (context.mounted) {
                  close(context, details);
                }
              },
            );
          },
        );
      },
    );
  }
}
