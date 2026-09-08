import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import 'package:car_app/core/resources/images_manager.dart' show ImagesManager;
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/image_picker_dialog.dart';
import 'package:car_app/features/auth/domain/entities/driver_signup_initial_data.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:car_app/features/auth/presentation/utils/auth_error_mapper.dart';
import 'package:car_app/features/legal/presentation/screens/agree_terms_screen.dart';
import 'package:car_app/generated/l10n.dart';

class SignupDriverView extends StatefulWidget {
  const SignupDriverView({super.key});

  @override
  State<SignupDriverView> createState() => _SignupDriverViewState();
}

class _SignupDriverViewState extends State<SignupDriverView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _agreeToTerms = false;
  DriverSignupInitialData? _draftData;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is DriverImagePickedFailure) {
          final errorMsg = AuthErrorMapper.getErrorMessage(
            context,
            errorCode: state.errorCode,
            fallbackMessage: state.message,
          );
          Fluttertoast.showToast(msg: errorMsg, backgroundColor: Colors.red);
        }
      },
      builder: (context, state) {
        final cubit = AuthCubit.get(context);
        if (_draftData?.driverImage != null && cubit.driverImage == null) {
          cubit.driverImage = _draftData!.driverImage;
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.pop(),
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
                  Center(
                    child: BlocBuilder<AuthCubit, AuthState>(
                      buildWhen: (prev, cur) =>
                          cur is DriverImagePickedSuccess ||
                          cur is DriverImagePickedFailure,
                      builder: (context, _) => GestureDetector(
                        onTap: () {
                          showImagePickerOptions(
                            context,
                            onSourceSelected: (source) =>
                                cubit.getDriverImage(source: source),
                          );
                        },
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.accent, width: 2),
                          ),
                          child: ClipOval(
                            child: cubit.driverImage == null
                                ? Image.asset(ImagesManager.changePicture,
                                    fit: BoxFit.scaleDown)
                                : Image.file(cubit.driverImage!,
                                    fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Text(S.of(context).fullName),
                  const SizedBox(height: 5.0),
                  _buildNameField(context),
                  const SizedBox(height: 20.0),
                  Text(S.of(context).mobileNumber),
                  const SizedBox(height: 5.0),
                  _buildMobileField(context),
                  const SizedBox(height: 20.0),
                  Text(S.of(context).password),
                  const SizedBox(height: 5.0),
                  _buildPasswordField(context, cubit),
                  const SizedBox(height: 12.0),
                  _buildTermsRow(context),
                  const SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: () => _goToNextStep(context, cubit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      S.of(context).loginsignupbutton,
                      style:
                          const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  _buildLoginRow(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNameField(BuildContext context) {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        labelText: S.of(context).enterYourName,
        prefixIcon:
            const Icon(Icons.person_outline_rounded, color: AppColors.accent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return S.of(context).yourNameCantBeEmpty;
        } else if (value.length < 6) {
          return S.of(context).nameShouldBe6Chars;
        }
        return null;
      },
    );
  }

  Widget _buildMobileField(BuildContext context) {
    return TextFormField(
      controller: _mobileController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: S.of(context).mobileNumber,
        prefixIcon:
            const Icon(Icons.local_phone_outlined, color: AppColors.accent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return S.of(context).yourMobileNumberCantBeEmpty;
        } else if (value.length != 10) {
          return S.of(context).yourNumberShouldBe10Digits;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(BuildContext context, AuthCubit cubit) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (prev, cur) => cur is PasswordVisibilityChanged,
      builder: (context, _) => TextFormField(
        controller: _passwordController,
        obscureText: cubit.isPasswordHidden,
        decoration: InputDecoration(
          labelText: S.of(context).enterYourPassword,
          prefixIcon:
              const Icon(Icons.lock_outline_rounded, color: AppColors.accent),
          suffixIcon: IconButton(
            icon: Icon(
              cubit.isPasswordHidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.accent,
            ),
            onPressed: cubit.togglePasswordVisibility,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return S.of(context).yourPasswordCantBeEmpty;
          } else if (value.length < 6) {
            return S.of(context).passwordShouldBe6Chars;
          } else if (!value.contains(RegExp(r'[A-Z]'))) {
            return S.of(context).passwordShouldContainCapital;
          } else if (!value.contains(RegExp(r'[a-z]'))) {
            return S.of(context).passwordShouldContainSmall;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTermsRow(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _agreeToTerms,
          activeColor: AppColors.primary,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
        ),
        Text(S.of(context).usersignupagree),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AgreeTermsScreen()),
          ),
          child: Text(
            S.of(context).userlayoutsettingsterms,
            style: const TextStyle(
              color: AppColors.accent,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _goToNextStep(BuildContext context, AuthCubit cubit) async {
    final effectiveDriverImage = cubit.driverImage ?? _draftData?.driverImage;
    if (effectiveDriverImage == null) {
      Fluttertoast.showToast(
        msg: S.of(context).pleaseUploadProfileImage,
        backgroundColor: Colors.orange,
      );
      return;
    }

    if (!_agreeToTerms) {
      Fluttertoast.showToast(
        msg: S.of(context).pleaseAgreeToTerms,
        backgroundColor: Colors.orange,
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final initialData = (_draftData ??
              const DriverSignupInitialData(
                name: '',
                mobile: '',
                password: '',
              ))
          .copyWith(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        password: _passwordController.text,
        driverImage: effectiveDriverImage,
      );

      final returnedData = await context.push<DriverSignupInitialData>(
        AppRoutes.driverSignupInfo,
        extra: initialData,
      );

      if (returnedData != null) {
        setState(() {
          _draftData = returnedData;
          if (returnedData.driverImage != null) {
            cubit.driverImage = returnedData.driverImage;
          }
        });
      }
    }
  }

  Widget _buildLoginRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          S.of(context).usersignuphaveaccount,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => context.go(AppRoutes.login),
          child: Text(
            S.of(context).loginbutton,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
