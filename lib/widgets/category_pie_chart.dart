import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/app_constants.dart';
import '../utils/formatters.dart';
import 'category_chip.dart';

/// Tek bir pasta dilimi için veri.
class PieSlice {
  final AppCategory category;
  final double amount;
  const PieSlice({required this.category, required this.amount});
}

/// Kategori dağılımını donut (delikli pasta) olarak gösteren grafik.
///
/// Saf [CustomPainter] ile çizilir — ek paket yok. Ortadaki halkada
/// toplam tutar gösterilir. Bir dilime tıklanırsa dilim hafifçe dışa
/// kayar (seçim feedback'i) ve altta o kategorinin etiketi + tutarı +
/// yüzdesi belirir.
///
/// Boş listede placeholder gösterir.
class CategoryPieChart extends StatefulWidget {
  final List<PieSlice> slices;
  final double size;

  const CategoryPieChart({super.key, required this.slices, this.size = 220});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int? _selectedIndex;

  double get _total =>
      widget.slices.fold<double>(0, (sum, s) => sum + s.amount);

  void _handleTap(TapUpDetails details) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final local = details.localPosition;
    final dx = local.dx - center.dx;
    final dy = local.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final outerR = widget.size / 2;
    final innerR = outerR * 0.55;
    // Halka dışı veya iç delik içindeki dokunuşları yok say.
    if (dist > outerR || dist < innerR) {
      setState(() => _selectedIndex = null);
      return;
    }
    // atan2 -pi..pi döner; -90° başlangıç (saat 12) için kaydır.
    var angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;
    var cumulative = 0.0;
    for (var i = 0; i < widget.slices.length; i++) {
      final share = _total == 0 ? 0 : widget.slices[i].amount / _total;
      final end = cumulative + share * 2 * math.pi;
      if (angle <= end) {
        setState(() {
          _selectedIndex = _selectedIndex == i ? null : i;
        });
        return;
      }
      cumulative = end;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slices.isEmpty || _total <= 0) {
      return SizedBox(
        height: widget.size,
        child: Center(
          child: Text(
            'Bu ay harcama yok',
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
      );
    }
    return Column(
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: GestureDetector(
            onTapUp: _handleTap,
            child: CustomPaint(
              painter: _PiePainter(
                slices: widget.slices,
                total: _total,
                selectedIndex: _selectedIndex,
                ringColor: Theme.of(context).colorScheme.surface,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Toplam',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.money(_total),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SelectionLabel(
          selected: _selectedIndex == null
              ? null
              : widget.slices[_selectedIndex!],
          total: _total,
        ),
      ],
    );
  }
}

class _SelectionLabel extends StatelessWidget {
  final PieSlice? selected;
  final double total;

  const _SelectionLabel({required this.selected, required this.total});

  @override
  Widget build(BuildContext context) {
    if (selected == null) {
      return Text(
        'Dilime dokunarak detayını görebilirsin',
        style: TextStyle(color: Theme.of(context).colorScheme.outline),
      );
    }
    final percent = total <= 0 ? 0 : (selected!.amount / total * 100);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CategoryChip(category: selected!.category, dense: true),
        const SizedBox(width: 8),
        Text(
          Formatters.money(selected!.amount),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 8),
        Text(
          '(%${percent.toStringAsFixed(0)})',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      ],
    );
  }
}

/// CustomPainter — donut dilimlerini çizer.
///
/// Saat 12'den başlar, saat yönünde dolar. Seçili dilim 6px dışa kayar
/// — vurgulu görüntü için.
class _PiePainter extends CustomPainter {
  final List<PieSlice> slices;
  final double total;
  final int? selectedIndex;
  final Color ringColor;

  _PiePainter({
    required this.slices,
    required this.total,
    required this.selectedIndex,
    required this.ringColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;
    final innerR = outerR * 0.55;

    // Başlangıç açısı: saat 12 (yukarı) = -pi/2.
    var start = -math.pi / 2;

    for (var i = 0; i < slices.length; i++) {
      final share = slices[i].amount / total;
      final sweep = share * 2 * math.pi;
      final isSelected = selectedIndex == i;

      // Seçili dilim için dilimin orta açısı yönünde hafif kaydırma.
      var sliceCenter = center;
      if (isSelected) {
        final midAngle = start + sweep / 2;
        const offset = 8.0;
        sliceCenter = Offset(
          center.dx + math.cos(midAngle) * offset,
          center.dy + math.sin(midAngle) * offset,
        );
      }

      final paint = Paint()
        ..color = slices[i].category.color
        ..style = PaintingStyle.fill;
      final path = Path()
        ..moveTo(sliceCenter.dx, sliceCenter.dy)
        ..arcTo(
          Rect.fromCircle(center: sliceCenter, radius: outerR),
          start,
          sweep,
          false,
        )
        ..close();
      canvas.drawPath(path, paint);

      start += sweep;
    }

    // İç delik — donut görünümü için.
    final holePaint = Paint()..color = ringColor;
    canvas.drawCircle(center, innerR, holePaint);
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.slices != slices ||
        oldDelegate.total != total ||
        oldDelegate.ringColor != ringColor;
  }
}
