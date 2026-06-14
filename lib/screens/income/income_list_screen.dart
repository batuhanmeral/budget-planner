import 'package:flutter/material.dart';

import '../../app/locale_controller.dart';
import '../../models/income.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/income_repository.dart';
import '../../widgets/date_range_filter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/income_tile.dart';
import '../../widgets/search_field.dart';
import 'income_calendar_view.dart';
import 'income_detail_screen.dart';
import 'income_form_screen.dart';

enum _ViewMode { list, calendar }

class IncomeListScreen extends StatefulWidget {
  const IncomeListScreen({super.key});

  @override
  State<IncomeListScreen> createState() => IncomeListScreenState();
}

class IncomeListScreenState extends State<IncomeListScreen> {
  String? _source;
  DateRangeValue? _range;
  String _query = '';
  IncomeSort _sort = IncomeSort.dateDesc;
  _ViewMode _view = _ViewMode.list;
  late Future<List<Income>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Income>> _load() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return [];
    return IncomeRepository.instance.getFilteredAndSorted(
      userId: user.id!,
      source: _source,
      from: _range?.from,
      to: _range?.to,
      noteQuery: _query,
      sort: _sort,
    );
  }

  void reload() {
    setState(() => _future = _load());
  }

  Future<void> _openDetail(Income income) async {
    final navigator = Navigator.of(context);
    final changed = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (_) => IncomeDetailScreen(incomeId: income.id!),
      ),
    );
    if (changed == true) reload();
  }

  Future<void> openAdd() async {
    final navigator = Navigator.of(context);
    final saved = await navigator.push<bool>(
      MaterialPageRoute(builder: (_) => const IncomeFormScreen()),
    );
    if (saved == true) reload();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final user = AuthService.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SegmentedButton<_ViewMode>(
            segments: [
              ButtonSegment(
                value: _ViewMode.list,
                label: Text(l.viewList),
                icon: const Icon(Icons.list),
              ),
              ButtonSegment(
                value: _ViewMode.calendar,
                label: Text(l.viewCalendar),
                icon: const Icon(Icons.calendar_month),
              ),
            ],
            selected: {_view},
            onSelectionChanged: (s) => setState(() => _view = s.first),
          ),
        ),
        Expanded(
          child: _view == _ViewMode.calendar
              ? const IncomeCalendarView()
              : _buildListBody(),
        ),
      ],
    );
  }

  Widget _buildListBody() {
    final l = context.l10n;
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
                      hint: l.searchByNoteHint,
                      onChanged: (v) {
                        _query = v;
                        reload();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<IncomeSort>(
                    tooltip: l.sortTooltip,
                    icon: const Icon(Icons.sort),
                    initialValue: _sort,
                    onSelected: (v) {
                      setState(() => _sort = v);
                      reload();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: IncomeSort.dateDesc,
                        child: Text(l.sortDateDesc),
                      ),
                      PopupMenuItem(
                        value: IncomeSort.dateAsc,
                        child: Text(l.sortDateAsc),
                      ),
                      PopupMenuItem(
                        value: IncomeSort.amountDesc,
                        child: Text(l.sortAmountDesc),
                      ),
                      PopupMenuItem(
                        value: IncomeSort.amountAsc,
                        child: Text(l.sortAmountAsc),
                      ),
                      PopupMenuItem(
                        value: IncomeSort.source,
                        child: Text(l.sortSourceAsc),
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
                            label: Text(l.all),
                            selected: _source == null,
                            onSelected: (_) {
                              setState(() => _source = null);
                              reload();
                            },
                          ),
                        ),
                        for (final s in CategoryService.instance.incomeAll)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              avatar: Icon(s.icon, size: 16, color: s.color),
                              label: Text(s.name),
                              selected: _source == s.name,
                              onSelected: (_) {
                                setState(
                                  () => _source = _source == s.name
                                      ? null
                                      : s.name,
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
          child: FutureBuilder<List<Income>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text(l.loadingDataError));
              }
              final items = snapshot.data ?? const <Income>[];
              if (items.isEmpty) {
                return EmptyState(
                  icon: Icons.savings_outlined,
                  title: l.emptyIncomesTitle,
                  subtitle: _source != null || _query.isNotEmpty
                      ? l.emptyIncomesFilterSubtitle
                      : l.emptyIncomesSubtitle,
                );
              }
              return RefreshIndicator(
                onRefresh: () async => reload(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final inc = items[i];
                    return IncomeTile(
                      income: inc,
                      onTap: () => _openDetail(inc),
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
