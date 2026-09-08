import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/services/home_widget_service.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/trip_security_service.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/chat/presentation/screens/trip_chat_screen.dart';
import 'package:car_app/features/driver_documents/presentation/screens/driver_documents_screen.dart';
import 'package:car_app/features/home/presentation/cubit/driver_home_cubit.dart';
import 'package:car_app/features/home/presentation/cubit/driver_home_state.dart';
import 'package:car_app/features/home/presentation/cubit/driver_layout_cubit.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/usecases/change_offer_status_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/change_trip_status_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_offers_by_trip_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_trip_details_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/make_offer_usecase.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_state.dart';
import 'package:car_app/features/trips/presentation/driver/screens/driver_new_trips_accept_screen.dart';
import 'package:car_app/features/trips/presentation/driver/widgets/new_trips/driver_trip_card_item.dart';
import 'package:car_app/generated/l10n.dart';

const _kNavy = AppColors.primary;
const _kNavyMid = AppColors.primaryLight;
const _kGold = AppColors.accent;
const _kGreen = AppColors.success;
const _kBg = Color(0xFFF2F4F8);
const _kCard = Colors.white;
const _kBorder = Color(0xFFE4E8F0);
const _kSub = Color(0xFF64748B);

class DriverHomeView extends StatefulWidget {
  const DriverHomeView({super.key});

  @override
  State<DriverHomeView> createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends State<DriverHomeView>
    with TickerProviderStateMixin {
  late final LocalStorage _storage;

  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _storage = di.sl<LocalStorage>();

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    DriverHomeCubit.of(context).loadHomeData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingSharedTripPricing();
      if (mounted) {
        DriverTripsCubit.get(context).getDriverTripsByTypes(isLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _glowCtrl.dispose();
    super.dispose();
  }

  void _openRadiusModal() {
    final trips = DriverTripsCubit.get(context);
    double r = trips.selectedRadius;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setBS) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(
                child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: _kBorder, borderRadius: BorderRadius.circular(2)),
            )),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(S.of(context).searchRadiusScope,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _kNavy)),
              IconButton(
                  icon:
                      const Icon(Icons.close_rounded, color: _kSub, size: 20),
                  onPressed: () => Navigator.pop(ctx)),
            ]),
            const SizedBox(height: 4),
            Text(S.of(context).searchRadiusDesc(r.toInt()),
                style: const TextStyle(fontSize: 12, color: _kSub)),
            const SizedBox(height: 18),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kNavy.withOpacity(0.06),
                border: Border.all(color: _kNavy.withOpacity(0.15), width: 2),
              ),
              child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${r.toInt()}',
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: _kNavy)),
                Text(S.of(context).kmOnly,
                    style: const TextStyle(fontSize: 12, color: _kSub)),
              ])),
            ),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderTheme.of(ctx).copyWith(
                activeTrackColor: _kNavy,
                inactiveTrackColor: _kBorder,
                thumbColor: _kNavy,
                overlayColor: _kNavy.withOpacity(0.1),
                trackHeight: 4,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 9),
              ),
              child: Slider(
                value: r,
                min: 5,
                max: 200,
                divisions: 39,
                onChanged: (v) => setBS(() => r = v),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [10, 25, 50, 75, 100, 150].map((km) {
                final sel = r.toInt() == km;
                return GestureDetector(
                  onTap: () => setBS(() => r = km.toDouble()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 5.5),
                    decoration: BoxDecoration(
                      color: sel ? _kNavy : _kBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: sel ? _kNavy : _kBorder),
                    ),
                    child: Text(S.of(context).kmUnit(km),
                        style: TextStyle(
                            color: sel ? Colors.white : Colors.black87,
                            fontWeight:
                                sel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kNavy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  trips.updateSearchFilters(radius: r);
                  di.sl<LocalStorage>().saveString(
                      key: 'driver_search_radius',
                      value: r.toInt().toString());
                  DriverHomeCubit.of(context)
                      .loadHomeData(silent: true, radius: r);
                  setState(() {});
                },
                child: Text(S.of(context).applyRadius,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverHomeCubit, DriverHomeState>(
      builder: (context, state) {
        if (state is DriverHomeLoading || state is DriverHomeInitial) {
          return const Scaffold(
              backgroundColor: _kBg,
              body:
                  Center(child: CircularProgressIndicator(color: _kNavy)));
        }

        if (state is DriverHomeError) {
          return Scaffold(
            backgroundColor: _kBg,
            body: Center(
                child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                    Icons
                        .signal_wifi_statusbar_connected_no_internet_4_rounded,
                    size: 56,
                    color: Colors.grey.shade400),
                const SizedBox(height: 14),
                Text(state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () =>
                      DriverHomeCubit.of(context).loadHomeData(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(S.of(context).retryAction),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _kNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
              ]),
            )),
          );
        }

        final data = state as DriverHomeLoaded;
        final isKycActive = data.isKycActive;

        return BlocBuilder<DriverTripsCubit, DriverTripsState>(
          builder: (context, tripsState) {
            final tripsCubit = DriverTripsCubit.get(context);
            final openCount = tripsCubit.TripsListByTypePrivete.length +
                tripsCubit.TripsListByTypeShared.length;

            if (tripsState is DriverTripsLoaded) {
              final activeTrip =
                  TripSecurityService.getActiveTrip(_storage);
              if (activeTrip != null) {
                HomeWidgetService.updateActiveTrip(
                    trip: activeTrip, isDriver: true);
              } else {
                HomeWidgetService.updateDriverTripsCount(openCount);
              }
            }
            return Scaffold(
              backgroundColor: _kBg,
              body: RefreshIndicator(
                color: _kNavy,
                displacement: 90,
                onRefresh: () async {
                  await DriverHomeCubit.of(context).loadHomeData();
                  if (context.mounted) {
                    DriverTripsCubit.get(context)
                        .getDriverTripsByTypes(isLoading: false);
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(children: [
                    _buildWaveHeader(data.driverName, data.driverPhotoUrl),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                      child: Column(children: [
                        if (!isKycActive) ...[
                          const _KycReviewBanner(),
                          const SizedBox(height: 12),
                        ],
                        _buildRadiusCard(),
                        const SizedBox(height: 12),
                        if (data.summary.acceptedCount > 0) ...[
                          _buildActiveTripBanner(data.summary.acceptedCount),
                          const SizedBox(height: 12),
                        ],
                        _buildTripsHeroCard(openCount),
                        const SizedBox(height: 18),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            S.of(context).myTripsStats,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildStatsGrid(data, openCount),
                      ]),
                    ),
                  ]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWaveHeader(String name, String? photoUrl) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kNavy, _kNavyMid],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            child: Row(children: [
              GestureDetector(
                onTap: () => DriverHomeCubit.of(context).loadHomeData(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.refresh_rounded,
                      color: _kNavy, size: 19),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${S.of(context).welcome} ',
                          style: TextStyle(
                              fontSize: 12,
                              color: _kGold.withOpacity(0.95),
                              fontWeight: FontWeight.w600)),
                      const Text('👋', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(name.isNotEmpty ? name : S.of(context).captainName,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
              const SizedBox(width: 12),
              AnimatedBuilder(
                animation: _glowAnim,
                builder: (_, __) => Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(
                        color: _kGold.withOpacity(
                            0.6 + 0.4 * _glowAnim.value),
                        width: 2),
                    boxShadow: [
                      BoxShadow(
                          color:
                              _kGold.withOpacity(0.35 * _glowAnim.value),
                          blurRadius: 10,
                          spreadRadius: 1),
                    ],
                  ),
                  child: AppCachedNetworkImage(
                    imageUrl: ApiEndpoints.buildImageUrl(photoUrl),
                    width: 46,
                    height: 46,
                    isCircle: true,
                    fallbackIcon: Icons.person_rounded,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildRadiusCard() {
    final radius = DriverTripsCubit.get(context).selectedRadius;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _kNavy,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.radar_rounded,
              color: Colors.white, size: 18),
        ),
        Expanded(
          child: Center(
            child: Text(
              S.of(context).searchRadiusLabel(radius.toInt()),
              style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
        ),
        GestureDetector(
          onTap: _openRadiusModal,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
            decoration: BoxDecoration(
                color: _kNavy, borderRadius: BorderRadius.circular(18)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.settings_rounded,
                  color: Colors.white, size: 12),
              const SizedBox(width: 4),
              Text(S.of(context).editAction,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildActiveTripBanner(int count) {
    return GestureDetector(
      onTap: () => DriverLayoutCubit.get(context).changeBottomScreen(1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kGreen.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
                color: _kGreen.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: _kGreen.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.directions_car_filled_rounded,
                color: _kGreen, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(S.of(context).hasActiveTripNotice,
                    style: const TextStyle(
                        color: Color(0xFF1B5E20),
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                Text(S.of(context).continueActiveTrip,
                    style: const TextStyle(
                        color: Color(0xFF388E3C), fontSize: 10.5)),
              ])),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: _kGreen, size: 12),
        ]),
      ),
    );
  }

  Widget _buildTripsHeroCard(int openCount) {
    return GestureDetector(
      onTap: () =>
          navigateTo(context, const DriverNewTripsAcceptScreenClean()),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [_kNavy, _kNavyMid],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: _kNavyMid.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: _kNavy.withOpacity(0.24),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: _buildHeroContent(openCount),
      ),
    );
  }

  Widget _buildHeroContent(int count) {
    return Stack(children: [
      Positioned(
        top: -12,
        right: -12,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      Positioned(
        top: -12,
        left: -12,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      Positioned(
        bottom: -12,
        right: -12,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      Positioned(
        bottom: -12,
        left: -12,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 4.5),
              decoration: BoxDecoration(
                color: _kGold,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.bolt_rounded, color: _kNavy, size: 14),
                const SizedBox(width: 3),
                Text(
                  count > 0
                      ? S.of(context).newRequestsCount(count)
                      : S.of(context).newTripsStat,
                  style: const TextStyle(
                    color: _kNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
              ]),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (_, __) => Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(
                    color: _kGold.withOpacity(
                        0.4 + 0.3 * _glowAnim.value),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _kGold.withOpacity(
                            0.6 + 0.4 * _glowAnim.value),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _kGold.withOpacity(
                              0.85 + 0.15 * _glowAnim.value),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Text(
            S.of(context).liveRequestsAvailable,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            S.of(context).heroTripsSubtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: _kGold,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _kGold.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_back_rounded,
                    color: _kNavy, size: 16),
                const SizedBox(width: 6),
                Text(
                  S.of(context).viewRequestsAndMakeOffer,
                  style: const TextStyle(
                    color: _kNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildStatsGrid(DriverHomeLoaded data, [int? openCount]) {
    final effectiveOpenCount = openCount ?? data.summary.openCount;
    final items = [
      _StatItem(
        title: S.of(context).newTripsStat,
        count: effectiveOpenCount,
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFE65100),
        bg: const Color(0xFFFFF3E0),
        onTap: () =>
            navigateTo(context, const DriverNewTripsAcceptScreenClean()),
      ),
      _StatItem(
        title: S.of(context).currentTripsStat,
        count: data.summary.acceptedCount,
        icon: Icons.directions_car_filled_rounded,
        color: const Color(0xFF1B5E20),
        bg: const Color(0xFFE8F5E9),
        onTap: () =>
            DriverLayoutCubit.get(context).changeBottomScreen(1),
      ),
      _StatItem(
        title: S.of(context).completedTripsStat,
        count: data.summary.completedCount,
        icon: Icons.check_circle_rounded,
        color: _kNavy,
        bg: const Color(0xFFE8EAF6),
        onTap: () =>
            DriverLayoutCubit.get(context).changeBottomScreen(1),
      ),
      _StatItem(
        title: S.of(context).suspendedTripsStat,
        count: data.summary.suspendedCount,
        icon: Icons.hourglass_bottom_rounded,
        color: const Color(0xFF6A1B9A),
        bg: const Color(0xFFF3E5F5),
        onTap: () =>
            DriverLayoutCubit.get(context).changeBottomScreen(1),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.25,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map(_buildStatCard).toList(),
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: item.bg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.color, size: 16),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color:
                        item.count > 0 ? item.color : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                '${item.count}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color:
                      item.count > 0 ? item.color : Colors.grey.shade400,
                  height: 1.0,
                ),
              ),
            ),
            Center(
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kSub,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkPendingSharedTripPricing() async {
    final pendingIdStr =
        _storage.read(key: 'pending_pricing_trip_id')?.toString();
    if (pendingIdStr == null || pendingIdStr.isEmpty) return;
    final tripId = int.tryParse(pendingIdStr);
    if (tripId == null || tripId <= 0) return;

    try {
      final tripDetailsResult =
          await di.sl<GetTripDetailsUseCase>().call(tripId);
      if (!mounted) return;
      tripDetailsResult.fold(
        (_) => null,
        (trip) {
          if (trip.status == TripStatus.suspended ||
              ((trip.approvedPrice ?? 0) <= 0 &&
                  trip.status == TripStatus.open)) {
            _showPendingTripPricingModal(trip);
          } else {
            _storage.remove(key: 'pending_pricing_trip_id');
          }
        },
      );
    } catch (_) {}
  }

  void _showPendingTripPricingModal(Trip trip) {
    final double parsedMin =
        trip.minimumPrice > 0 ? trip.minimumPrice : 1.0;
    double parsedMax = trip.maximumPrice > parsedMin
        ? trip.maximumPrice
        : (parsedMin + 10.0);
    if (parsedMax <= parsedMin) {
      parsedMax = parsedMin + 5.0;
    }

    final priceController =
        TextEditingController(text: parsedMin.toStringAsFixed(0));
    double selectedPrice = parsedMin;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return PopScope(
              canPop: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: EdgeInsets.fromLTRB(
                  22,
                  16,
                  22,
                  MediaQuery.of(modalContext).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.timer_outlined,
                                color: Colors.amber.shade800, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S
                                      .of(modalContext)
                                      .pendingPricingTripTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  S
                                      .of(modalContext)
                                      .pendingPricingTripSubtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.trip_origin,
                                    color: _kNavy, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    cleanLocationName(
                                        trip.fromLocationName),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    color: Colors.redAccent, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    cleanLocationName(
                                        trip.toLocationName),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        S.of(modalContext).setTotalRequiredPrice,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(modalContext).copyWith(
                                activeTrackColor: _kNavy,
                                inactiveTrackColor:
                                    _kNavy.withOpacity(0.15),
                                thumbColor: _kNavy,
                                trackHeight: 5,
                              ),
                              child: Slider(
                                value: selectedPrice.clamp(
                                    parsedMin, parsedMax),
                                min: parsedMin,
                                max: parsedMax,
                                divisions: ((parsedMax - parsedMin) * 2)
                                    .round()
                                    .clamp(1, 100),
                                onChanged: (val) {
                                  setModalState(() {
                                    selectedPrice = double.parse(
                                        val.toStringAsFixed(1));
                                    priceController.text =
                                        selectedPrice.toStringAsFixed(1);
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 80,
                            height: 40,
                            child: TextField(
                              controller: priceController,
                              keyboardType: const TextInputType
                                  .numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: _kNavy,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                suffixText: S.of(modalContext).jod,
                                suffixStyle: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (val) {
                                final entered = double.tryParse(val);
                                if (entered != null) {
                                  setModalState(
                                      () => selectedPrice = entered);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  setModalState(
                                      () => isSubmitting = true);
                                  try {
                                    final rawUid = _storage
                                            .read(key: 'userid') ??
                                        _storage.read(key: 'user_id');
                                    final driverId = int.tryParse(
                                            rawUid?.toString() ?? '') ??
                                        (trip.driverId ??
                                            trip.driver?.id ??
                                            0);

                                    final offerRes = await di
                                        .sl<MakeOfferUseCase>()
                                        .call(
                                      offerData: {
                                        "driver_id": driverId,
                                        "trip_id": trip.id,
                                        "note": '',
                                        "price": selectedPrice,
                                        "percentage": 0.0,
                                      },
                                    );

                                    await offerRes.fold(
                                      (failure) async {
                                        showToast(
                                            text: failure.message,
                                            state: ToastStates.ERROR);
                                      },
                                      (_) async {
                                        try {
                                          final offersRes = await di
                                              .sl<
                                                  GetOffersByTripUseCase>()
                                              .call(trip.id);
                                          await offersRes.fold(
                                            (_) async => null,
                                            (offers) async {
                                              final myOffers = offers
                                                  .where((o) =>
                                                      o.driverId ==
                                                          driverId ||
                                                      o.driver?.id ==
                                                          driverId)
                                                  .toList();
                                              if (myOffers.isNotEmpty) {
                                                final targetOffer =
                                                    myOffers.last;
                                                await di
                                                    .sl<
                                                        ChangeOfferStatusUseCase>()
                                                    .call(
                                                      offerId:
                                                          targetOffer.id,
                                                      status: 'accepted',
                                                      userId: driverId,
                                                    );
                                              }
                                            },
                                          );
                                        } catch (_) {}

                                        await di
                                            .sl<
                                                ChangeTripStatusUseCase>()
                                            .call(
                                              tripId: trip.id,
                                              status: 'accepted',
                                            );
                                        _storage.saveString(
                                            key:
                                                'offer_status_${trip.id}',
                                            value: 'accepted');
                                        await _storage.remove(
                                            key:
                                                'pending_pricing_trip_id');
                                        if (mounted) {
                                          Navigator.pop(modalCtx);
                                          showToast(
                                              text: S
                                                  .of(context)
                                                  .tripPriceConfirmedSuccess,
                                              state:
                                                  ToastStates.SUCESS);
                                          String dName = _storage
                                                  .read(
                                                      key: 'username')
                                                  ?.toString() ??
                                              '';
                                          String dPhone = _storage
                                                  .read(key: 'phone')
                                                  ?.toString() ??
                                              '';
                                          navigateTo(
                                            context,
                                            TripChatScreenClean(
                                              driverName: dName.isNotEmpty
                                                  ? dName
                                                  : S
                                                      .of(context)
                                                      .driver,
                                              driverPhone: dPhone,
                                              tripFrom:
                                                  cleanLocationName(trip
                                                      .fromLocationName),
                                              tripTo: cleanLocationName(
                                                  trip.toLocationName),
                                              tripDatetime:
                                                  trip.tripDatetime,
                                              acceptedPrice:
                                                  selectedPrice,
                                              tripId: trip.id,
                                              offerId: 0,
                                              tripType: 'shared',
                                              members: [
                                                if (trip.driver != null)
                                                  trip.driver!.toMap(),
                                                if (trip.creator != null)
                                                  trip.creator!.toMap(),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  } catch (e) {
                                    showToast(
                                        text:
                                            '${S.of(context).errorOccurred}: $e',
                                        state: ToastStates.ERROR);
                                  } finally {
                                    if (mounted) {
                                      setModalState(
                                          () => isSubmitting = false);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  S
                                      .of(modalContext)
                                      .confirmPriceAndActivateTrip,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final confirm =
                                      await showDialog<bool>(
                                    context: modalContext,
                                    builder: (dCtx) => AlertDialog(
                                      title: Text(S
                                          .of(modalContext)
                                          .confirmCancelTrip),
                                      content: Text(S
                                          .of(modalContext)
                                          .cancelPendingTripConfirm),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                              dCtx, false),
                                          child: Text(S
                                              .of(modalContext)
                                              .backOrDismiss),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(
                                              dCtx, true),
                                          style:
                                              ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.red),
                                          child: Text(
                                              S
                                                  .of(modalContext)
                                                  .yesCancel,
                                              style: const TextStyle(
                                                  color:
                                                      Colors.white)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      await di
                                          .sl<ChangeTripStatusUseCase>()
                                          .call(
                                            tripId: trip.id,
                                            status: 'canceled',
                                          );
                                      await _storage.remove(
                                          key:
                                              'pending_pricing_trip_id');
                                      if (mounted) {
                                        Navigator.pop(modalCtx);
                                        showToast(
                                            text: S
                                                .of(context)
                                                .tripCancelledSuccessfully,
                                            state:
                                                ToastStates.SUCESS);
                                        DriverHomeCubit.of(context)
                                            .loadHomeData();
                                      }
                                    } catch (_) {}
                                  }
                                },
                          icon: Icon(Icons.cancel_outlined,
                              size: 16, color: Colors.red.shade400),
                          label: Text(
                            S.of(modalContext).cancelPendingTrip,
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 28);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 12,
      size.width,
      size.height - 28,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _KycReviewBanner extends StatelessWidget {
  const _KycReviewBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateTo(context, const DriverDocumentsScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDE7),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.warning.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
                color: AppColors.warning.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                shape: BoxShape.circle),
            child: Icon(Icons.hourglass_top_rounded,
                color: Colors.orange.shade800, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(S.of(context).accountUnderReviewBannerTitle,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                        fontSize: 12)),
                Text(S.of(context).kycRequiredMessage,
                    style: TextStyle(
                        color: Colors.orange.shade700, fontSize: 10.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ])),
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 12, color: Colors.orange.shade700),
        ]),
      ),
    );
  }
}

class _StatItem {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  const _StatItem({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });
}
