import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/rating_prompt_helper.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/ratings/presentation/cubit/ratings_cubit.dart';
import 'package:car_app/features/ratings/presentation/cubit/ratings_state.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TripRatingScreen extends StatelessWidget {
  final int tripId;
  final int targetUserId;
  final String targetUserName;
  final bool isDriverRatingPassenger;
  final int? initialStars;
  final String? initialComment;
  final bool isEdit;

  const TripRatingScreen({
    super.key,
    required this.tripId,
    required this.targetUserId,
    this.targetUserName = '',
    this.isDriverRatingPassenger = false,
    this.initialStars,
    this.initialComment,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RatingsCubit>(),
      child: _TripRatingScreenContent(
        tripId: tripId,
        targetUserId: targetUserId,
        targetUserName: targetUserName,
        isDriverRatingPassenger: isDriverRatingPassenger,
        initialStars: initialStars,
        initialComment: initialComment,
        isEdit: isEdit,
      ),
    );
  }
}

class _TripRatingScreenContent extends StatefulWidget {
  final int tripId;
  final int targetUserId;
  final String targetUserName;
  final bool isDriverRatingPassenger;
  final int? initialStars;
  final String? initialComment;
  final bool isEdit;

  const _TripRatingScreenContent({
    required this.tripId,
    required this.targetUserId,
    required this.targetUserName,
    required this.isDriverRatingPassenger,
    this.initialStars,
    this.initialComment,
    required this.isEdit,
  });

  @override
  State<_TripRatingScreenContent> createState() => _TripRatingScreenContentState();
}

class _TripRatingScreenContentState extends State<_TripRatingScreenContent> {
  late double _rating;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _rating = (widget.initialStars ?? 5).toDouble();
    _commentController = TextEditingController(text: widget.initialComment ?? '');
    // Immediately dismiss rating dialog trigger so returning to home will not show a dialog
    RatingPromptHelper.dismissTripRating(widget.tripId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitRating(BuildContext context) {
    if (widget.isDriverRatingPassenger) {
      showToast(
        text: S.of(context).driverRatesPassengerNotSupported,
        state: ToastStates.WARNING,
      );
      return;
    }

    final stars = _rating.round().clamp(1, 5);
    final comment = _commentController.text.trim();

    RatingsCubit.get(context).submitRating(
      tripId: widget.tripId,
      stars: stars,
      comment: comment.isNotEmpty ? comment : null,
      ratedUserId: widget.targetUserId > 0 ? widget.targetUserId : null,
      isEdit: widget.isEdit,
    );
  }

  void _navigateHome() {
    RatingPromptHelper.dismissTripRating(widget.tripId);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(widget.isDriverRatingPassenger ? AppRoutes.driverHome : AppRoutes.passengerHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final displayName = widget.targetUserName.isNotEmpty
        ? widget.targetUserName
        : (widget.isDriverRatingPassenger ? s.passenger : s.driver);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _navigateHome();
      },
      child: BlocConsumer<RatingsCubit, RatingsState>(
        listener: (context, state) {
          if (state is RatingSubmitSuccess) {
            RatingPromptHelper.markTripRated(widget.tripId);
            showToast(
              text: widget.isEdit ? s.ratingUpdateSuccess : s.ratingSubmitSuccess,
              state: ToastStates.SUCESS,
            );
            _navigateHome();
          } else if (state is RatingSubmitError) {
            final errorMsg = RatingsCubit.mapErrorCode(context, state.errorCode, state.message);
            showToast(
              text: errorMsg,
              state: ToastStates.ERROR,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is RatingSubmitting;

          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FD),
            appBar: AppBar(
              title: Text(
                widget.isEdit ? s.editRatingBtn : s.ratingScreenTitle,
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: isLoading ? null : _navigateHome,
              ),
              actions: [
                if (!widget.isEdit && !widget.isDriverRatingPassenger)
                  TextButton(
                    onPressed: isLoading ? null : _navigateHome,
                    child: Text(
                      s.skipRating,
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  // Avatar with Badge
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                      border: Border.all(color: AppColors.primary, width: 2.5),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 55,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Target User Name
                  Text(
                    displayName,
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Prompt question
                  Text(
                    s.rateYourExperienceWith(displayName),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Rating Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (widget.isDriverRatingPassenger) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.amber.shade800),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    s.driverRatesPassengerNotSupported,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Interactive Stars Bar
                        PannableRatingBar(
                          rate: _rating,
                          items: List.generate(
                            5,
                            (index) => const RatingWidget(
                              selectedColor: Colors.amber,
                              unSelectedColor: Color(0xFFE0E0E0),
                              child: Icon(
                                Icons.star_rounded,
                                size: 44,
                              ),
                            ),
                          ),
                          onChanged: widget.isDriverRatingPassenger
                              ? null
                              : (value) {
                                  setState(() {
                                    _rating = value.clamp(1.0, 5.0);
                                  });
                                },
                        ),
                        const SizedBox(height: 12),

                        // Numerical Stars Display
                        Text(
                          '${_rating.round()} / 5',
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Comment Input Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _commentController,
                      maxLines: 4,
                      maxLength: 1000,
                      enabled: !widget.isDriverRatingPassenger && !isLoading,
                      style: GoogleFonts.cairo(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: s.ratingCommentHint,
                        hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400, fontSize: 13),
                        contentPadding: const EdgeInsets.all(16),
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 24-hour edit note
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        s.ratingEditWindowNote,
                        style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Submit / Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (isLoading || widget.isDriverRatingPassenger)
                          ? null
                          : () => _submitRating(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.isEdit ? s.updateRatingBtn : s.submitRatingBtn,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
