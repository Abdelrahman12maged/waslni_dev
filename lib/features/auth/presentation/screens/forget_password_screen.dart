import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:car_app/features/auth/presentation/utils/auth_error_mapper.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorText;

  @override
  void dispose() {
    _mobileController.dispose();
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
    if (state is ResendCodeSuccess) {
      Fluttertoast.showToast(
        msg: S.of(context).verificationCodeSent,
        backgroundColor: Colors.green,
        gravity: ToastGravity.TOP,
      );
      // Go to reset password confirm screen, passing the mobile number
      context.push(
        AppRoutes.forgetPasswordConfirm,
        extra: _mobileController.text.trim(),
      );
    } else if (state is ResendCodeFailure) {
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
              Center(child: SvgPicture.asset('assets/images/forgetpass.svg')),
              const SizedBox(height: 30.0),
              Text(
                S.of(context).forgetPassword,
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15.0),
              Text(
                S.of(context).enterTheMobileNumberForAccess,
                style: const TextStyle(color: Colors.grey, fontSize: 15.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25.0),
              Text(S.of(context).mobileNumber),
              const SizedBox(height: 5.0),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: S.of(context).mobileNumberPlaceholder,
                  prefixIcon: Icon(Icons.local_phone_outlined, color: AppColors.accent),
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
                  errorText: _errorText,
                ),
              ),
              const SizedBox(height: 40.0),
              state is ResendCodeLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        final mobile = _mobileController.text.trim();
                        if (mobile.isEmpty) {
                          setState(() {
                            _errorText = S.of(context).yourMobileNumberCantBeEmpty;
                          });
                        } else if (mobile.length >= 9 && mobile.length <= 14) {
                          setState(() {
                            _errorText = null;
                          });
                          cubit.resendVerificationCode(mobile);
                        } else {
                          setState(() {
                            _errorText = S.of(context).numberShouldBe9To14Digits;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        S.of(context).send,
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
