import 'dart:io';
import 'package:car_app/generated/l10n.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/core/formatters/plate_number_formatter.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/settings/domain/entities/user_profile.dart';
import 'package:car_app/features/settings/data/models/user_profile_model.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:car_app/features/settings/presentation/cubit/profile_state.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/widgets/image_picker_dialog.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:car_app/features/settings/presentation/driver/screens/driver_edit_profile_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

const Color _mainColor = AppColors.primary;
const Color _iconsColor = AppColors.accent;

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (context) => di.sl<ProfileCubit>()..getUserMyProfile(),
      child: const _DriverProfileContent(),
    );
  }
}

class _DriverProfileContent extends StatefulWidget {
  const _DriverProfileContent();

  @override
  State<_DriverProfileContent> createState() => _DriverProfileContentState();
}

class _DriverProfileContentState extends State<_DriverProfileContent> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userMobileNumberController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userGenderController = TextEditingController();
  final TextEditingController userLangController = TextEditingController();

  final TextEditingController driverCarTypeController = TextEditingController();
  final TextEditingController driverSeatsNumberController = TextEditingController();
  final TextEditingController driverCarModelController = TextEditingController();
  final TextEditingController driverPlateNumberController = TextEditingController();

  UserProfile? user;
  String? avatarUrl;
  final String baseUrl = ApiEndpoints.mediaBaseUrl;

  int currentIndex = 0;
  bool _isUpdatingImage = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getStates();
  }

  String? _buildImageUrl(String? imgPath) => ApiEndpoints.buildImageUrl(imgPath);

  Future<void> _getStates() async {
    final box = await Hive.openBox('hive_box');
    final userCached = box.get('user_data');
    if (userCached != null && userCached is Map) {
      final parsed = UserProfileModel.fromJson(Map<String, dynamic>.from(userCached));
      _applyUserData(parsed);
    }
  }

  void _applyUserData(UserProfile userProfile) {
    if (!mounted) return;
    setState(() {
      user = userProfile;
      avatarUrl = _buildImageUrl(userProfile.photo);
      if (avatarUrl != null && avatarUrl!.isNotEmpty) {
        di.sl<LocalStorage>().saveString(key: 'profile_picture_url', value: avatarUrl!);
        di.sl<LocalStorage>().saveString(key: 'driver_image', value: avatarUrl!);
        di.sl<LocalStorage>().saveString(key: 'photo', value: avatarUrl!);
      }

      userNameController.text = userProfile.name ?? '';
      userMobileNumberController.text = userProfile.mobile ?? '';
      userEmailController.text = userProfile.email ?? '';
      final rawGender = userProfile.gender ?? '';
      userGenderController.text = rawGender == 'male'
          ? S.of(context).male
          : rawGender == 'female'
              ? S.of(context).female
              : rawGender;
      final rawLang = userProfile.lang ?? '';
      userLangController.text = rawLang == 'ar'
          ? S.of(context).arabic
          : rawLang == 'en'
              ? S.of(context).english
              : rawLang;

      final car = userProfile.car;
      if (car != null) {
        driverCarTypeController.text = car.type;
        driverSeatsNumberController.text = car.seats.toString();
        driverCarModelController.text = car.model;
        driverPlateNumberController.text = PlateNumberFormatter.format(car.plateNumber);
      }
    });
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final picked = await _imagePicker.pickImage(source: source);
    if (picked == null) return;
    final file = File(picked.path);
    final fileName = picked.path.split(RegExp(r'[/\\]')).last;
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';

    setState(() {
      _isUpdatingImage = true;
    });

    try {
      final multiFile = await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: MediaType("image", ext),
      );

      final rawUid = di.sl<LocalStorage>().read(key: 'userid') ??
          di.sl<LocalStorage>().read(key: 'user_id');
      final userId = int.tryParse(rawUid?.toString() ?? '') ?? (user?.id ?? 0);

      final Map<String, dynamic> map = {
        'name': userNameController.text.isNotEmpty
            ? userNameController.text
            : (user?.name ?? ''),
        'mobile': userMobileNumberController.text.isNotEmpty
            ? userMobileNumberController.text
            : (user?.mobile ?? ''),
        'user_id': userId,
        'user_type': user?.userType ?? 'driver',
        'profile_picture': multiFile,
      };

      final car = user?.car;
      if (car != null) {
        map['type'] = car.type;
        map['seats'] = car.seats.toString();
        map['model'] = car.model;
        map['plate_number'] = car.plateNumber;
      }

      final formData = FormData.fromMap(map);
      await context.read<ProfileCubit>().updateUserMyProfile(profileData: formData);
    } catch (e) {
      showToast(text: e.toString(), state: ToastStates.ERROR);
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSuccess) {
          _applyUserData(state.userProfile);
          showToast(text: S.of(context).updatedSuccessfully, state: ToastStates.SUCESS);
        } else if (state is ProfileUpdateError) {
          showToast(text: state.message, state: ToastStates.ERROR);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade100,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            S.of(context).userlayoutsettingsmyprofile,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          actions: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.bell, color: _mainColor, size: 20),
              onPressed: () => navigateTo(context, const CleanNotificationsScreen()),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Driver Profile Header with Orbit Background & Dynamic Avatar
              SizedBox(
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/orbits.svg',
                      width: 300,
                    ),
                    GestureDetector(
                      onTap: _isUpdatingImage
                          ? null
                          : () => showImagePickerOptions(
                                context,
                                onSourceSelected: (source) => _pickAndUploadAvatar(source),
                              ),
                      child: Stack(
                        children: [
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
                                child: _isUpdatingImage
                                    ? const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2.5),
                                      )
                                    : AppCachedNetworkImage(
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
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: _mainColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (user != null && (user!.name != null || user!.mobile != null)) ...[
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
              const SizedBox(height: 16.0),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TabBar(
                          onTap: (value) {
                            setState(() {
                              currentIndex = value;
                            });
                          },
                          physics: const NeverScrollableScrollPhysics(),
                          isScrollable: false,
                          splashBorderRadius: BorderRadius.circular(10),
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: _mainColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.black87,
                          tabs: [
                            Tab(
                              child: defaultText(
                                text: S.of(context).personalInformation,
                                textFontSize: 13.0,
                                textColor: currentIndex == 0 ? Colors.white : Colors.black,
                              ),
                            ),
                            Tab(
                              child: defaultText(
                                text: S.of(context).workInformation,
                                textFontSize: 13.0,
                                textColor: currentIndex == 1 ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Expanded(
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            // Tab 1: Personal Info
                            ListView(
                              physics: const BouncingScrollPhysics(),
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
                                const SizedBox(height: 25.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.lock_outline, color: _mainColor, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                         child: Text(
                                           S.of(context).profileDataProtected,
                                           style: TextStyle(
                                             color: Colors.grey.shade700,
                                             fontSize: 12,
                                             fontFamily: 'Cairo',
                                           ),
                                         ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                              ],
                            ),
                            // Tab 2: Work & Car Info
                            ListView(
                              physics: const BouncingScrollPhysics(),
                              children: [
                                defaultText(text: S.of(context).typeOfCar),
                                const SizedBox(height: 5.0),
                                defaultFormField(
                                  controller: driverCarTypeController,
                                  label: S.of(context).enterCarType,
                                  prefix: Icons.directions_car_outlined,
                                  prefixColor: _iconsColor,
                                  isReadOnly: true,
                                ),
                                const SizedBox(height: 16.0),
                                defaultText(text: S.of(context).numberOfSeats),
                                const SizedBox(height: 5.0),
                                defaultFormField(
                                  controller: driverSeatsNumberController,
                                  label: S.of(context).enterNumberOfSeats,
                                  prefix: Icons.airline_seat_recline_normal_outlined,
                                  prefixColor: _iconsColor,
                                  isReadOnly: true,
                                ),
                                const SizedBox(height: 16.0),
                                defaultText(text: S.of(context).modelOfCar),
                                const SizedBox(height: 5.0),
                                defaultFormField(
                                  controller: driverCarModelController,
                                  label: S.of(context).enterCarModel,
                                  prefix: Icons.time_to_leave_outlined,
                                  prefixColor: _iconsColor,
                                  isReadOnly: true,
                                ),
                                const SizedBox(height: 16.0),
                                defaultText(text: S.of(context).plateNumber),
                                const SizedBox(height: 5.0),
                                defaultFormField(
                                  controller: driverPlateNumberController,
                                  label: S.of(context).enterPlateNumber,
                                  prefix: Icons.badge_outlined,
                                  prefixColor: _iconsColor,
                                  isReadOnly: true,
                                  textDirection: TextDirection.ltr,
                                ),
                                const SizedBox(height: 20.0),
                                defaultText(text: S.of(context).drivingLicense),
                                const SizedBox(height: 5.0),
                                largeImagePicker(
                                  context: context,
                                  onTap: () {},
                                  image: _buildImageUrl(user?.car?.drivingLic),
                                ),
                                const SizedBox(height: 16.0),
                                defaultText(text: S.of(context).carInterior),
                                const SizedBox(height: 5.0),
                                largeImagePicker(
                                  context: context,
                                  onTap: () {},
                                  image: _buildImageUrl(user?.car?.insidePicture),
                                ),
                                const SizedBox(height: 16.0),
                                defaultText(text: S.of(context).carExterior),
                                const SizedBox(height: 5.0),
                                largeImagePicker(
                                  context: context,
                                  onTap: () {},
                                  image: _buildImageUrl(user?.car?.outsidePicture),
                                ),
                                const SizedBox(height: 25.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.lock_outline, color: _mainColor, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                         child: Text(
                                           S.of(context).vehicleDataProtected,
                                           style: TextStyle(
                                             color: Colors.grey.shade700,
                                             fontSize: 12,
                                             fontFamily: 'Cairo',
                                           ),
                                         ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
