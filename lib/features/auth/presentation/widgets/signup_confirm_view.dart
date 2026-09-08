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

class SignupConfirmView extends StatefulWidget {
  final String mobile;

  const SignupConfirmView({super.key, required this.mobile});

  @override
  State<SignupConfirmView> createState() => _SignupConfirmViewState();
}

class _SignupConfirmViewState extends State<SignupConfirmView> {
  final _codeController = TextEditingController();
  int _secondsRemaining = 60;
  Timer? _timer;

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
    super.dispose();
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is VerificationCodeSuccess) {
      Fluttertoast.showToast(
        msg: S.of(context).accountVerifiedSuccessfully,
        backgroundColor: Colors.green,
        gravity: ToastGravity.TOP,
      );
      context.go(AppRoutes.login, extra: widget.mobile);
    } else if (state is VerificationCodeFailure) {
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/accountconfirm.svg',
                width: 120,
              ),
              const SizedBox(height: 30.0),
              Text(
                S.of(context).accountConfirmation,
                style: const TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15.0),
              Text(
                S.of(context).enterCodeSentToMobile,
                style: const TextStyle(color: Colors.grey, fontSize: 15.0),
                textAlign: TextAlign.center,
              ),
              Text(
                widget.mobile,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25.0),
              SizedBox(
                width: double.infinity,
                child: Pinput(
                  length: 6,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  autofocus: true,
                  closeKeyboardWhenCompleted: true,
                  controller: _codeController,
                ),
              ),
              const SizedBox(height: 50.0),
              state is VerificationCodeLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        if (_codeController.text.length == 6) {
                          cubit.checkVerificationCode(
                            mobile: widget.mobile,
                            code: _codeController.text,
                          );
                        } else {
                          Fluttertoast.showToast(
                              msg: S.of(context).pleaseEnterFull6DigitCode);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        S.of(context).accountConfirmation,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
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
