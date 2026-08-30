import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/location_helper.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/utils/trip_security_service.dart';
import 'package:car_app/core/utils/chat_channel_helper.dart';
import 'package:car_app/core/widgets/unread_badge.dart';
import 'package:car_app/features/chat/presentation/screens/trip_chat_screen.dart';
import 'package:car_app/features/trips/data/models/trip_model.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_state.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverChatScreenClean extends StatefulWidget {
  const DriverChatScreenClean({super.key});

  @override
  State<DriverChatScreenClean> createState() => _DriverChatScreenCleanState();
}

class _DriverChatScreenCleanState extends State<DriverChatScreenClean>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchChatController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DriverTripsCubit>().loadDriverTrips();
      }
    });
  }

  @override
  void dispose() {
    searchChatController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _makeCall(String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      showToast(
          text: S.of(context).driverPhoneNotAvailable,
          state: ToastStates.WARNING);
      return;
    }
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  String _formatTime(dynamic rawTimestamp) {
    if (rawTimestamp == null) return '';
    DateTime dt;
    if (rawTimestamp is Timestamp) {
      dt = rawTimestamp.toDate();
    } else if (rawTimestamp is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    } else {
      return '';
    }
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return S.current.timeJustNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes} ${S.current.timeMinutesAgo}';
    if (diff.inHours < 24) return DateFormat('hh:mm a').format(dt);
    return DateFormat('dd/MM').format(dt);
  }

  Widget _buildStatusBadge(String? status) {
    String label = S.current.waitingToMove;
    Color color = const Color(0xFF64748B);
    Color bg = const Color(0xFFF1F5F9);

    switch (status) {
      case 'on_the_way':
        label = S.current.onWayToPassenger;
        color = const Color(0xFF2563EB);
        bg = const Color(0xFFEFF6FF);
        break;
      case 'close_to_customer':
        label = S.current.nearPassenger;
        color = const Color(0xFFD97706);
        bg = const Color(0xFFFEF3C7);
        break;
      case 'arrive_customer':
        label = S.current.arrivedPickupLocation;
        color = const Color(0xFF059669);
        bg = const Color(0xFFECFDF5);
        break;
      case 'start':
        label = S.current.tripInProgressStatus;
        color = const Color(0xFF7C3AED);
        bg = const Color(0xFFF5F3FF);
        break;
      default:
        label = S.current.waitingToMove;
        color = const Color(0xFF64748B);
        bg = const Color(0xFFF1F5F9);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverTripsCubit, DriverTripsState>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = DriverTripsCubit.get(context);
        final privateTrips = cubit.TripsListByTypeCurrentPrivete;
        final sharedTrips = cubit.TripsListByTypeCurrentShared;
        final isLoading = state is DriverTripsLoading;

        return Container(
          color: const Color(0xFFF8FAFC),
          child: Column(
            children: [
              // ── Search Field & Tabs Bar Container ──
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Search Form Field
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: searchChatController,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.cairo(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: S.of(context).searchForChat,
                          hintStyle: GoogleFonts.cairo(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          suffixIcon: searchChatController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    searchChatController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Modern Tab Bar
                    Container(
                      height: 42,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF64748B),
                        labelStyle: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: [
                          Tab(
                            text:
                                '${S.of(context).privateTrip} (${privateTrips.length})',
                          ),
                          Tab(
                            text:
                                '${S.of(context).sharedTrip} (${sharedTrips.length})',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── TabBarView Content ──
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTripsChatList(context, privateTrips,
                              isShared: false),
                          _buildTripsChatList(context, sharedTrips,
                              isShared: true),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTripsChatList(BuildContext context, List tripsList,
      {required bool isShared}) {
    final storage = di.sl<LocalStorage>();
    final activeTrip = TripSecurityService.getActiveTrip(storage);

    final List<Trip> trips = tripsList
        .map((t) => t is Trip
            ? t
            : TripModel.fromJson(Map<String, dynamic>.from(t is Map ? t : {})))
        .toList();

    // Ensure active accepted trip is visible in chats list immediately
    if (activeTrip != null) {
      final bool matchesTab = isShared
          ? (activeTrip.type == TripType.shared)
          : (activeTrip.type == TripType.private);
      final bool alreadyExists = trips.any((t) => t.id == activeTrip.id);
      if (matchesTab && !alreadyExists) {
        trips.insert(0, activeTrip);
      }
    }

    final query = searchChatController.text.trim().toLowerCase();
    final filtered = trips.where((t) {
      if (query.isEmpty) return true;
      final from = cleanLocationName(t.fromLocationName).toLowerCase();
      final to = cleanLocationName(t.toLocationName).toLowerCase();
      final creator = t.creator?.name.toLowerCase() ?? '';
      return from.contains(query) ||
          to.contains(query) ||
          creator.contains(query);
    }).toList();

    if (filtered.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await context.read<DriverTripsCubit>().loadDriverTrips();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.55,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    isShared
                        ? FontAwesomeIcons.peopleGroup
                        : FontAwesomeIcons.comments,
                    size: 40,
                    color: AppColors.primary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context).noActiveChatsForTrips,
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  S.of(context).noActiveChatsDesc,
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 1,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    context.read<DriverTripsCubit>().loadDriverTrips();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(S.of(context).refreshList,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<DriverTripsCubit>().loadDriverTrips();
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final Trip trip = filtered[index];
          final passengerName = trip.creator?.name.isNotEmpty == true
              ? trip.creator!.name
              : (isShared
                  ? S.of(context).tripPassengers
                  : S.of(context).passenger);
          final passengerPhone = trip.creator?.phone ?? '';
          final cleanFrom = cleanLocationName(trip.fromLocationName);
          final cleanTo = cleanLocationName(trip.toLocationName);
          final tripFrom =
              cleanFrom.isNotEmpty == true ? cleanFrom : S.of(context).chatFrom;
          final tripTo =
              cleanTo.isNotEmpty == true ? cleanTo : S.of(context).chatTo;
          final passengersList = trip.passengers.map((p) => p.toMap()).toList();
          final price = trip.approvedPrice ?? trip.minimumPrice ?? 0.0;

          final currentDriverId = int.tryParse(di.sl<LocalStorage>().read(key: 'userid')?.toString() ?? '') ?? 0;
          final targetChatId = isShared
              ? ChatChannelHelper.sharedTripGroupChatId(tripId: trip.id)
              : ChatChannelHelper.privateTripChatId(tripId: trip.id, driverId: currentDriverId);

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .doc(targetChatId)
                .snapshots(),
            builder: (context, snapshot) {
              final chatData = snapshot.data?.data();
              final lastMsg = chatData?['last_message']?.toString();
              final lastSender = chatData?['last_sender_name']?.toString();
              final rawTime =
                  chatData?['last_timestamp'] ?? chatData?['updated_at'];
              final timeStr = _formatTime(rawTime);

              void openChat() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TripChatScreenClean(
                      driverName: passengerName,
                      driverPhone: passengerPhone,
                      tripFrom: tripFrom,
                      tripTo: tripTo,
                      tripDatetime: trip.tripDatetime,
                      acceptedPrice: price,
                      tripId: trip.id,
                      offerId: 0,
                      driverId: currentDriverId,
                      chatId: targetChatId,
                      tripType: isShared ? 'shared' : 'private',
                      members: isShared && passengersList.isNotEmpty
                          ? passengersList
                          : [
                              if (trip.creator != null) trip.creator!.toMap(),
                              if (trip.driver != null) trip.driver!.toMap(),
                            ],
                    ),
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: openChat,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Top Header Row: Avatar + Title/Status + Time ──
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              UnreadBadge(
                                chatId: targetChatId,
                                currentUserId: currentDriverId.toString(),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isShared
                                        ? Colors.purple.shade50
                                        : AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isShared
                                          ? Icons.groups_rounded
                                          : Icons.person_rounded,
                                      color: isShared
                                          ? Colors.purple
                                          : AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            passengerName,
                                            style: GoogleFonts.cairo(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: const Color(0xFF0F172A),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isShared &&
                                            passengersList.isNotEmpty) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.purple.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${passengersList.length} ${S.of(context).passengers}',
                                              style: GoogleFonts.cairo(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.purple.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    _buildStatusBadge(trip.onGoingStatus),
                                  ],
                                ),
                              ),
                              if (timeStr.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    timeStr,
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ── Route & Location Summary ──
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFFF1F5F9)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.near_me_rounded,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '$tripFrom ⬅️ $tripTo',
                                    style: GoogleFonts.cairo(
                                      color: const Color(0xFF475569),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (price > 0)
                                  Text(
                                    '${price.toStringAsFixed(1)} ${S.of(context).jod}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF059669),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ── Live Last Message Preview ──
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: lastMsg != null
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 14,
                                  color: lastMsg != null
                                      ? const Color(0xFF2563EB)
                                      : Colors.grey.shade400,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    lastMsg != null
                                        ? '${lastSender != null && lastSender.isNotEmpty ? "$lastSender: " : ""}$lastMsg'
                                        : S.of(context).noMessagesYetTapToChat,
                                    style: GoogleFonts.cairo(
                                      color: lastMsg != null
                                          ? const Color(0xFF1E3A8A)
                                          : Colors.grey.shade500,
                                      fontSize: 12,
                                      fontWeight: lastMsg != null
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── Joined Passengers Private DMs (For Shared Trips) ──
                          if (isShared && trip.passengers.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.people_outline_rounded,
                                          size: 14, color: Colors.purple),
                                      const SizedBox(width: 6),
                                      Text(
                                        'محادثات الركاب المنضمين (خاص)',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ...trip.passengers.map((p) {
                                    final pDmChatId =
                                        ChatChannelHelper.sharedTripDmChatId(
                                            tripId: trip.id,
                                            passengerId: p.id);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 3.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor:
                                                Colors.green.shade100,
                                            child: const Icon(Icons.person,
                                                size: 14,
                                                color: Color(0xFF166534)),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              p.name.isNotEmpty
                                                  ? p.name
                                                  : S.of(context).passenger,
                                              style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    const Color(0xFF1E293B),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDCFCE7),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'منضم للرحلة',
                                              style: GoogleFonts.cairo(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    const Color(0xFF166534),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          UnreadBadge(
                                            chatId: pDmChatId,
                                            currentUserId:
                                                currentDriverId.toString(),
                                            child: SizedBox(
                                              height: 28,
                                              width: 32,
                                              child: IconButton(
                                                style: IconButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.purple.shade50,
                                                  padding: EdgeInsets.zero,
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          TripChatScreenClean(
                                                        driverName: p.name,
                                                        driverPhone: p.phone ?? '',
                                                        tripFrom: tripFrom,
                                                        tripTo: tripTo,
                                                        tripDatetime:
                                                            trip.tripDatetime,
                                                        acceptedPrice: price,
                                                        tripId: trip.id,
                                                        offerId: 0,
                                                        driverId:
                                                            currentDriverId,
                                                        passengerId: p.id,
                                                        chatId: pDmChatId,
                                                        tripType: 'shared',
                                                        isDm: true,
                                                        isInquiry: false,
                                                        isOffersPhase: false,
                                                        members: [
                                                          p.toMap(),
                                                          if (trip.driver !=
                                                              null)
                                                            trip.driver!
                                                                .toMap(),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(
                                                    Icons.chat_outlined,
                                                    size: 15,
                                                    color: Colors.purple),
                                              ),
                                            ),
                                          ),
                                          if (p.phone != null && p.phone!.isNotEmpty) ...[
                                            const SizedBox(width: 4),
                                            SizedBox(
                                              height: 28,
                                              width: 32,
                                              child: IconButton(
                                                style: IconButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFFECFDF5),
                                                  padding: EdgeInsets.zero,
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    _makeCall(p.phone),
                                                icon: const Icon(
                                                    Icons.call_rounded,
                                                    size: 15,
                                                    color: Color(0xFF059669)),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),

                          // ── Action Buttons Row ──
                          Row(
                            children: [
                              // Open Chat Button
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 36,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: openChat,
                                    icon: const Icon(
                                      Icons.chat_rounded,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                    label: Text(
                                      isShared
                                          ? 'الدردشة الجماعية'
                                          : S.of(context).chatTabLabel,
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Quick Tracking Button
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 36,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: AppColors.primary),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (isShared) {
                                        context.push(
                                            AppRoutes.driverOngoingSharedTrip,
                                            extra: trip);
                                      } else {
                                        context.push(
                                            AppRoutes.driverOngoingPrivateTrip,
                                            extra: trip);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.map_rounded,
                                      color: AppColors.primary,
                                      size: 15,
                                    ),
                                    label: Text(
                                      S.of(context).trackingTabLabel,
                                      style: GoogleFonts.cairo(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Direct Call Button
                              if (passengerPhone.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 36,
                                  width: 38,
                                  child: IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFFECFDF5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(
                                            color: Color(0xFFA7F3D0)),
                                      ),
                                    ),
                                    padding: EdgeInsets.zero,
                                    onPressed: () =>
                                        _makeCall(passengerPhone),
                                    icon: const Icon(
                                      Icons.call_rounded,
                                      color: Color(0xFF059669),
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
