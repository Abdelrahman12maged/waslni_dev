import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:car_app/features/auth/presentation/utils/auth_error_mapper.dart';
import 'package:car_app/generated/l10n.dart';

class ResetPasswordView extends StatefulWidget {
  final String mobile;

  const ResetPasswordView({super.key, required this.mobile});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _secondsRemaining = 60;
  Timer? _timer;
  bool _isPasswordHidden = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is ResetPasswordSuccess) {
      Fluttertoast.showToast(
        msg: S.of(context).passwordResetSuccessfully,
        backgroundColor: Colors.green,
        gravity: ToastGravity.TOP,
      );
      context.go(AppRoutes.login);
    } else if (state is ResetPasswordFailure) {
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
    } else if (state is ResendCodeSuccess) {
      Fluttertoast.showToast(
        msg: S.of(context).verificationCodeSent,
        backgroundColor: Colors.green,
        gravity: ToastGravity.TOP,
      );
      _startTimer();
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: _handleState,
      builder: _buildUI,
    );
  }

  Widget _buildUI(BuildContext context, AuthState state) {
    if (widget.mobile.trim().isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 64, color: Colors.orange),
                const SizedBox(height: 16),
                Text(
                  S.of(context).mobileNumberRequired,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.forgetPassword),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    S.of(context).backToForgetPassword,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
              Center(
                  child: SvgPicture.asset('assets/images/accountconfirm.svg',
                      width: 100)),
              const SizedBox(height: 20.0),
              Text(
                S.of(context).accountConfirmation,
                style: const TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              Text(
                S.of(context).enterCodeSentToMobile,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              Text(
                widget.mobile,
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              Pinput(
                length: 6,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                controller: _codeController,
              ),
              const SizedBox(height: 30.0),
              Text(S.of(context).newPassword),
              const SizedBox(height: 5.0),
              TextFormField(
                controller: _passwordController,
                obscureText: _isPasswordHidden,
                decoration: InputDecoration(
                  labelText: S.of(context).enterNewPassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      color: AppColors.accent),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordHidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.accent,
                    ),
                    onPressed: () =>
                        setState(() => _isPasswordHidden = !_isPasswordHidden),
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
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 2.0),
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
                  } else if (!value.contains(RegExp(r'[0-9]'))) {
                    return S.of(context).passwordShouldContainNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              Text(S.of(context).confirmPassword),
              const SizedBox(height: 5.0),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _isPasswordHidden,
                decoration: InputDecoration(
                  labelText: S.of(context).EnterYourPasswordConfirm,
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      color: AppColors.accent),
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
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return S.of(context).passwordsMustMatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 35.0),
              state is ResetPasswordLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        if (_codeController.text.length != 6) {
                          Fluttertoast.showToast(
                              msg: S.of(context).pleaseEnterFull6DigitCode);
                          return;
                        }
                        if (_formKey.currentState!.validate()) {
                          cubit.resetPassword(
                            mobile: widget.mobile,
                            password: _passwordController.text,
                            code: _codeController.text,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        S.of(context).done,
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white),
                      ),
                    ),
              const SizedBox(height: 30.0),
              state is ResendCodeLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Text(
                          _secondsRemaining == 0
                              ? S.of(context).resendCodeAvailableNow
                              : '${S.of(context).resendCodeWithin} 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _secondsRemaining == 0
                              ? () =>
                                  cubit.resendVerificationCode(widget.mobile)
                              : null,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            disabledForegroundColor: Colors.grey,
                          ),
                          child: Text(
                            S.of(context).send,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
