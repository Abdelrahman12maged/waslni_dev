import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:car_app/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restart_app/restart_app.dart';

class ChooseLangScreen extends StatefulWidget {
  const ChooseLangScreen({super.key});

  @override
  State<ChooseLangScreen> createState() => _ChooseLangScreenState();
}

class _ChooseLangScreenState extends State<ChooseLangScreen> {
  bool _isEnglish = true;
  bool _isLoading = false;

  Future<void> _submitLang(String lang) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final storage = sl<LocalStorage>();
    await storage.saveString(key: 'lang', value: lang);
    await storage.saveBool(key: 'onboarding', value: false);

    if (mounted) {
      MyApp.setLocale(context, lang);
      await Restart.restartApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/changelang.png'),
              const SizedBox(height: 30.0),
              Text(
                S.of(context).welcomeChooseLanguage,
                style: const TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30.0),

              // ── Arabic ────────────────────────────────────
              _LangTile(
                label: S.of(context).userlayoutsettingsLanguagearabic,
                isSelected: !_isEnglish,
                onTap: () {
                  setState(() => _isEnglish = false);
                  _submitLang('ar');
                },
              ),
              const SizedBox(height: 20.0),

              // ── English ───────────────────────────────────
              _LangTile(
                label: S.of(context).userlayoutsettingsLanguageenglish,
                isSelected: _isEnglish,
                onTap: () {
                  setState(() => _isEnglish = true);
                  _submitLang('en');
                },
              ),

              if (_isLoading) ...[
                const SizedBox(height: 30),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: isSelected ? AppColors.primary : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: const BorderSide(width: 0.5),
      ),
      leading: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: 15.0,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Icon(
          Icons.keyboard_arrow_right_outlined,
          size: 25.0,
          color: isSelected ? AppColors.primary : Colors.white,
        ),
      ),
    );
  }
}
