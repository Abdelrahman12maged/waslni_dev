import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class _BoardingItem {
  final String image;
  final String title;
  final String body;
  const _BoardingItem({
    required this.image,
    required this.title,
    required this.body,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  List<_BoardingItem> get _items => [
        _BoardingItem(
          image: 'assets/images/onboarding1.svg',
          title: S.of(context).welcomeToCarApp,
          body: S.of(context).introMessage,
        ),
        _BoardingItem(
          image: 'assets/images/onboarding2.svg',
          title: S.of(context).journeyStartsHere,
          body: S.of(context).unlockPossibilities,
        ),
        _BoardingItem(
          image: 'assets/images/onboarding3.svg',
          title: S.of(context).experienceFuture,
          body: S.of(context).joinInnovation,
        ),
      ];

  bool get _isFirst => _currentIndex == 0;
  bool get _isLast => _currentIndex == _items.length - 1;

  void _goToNext() {
    if (_isLast) {
      _finishOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 750),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  void _goToPrevious() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 750),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  void _finishOnboarding() async {
    final storage = sl<LocalStorage>();
    await storage.saveBool(key: 'onboarding', value: false);
    if (mounted) {
      context.go(AppRoutes.chooseLang);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: !_isFirst
              ? IconButton(
                  onPressed: _goToPrevious,
                  icon: const Icon(Icons.arrow_back_ios),
                )
              : const SizedBox.shrink(),
          actions: [
            TextButton(
              onPressed: _finishOnboarding,
              child: Text(S.of(context).skip),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (context, index) =>
                      _BoardingItemWidget(item: items[index]),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: items.length,
                      effect: CustomizableEffect(
                        dotDecoration: DotDecoration(
                          width: 12.0,
                          height: 20.0,
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        activeDotDecoration: DotDecoration(
                          width: 11.0,
                          height: 35.0,
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    FloatingActionButton(
                      backgroundColor: AppColors.primary,
                      onPressed: _goToNext,
                      child: const Icon(Icons.arrow_forward_ios,
                          color: Colors.white),
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

class _BoardingItemWidget extends StatelessWidget {
  final _BoardingItem item;
  const _BoardingItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: SvgPicture.asset(item.image)),
        const SizedBox(height: 20.0),
        Text(
          item.title,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15.0),
        Text(
          item.body,
          style: const TextStyle(fontSize: 15.0, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
