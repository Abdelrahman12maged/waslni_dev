import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import 'package:car_app/core/formatters/plate_number_formatter.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/widgets/image_picker_dialog.dart';
import 'package:car_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:car_app/features/settings/domain/entities/user_profile.dart';
import 'package:car_app/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:car_app/features/settings/presentation/cubit/profile_state.dart';
import 'package:car_app/generated/l10n.dart';

const Color _mainColor = AppColors.primary;
const Color _iconsColor = AppColors.accent;

class DriverEditProfileView extends StatefulWidget {
  final VoidCallback updateStates;

  const DriverEditProfileView({super.key, required this.updateStates});

  @override
  State<DriverEditProfileView> createState() => _DriverEditProfileViewState();
}

class _DriverEditProfileViewState extends State<DriverEditProfileView> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userMobileNumberController =
      TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();
  final TextEditingController driverCarTypeController = TextEditingController();
  final TextEditingController driverSeatsNumberController =
      TextEditingController();
  final TextEditingController driverCarModelController =
      TextEditingController();
  final TextEditingController driverPlateNumberController =
      TextEditingController();

  UserProfile? user;
  final String baseUrl = ApiEndpoints.mediaBaseUrl;

  File? driverLicenseImage;
  File? driverCarOutsideImage;
  File? driverCarInsideImage;
  File? personalAvatarImage;

  final ImagePicker pickerAvatar = ImagePicker();
  final ImagePicker picker1 = ImagePicker();
  final ImagePicker picker2 = ImagePicker();
  final ImagePicker picker3 = ImagePicker();

  String avatarUrlStr = '';
  String driverLicenseImage1 = '';
  String driverCarOutsideImage1 = '';
  String driverCarInsideImage1 = '';

  int currentIndex = 0;
  bool hidePass = true;

  @override
  void initState() {
    super.initState();
    _getStates();
  }

  @override
  void dispose() {
    userNameController.dispose();
    userMobileNumberController.dispose();
    userEmailController.dispose();
    userPasswordController.dispose();
    driverCarTypeController.dispose();
    driverSeatsNumberController.dispose();
    driverCarModelController.dispose();
    driverPlateNumberController.dispose();
    super.dispose();
  }

  String _buildImageUrl(String? imgPath) =>
      ApiEndpoints.buildImageUrl(imgPath) ?? '';

  Future<void> _getStates() async {
    final box = await Hive.openBox('hive_box');
    final userCached = box.get('user_data');
    if (userCached != null && userCached is Map) {
      final parsed =
          UserProfile.fromMap(Map<String, dynamic>.from(userCached));
      setState(() {
        user = parsed;
        userNameController.text = parsed.name ?? '';
        userMobileNumberController.text = parsed.mobile ?? '';
        userEmailController.text = parsed.email ?? '';
        avatarUrlStr = _buildImageUrl(parsed.photo);

        final car = parsed.car;
        if (car != null) {
          driverCarTypeController.text = car.type;
          driverSeatsNumberController.text = car.seats.toString();
          driverCarModelController.text = car.model;
          driverPlateNumberController.text =
              PlateNumberFormatter.format(car.plateNumber);

          driverLicenseImage1 = _buildImageUrl(car.drivingLic);
          driverCarInsideImage1 = _buildImageUrl(car.insidePicture);
          driverCarOutsideImage1 = _buildImageUrl(car.outsidePicture);
        }
      });
    }
  }

  Future<void> _pickAvatarImage(
      {ImageSource source = ImageSource.gallery}) async {
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

  Future<void> getDriverInfoImages(int imageNum,
      {ImageSource source = ImageSource.gallery}) async {
    if (imageNum == 0) {
      final pickedFile1 = await picker1.pickImage(source: source);
      if (!mounted) return;
      if (pickedFile1 != null) {
        setState(() {
          driverLicenseImage = File(pickedFile1.path);
          driverLicenseImage1 = pickedFile1.path;
        });
      } else {
        showToast(
          text: S.of(context).noImageLicenseSelected,
          state: ToastStates.WARNING,
        );
      }
    } else if (imageNum == 1) {
      final pickedFile2 = await picker2.pickImage(source: source);
      if (!mounted) return;
      if (pickedFile2 != null) {
        setState(() {
          driverCarInsideImage = File(pickedFile2.path);
          driverCarInsideImage1 = pickedFile2.path;
        });
      } else {
        showToast(
          text: S.of(context).noImageInteriorSelected,
          state: ToastStates.WARNING,
        );
      }
    } else if (imageNum == 2) {
      final pickedFile3 = await picker3.pickImage(source: source);
      if (!mounted) return;
      if (pickedFile3 != null) {
        setState(() {
          driverCarOutsideImage = File(pickedFile3.path);
          driverCarOutsideImage1 = pickedFile3.path;
        });
      } else {
        showToast(
          text: S.of(context).noImageExteriorSelected,
          state: ToastStates.WARNING,
        );
      }
    }
  }

  Future<void> _updateProfile(ProfileCubit cubit) async {
    final userId = user?.id ?? 0;
    final userType = user?.userType ?? 'driver';

    final Map<String, dynamic> map = {
      "mobile": userMobileNumberController.text,
      'name': userNameController.text,
      'type': driverCarTypeController.text,
      'seats': driverSeatsNumberController.text,
      'model': driverCarModelController.text,
      'plate_number': driverPlateNumberController.text,
      'user_id': userId,
      'user_type': userType,
    };

    if (userPasswordController.text.isNotEmpty) {
      map["password"] = userPasswordController.text;
    }
    if (userEmailController.text.isNotEmpty) {
      map["email"] = userEmailController.text;
    }

    if (!driverLicenseImage1.contains('http') &&
        driverLicenseImage != null) {
      map["driving_lic"] = await MultipartFile.fromFile(
        driverLicenseImage!.path,
        filename: driverLicenseImage!.path.split('/').last,
        contentType: MediaType(
          "image",
          driverLicenseImage!.path.split('.').last,
        ),
      );
    }
    if (!driverCarOutsideImage1.contains('http') &&
        driverCarOutsideImage != null) {
      map["outside_picture"] = await MultipartFile.fromFile(
        driverCarOutsideImage!.path,
        filename: driverCarOutsideImage!.path.split('/').last,
        contentType: MediaType(
          "image",
          driverCarOutsideImage!.path.split('.').last,
        ),
      );
    }
    if (!driverCarInsideImage1.contains('http') &&
        driverCarInsideImage != null) {
      map["inside_picture"] = await MultipartFile.fromFile(
        driverCarInsideImage!.path,
        filename: driverCarInsideImage!.path.split('/').last,
        contentType: MediaType(
          "image",
          driverCarInsideImage!.path.split('.').last,
        ),
      );
    }
    if (personalAvatarImage != null) {
      final fileName =
          personalAvatarImage!.path.split(RegExp(r'[/\\]')).last;
      final ext = fileName.contains('.')
          ? fileName.split('.').last.toLowerCase()
          : 'jpg';
      final multiFile = await MultipartFile.fromFile(
        personalAvatarImage!.path,
        filename: fileName,
        contentType: MediaType("image", ext),
      );
      map["profile_picture"] = multiFile;
    }

    final formData = FormData.fromMap(map);
    await cubit.updateUserMyProfile(profileData: formData);
  }

  Widget _buildAvatarWidget() {
    ImageProvider imgProvider;
    if (personalAvatarImage != null) {
      imgProvider = FileImage(personalAvatarImage!);
    } else {
      imgProvider = appCachedImageProvider(avatarUrlStr,
          fallbackAsset: 'assets/images/passenger.png');
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
            actionsOnPressed: () =>
                navigateTo(context, const CleanNotificationsScreen()),
          ),
          body: Padding(
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
                      _buildAvatarWidget(),
                    ],
                  ),
                ),
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
                                  textColor: currentIndex == 0
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              Tab(
                                child: defaultText(
                                  text: S.of(context).workInformation,
                                  textFontSize: 13.0,
                                  textColor: currentIndex == 1
                                      ? Colors.white
                                      : Colors.black,
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
                                  ),
                                  const SizedBox(height: 16.0),
                                  defaultText(
                                      text: S.of(context).mobileNumber),
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
                                    suffix: hidePass
                                        ? Icons.visibility
                                        : Icons.visibility_off,
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
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          text: S.of(context).cancel,
                                          background: Colors.white,
                                          textColor: Colors.black,
                                          borderColor: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: isLoading
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator())
                                            : defaultButton(
                                                onPressed: () =>
                                                    _updateProfile(cubit),
                                                text: S.of(context).save,
                                                background: _mainColor,
                                              ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20.0),
                                ],
                              ),
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
                                  ),
                                  const SizedBox(height: 16.0),
                                  defaultText(
                                      text: S.of(context).numberOfSeats),
                                  const SizedBox(height: 5.0),
                                  defaultFormField(
                                    controller: driverSeatsNumberController,
                                    label:
                                        S.of(context).enterNumberOfSeats,
                                    prefix: Icons
                                        .airline_seat_recline_normal_outlined,
                                    prefixColor: _iconsColor,
                                    inputType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 16.0),
                                  defaultText(text: S.of(context).modelOfCar),
                                  const SizedBox(height: 5.0),
                                  defaultFormField(
                                    controller: driverCarModelController,
                                    label: S.of(context).enterCarModel,
                                    prefix: Icons.time_to_leave_outlined,
                                    prefixColor: _iconsColor,
                                  ),
                                  const SizedBox(height: 16.0),
                                  defaultText(text: S.of(context).plateNumber),
                                  const SizedBox(height: 5.0),
                                  TextFormField(
                                    controller: driverPlateNumberController,
                                    keyboardType: TextInputType.number,
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.left,
                                    inputFormatters: [PlateNumberFormatter()],
                                    decoration: InputDecoration(
                                      labelText: S.of(context).enterPlateNumber,
                                      hintText: S.of(context).enterPlateNumber,
                                      prefixIcon: Icon(
                                        Icons.badge_outlined,
                                        color: _iconsColor,
                                      ),
                                      border: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value != null &&
                                          value.isNotEmpty &&
                                          !RegExp(r'^\d{2} - \d+$')
                                              .hasMatch(value)) {
                                        return S
                                            .of(context)
                                            .plateNumberInvalidFormat;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20.0),
                                  defaultText(
                                      text: S.of(context).drivingLicense),
                                  const SizedBox(height: 5.0),
                                  largeImagePicker(
                                    context: context,
                                    onTap: () => showImagePickerOptions(
                                      context,
                                      onSourceSelected: (source) =>
                                          getDriverInfoImages(0,
                                              source: source),
                                    ),
                                    image: driverLicenseImage1,
                                  ),
                                  const SizedBox(height: 16.0),
                                  defaultText(text: S.of(context).carInterior),
                                  const SizedBox(height: 5.0),
                                  largeImagePicker(
                                    context: context,
                                    onTap: () => showImagePickerOptions(
                                      context,
                                      onSourceSelected: (source) =>
                                          getDriverInfoImages(1,
                                              source: source),
                                    ),
                                    image: driverCarInsideImage1,
                                  ),
                                  const SizedBox(height: 16.0),
                                  defaultText(text: S.of(context).carExterior),
                                  const SizedBox(height: 5.0),
                                  largeImagePicker(
                                    context: context,
                                    onTap: () => showImagePickerOptions(
                                      context,
                                      onSourceSelected: (source) =>
                                          getDriverInfoImages(2,
                                              source: source),
                                    ),
                                    image: driverCarOutsideImage1,
                                  ),
                                  const SizedBox(height: 30.0),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: defaultButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          text: S.of(context).cancel,
                                          background: Colors.white,
                                          textColor: Colors.black,
                                          borderColor: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: isLoading
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator())
                                            : defaultButton(
                                                onPressed: () =>
                                                    _updateProfile(cubit),
                                                text: S.of(context).save,
                                                background: _mainColor,
                                              ),
                                      ),
                                    ],
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
        );
      },
    );
  }
}
