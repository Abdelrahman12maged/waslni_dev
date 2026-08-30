import 'dart:io';
import 'package:car_app/core/data/jordan_car_data.dart';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/widgets/searchable_dropdown.dart';
import 'package:car_app/features/auth/domain/entities/driver_signup_initial_data.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:car_app/features/auth/presentation/utils/auth_error_mapper.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:car_app/core/formatters/plate_number_formatter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;

class DriverSignupInfoScreen extends StatefulWidget {
  final DriverSignupInitialData initialData;

  const DriverSignupInfoScreen({super.key, required this.initialData});

  @override
  State<DriverSignupInfoScreen> createState() => _DriverSignupInfoScreenState();
}

class _DriverSignupInfoScreenState extends State<DriverSignupInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _seatsController = TextEditingController();
  final _plateNumberController = TextEditingController();

  String? _selectedCarType;
  String? _selectedCarModel;

  @override
  void initState() {
    super.initState();
    _selectedCarType = widget.initialData.carType;
    _selectedCarModel = widget.initialData.carModel;
    _seatsController.text = widget.initialData.seats ?? '';
    _plateNumberController.text = widget.initialData.plateNumber ?? '';
  }

  DriverSignupInitialData _getCurrentDraft(AuthCubit cubit) {
    return widget.initialData.copyWith(
      carType: _selectedCarType,
      carModel: _selectedCarModel,
      seats: _seatsController.text.trim(),
      plateNumber: _plateNumberController.text.trim(),
      drivingLic: cubit.driverLicenseImage,
      insidePicture: cubit.driverCarInsideImage,
      outsidePicture: cubit.driverCarOutsideImage,
      nationalId: cubit.nationalIdFile,
      criminalRecord: cubit.criminalRecordFile,
      vehicleLicense: cubit.vehicleLicenseDocFile,
    );
  }

  @override
  void dispose() {
    _seatsController.dispose();
    _plateNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: _handleState,
        builder: _buildUI,
      ),
    );
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is SignUpSuccess) {
      Fluttertoast.showToast(
        msg: S.of(context).registrationSuccessful,
        backgroundColor: Colors.green,
        gravity: ToastGravity.TOP,
      );
      // Navigate directly to Driver Home Screen
      context.go(AppRoutes.driverHome);
    } else if (state is SignUpFailure) {
      final errorMsg = AuthErrorMapper.getErrorMessage(
        context,
        errorCode: state.errorCode,
        fallbackMessage: state.message,
      );
      Fluttertoast.showToast(
        msg: errorMsg,
        backgroundColor: Colors.red,
        gravity: ToastGravity.TOP,
      );
    }
  }

  Widget _buildUI(BuildContext context, AuthState state) {
    final cubit = AuthCubit.get(context);
    cubit.driverImage ??= widget.initialData.driverImage;
    cubit.driverLicenseImage ??= widget.initialData.drivingLic;
    cubit.driverCarInsideImage ??= widget.initialData.insidePicture;
    cubit.driverCarOutsideImage ??= widget.initialData.outsidePicture;
    cubit.nationalIdFile ??= widget.initialData.nationalId;
    cubit.criminalRecordFile ??= widget.initialData.criminalRecord;
    cubit.vehicleLicenseDocFile ??= widget.initialData.vehicleLicense;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.pop(_getCurrentDraft(cubit));
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(_getCurrentDraft(cubit)),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // ── Car Type ──────────────────────────────────────────
              Text(S.of(context).typeOfCar,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              SearchableDropdownField(
                label: S.of(context).typeOfCar,
                hint: S.of(context).enterCarType,
                value: _selectedCarType,
                prefixIcon: Icons.directions_car_outlined,
                options: JordanCarData.brands,
                addCustomLabel: S.of(context).addCarType,
                validator: (v) {
                  if (v == null || v.isEmpty) return S.of(context).carTypeCantBeEmpty;
                  return null;
                },
                onSelected: (val) => setState(() {
                  _selectedCarType = val;
                  _selectedCarModel = null; // reset model when brand changes
                }),
              ),
              const SizedBox(height: 20),

              // ── Car Model (depends on brand) ───────────────────────
              Text(S.of(context).modelOfCar,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              SearchableDropdownField(
                label: S.of(context).modelOfCar,
                hint: _selectedCarType == null
                    ? S.of(context).selectCarTypeFirst
                    : S.of(context).enterCarModel,
                value: _selectedCarModel,
                prefixIcon: Icons.directions_car_filled_outlined,
                options: JordanCarData.modelsFor(_selectedCarType),
                addCustomLabel: S.of(context).addCarModel,
                validator: (v) {
                  if (v == null || v.isEmpty) return S.of(context).carModelCantBeEmpty;
                  return null;
                },
                onSelected: (val) => setState(() => _selectedCarModel = val),
              ),
              const SizedBox(height: 20),

              // ── Number of Seats ───────────────────────────────────
              Text(S.of(context).numberOfSeats,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              _buildSeatsField(context),
              const SizedBox(height: 20),

              // ── Plate Number ──────────────────────────────────────
              Text(S.of(context).plateNumber,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              _buildPlateNumberField(context),
              const SizedBox(height: 28),

              // ── Vehicle Photos (Camera Only) ──────────────────────
              _buildImageSection(context, cubit),
              const SizedBox(height: 30),

              // ── KYC Official Documents (Images or PDFs) ───────────
              _buildKycDocumentsSection(context, cubit),
              const SizedBox(height: 35),

              // ── Submit ─────────────────────────────────────────────
              state is SignUpLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () => _submitSignup(context, cubit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        S.of(context).loginsignupbutton,
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Field builders ───────────────────────────────────────────────────────

  Widget _buildSeatsField(BuildContext context) {
    return TextFormField(
      controller: _seatsController,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(
        label: S.of(context).enterNumberOfSeats,
        icon: Icons.person_outline_rounded,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return S.of(context).numberOfSeatsCantBeEmpty;
        }
        return null;
      },
    );
  }

  Widget _buildPlateNumberField(BuildContext context) {
    return TextFormField(
      controller: _plateNumberController,
      keyboardType: TextInputType.number,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      inputFormatters: [PlateNumberFormatter()],
      decoration: _inputDecoration(
        label: S.of(context).enterPlateNumber,
        icon: Icons.pin_outlined,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return S.of(context).plateNumberCantBeEmpty;
        }
        // Must match NN - NNNNN pattern
        if (!RegExp(r'^\d{2} - \d+$').hasMatch(value)) {
          return S.of(context).plateNumberInvalidFormat;
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.accent),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  // ── Vehicle Image Section (Camera ONLY for car & driving license) ────────

  Widget _buildImageSection(BuildContext context, AuthCubit cubit) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (prev, cur) =>
          cur is DriverLicenseImagePickedSuccess ||
          cur is DriverCarInsideImagePickedSuccess ||
          cur is DriverCarOutsideImagePickedSuccess ||
          cur is DriverInfoImagePickedFailure,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Driving License — camera only
          Text(S.of(context).drivingLicense,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          _CameraOnlyImageBox(
            file: cubit.driverLicenseImage,
            icon: Icons.credit_card_outlined,
            hint: S.of(context).attachPhoto,
            onTap: () => cubit.getDriverInfoImages(0, source: ImageSource.camera),
          ),
          const SizedBox(height: 20),

          // Car Interior — camera only
          Text(S.of(context).carInterior,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          _CameraOnlyImageBox(
            file: cubit.driverCarInsideImage,
            icon: Icons.airline_seat_recline_normal_outlined,
            hint: S.of(context).attachPhoto,
            onTap: () => cubit.getDriverInfoImages(1, source: ImageSource.camera),
          ),
          const SizedBox(height: 20),

          // Car Exterior — camera only
          Text(S.of(context).carExterior,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          _CameraOnlyImageBox(
            file: cubit.driverCarOutsideImage,
            icon: Icons.directions_car_outlined,
            hint: S.of(context).attachPhoto,
            onTap: () => cubit.getDriverInfoImages(2, source: ImageSource.camera),
          ),
        ],
      ),
    );
  }

  // ── Official KYC Documents Section ────────────────────────────────────────

  Widget _buildKycDocumentsSection(BuildContext context, AuthCubit cubit) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (prev, cur) =>
          cur is DriverDocumentPickedSuccess ||
          cur is DriverDocumentRemoved,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  S.of(context).officialDocuments,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. National ID
          _DocumentUploadCard(
            title: S.of(context).nationalIdDocument,
            icon: Icons.badge_outlined,
            file: cubit.nationalIdFile,
            onPick: () => cubit.pickDriverDocument('national_id'),
            onRemove: () => cubit.removeDriverDocument('national_id'),
          ),
          const SizedBox(height: 16),

          // 2. Criminal Record Certificate
          _DocumentUploadCard(
            title: S.of(context).criminalRecordDocument,
            icon: Icons.verified_outlined,
            file: cubit.criminalRecordFile,
            onPick: () => cubit.pickDriverDocument('criminal_record'),
            onRemove: () => cubit.removeDriverDocument('criminal_record'),
          ),
          const SizedBox(height: 16),

          // 3. Vehicle License
          _DocumentUploadCard(
            title: S.of(context).vehicleLicenseDocument,
            icon: Icons.directions_car_filled_outlined,
            file: cubit.vehicleLicenseDocFile,
            onPick: () => cubit.pickDriverDocument('vehicle_license'),
            onRemove: () => cubit.removeDriverDocument('vehicle_license'),
          ),
        ],
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  void _submitSignup(BuildContext context, AuthCubit cubit) {
    if (cubit.driverLicenseImage == null) {
      Fluttertoast.showToast(
          msg: S.of(context).licenseImageCantBeEmpty,
          backgroundColor: Colors.orange);
      return;
    }
    if (cubit.driverCarInsideImage == null) {
      Fluttertoast.showToast(
          msg: S.of(context).carInsideImageCantBeEmpty,
          backgroundColor: Colors.orange);
      return;
    }
    if (cubit.driverCarOutsideImage == null) {
      Fluttertoast.showToast(
          msg: S.of(context).carOutsideImageCantBeEmpty,
          backgroundColor: Colors.orange);
      return;
    }

    // Official documents validation
    if (cubit.nationalIdFile == null) {
      Fluttertoast.showToast(
          msg: S.of(context).nationalIdCantBeEmpty,
          backgroundColor: Colors.orange);
      return;
    }
    if (cubit.criminalRecordFile == null) {
      Fluttertoast.showToast(
          msg: S.of(context).criminalRecordCantBeEmpty,
          backgroundColor: Colors.orange);
      return;
    }
    if (cubit.vehicleLicenseDocFile == null) {
      Fluttertoast.showToast(
          msg: S.of(context).vehicleLicenseCantBeEmpty,
          backgroundColor: Colors.orange);
      return;
    }

    if (_formKey.currentState!.validate()) {
      final storage = sl<LocalStorage>();
      final language = storage.read(key: 'lang') as String? ?? 'en';
      storage.saveString(key: 'usertype', value: 'driver');

      cubit.signUp(
        name: widget.initialData.name,
        mobile: widget.initialData.mobile,
        password: widget.initialData.password,
        gender: 'male',
        userType: 'driver',
        language: language,
        profilePicture: widget.initialData.driverImage ?? cubit.driverImage,
        carType: _selectedCarType ?? '',
        seats: _seatsController.text.trim(),
        carModel: _selectedCarModel ?? '',
        plateNumber: _plateNumberController.text.trim(),
        drivingLic: cubit.driverLicenseImage,
        insidePicture: cubit.driverCarInsideImage,
        outsidePicture: cubit.driverCarOutsideImage,
      );
    }
  }
}

// ── Document Upload Card (For Image & PDF) ───────────────────────────────────

class _DocumentUploadCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final File? file;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _DocumentUploadCard({
    required this.title,
    required this.icon,
    required this.file,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = file?.path.split('/').last.split('\\').last;
    final isPdf = fileName?.toLowerCase().endsWith('.pdf') ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: file != null ? AppColors.primary : Colors.grey.shade300,
          width: file != null ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              if (file != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 13, color: Colors.green.shade700),
                      const SizedBox(width: 4),
                      Text(
                        S.of(context).fileSelected,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // File selection box
          if (file == null)
            GestureDetector(
              onTap: onPick,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      S.of(context).pdfOrImageAllowed,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    isPdf ? Icons.picture_as_pdf_rounded : Icons.image_outlined,
                    color: isPdf ? Colors.red.shade700 : AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      fileName ?? '',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz, color: AppColors.primary, size: 20),
                    tooltip: S.of(context).replaceDocument,
                    onPressed: onPick,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 18),
                    tooltip: S.of(context).removeFile,
                    onPressed: onRemove,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Camera-Only Image Box ──────────────────────────────────────────────────────

class _CameraOnlyImageBox extends StatelessWidget {
  final File? file;
  final IconData icon;
  final String hint;
  final VoidCallback onTap;

  const _CameraOnlyImageBox({
    required this.file,
    required this.icon,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(
            color: file != null ? AppColors.primary : Colors.grey.shade400,
            width: file != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: file != null ? null : Colors.grey.shade50,
        ),
        child: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt_rounded,
                        color: AppColors.primary, size: 36),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hint,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    S.of(context).cameraOnly,
                    style: TextStyle(
                        color: AppColors.primary.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(file!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity),
                  ),
                  // Retake button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
