import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../services/auth_service.dart';

/// Uygulama açılışında gösterilen, auto-login kontrolü yapan ekran.
///
/// `tryAutoLogin` sonucuna göre Home'a veya Login'e yönlendirir; back
/// stack'i temizleyerek splash'a geri dönmeyi engeller.
///
/// İlk frame'den sonra çalışsın diye `addPostFrameCallback` kullanılır
/// — initState'te doğrudan Navigator çağırmak hata verir.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final user = await AuthService.instance.tryAutoLogin();
    if (!mounted) return;
    final route = user != null ? AppRoutes.home : AppRoutes.login;
    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
