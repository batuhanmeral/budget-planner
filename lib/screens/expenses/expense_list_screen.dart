import 'package:flutter/material.dart';

import '../../models/expense.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/expense_repository.dart';
import '../../widgets/date_range_filter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/expense_tile.dart';
import '../../widgets/search_field.dart';
import 'expense_calendar_view.dart';
import 'expense_detail_screen.dart';
import 'expense_form_screen.dart';

/// Harcama görüntüleme modu — üstteki SegmentedButton'dan seçilir.
enum _ViewMode { list, calendar }

/// Harcamalar sekmesinin içeriği. HomeScreen'in IndexedStack'i içine
/// yerleştirilir; kendi Scaffold'u yoktur.
///
/// İki görünüm: **Liste** (arama+filtre+sıralama+liste) ve **Takvim**
/// (ay grid + gün bottom sheet). Üstteki [SegmentedButton] ile geçilir.
/// Filtreler sadece liste görünümünde etkilidir; takvim kendi ay
/// navigasyonunu yönetir.
///
/// State public ([ExpenseListScreenState]) çünkü HomeScreen FAB'ı
/// GlobalKey üzerinden `openAdd()` ve `reload()` çağırıyor.
class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => ExpenseListScreenState();
}

class ExpenseListScreenState extends State<ExpenseListScreen> {
  String? _category;
  DateRangeValue? _range;
  String _query = '';
  ExpenseSort _sort = ExpenseSort.dateDesc;
  _ViewMode _view = _ViewMode.list;
  late Future<List<Expense>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Expense>> _load() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return [];
    return ExpenseRepository.instance.getFilteredAndSorted(
      userId: user.id!,
      category: _category,
      from: _range?.from,
      to: _range?.to,
      noteQuery: _query,
      sort: _sort,
    );
  }

  void reload() {
    setState(() => _future = _load());
  }

  Future<void> _openDetail(Expense expense) async {
    final navigator = Navigator.of(context);
    final changed = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (_) => ExpenseDetailScreen(expenseId: expense.id!),
      ),
    );
    if (changed == true) reload();
  }

  Future<void> openAdd() async {
    final navigator = Navigator.of(context);
    final saved = await navigator.push<bool>(
      MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
    );
    if (saved == true) reload();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Liste/Takvim toggle — her zaman görünür.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SegmentedButton<_ViewMode>(
            segments: const [
              ButtonSegment(
                value: _ViewMode.list,
                label: Text('Liste'),
                icon: Icon(Icons.list),
              ),
              ButtonSegment(
                value: _ViewMode.calendar,
                label: Text('Takvim'),
                icon: Icon(Icons.calendar_month),
              ),
            ],
            selected: {_view},
            onSelectionChanged: (s) => setState(() => _view = s.first),
          ),
        ),
        Expanded(
          child: _view == _ViewMode.calendar
              ? const ExpenseCalendarView()
              : _buildListBody(),
        ),
      ],
    );
  }

  /// Liste modunun gövdesi — filtreler + FutureBuilder.
  Widget _buildListBody() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SearchField(
                      hint: 'Açıklamada ara...',
                      onChanged: (v) {
                        _query = v;
                        reload();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<ExpenseSort>(
                    tooltip: 'Sırala',
                    icon: const Icon(Icons.sort),
                    initialValue: _sort,
                    onSelected: (v) {
                      setState(() => _sort = v);
                      reload();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: ExpenseSort.dateDesc,
                        child: Text('Tarih (yeni)'),
                      ),
                      PopupMenuItem(
                        value: ExpenseSort.dateAsc,
                        child: Text('Tarih (eski)'),
                      ),
                      PopupMenuItem(
                        value: ExpenseSort.amountDesc,
                        child: Text('Tutar (yüksek)'),
                      ),
                      PopupMenuItem(
                        value: ExpenseSort.amountAsc,
                        child: Text('Tutar (düşük)'),
                      ),
                      PopupMenuItem(
                        value: ExpenseSort.category,
                        child: Text('Kategori'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DateRangeFilter(
                value: _range ?? DateRangeValue.thisMonth(),
                onChanged: (v) {
                  setState(() => _range = v);
                  reload();
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: AnimatedBuilder(
                  animation: CategoryService.instance,
                  builder: (context, _) {
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: const Text('Tümü'),
                            selected: _category == null,
                            onSelected: (_) {
                              setState(() => _category = null);
                              reload();
                            },
                          ),
                        ),
                        for (final c in CategoryService.instance.all)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              avatar: Icon(c.icon, size: 16, color: c.color),
                              label: Text(c.name),
                              selected: _category == c.name,
                              onSelected: (_) {
                                setState(
                                  () => _category = _category == c.name
                                      ? null
                                      : c.name,
                                );
                                reload();
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: FutureBuilder<List<Expense>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Veriler yüklenemedi.'));
              }
              final items = snapshot.data ?? const <Expense>[];
              if (items.isEmpty) {
                return EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Henüz harcama yok',
                  subtitle: _category != null || _query.isNotEmpty
                      ? 'Filtreyi değiştirip tekrar deneyin.'
                      : 'Sağ alttaki + ile ilk harcamanı ekle.',
                );
              }
              return RefreshIndicator(
                onRefresh: () async => reload(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                  itemCount: items.length,
                  itemBuilder: (_, i) => ExpenseTile(
                    expense: items[i],
                    onTap: () => _openDetail(items[i]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
