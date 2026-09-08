import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/driver_documents/domain/entities/driver_account_status.dart';
import 'package:car_app/features/driver_documents/domain/entities/driver_document.dart';
import 'package:car_app/features/driver_documents/presentation/cubit/driver_documents_cubit.dart';
import 'package:car_app/features/driver_documents/presentation/cubit/driver_documents_state.dart';
import 'package:car_app/generated/l10n.dart';

class DriverDocumentsView extends StatelessWidget {
  const DriverDocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).myDocuments),
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<DriverDocumentsCubit, DriverDocumentsState>(
        listener: _handleListener,
        builder: _buildBody,
      ),
    );
  }

  void _handleListener(BuildContext context, DriverDocumentsState state) {
    if (state is DriverDocumentsUploadSuccess) {
      Fluttertoast.showToast(
        msg: S.of(context).documentUploadSuccess,
        backgroundColor: Colors.green,
        gravity: ToastGravity.TOP,
      );
    } else if (state is DriverDocumentsUploadError) {
      Fluttertoast.showToast(
        msg: state.message,
        backgroundColor: Colors.red,
        gravity: ToastGravity.TOP,
      );
    }
  }

  Widget _buildBody(BuildContext context, DriverDocumentsState state) {
    final cubit = DriverDocumentsCubit.of(context);
    final status = cubit.currentStatus;

    if (state is DriverDocumentsLoading && status == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state is DriverDocumentsError && status == null) {
      return _ErrorView(message: state.message, onRetry: cubit.loadDocuments);
    }

    final isUploading = state is DriverDocumentsUploading;

    return RefreshIndicator(
      onRefresh: cubit.loadDocuments,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (status != null) ...[
            _AccountStatusBanner(account: status.account),
            const SizedBox(height: 20),
            _DocumentCard(
              docType: 'national_id',
              document: status.documentFor('national_id'),
              cubit: cubit,
              isAccountActive: status.account.isActive,
            ),
            const SizedBox(height: 12),
            _DocumentCard(
              docType: 'criminal_record',
              document: status.documentFor('criminal_record'),
              cubit: cubit,
              isAccountActive: status.account.isActive,
            ),
            const SizedBox(height: 12),
            _DocumentCard(
              docType: 'vehicle_license',
              document: status.documentFor('vehicle_license'),
              cubit: cubit,
              isAccountActive: status.account.isActive,
            ),
          ],
          const SizedBox(height: 24),
          BlocBuilder<DriverDocumentsCubit, DriverDocumentsState>(
            builder: (ctx, _) {
              final hasPending = cubit.hasPendingFiles;
              return SizedBox(
                width: double.infinity,
                child: isUploading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary))
                    : ElevatedButton.icon(
                        onPressed: hasPending ? () => _upload(ctx) : null,
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: Text(S.of(ctx).uploadSelectedDocuments),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _upload(BuildContext context) {
    final cubit = DriverDocumentsCubit.of(context);
    if (!cubit.hasPendingFiles) {
      Fluttertoast.showToast(
        msg: S.of(context).atLeastOneDocumentRequired,
        backgroundColor: Colors.orange,
        gravity: ToastGravity.TOP,
      );
      return;
    }
    cubit.uploadPendingDocuments();
  }
}

class _AccountStatusBanner extends StatelessWidget {
  final DriverAccountStatus account;
  const _AccountStatusBanner({required this.account});

  String _docLabel(BuildContext context, String type) {
    switch (type) {
      case 'national_id':
        return S.of(context).nationalIdDocument;
      case 'criminal_record':
        return S.of(context).criminalRecordDocument;
      case 'vehicle_license':
        return S.of(context).vehicleLicenseDocument;
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = account.isActive;
    final hasMissing = account.missingDocuments.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.shade50
            : (hasMissing ? Colors.orange.shade50 : Colors.amber.shade50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? Colors.green.shade300
              : (hasMissing ? Colors.orange.shade300 : Colors.amber.shade400),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isActive
                    ? Icons.verified_user
                    : (hasMissing
                        ? Icons.warning_amber_rounded
                        : Icons.hourglass_top_rounded),
                color: isActive
                    ? Colors.green.shade600
                    : (hasMissing
                        ? Colors.orange.shade800
                        : Colors.amber.shade800),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isActive
                          ? S.of(context).accountStatusActive
                          : S.of(context).accountStatusUnderReview,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? Colors.green.shade700
                            : (hasMissing
                                ? Colors.orange.shade900
                                : Colors.amber.shade900),
                        fontSize: 14,
                      ),
                    ),
                    if (account.message.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        account.message,
                        style: TextStyle(
                          color: isActive
                              ? Colors.green.shade700
                              : (hasMissing
                                  ? Colors.orange.shade800
                                  : Colors.amber.shade800),
                          fontSize: 12,
                        ),
                      ),
                    ] else if (isActive) ...[
                      const SizedBox(height: 4),
                      Text(
                        S.of(context).accountActiveDocsLockedMessage,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ] else if (!hasMissing) ...[
                      const SizedBox(height: 4),
                      Text(
                        S.of(context).allDocumentsUploadedReview,
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!isActive && hasMissing) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.orange.shade200),
            const SizedBox(height: 8),
            Text(
              S.of(context).missingDocumentsRequired,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade900,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: account.missingDocuments.map((docType) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close_rounded,
                          size: 13, color: Colors.red.shade700),
                      const SizedBox(width: 4),
                      Text(
                        _docLabel(context, docType),
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final String docType;
  final DriverDocument? document;
  final DriverDocumentsCubit cubit;
  final bool isAccountActive;

  const _DocumentCard({
    required this.docType,
    required this.document,
    required this.cubit,
    this.isAccountActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverDocumentsCubit, DriverDocumentsState>(
      buildWhen: (p, c) =>
          (c is DocumentFilePicked && c.type == docType) ||
          c is DriverDocumentsLoaded ||
          c is DriverDocumentsUploadSuccess,
      builder: (ctx, state) {
        File? pendingFile;
        switch (docType) {
          case 'national_id':
            pendingFile = cubit.pendingNationalId;
            break;
          case 'criminal_record':
            pendingFile = cubit.pendingCriminalRecord;
            break;
          case 'vehicle_license':
            pendingFile = cubit.pendingVehicleLicense;
            break;
        }

        final isUploaded = document?.uploaded ?? false;
        final isExpired = document?.isExpired ?? false;
        final isLocked = isAccountActive && isUploaded;
        final label = document?.typeLabel ?? _fallbackLabel(context, docType);

        return Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _borderColor(
                  isUploaded, isExpired, pendingFile != null, isLocked),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _docIcon(docType),
                      color: AppColors.accent,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _StatusChip(
                      isUploaded: isUploaded,
                      isExpired: isExpired,
                      hasPending: pendingFile != null,
                      isLocked: isLocked,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (isUploaded && document != null) ...[
                  if (document!.originalName != null)
                    _InfoRow(
                      icon: Icons.attach_file,
                      text: document!.originalName!,
                    ),
                  if (document!.uploadedAt != null)
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      text:
                          '${S.of(context).uploadedAt}: ${_formatDate(document!.uploadedAt!)}',
                    ),
                ],
                if (pendingFile != null) ...[
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.check_circle_outline,
                    text:
                        '${S.of(context).fileSelected}: ${pendingFile.path.split('/').last.split('\\').last}',
                    color: AppColors.primary,
                  ),
                ],
                const SizedBox(height: 12),
                if (isLocked)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline,
                            size: 16, color: Colors.green.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            S.of(context).lockedDocumentNotice,
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => cubit.pickDocument(docType),
                      icon: Icon(
                        isUploaded || pendingFile != null
                            ? Icons.swap_horiz
                            : Icons.upload_file_outlined,
                        size: 18,
                      ),
                      label: Text(
                        isUploaded || pendingFile != null
                            ? S.of(context).replaceDocument
                            : S.of(context).uploadDocument,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _borderColor(
      bool isUploaded, bool isExpired, bool hasPending, bool isLocked) {
    if (hasPending) return AppColors.primary;
    if (isExpired) return Colors.red.shade300;
    if (isLocked) return Colors.green.shade400;
    if (isUploaded) return Colors.green.shade300;
    return Colors.grey.shade300;
  }

  IconData _docIcon(String type) {
    switch (type) {
      case 'national_id':
        return Icons.badge_outlined;
      case 'criminal_record':
        return Icons.verified_outlined;
      case 'vehicle_license':
        return Icons.directions_car_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  String _fallbackLabel(BuildContext context, String type) {
    switch (type) {
      case 'national_id':
        return S.of(context).docNationalId;
      case 'criminal_record':
        return S.of(context).docNonCriminal;
      case 'vehicle_license':
        return S.of(context).docVehicleLicense;
      default:
        return type;
    }
  }

  String _formatDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);
}

class _StatusChip extends StatelessWidget {
  final bool isUploaded;
  final bool isExpired;
  final bool hasPending;
  final bool isLocked;

  const _StatusChip({
    required this.isUploaded,
    required this.isExpired,
    required this.hasPending,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    if (hasPending) {
      return _chip(context, S.of(context).fileSelected, Colors.blue.shade700,
          Colors.blue.shade50, Icons.pending_outlined);
    }
    if (isExpired) {
      return _chip(
          context,
          S.of(context).documentExpired,
          Colors.red.shade700,
          Colors.red.shade50,
          Icons.warning_amber_outlined);
    }
    if (isLocked) {
      return _chip(
          context,
          S.of(context).documentApprovedLocked,
          Colors.green.shade800,
          Colors.green.shade100,
          Icons.lock_outline);
    }
    if (isUploaded) {
      return _chip(
          context,
          S.of(context).documentUploaded,
          Colors.green.shade700,
          Colors.green.shade50,
          Icons.check_circle_outline);
    }
    return _chip(context, S.of(context).documentMissing,
        Colors.orange.shade700, Colors.orange.shade50, Icons.upload_outlined);
  }

  Widget _chip(BuildContext context, String label, Color fg, Color bg,
      IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoRow({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? Colors.grey.shade500),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
