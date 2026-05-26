import 'package:flutter/material.dart';

import '../../models/expense.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/expense_repository.dart';
import '../../widgets/category_picker_dialog.dart';
import '../../widgets/confirm_dialog.dart';
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

  // Toplu seçim modu: bir veya daha fazla harcama seçilmişse aktif.
  // Header normal filtreleri gizler, üstte seçim toolbar'ı gösterir.
  final Set<int> _selectedIds = <int>{};
  bool get _selectionMode => _selectedIds.isNotEmpty;

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

  void _exitSelectionMode() {
    setState(() => _selectedIds.clear());
  }

  void _toggleSelection(int id) {
    setState(() {
      if (!_selectedIds.add(id)) _selectedIds.remove(id);
    });
  }

  /// Seçili harcamaları toplu siler — onaylı.
  Future<void> _bulkDelete() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final count = _selectedIds.length;
    final ok = await showConfirmDialog(
      context,
      title: 'Harcamaları sil',
      message: 'Seçili $count harcamayı silmek istediğinize emin misiniz?',
    );
    if (!ok || !mounted) return;
    try {
      await ExpenseRepository.instance.deleteMany(
        ids: _selectedIds.toList(),
        userId: user.id!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count harcama silindi')),
      );
      _selectedIds.clear();
      reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silinemedi')),
      );
    }
  }

  /// Seçili harcamaların kategorisini topluca değiştirir.
  Future<void> _bulkChangeCategory() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final newCategory = await pickCategory(context);
    if (newCategory == null || !mounted) return;
    try {
      final affected = await ExpenseRepository.instance.updateCategoryMany(
        ids: _selectedIds.toList(),
        userId: user.id!,
        category: newCategory.name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$affected harcamanın kategorisi "${newCategory.name}" oldu',
          ),
        ),
      );
      _selectedIds.clear();
      reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncellenemedi')),
      );
    }
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
        // Seçim modu üstte ayrı bir toolbar gösterir; aksi takdirde
        // Liste/Takvim toggle görünür.
        if (_selectionMode)
          _SelectionToolbar(
            selectedCount: _selectedIds.length,
            onClose: _exitSelectionMode,
            onDelete: _bulkDelete,
            onChangeCategory: _bulkChangeCategory,
          )
        else
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
          child: _view == _ViewMode.calendar && !_selectionMode
              ? const ExpenseCalendarView()
              : _buildListBody(),
        ),
      ],
    );
  }

  /// Liste modunun gövdesi — filtreler + FutureBuilder.
  /// Seçim modundayken filtre alanı gizlenir (uzun listede dağılmasın).
  Widget _buildListBody() {
    return Column(
      children: [
        if (!_selectionMode)
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
        if (!_selectionMode) const Divider(height: 1),
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
                  itemBuilder: (_, i) {
                    final ex = items[i];
                    final isSelected = _selectedIds.contains(ex.id);
                    return ExpenseTile(
                      expense: ex,
                      selected: isSelected,
                      onTap: () {
                        // Seçim modundayken normal tap toggle yapar;
                        // değilse detay ekranına geçer.
                        if (_selectionMode) {
                          _toggleSelection(ex.id!);
                        } else {
                          _openDetail(ex);
                        }
                      },
                      onLongPress: () => _toggleSelection(ex.id!),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Toplu seçim modunda gösterilen üst toolbar.
///
/// AppBar HomeScreen tarafından yönetildiği için burada doğrudan
/// değiştiremiyoruz; onun yerine ekran içinde benzer görünüm sağlayan
/// bir bar gösteriyoruz. Sol: çıkış X, orta: "X seçili", sağ: aksiyonlar.
class _SelectionToolbar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onClose;
  final VoidCallback onDelete;
  final VoidCallback onChangeCategory;

  const _SelectionToolbar({
    required this.selectedCount,
    required this.onClose,
    required this.onDelete,
    required this.onChangeCategory,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: primary.withValues(alpha: 0.12),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Seçimi iptal et',
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
              Expanded(
                child: Text(
                  '$selectedCount seçili',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Kategori değiştir',
                icon: const Icon(Icons.swap_horiz),
                onPressed: onChangeCategory,
              ),
              IconButton(
                tooltip: 'Sil',
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
