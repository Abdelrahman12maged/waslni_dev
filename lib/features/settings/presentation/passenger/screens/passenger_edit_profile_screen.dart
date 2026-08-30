import 'dart:io';

import 'package:car_app/generated/l10n.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:car_app/features/settings/presentation/cubit/profile_state.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:car_app/core/widgets/image_picker_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:car_app/features/settings/domain/entities/user_profile.dart';
import 'package:car_app/features/settings/data/models/user_profile_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

const Color _mainColor = AppColors.primary;
const Color _iconsColor = AppColors.accent;

class PassengerEditProfileScreen extends StatefulWidget {
  const PassengerEditProfileScreen({super.key, required this.updateStates});
  final VoidCallback updateStates;

  @override
  State<PassengerEditProfileScreen> createState() =>
      _PassengerEditProfileScreenState();
}

class _PassengerEditProfileScreenState
    extends State<PassengerEditProfileScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userMobileNumberController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();

  UserProfile? user;
  final String baseUrl = ApiEndpoints.mediaBaseUrl;

  File? personalAvatarImage;
  final ImagePicker pickerAvatar = ImagePicker();
  String avatarUrlStr = '';

  bool hidePass = true;

  @override
  void initState() {
    super.initState();
    _getUserCachedData();
  }

  String _buildImageUrl(String? imgPath) =>
      ApiEndpoints.buildImageUrl(imgPath) ?? '';

  Future<void> _getUserCachedData() async {
    final box = await Hive.openBox('hive_box');
    final userCached = box.get('user_data');
    if (userCached != null && userCached is Map) {
      final parsed = UserProfileModel.fromJson(Map<String, dynamic>.from(userCached));
      setState(() {
        user = parsed;
        userNameController.text = parsed.name ?? '';
        userMobileNumberController.text = parsed.mobile ?? '';
        userEmailController.text = parsed.email ?? '';
        avatarUrlStr = _buildImageUrl(parsed.photo);
      });
    }
  }

  Future<void> _pickAvatarImage({ImageSource source = ImageSource.gallery}) async {
    final pickedFile = await pickerAvatar.pickImage(source: source);
    if (!mounted) return;
    if (pickedFile != null) {
      setState(() {
        personalAvatarImage = File(pickedFile.path);
        avatarUrlStr = pickedFile.path;
      });
    } else {
      showToast(
        text: S.of(context).noProfileImageSelected,
        state: ToastStates.WARNING,
      );
    }
  }

  Future<void> _updateProfile(ProfileCubit cubit) async {
    final userId = user?.id ?? 0;
    final userType = user?.userType ?? 'passenger';

    final Map<String, dynamic> map = {
      'name': userNameController.text,
      'mobile': userMobileNumberController.text,
      'user_id': userId,
      'user_type': userType,
    };

    if (userPasswordController.text.isNotEmpty) {
      map['password'] = userPasswordController.text;
    }
    if (userEmailController.text.isNotEmpty) {
      map['email'] = userEmailController.text;
    }

    if (personalAvatarImage != null) {
      final fileName = personalAvatarImage!.path.split(RegExp(r'[/\\]')).last;
      final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
      map['profile_picture'] = await MultipartFile.fromFile(
        personalAvatarImage!.path,
        filename: fileName,
        contentType: MediaType('image', ext),
      );
    }

    final formData = FormData.fromMap(map);
    await cubit.updateUserMyProfile(profileData: formData);
  }

  Widget _buildAvatarWidget() {
    ImageProvider imgProvider;
    if (personalAvatarImage != null) {
      imgProvider = FileImage(personalAvatarImage!);
    } else {
      imgProvider = appCachedImageProvider(avatarUrlStr, fallbackAsset: 'assets/images/passenger.png');
    }

    return InkWell(
      onTap: () => showImagePickerOptions(
        context,
        onSourceSelected: (source) => _pickAvatarImage(source: source),
      ),
      borderRadius: BorderRadius.circular(55),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 110.0,
            width: 110.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(55),
                child: Image(
                  image: imgProvider,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/passenger.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: _mainColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          showToast(
            text: S.of(context).updatedSuccessfully,
            state: ToastStates.SUCESS,
            toastPlace: ToastGravity.TOP,
          );
          widget.updateStates();
          Navigator.of(context).pop();
        } else if (state is ProfileUpdateError) {
          showToast(
            text: state.message,
            state: ToastStates.ERROR,
            toastPlace: ToastGravity.TOP,
          );
        }
      },
      builder: (context, state) {
        final cubit = ProfileCubit.get(context);
        final isLoading = state is ProfileUpdating;

        return Scaffold(
          appBar: defaultAppBar(
            backgroundColor: Colors.grey.shade100,
            leadingOnPressed: () => Navigator.of(context).pop(),
            titleText: S.of(context).editProfile,
            actionsIcon: FontAwesomeIcons.bell,
            actionsIconColor: _mainColor,
            actionsOnPressed: () => navigateTo(context, const CleanNotificationsScreen()),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Avatar Header with Orbits SVG
                SizedBox(
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/orbits.svg',
                        width: 300,
                      ),
                      _buildAvatarWidget(),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                // Form Card
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      defaultText(text: S.of(context).fullName),
                      const SizedBox(height: 5.0),
                      defaultFormField(
                        controller: userNameController,
                        label: S.of(context).enterYourName,
                        prefix: Icons.person_2_outlined,
                        prefixColor: _iconsColor,
                      ),
                      const SizedBox(height: 16.0),
                      defaultText(text: S.of(context).mobileNumber),
                      const SizedBox(height: 5.0),
                      defaultFormField(
                        controller: userMobileNumberController,
                        label: S.of(context).mobileNumber,
                        prefix: Icons.call_outlined,
                        prefixColor: _iconsColor,
                      ),
                      const SizedBox(height: 16.0),
                      defaultText(text: S.of(context).email),
                      const SizedBox(height: 5.0),
                      defaultFormField(
                        controller: userEmailController,
                        label: S.of(context).enterEmail,
                        prefix: Icons.email_outlined,
                        prefixColor: _iconsColor,
                        inputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16.0),
                      defaultText(text: S.of(context).password),
                      const SizedBox(height: 5.0),
                      defaultFormField(
                        inputType: TextInputType.visiblePassword,
                        controller: userPasswordController,
                        label: S.of(context).enterYourPassword,
                        prefix: Icons.lock_outline_rounded,
                        prefixColor: _iconsColor,
                        suffix: hidePass ? Icons.visibility : Icons.visibility_off,
                        isPassword: hidePass,
                        suffixPressed: () {
                          setState(() {
                            hidePass = !hidePass;
                          });
                        },
                        suffixColor: _iconsColor,
                      ),
                      const SizedBox(height: 30.0),
                      Row(
                        children: [
                          Expanded(
                            child: defaultButton(
                              onPressed: () => Navigator.of(context).pop(),
                              text: S.of(context).cancel,
                              background: Colors.white,
                              textColor: Colors.black,
                              borderColor: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : defaultButton(
                                    onPressed: () => _updateProfile(cubit),
                                    text: S.of(context).save,
                                    background: _mainColor,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
