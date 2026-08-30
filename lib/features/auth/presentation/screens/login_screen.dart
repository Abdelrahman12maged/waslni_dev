import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:car_app/features/auth/presentation/utils/auth_error_mapper.dart';
import 'package:car_app/features/home/presentation/cubit/driver_layout_cubit.dart';
import 'package:car_app/features/home/presentation/cubit/user_layout_cubit.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  final String? initialMobile;
  const LoginScreen({super.key, this.initialMobile});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final storage = sl<LocalStorage>();
    final isRemembered = storage.read(key: 'remember_me') as bool? ?? false;
    if (isRemembered) {
      final savedMobile = storage.read(key: 'saved_mobile') as String?;
      final savedPassword = storage.read(key: 'saved_password') as String?;
      if (savedMobile != null && savedMobile.isNotEmpty) {
        _phoneController.text = savedMobile;
      }
      if (savedPassword != null && savedPassword.isNotEmpty) {
        _passwordController.text = savedPassword;
      }
    } else if (widget.initialMobile != null && widget.initialMobile!.isNotEmpty) {
      _phoneController.text = widget.initialMobile!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
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

  // ── State Listener ────────────────────────────────────────────────────────

  void _handleState(BuildContext context, AuthState state) {
    if (state is LoginSuccess) {
      Fluttertoast.showToast(
        msg: S.of(context).loginSuccessful,
        backgroundColor: Colors.green,
        gravity: ToastGravity.TOP,
      );
      // go_router decides the correct layout from the redirect logic
      if (state.user.userType == 'passenger') {
        try {
          UserLayoutCubit.get(context).changeBottomScreen(0);
        } catch (_) {}
        context.go(AppRoutes.passengerHome);
      } else {
        try {
          DriverLayoutCubit.get(context).changeBottomScreen(0);
        } catch (_) {}
        context.go(AppRoutes.driverHome);
      }
    } else if (state is LoginFailure) {
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

  // ── UI Builder ────────────────────────────────────────────────────────────

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
                // ── Logo ──────────────────────────────────────────
                Center(child: SvgPicture.asset('assets/images/logo.svg')),
                const SizedBox(height: 30.0),

                // ── Phone ─────────────────────────────────────────
                Text(S.of(context).loginmobiletitle),
                const SizedBox(height: 5.0),
                _buildPhoneField(context),
                const SizedBox(height: 40.0),

                // ── Password ──────────────────────────────────────
                Text(S.of(context).loginpasswordtitle),
                const SizedBox(height: 5.0),
                _buildPasswordField(context, cubit),
                const SizedBox(height: 8.0),

                // ── Remember Me / Forget ──────────────────────────
                _buildRememberForgetRow(context, cubit),
                const SizedBox(height: 30.0),

                // ── Login Button ──────────────────────────────────
                state is LoginLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildLoginButton(context, cubit),
                const SizedBox(height: 30.0),

                // ── Sign Up Link ──────────────────────────────────
                _buildSignUpRow(context, cubit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Field Builders ────────────────────────────────────────────────────────

  Widget _buildPhoneField(BuildContext context) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: S.of(context).loginmobilelabel,
        prefixIcon:
            Icon(Icons.local_phone_outlined, color: AppColors.accent),
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
          labelText: S.of(context).loginpasswordlabel,
          prefixIcon:
              Icon(Icons.lock_outline_rounded, color: AppColors.accent),
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
            return S.of(context).passwordCantBeEmpty;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRememberForgetRow(BuildContext context, AuthCubit cubit) {
    return Row(
      children: [
        BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (prev, cur) => cur is RememberMeChanged,
          builder: (context, _) => Checkbox(
            value: cubit.rememberMe,
            activeColor: AppColors.primary,
            onChanged: (v) => cubit.setRememberMe(v ?? false),
          ),
        ),
        Text(S.of(context).loginrememberme),
        const Spacer(),
        TextButton(
          onPressed: () => context.push(AppRoutes.forgetPassword),
          child: Text(
            S.of(context).loginforgetpassword,
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context, AuthCubit cubit) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          cubit.login(
            mobile: _phoneController.text.trim(),
            password: _passwordController.text,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        S.of(context).loginbutton,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildSignUpRow(BuildContext context, AuthCubit cubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          S.of(context).logindonthaveaccount,
          style: const TextStyle(color: Colors.grey),
        ),
        GestureDetector(
          onTap: () => _showUserTypeDialog(context, cubit),
          child: Text(
            S.of(context).loginsignupbutton,
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

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showUserTypeDialog(BuildContext screenContext, AuthCubit cubit) {
    showDialog(
      context: screenContext,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (dialogContext, state) => AlertDialog(
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S.of(screenContext).logindialogwelcome,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _UserTypeCard(
                      label: S.of(screenContext).logindialogpassenger,
                      imagePath: 'assets/images/passenger.png',
                      isSelected: cubit.isPassenger,
                      onTap: () => cubit.setUserType(true),
                    ),
                    const SizedBox(width: 12),
                    _UserTypeCard(
                      label: S.of(screenContext).logindialogdriver,
                      imagePath: 'assets/images/driver.png',
                      isSelected: !cubit.isPassenger,
                      onTap: () => cubit.setUserType(false),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    if (cubit.isPassenger) {
                      Future.delayed(const Duration(milliseconds: 200),
                          () => _showGenderDialog(screenContext, cubit));
                    } else {
                      screenContext.push(AppRoutes.driverSignup);
                    }
                  },
                  child: Text(
                    S.of(screenContext).logindialogbutton,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGenderDialog(BuildContext screenContext, AuthCubit cubit) {
    showDialog(
      context: screenContext,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (dialogContext, state) => AlertDialog(
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S.of(screenContext).logingenderdialogwelcome,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _UserTypeCard(
                      label: S.of(screenContext).logingenderdialogfemale,
                      imagePath: 'assets/images/female.png',
                      isSelected: !cubit.isMale,
                      onTap: () => cubit.setGender(false),
                    ),
                    const SizedBox(width: 12),
                    _UserTypeCard(
                      label: S.of(screenContext).logingenderdialogmale,
                      imagePath: 'assets/images/male.png',
                      isSelected: cubit.isMale,
                      onTap: () => cubit.setGender(true),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    screenContext.push(AppRoutes.passengerSignup);
                  },
                  child: Text(
                    S.of(screenContext).logindialogbutton,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable Card Widget ──────────────────────────────────────────────────────

class _UserTypeCard extends StatelessWidget {
  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(imagePath, height: 70, width: 70),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.grey,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
