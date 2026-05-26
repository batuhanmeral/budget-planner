import 'package:flutter/material.dart';

import '../app/locale_controller.dart';

/// Bir kategorinin bütçesi ile harcaması arasındaki orandan üretilen
/// uyarı verisi. Ratio = harcama / limit.
///
/// [isOver] >= 1.0, [isWarning] 0.9-1.0 arasında.
class BudgetAlert {
  final String category;
  final double ratio;
  const BudgetAlert({required this.category, required this.ratio});

  bool get isOver => ratio >= 1.0;
  bool get isWarning => !isOver && ratio >= 0.9;
}

/// Dashboard ve bütçe listesinin üstünde gösterilen uyarı banner'ı.
///
/// Aşılan bütçeler varsa kırmızı, yoksa %90 üstü varsa turuncu banner.
/// Hiçbir uyarı yoksa boş widget döner — ekranda yer kaplamaz.
/// Birden fazla kategori varsa adlar virgülle birleştirilir.
class BudgetAlertBanner extends StatelessWidget {
  final List<BudgetAlert> alerts;

  const BudgetAlertBanner({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    final over = alerts.where((a) => a.isOver).toList();
    final warning = alerts.where((a) => a.isWarning).toList();

    if (over.isEmpty && warning.isEmpty) return const SizedBox.shrink();

    final isRed = over.isNotEmpty;
    final color = isRed ? Colors.red : Colors.orange;
    final icon = isRed ? Icons.error_outline : Icons.warning_amber_rounded;
    final list = isRed ? over : warning;
    final names = list.map((a) => a.category).join(', ');
    final l = context.l10n;
    final message = isRed ? l.budgetAlertOver(names) : l.budgetAlertWarn(names);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
