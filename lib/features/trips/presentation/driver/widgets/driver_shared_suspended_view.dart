import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/trips/domain/entities/offer.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_state.dart';
import 'package:car_app/features/trips/presentation/shared_widgets/trip_details_screen_content.dart';
import 'package:car_app/generated/l10n.dart';

class DriverSharedSuspendedView extends StatefulWidget {
  final Trip trip;

  const DriverSharedSuspendedView({
    super.key,
    required this.trip,
  });

  @override
  State<DriverSharedSuspendedView> createState() =>
      _DriverSharedSuspendedViewState();
}

class _DriverSharedSuspendedViewState extends State<DriverSharedSuspendedView> {
  bool isLoading = true;
  List offersList = [];
  Map acceptedOffer = {};

  void _passState(newOffersList, newAcceptedOffer) {
    if (!mounted) return;
    setState(() {
      isLoading = false;
      offersList = newOffersList ?? [];
      acceptedOffer = newAcceptedOffer is Map ? newAcceptedOffer : {};
    });
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          S.of(context).cancelTrip,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          S.of(context).areYouSure,
          style: GoogleFonts.cairo(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel,
                style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              DriverTripsCubit.get(context).changeTripStatus(
                stoploading: () {
                  if (mounted) setState(() => isLoading = false);
                },
                id: widget.trip.id.toString(),
                status: 'canceled',
                PassState: _passState,
              );
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).cancelTrip,
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverTripsCubit, DriverTripsState>(
      listener: (context, state) {},
      bloc: DriverTripsCubit.get(context)
        ..getOffersByTripId(
          stoploading: _passState,
          id: widget.trip.id.toString(),
          isLoading: isLoading,
        ),
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF1E293B), size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              S.of(context).suspendedTrip,
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          body: TripDetailsScreenContent(
            trip: widget.trip,
            isDriver: true,
            bottomAction: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side:
                        const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.cancel_outlined,
                      color: Color(0xFFEF4444), size: 20),
                  label: Text(
                    S.of(context).cancelTrip,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
                if (offersList.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    S.of(context).offersList,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: offersList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final rawOffer = offersList[index];
                      final Offer offer = rawOffer is Offer
                          ? rawOffer
                          : Offer.fromMap(Map<String, dynamic>.from(
                              rawOffer is Map ? rawOffer : {}));
                      final isAccepted = offer.status == OfferStatus.accepted;
                      final isRejected = offer.status == OfferStatus.rejected;
                      final price = offer.price > 0
                          ? offer.price.toStringAsFixed(2)
                          : (widget.trip.approvedPrice?.toStringAsFixed(2) ??
                              widget.trip.maximumPrice.toStringAsFixed(2));

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isAccepted
                                ? Colors.green
                                : (isRejected
                                    ? Colors.red
                                    : Colors.grey.shade300),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  offer.creator?.name.isNotEmpty == true
                                      ? offer.creator!.name
                                      : S.of(context).passenger,
                                  style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                Text(
                                  '$price ${S.of(context).jod}',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            if (offer.status == OfferStatus.pending) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        DriverTripsCubit.get(context)
                                            .changeOfferStatus(
                                          id: offer.id,
                                          status: 'accepted',
                                          PassState: _passState,
                                          stoploading: () {
                                            if (mounted) {
                                              setState(
                                                  () => isLoading = false);
                                            }
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF10B981),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      child: Text(S.of(context).acceptOffer,
                                          style: GoogleFonts.cairo(
                                              color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        DriverTripsCubit.get(context)
                                            .changeOfferStatus(
                                          id: offer.id,
                                          status: 'rejected',
                                          PassState: _passState,
                                          stoploading: () {
                                            if (mounted) {
                                              setState(
                                                  () => isLoading = false);
                                            }
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFEF4444),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      child: Text(S.of(context).rejectOffer,
                                          style: GoogleFonts.cairo(
                                              color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
