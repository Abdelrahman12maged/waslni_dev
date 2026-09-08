import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/image_picker_dialog.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:car_app/features/auth/presentation/utils/auth_error_mapper.dart';
import 'package:car_app/features/legal/presentation/screens/agree_terms_screen.dart';
import 'package:car_app/generated/l10n.dart';

class SignupUserView extends StatefulWidget {
  const SignupUserView({super.key});

  @override
  State<SignupUserView> createState() => _SignupUserViewState();
}

class _SignupUserViewState extends State<SignupUserView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is SignUpSuccess) {
      Fluttertoast.showToast(
        msg: S.of(context).registrationSuccessful,
        backgroundColor: Colors.green,
        gravity: ToastGravity.TOP,
      );
      context.go(AppRoutes.passengerHome);
    } else if (state is ProfileImagePickedFailure) {
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: _handleState,
      builder: _buildUI,
    );
  }

  Widget _buildUI(BuildContext context, AuthState state) {
    final cubit = AuthCubit.get(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: SvgPicture.asset('assets/images/logo.svg')),
                const SizedBox(height: 20.0),
                _buildProfileImagePicker(context, cubit),
                const SizedBox(height: 20.0),
                Text(S.of(context).usersignupnametitle),
                const SizedBox(height: 5.0),
                _buildNameField(context),
                const SizedBox(height: 20.0),
                Text(S.of(context).usersignupmobiletitle),
                const SizedBox(height: 5.0),
                _buildMobileField(context),
                const SizedBox(height: 20.0),
                Text(S.of(context).usersignuppasswordtitle),
                const SizedBox(height: 5.0),
                _buildPasswordField(context, cubit),
                const SizedBox(height: 12.0),
                _buildTermsRow(context),
                const SizedBox(height: 30.0),
                state is SignUpLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSignUpButton(context, cubit),
                const SizedBox(height: 30.0),
                _buildLoginRow(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker(BuildContext context, AuthCubit cubit) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (prev, cur) =>
          cur is ProfileImagePickedSuccess || cur is ProfileImagePickedFailure,
      builder: (context, _) => Center(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                showImagePickerOptions(
                  context,
                  onSourceSelected: (source) =>
                      cubit.getProfileImage(source: source),
                );
              },
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: cubit.profileImage != null
                    ? ClipOval(
                        child: Image.file(
                          cubit.profileImage!,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_rounded,
                              size: 42, color: Colors.grey.shade400),
                        ],
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  showImagePickerOptions(
                    context,
                    onSourceSelected: (source) =>
                        cubit.getProfileImage(source: source),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        labelText: S.of(context).usersignupnamelabel,
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
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: S.of(context).usersignupmobilelabel,
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
          labelText: S.of(context).usersignuppasswordlabel,
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
            S.of(context).usersignupterms,
            style: const TextStyle(
              color: AppColors.accent,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(BuildContext context, AuthCubit cubit) {
    return ElevatedButton(
      onPressed: () {
        if (!_agreeToTerms) {
          Fluttertoast.showToast(
            msg: S.of(context).pleaseAgreeToTerms,
            backgroundColor: Colors.orange,
          );
          return;
        }

        if (_formKey.currentState!.validate()) {
          final storage = sl<LocalStorage>();
          final gender = storage.read(key: 'gender') as String? ?? 'male';
          final language = storage.read(key: 'lang') as String? ?? 'en';

          cubit.signUp(
            name: _nameController.text.trim(),
            mobile: _mobileController.text.trim(),
            password: _passwordController.text,
            gender: gender,
            userType: 'passenger',
            language: language,
            profilePicture: cubit.profileImage,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        S.of(context).usersignupbutton,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
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
            S.of(context).usersignuploginbutton,
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
