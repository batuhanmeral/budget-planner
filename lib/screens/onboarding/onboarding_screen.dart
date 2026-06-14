import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app_constants.dart';
import '../../app/app_routes.dart';
import '../../app/locale_controller.dart';
import '../../l10n/app_l10n.dart';

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  List<_OnboardingPage> _buildPages(AppL10n l) => [
    _OnboardingPage(
      icon: Icons.receipt_long,
      title: l.onboardingTitle1,
      subtitle: l.onboardingSubtitle1,
    ),
    _OnboardingPage(
      icon: Icons.savings_outlined,
      title: l.onboardingTitle2,
      subtitle: l.onboardingSubtitle2,
    ),
    _OnboardingPage(
      icon: Icons.pie_chart_outline,
      title: l.onboardingTitle3,
      subtitle: l.onboardingSubtitle3,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final navigator = Navigator.of(context);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.onboardingSeen, true);
    if (!mounted) return;
    navigator.pushReplacementNamed(AppRoutes.login);
  }

  void _next(int total) {
    if (_index < total - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pages = _buildPages(l);
    final isLast = _index == pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLast ? null : _finish,
                child: Text(isLast ? '' : l.skip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _PageView(page: pages[i]),
              ),
            ),
            _DotsIndicator(count: pages.length, current: _index),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _next(pages.length),
                  child: Text(isLast ? l.start : l.next),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  final _OnboardingPage page;
  const _PageView({required this.page});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 80, color: primary),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final inactive = Theme.of(
      context,
    ).colorScheme.outline.withValues(alpha: 0.3);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: i == current ? 24 : 8,
            decoration: BoxDecoration(
              color: i == current ? primary : inactive,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
