import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/features/driver_documents/presentation/cubit/driver_documents_cubit.dart';
import 'package:car_app/features/driver_documents/presentation/widgets/driver_documents_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver Documents Screen
// ─────────────────────────────────────────────────────────────────────────────
class DriverDocumentsScreen extends StatelessWidget {
  const DriverDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DriverDocumentsCubit>(
      create: (_) => sl<DriverDocumentsCubit>()..loadDocuments(),
      child: const DriverDocumentsView(),
    );
  }
}
