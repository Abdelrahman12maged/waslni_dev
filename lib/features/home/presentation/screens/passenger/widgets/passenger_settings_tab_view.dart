import 'dart:developer';

import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:restart_app/restart_app.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/services/driver_location_tracker_service.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/trip_security_service.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/legal/presentation/screens/contact_us_screen.dart';
import 'package:car_app/features/legal/presentation/screens/privacy_policy_screen.dart';
import 'package:car_app/features/legal/presentation/screens/terms_screen.dart';
import 'package:car_app/features/settings/presentation/passenger/screens/passenger_profile_screen.dart';
import 'package:car_app/features/settings/presentation/passenger/screens/passenger_saved_locations_screen.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:car_app/main.dart';

class PassengerSettingsTabView extends StatefulWidget {
  const PassengerSettingsTabView({super.key});

  @override
  State<PassengerSettingsTabView> createState() =>
      _PassengerSettingsTabViewState();
}

class _PassengerSettingsTabViewState extends State<PassengerSettingsTabView> {
  bool isEnglish = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalStorage _localStorage = sl<LocalStorage>();

  @override
  void initState() {
    super.initState();
    if (_localStorage.read(key: 'lang') == 'ar') {
      setState(() {
        isEnglish = false;
      });
    }
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      DriverLocationTrackerService.instance.stopTracking(_localStorage);
    } catch (e) {
      log('Logout location stop error: $e', name: 'Logout');
    }

    try {
      MyApp.cancelTokenRefreshSubscription();
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      log('Logout FCM token delete error: $e', name: 'Logout');
    }

    try {
      TripSecurityService.clearActiveTrip(_localStorage);
    } catch (e) {
      log('Logout clear active trip error: $e', name: 'Logout');
    }

    try {
      await _auth.signOut();
    } catch (e) {
      log('Logout Firebase auth signout error: $e', name: 'Logout');
    }

    try {
      if (Hive.isBoxOpen('hive_box')) {
        await Hive.box('hive_box').clear();
      } else {
        final box = await Hive.openBox('hive_box');
        await box.clear();
      }
    } catch (e) {
      log('Logout Hive clear error: $e', name: 'Logout');
    }

    try {
      final rememberMe =
          _localStorage.read(key: 'remember_me') as bool? ?? false;
      final savedMobile = _localStorage.read(key: 'saved_mobile') as String?;
      final savedPassword =
          _localStorage.read(key: 'saved_password') as String?;
      final lang = _localStorage.read(key: 'lang') as String?;

      await _localStorage.clear();

      await _localStorage.saveBool(key: 'onboarding', value: false);

      if (lang != null) {
        await _localStorage.saveString(key: 'lang', value: lang);
      }
      if (rememberMe && savedMobile != null && savedPassword != null) {
        await _localStorage.saveBool(key: 'remember_me', value: true);
        await _localStorage.saveString(key: 'saved_mobile', value: savedMobile);
        await _localStorage.saveString(
            key: 'saved_password', value: savedPassword);
      }
    } catch (e) {
      log('Logout LocalStorage clear error: $e', name: 'Logout');
    }

    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  Future<void> _launchURL(String link) async {
    try {
      final Uri url = Uri.parse(link);
      final bool launched =
          await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $link'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $link'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  void _submitBoardingLang(String lang) {
    _localStorage.saveString(key: 'lang', value: lang).then((_) {
      if (lang == 'ar') {
        setState(() {
          isEnglish = false;
        });
      }
      Restart.restartApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          settingsTile(
            leadingIcon: Icons.person_2_outlined,
            leadingIconColor: AppColors.accent,
            titleText: S.of(context).userlayoutsettingsmyprofile,
            trailingIcon: Icons.keyboard_arrow_right_outlined,
            tileColor: Colors.white,
            onTap: () {
              navigateTo(context, const PassengerProfileScreen());
            },
          ),
          const SizedBox(height: 20.0),
          settingsTile(
            leadingIcon: Icons.location_on_outlined,
            leadingIconColor: AppColors.accent,
            titleText: S.of(context).userlayoutsettingssavelocations,
            trailingIcon: Icons.keyboard_arrow_right_outlined,
            tileColor: Colors.white,
            onTap: () {
              navigateTo(context, const PassengerSavedLocationsScreen());
            },
          ),
          const SizedBox(height: 20.0),
          settingsTile(
            leadingIcon: Icons.star_outline_rounded,
            leadingIconColor: AppColors.accent,
            titleText: S.of(context).myRatingsTitle,
            trailingIcon: Icons.keyboard_arrow_right_outlined,
            tileColor: Colors.white,
            onTap: () {
              context.push(AppRoutes.myRatings);
            },
          ),
          const SizedBox(height: 20.0),
          settingsTile(
            leadingIcon: Icons.rate_review_outlined,
            leadingIconColor: AppColors.accent,
            titleText: S.of(context).pendingRatingsTitle,
            trailingIcon: Icons.keyboard_arrow_right_outlined,
            tileColor: Colors.white,
            onTap: () {
              context.push(AppRoutes.pendingRatings);
            },
          ),
          const SizedBox(height: 20.0),
          ExpandableNotifier(
            child: ScrollOnExpand(
              scrollOnCollapse: true,
              scrollOnExpand: true,
              child: Expandable(
                theme: const ExpandableThemeData(
                  animationDuration: Duration(milliseconds: 500),
                ),
                collapsed: ExpandableButton(
                  child: settingsTile(
                    leadingIcon: Icons.blur_circular,
                    leadingIconColor: AppColors.accent,
                    titleText: S.of(context).userlayoutsettingsLanguage,
                    trailingIcon: Icons.keyboard_arrow_down_rounded,
                    tileColor: Colors.white,
                  ),
                ),
                expanded: Column(
                  children: [
                    ExpandableButton(
                      child: settingsTile(
                        leadingIcon: Icons.blur_circular,
                        leadingIconColor: Colors.white,
                        titleText: S.of(context).userlayoutsettingsLanguage,
                        titleTextColor: Colors.white,
                        trailingIcon: Icons.keyboard_arrow_up_outlined,
                        trailingIconColor: Colors.white,
                        trailingIconBackColor: Colors.white30,
                        tileColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    GestureDetector(
                      onTap: () => _submitBoardingLang('en'),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          side: const BorderSide(
                              width: 0.5, color: Colors.grey),
                        ),
                        title: defaultText(
                          text:
                              S.of(context).userlayoutsettingsLanguageenglish,
                          textAlign: TextAlign.center,
                        ),
                        tileColor:
                            !isEnglish ? Colors.white : AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    GestureDetector(
                      onTap: () => _submitBoardingLang('ar'),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          side: const BorderSide(
                              width: 0.5, color: Colors.grey),
                        ),
                        title: defaultText(
                          text: S.of(context).userlayoutsettingsLanguagearabic,
                          textAlign: TextAlign.center,
                        ),
                        tileColor:
                            isEnglish ? Colors.white : AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          settingsTile(
            leadingIcon: Icons.shield_outlined,
            leadingIconColor: AppColors.accent,
            titleText: S.of(context).userlayoutsettingspolicy,
            trailingIcon: Icons.keyboard_arrow_right_outlined,
            tileColor: Colors.white,
            onTap: () {
              navigateTo(context, const PrivacyPolicyScreen());
            },
          ),
          const SizedBox(height: 20.0),
          settingsTile(
            leadingIcon: Icons.my_library_books_outlined,
            leadingIconColor: AppColors.accent,
            titleText: S.of(context).userlayoutsettingsterms,
            trailingIcon: Icons.keyboard_arrow_right_outlined,
            tileColor: Colors.white,
            onTap: () {
              navigateTo(context, const TermsScreen());
            },
          ),
          const SizedBox(height: 20.0),
          settingsTile(
            leadingIcon: Icons.mail_outline_rounded,
            leadingIconColor: AppColors.accent,
            titleText: S.of(context).userlayoutsettingscontactus,
            trailingIcon: Icons.keyboard_arrow_right_outlined,
            tileColor: Colors.white,
            onTap: () {
              navigateTo(context, const ContactUsScreen());
            },
          ),
          const SizedBox(height: 20.0),
          settingsTile(
            leadingIcon: Icons.call_outlined,
            leadingIconColor: AppColors.accent,
            titleText: '0595845454',
            trailingIconBackColor: Colors.transparent,
            tileColor: Colors.white,
            onTap: () {
              _launchURL('tel:0595845454');
            },
          ),
          const SizedBox(height: 25.0),
          settingsTile(
            leadingIcon: Icons.logout,
            titleText: S.of(context).userlayoutsettingslogout,
            titleTextColor: Colors.white,
            trailingIconBackColor: Colors.transparent,
            tileColor: AppColors.primary,
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) {
                  bool isLoggingOut = false;
                  return StatefulBuilder(
                    builder: (context, setDialogState) {
                      return PopScope(
                        canPop: !isLoggingOut,
                        child: AlertDialog(
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.white,
                          iconPadding: EdgeInsets.zero,
                          content: SizedBox(
                            height: MediaQuery.of(context).size.height / 3.5,
                            child: Column(
                              children: [
                                Text(
                                  S.of(context).doYouWantToLogout,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
                                  height:
                                      MediaQuery.of(context).size.height / 4,
                                  child: Image.asset('assets/images/sad.png'),
                                )
                              ],
                            ),
                          ),
                          actions: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                    border: Border.all(
                                      width: 1,
                                      color: isLoggingOut
                                          ? Colors.grey.shade300
                                          : Colors.black,
                                    ),
                                  ),
                                  child: MaterialButton(
                                    onPressed: isLoggingOut
                                        ? null
                                        : () {
                                            Navigator.pop(dialogContext);
                                          },
                                    child: Text(
                                      S.of(context).no,
                                      style: TextStyle(
                                        color: isLoggingOut
                                            ? Colors.grey
                                            : Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: isLoggingOut
                                        ? AppColors.primary.withOpacity(0.7)
                                        : AppColors.primary,
                                  ),
                                  child: MaterialButton(
                                    onPressed: isLoggingOut
                                        ? null
                                        : () async {
                                            setDialogState(() {
                                              isLoggingOut = true;
                                            });
                                            await _performLogout(context);
                                          },
                                    child: isLoggingOut
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            S.of(context).yes,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
