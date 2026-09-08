import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:car_app/features/settings/domain/entities/user_profile.dart';
import 'package:car_app/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:car_app/features/settings/presentation/cubit/profile_state.dart';
import 'package:car_app/features/settings/presentation/passenger/screens/passenger_edit_profile_screen.dart';
import 'package:car_app/generated/l10n.dart';

const Color _mainColor = AppColors.primary;
const Color _iconsColor = AppColors.accent;

class PassengerProfileView extends StatefulWidget {
  const PassengerProfileView({super.key});

  @override
  State<PassengerProfileView> createState() => _PassengerProfileViewState();
}

class _PassengerProfileViewState extends State<PassengerProfileView> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userMobileNumberController =
      TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userGenderController = TextEditingController();
  final TextEditingController userLangController = TextEditingController();

  UserProfile? user;
  String? avatarUrl;
  final String baseUrl = ApiEndpoints.mediaBaseUrl;

  @override
  void initState() {
    super.initState();
    _getUserCachedData();
  }

  @override
  void dispose() {
    userNameController.dispose();
    userMobileNumberController.dispose();
    userEmailController.dispose();
    userGenderController.dispose();
    userLangController.dispose();
    super.dispose();
  }

  String? _buildAvatarUrl(String? photo) => ApiEndpoints.buildImageUrl(photo);

  Future<void> _getUserCachedData() async {
    final box = await Hive.openBox('hive_box');
    final userCached = box.get('user_data');
    if (userCached != null && userCached is Map) {
      final parsed =
          UserProfile.fromMap(Map<String, dynamic>.from(userCached));
      _applyUserData(parsed);
    }
  }

  void _applyUserData(UserProfile userProfile) {
    if (!mounted) return;
    setState(() {
      user = userProfile;
      avatarUrl = _buildAvatarUrl(userProfile.photo);

      userNameController.text = userProfile.name ?? '';
      userMobileNumberController.text = userProfile.mobile ?? '';
      userEmailController.text = userProfile.email ?? '';

      final rawGender = userProfile.gender ?? '';
      userGenderController.text = rawGender == 'male'
          ? S.of(context).logingenderdialogmale
          : rawGender == 'female'
              ? S.of(context).logingenderdialogfemale
              : rawGender;

      final rawLang = userProfile.lang ?? '';
      userLangController.text = rawLang == 'ar'
          ? S.of(context).userlayoutsettingsLanguagearabic
          : rawLang == 'en'
              ? S.of(context).userlayoutsettingsLanguageenglish
              : rawLang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSuccess) {
          _applyUserData(state.userProfile);
        }
      },
      child: Scaffold(
        appBar: defaultAppBar(
          backgroundColor: Colors.grey.shade100,
          leadingOnPressed: () => Navigator.of(context).pop(),
          titleText: S.of(context).userlayoutsettingsmyprofile,
          actionsIcon: FontAwesomeIcons.bell,
          actionsIconColor: _mainColor,
          actionsOnPressed: () =>
              navigateTo(context, const CleanNotificationsScreen()),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/orbits.svg',
                      width: 300,
                    ),
                    Container(
                      height: 110.0,
                      width: 110.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(55),
                          child: AppCachedNetworkImage(
                            imageUrl: avatarUrl,
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            errorWidget: Image.asset(
                              'assets/images/passenger.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (user != null &&
                  (user!.name != null || user!.mobile != null)) ...[
                Text(
                  user!.name ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _mainColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user!.mobile ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 20.0),
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
                      isReadOnly: true,
                    ),
                    const SizedBox(height: 16.0),
                    defaultText(text: S.of(context).mobileNumber),
                    const SizedBox(height: 5.0),
                    defaultFormField(
                      controller: userMobileNumberController,
                      label: S.of(context).mobileNumber,
                      prefix: Icons.call_outlined,
                      prefixColor: _iconsColor,
                      isReadOnly: true,
                    ),
                    if (userEmailController.text.isNotEmpty) ...[
                      const SizedBox(height: 16.0),
                      defaultText(text: S.of(context).email),
                      const SizedBox(height: 5.0),
                      defaultFormField(
                        controller: userEmailController,
                        label: S.of(context).email,
                        prefix: Icons.email_outlined,
                        prefixColor: _iconsColor,
                        isReadOnly: true,
                      ),
                    ],
                    if (userGenderController.text.isNotEmpty) ...[
                      const SizedBox(height: 16.0),
                      defaultText(text: S.of(context).gender),
                      const SizedBox(height: 5.0),
                      defaultFormField(
                        controller: userGenderController,
                        label: S.of(context).gender,
                        prefix: Icons.wc_outlined,
                        prefixColor: _iconsColor,
                        isReadOnly: true,
                      ),
                    ],
                    if (userLangController.text.isNotEmpty) ...[
                      const SizedBox(height: 16.0),
                      defaultText(text: S.of(context).preferredLanguage),
                      const SizedBox(height: 5.0),
                      defaultFormField(
                        controller: userLangController,
                        label: S.of(context).preferredLanguage,
                        prefix: Icons.language_outlined,
                        prefixColor: _iconsColor,
                        isReadOnly: true,
                      ),
                    ],
                    const SizedBox(height: 30.0),
                    defaultButton(
                      onPressed: () {
                        navigateTo(
                          context,
                          PassengerEditProfileScreen(
                              updateStates: _getUserCachedData),
                        );
                      },
                      text: S.of(context).editProfile,
                      background: _mainColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
