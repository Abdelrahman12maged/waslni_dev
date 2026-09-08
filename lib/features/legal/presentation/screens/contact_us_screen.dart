import 'package:car_app/generated/l10n.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _launchURL(BuildContext context, String link) async {
    try {
      final Uri url = Uri.parse(link);
      final bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $link'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $link'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(
        backgroundColor: Colors.grey[300],
        leadingOnPressed: () {
          Navigator.of(context).pop();
        },
        titleText: S.of(context).userlayoutsettingscontactus,
        actionsIconColor: AppColors.primary,
        actionsOnPressed: () {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _launchURL(context, 'tel:59725881953'),
              child: contactListTile(
                leadingIcon: Icons.phone_in_talk_outlined,
                titleText: S.of(context).mobileNumber,
                subtitleText: '+59725881953',
              ),
            ),
            GestureDetector(
              onTap: () {
                final website = ApiEndpoints.companyWebsite;
                if (website.isNotEmpty) _launchURL(context, website);
              },
              child: contactListTile(
                titleText: S.of(context).website,
                subtitleText: ApiEndpoints.companyWebsite,
                leadingIcon: Icons.blur_circular,
              ),
            ),
            GestureDetector(
              onTap: () {
                final email = ApiEndpoints.supportEmail;
                if (email.isNotEmpty) _launchURL(context, 'mailto:$email');
              },
              child: contactListTile(
                titleText: S.of(context).email,
                subtitleText: ApiEndpoints.supportEmail,
                leadingIcon: Icons.email_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
