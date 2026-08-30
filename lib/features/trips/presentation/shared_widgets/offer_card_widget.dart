// import 'package:car_app/features/trips/domain/entities/offer.dart';
// import 'package:car_app/generated/l10n.dart';
// import 'package:flutter/material.dart';

// /// Reusable card for displaying a driver's offer.
// /// Used in both passenger (view offers) and driver (view their own offer) screens.
// class OfferCardWidget extends StatelessWidget {
//   const OfferCardWidget({
//     super.key,
//     required this.offer,
//     this.onAccept,
//     this.onReject,
//     this.isPassengerView = true,
//   });

//   final Offer offer;

//   /// Callback when the passenger accepts this offer.
//   final VoidCallback? onAccept;

//   /// Callback when the passenger rejects this offer.
//   final VoidCallback? onReject;

//   /// If true: shows accept/reject buttons (passenger view).
//   /// If false: shows status only (driver view).
//   final bool isPassengerView;

//   @override
//   Widget build(BuildContext context) {
//     final driverName =
//         offer.driver?.name.isNotEmpty == true ? offer.driver!.name : S.of(context).chatDriver;

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Header ─────────────────────────────────────────────────
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 22,
//                   backgroundColor: Colors.blue.shade50,
//                   child: const Icon(Icons.person, color: Colors.blue),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         driverName,
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 15),
//                       ),
//                       if (offer.driver?.phone != null && offer.driver!.phone!.isNotEmpty)
//                         Text(
//                           offer.driver!.phone!,
//                           style: const TextStyle(
//                               fontSize: 12, color: Colors.grey),
//                         ),
//                     ],
//                   ),
//                 ),
//                 // Price
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       '${offer.price.toStringAsFixed(0)} ₪',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                     Text(S.of(context).proposedPrice,
//                         style: const TextStyle(fontSize: 10, color: Colors.grey)),
//                   ],
//                 ),
//               ],
//             ),

//             // ── Status badge ────────────────────────────────────────────
//             const SizedBox(height: 12),
//             _OfferStatusBadge(status: offer.status),

//             // ── Actions (passenger view, pending offers only) ────────────
//             if (isPassengerView && offer.isPending) ...[
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: onReject,
//                       icon: const Icon(Icons.close, size: 16),
//                       label: Text(S.of(context).reject),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: Colors.red,
//                         side: const BorderSide(color: Colors.red),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: onAccept,
//                       icon: const Icon(Icons.check, size: 16),
//                       label: Text(S.of(context).accept),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _OfferStatusBadge extends StatelessWidget {
//   const _OfferStatusBadge({required this.status});
//   final OfferStatus status;

//   @override
//   Widget build(BuildContext context) {
//     final (label, color) = switch (status) {
//       OfferStatus.pending => (S.of(context).offerStatusPending, Colors.orange),
//       OfferStatus.accepted => (S.of(context).offerStatusAccepted, Colors.green),
//       OfferStatus.rejected => (S.of(context).offerStatusRejected, Colors.red),
//       OfferStatus.expired => ('منتهي الصلاحية', Colors.grey),
//     };

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.12),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(label,
//           style: TextStyle(
//               color: color, fontSize: 12, fontWeight: FontWeight.bold)),
//     );
//   }
// }
