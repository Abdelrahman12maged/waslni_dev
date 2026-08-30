import 'package:car_app/generated/l10n.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(
        backgroundColor: Colors.grey[300],
        leadingOnPressed: () {
          Navigator.of(context).pop();
        },
        titleText: S.of(context).userlayoutsettingsterms,
        actionsIconColor: AppColors.primary,
        actionsOnPressed: () {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/terms.svg'),
            const SizedBox(height: 25.0),
            defaultText(
              text: S.of(context).fullTermsText,
              spaceBetweenLines: 1.8,
            ),
          ],
        ),
      ),
    );
  }
}
