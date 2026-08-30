import 'package:car_app/generated/l10n.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AgreeTermsScreen extends StatelessWidget {
  const AgreeTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/terms.svg'),
            const SizedBox(height: 25.0),
            defaultText(
              text: S.of(context).userlayoutsettingsterms,
              textColor: AppColors.primary,
              textFontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 25.0),
            defaultText(
              text: S.of(context).fullTermsText,
              spaceBetweenLines: 1.8,
            ),
            const SizedBox(height: 40.0),
            Row(
              children: [
                Expanded(
                  child: defaultButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    text: S.of(context).disagree,
                    background: Colors.white,
                    textColor: Colors.black,
                    borderColor: Colors.black87,
                    fontWeight: FontWeight.w500,
                    borderWidth: 0.5,
                  ),
                ),
                const SizedBox(width: 20.0),
                Expanded(
                  child: defaultButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    text: S.of(context).agree,
                    background: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
