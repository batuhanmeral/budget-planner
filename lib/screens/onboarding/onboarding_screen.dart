import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app_constants.dart';
import '../../app/app_routes.dart';

/// Tek bir onboarding sayfasının görsel verisi.
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

/// Uygulamanın ilk açılışında gösterilen 3 sayfalık tanıtım ekranı.
///
/// Her sayfa: büyük ikon + başlık + alt metin. Altta sayfa indicator
/// dot'ları ve "Atla / İleri" butonları. Son sayfada "Başla" butonu
/// onboarding'i tamamlar — prefs'e işaret yazılır ve login'e yönlendirilir.
///
/// Splash bu ekrana yalnızca [PrefsKeys.onboardingSeen] yoksa
/// yönlendirir; sonraki açılışlarda atlanır.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = <_OnboardingPage>[
    _OnboardingPage(
      icon: Icons.receipt_long,
      title: 'Harcamalarını takip et',
      subtitle:
          'Günlük harcamalarını kategorilerle birlikte kaydet, nereye ne kadar gittiğini hatırla.',
    ),
    _OnboardingPage(
      icon: Icons.savings_outlined,
      title: 'Bütçe belirle',
      subtitle:
          'Her kategori için aylık limit koy, %90\'a yaklaşınca uyarı al.',
    ),
    _OnboardingPage(
      icon: Icons.pie_chart_outline,
      title: 'Aylık rapor',
      subtitle:
          'Pasta grafik, haftalık bar ve yıllık özet ile finansal durumunu tek bakışta gör.',
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

  void _next() {
    if (_index < _pages.length - 1) {
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
    final isLast = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLast ? null : _finish,
                child: Text(isLast ? '' : 'Atla'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _PageView(page: _pages[i]),
              ),
            ),
            _DotsIndicator(count: _pages.length, current: _index),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(isLast ? 'Başla' : 'İleri'),
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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
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

/// Aktif sayfayı göstermek için 3 küçük nokta.
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
