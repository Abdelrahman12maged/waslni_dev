import 'package:car_app/generated/l10n.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/features/settings/domain/entities/saved_location.dart';
import 'package:car_app/features/settings/presentation/cubit/saved_locations_cubit.dart';
import 'package:car_app/features/settings/presentation/cubit/saved_locations_state.dart';
import 'package:car_app/features/settings/presentation/passenger/screens/passenger_add_saved_location_screen.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:car_app/core/di/injection_container.dart' as di;

class PassengerSavedLocationsScreen extends StatelessWidget {
  const PassengerSavedLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return BlocProvider<SavedLocationsCubit>(
      create: (context) => di.sl<SavedLocationsCubit>()..getSavedLocations(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF1E293B),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            S.of(context).userlayoutsettingssavelocations,
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              onPressed: () =>
                  navigateTo(context, const CleanNotificationsScreen()),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocConsumer<SavedLocationsCubit, SavedLocationsState>(
          listener: (context, state) {
            if (state is SaveLocationSuccessSnackBarState) {
              showToast(
                text: S.of(context).addressAddedSuccessfully,
                state: ToastStates.SUCESS,
              );
              SavedLocationsCubit.get(context).getSavedLocations();
            }
            if (state is SavedLocationsError) {
              showToast(text: state.message, state: ToastStates.ERROR);
            }
          },
          builder: (context, state) {
            final cubit = SavedLocationsCubit.get(context);
            final locations = cubit.savedLocationsList;

            if (state is SavedLocationsLoading && locations.isEmpty) {
              return _buildSkeletonList();
            }

            return Stack(
              children: [
                RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => cubit.getSavedLocations(),
                  child: locations.isEmpty
                      ? _buildEmptyState(context)
                      : ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                          children: [
                            // ── Summary Header ─────────────────────────
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.bookmark_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          S.of(context).savedLocationsFavoriteTitle,
                                          style: GoogleFonts.cairo(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          S.of(context).savedLocationsFavoriteDesc,
                                          style: GoogleFonts.cairo(
                                            fontSize: 11.5,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Text(
                                      '${locations.length} ${S.of(context).savedLocationDefault}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── Saved Locations Cards ──────────────────
                            ...locations.map((loc) => _SavedLocationCard(
                                  location: loc,
                                  isArabic: isArabic,
                                  onOrderRide: () =>
                                      _handleOrderRide(context, loc),
                                  onDelete: () => _confirmDelete(
                                      context, cubit, loc),
                                )),
                          ],
                        ),
                ),

                // ── Floating Bottom Action Button ────────────────────
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.30),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const PassengerAddSavedLocationScreen(),
                          ),
                        );
                        if (context.mounted) {
                          cubit.getSavedLocations();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_location_alt_rounded, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            S.of(context).addNewLocation,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleOrderRide(BuildContext context, SavedLocation location) {
    // Navigate to Add Private Trip with preset destination location
    context.push(
      AppRoutes.passengerAddPrivateTrip,
      extra: {
        'preset_destination_name': location.name ?? '',
        'preset_destination_lat':
            double.tryParse(location.latitude ?? '') ?? 0.0,
        'preset_destination_lng':
            double.tryParse(location.longitude ?? '') ?? 0.0,
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    SavedLocationsCubit cubit,
    SavedLocation location,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bCtx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                size: 32,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).deleteSavedLocationTitle,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${S.of(context).deleteSavedLocationConfirm} (${location.name ?? ''})',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(bCtx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      S.of(context).cancel,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(bCtx);
                      if (location.id != null) {
                        cubit.deleteSavedLocation(location.id!);
                        showToast(
                          text: S.of(context).locationDeletedSuccess,
                          state: ToastStates.SUCESS,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      S.of(context).confirmDelete,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.12),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_rounded,
                  size: 54,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                S.of(context).noSavedLocationsYet,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  S.of(context).noSavedLocationsDesc,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => Container(
        height: 85,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 200,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedLocationCard extends StatelessWidget {
  final SavedLocation location;
  final bool isArabic;
  final VoidCallback onOrderRide;
  final VoidCallback onDelete;

  const _SavedLocationCard({
    required this.location,
    required this.isArabic,
    required this.onOrderRide,
    required this.onDelete,
  });

  _LocationCategory get _category {
    final name = (location.name ?? '').toLowerCase();
    if (name.contains('منزل') ||
        name.contains('بيت') ||
        name.contains('home') ||
        name.contains('دار')) {
      return _LocationCategory.home;
    }
    if (name.contains('عمل') ||
        name.contains('شغل') ||
        name.contains('مكتب') ||
        name.contains('work') ||
        name.contains('office') ||
        name.contains('شركة')) {
      return _LocationCategory.work;
    }
    if (name.contains('جامعة') ||
        name.contains('مدرسة') ||
        name.contains('كلية') ||
        name.contains('school') ||
        name.contains('university')) {
      return _LocationCategory.education;
    }
    if (name.contains('مول') ||
        name.contains('سوق') ||
        name.contains('متجر') ||
        name.contains('mall') ||
        name.contains('market') ||
        name.contains('shop')) {
      return _LocationCategory.shopping;
    }
    return _LocationCategory.custom;
  }

  @override
  Widget build(BuildContext context) {
    final cat = _category;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onOrderRide,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // ── Category Icon Container ──────────────────
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cat.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    cat.icon,
                    size: 24,
                    color: cat.color,
                  ),
                ),
                const SizedBox(width: 14),

                // ── Location Name & Coordinates ──────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              location.name ?? S.of(context).savedLocationDefault,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: cat.color.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              cat.getLocalizedLabel(context),
                              style: GoogleFonts.cairo(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: cat.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              (location.latitude != null &&
                                      location.longitude != null)
                                  ? '${location.latitude}, ${location.longitude}'
                                  : S.of(context).savedGeographicLocation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // ── Quick Action: Order / Delete ─────────────
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                  onPressed: onDelete,
                  tooltip: S.of(context).confirmDelete,
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _LocationCategory {
  home(
    icon: Icons.home_rounded,
    color: Color(0xFF2563EB),
  ),
  work(
    icon: Icons.business_rounded,
    color: Color(0xFFD97706),
  ),
  education(
    icon: Icons.school_rounded,
    color: Color(0xFF059669),
  ),
  shopping(
    icon: Icons.shopping_bag_rounded,
    color: Color(0xFF7C3AED),
  ),
  custom(
    icon: Icons.location_on_rounded,
    color: AppColors.primary,
  );

  final IconData icon;
  final Color color;

  const _LocationCategory({
    required this.icon,
    required this.color,
  });

  String getLocalizedLabel(BuildContext context) {
    switch (this) {
      case _LocationCategory.home:
        return S.of(context).presetHome;
      case _LocationCategory.work:
        return S.of(context).presetWork;
      case _LocationCategory.education:
        return S.of(context).presetStudy;
      case _LocationCategory.shopping:
        return S.of(context).presetShopping;
      case _LocationCategory.custom:
        return S.of(context).savedLocationDefault;
    }
  }
}
