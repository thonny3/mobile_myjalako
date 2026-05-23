import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../demo_data.dart';
import '../models/budget.dart';
import '../responsive.dart';
import '../services/auth_service.dart';
import '../services/budget_service.dart';
import 'budget_detail_screen.dart';
import 'new_budget_screen.dart';

class BudgetsScreen extends StatefulWidget {
  final String currency;
  final double bottomPadding;

  const BudgetsScreen({
    super.key,
    required this.currency,
    this.bottomPadding = 0,
  });

  @override
  State<BudgetsScreen> createState() => BudgetsScreenState();
}

class BudgetsScreenState extends State<BudgetsScreen> {
  void reload() => _loadBudgets();
  void openNewBudget() => _openNewBudget();

  static const _monthLabels = [
    'Janvier',
    'Fevrier',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Aout',
    'Septembre',
    'Octobre',
    'Novembre',
    'Decembre',
  ];

  String _filter = 'Tous';
  bool _isLoading = true;
  String? _errorMessage;
  List<Budget> _budgets = [];
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  List<Budget> get _monthBudgets =>
      _budgets.where((b) => b.isForMonth(_selectedMonth)).toList();

  int get _totalLimit =>
      _monthBudgets.fold(0, (s, b) => s + b.limit.round());

  int get _totalSpent =>
      _monthBudgets.fold(0, (s, b) => s + b.spent.round());

  int get _totalRemaining => _totalLimit - _totalSpent;

  double get _globalProgress =>
      _totalLimit > 0 ? (_totalSpent / _totalLimit).clamp(0.0, 1.0) : 0.0;

  List<Budget> get _filteredBudgets {
    return _monthBudgets.where((b) {
      final progress = b.limit > 0 ? b.spent / b.limit : 0.0;
      switch (_filter) {
        case 'Depasses':
          return b.isOver;
        case 'OK':
          return progress <= 0.75;
        default:
          return true;
      }
    }).toList();
  }

  int get _overBudgetCount => _monthBudgets.where((b) => b.isOver).length;

  bool get _canGoNextMonth {
    final now = DateTime.now();
    return _selectedMonth.year < now.year ||
        (_selectedMonth.year == now.year && _selectedMonth.month < now.month);
  }

  String _formatAmount(num amount) => DemoData.formatAmount(amount);

  String get _monthLabel {
    final m = _selectedMonth.month;
    return '${_monthLabels[m - 1]} ${_selectedMonth.year}';
  }

  Future<void> _loadBudgets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await BudgetService.getAll();
      if (!mounted) return;
      setState(() {
        _budgets = list;
        _isLoading = false;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _budgets = [];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger les budgets : $e';
        _budgets = [];
      });
    }
  }

  Future<void> _openNewBudget() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => NewBudgetScreen(
          currency: widget.currency,
          selectedMonth: _selectedMonth,
        ),
      ),
    );

    if (created != true || !mounted) return;
    await _loadBudgets();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Budget cree avec succes'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openDetail(Budget budget) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetDetailScreen(
          idBudget: budget.idBudget,
          currency: widget.currency,
        ),
      ),
    );
    if (changed == true && mounted) await _loadBudgets();
  }

  void _prevMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    if (!_canGoNextMonth) return;
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final h = r.horizontalPadding;
    final filtered = _filteredBudgets;

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: _loadBudgets,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(bottom: widget.bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(r),
            Transform.translate(
              offset: const Offset(0, -24),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: h),
                child: _buildSummaryCard(),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: h),
              child: _buildMonthSelector(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: h),
              child: _buildFilterChips(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoading
                              ? 'Categories (…)'
                              : 'Categories (${filtered.length})',
                          style: const TextStyle(
                            color: Color(0xFF1C2D11),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_overBudgetCount > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '$_overBudgetCount depasse${_overBudgetCount > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Color(0xFFC62828),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_overBudgetCount > 0 && !_isLoading)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_overBudgetCount',
                        style: const TextStyle(
                          color: Color(0xFFC62828),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Material(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: _isLoading ? null : _openNewBudget,
                      borderRadius: BorderRadius.circular(14),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.add_rounded,
                          color: AppColors.accent,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              )
            else if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: h),
                child: _buildErrorCard(_errorMessage!),
              )
            else if (filtered.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: h),
                child: _buildEmptyCard(),
              )
            else
              ...filtered.map(_buildBudgetTile),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppResponsive r) {
    return Container(
      width: double.infinity,
      padding: r.headerInsets(),
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budgets',
            style: TextStyle(
              color: Colors.white,
              fontSize: r.titleMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Suivez vos depenses par categorie',
            style: TextStyle(color: Colors.white70, fontSize: r.sp(13)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final isOver = _totalSpent > _totalLimit;
    final progressColor = isOver ? const Color(0xFFC62828) : AppColors.accent;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF8E9A86).withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Budget mensuel global',
                style: TextStyle(
                  color: Color(0xFF8E9A86),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOver ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isLoading ? '…' : '${(_globalProgress * 100).round()} %',
                  style: TextStyle(
                    color: isOver ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _isLoading ? 0 : _globalProgress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: const Color(0xFFF0F2EF),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryStat(
                  'Depense',
                  _isLoading ? 0 : _totalSpent,
                  const Color(0xFF1C2D11),
                ),
              ),
              Container(
                height: 36,
                width: 1,
                color: const Color(0xFF8E9A86).withValues(alpha: 0.12),
              ),
              Expanded(
                child: _buildSummaryStat(
                  'Restant',
                  _isLoading ? 0 : _totalRemaining,
                  _totalRemaining >= 0
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                ),
              ),
              Container(
                height: 36,
                width: 1,
                color: const Color(0xFF8E9A86).withValues(alpha: 0.12),
              ),
              Expanded(
                child: _buildSummaryStat(
                  'Plafond',
                  _isLoading ? 0 : _totalLimit,
                  const Color(0xFF8E9A86),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, int value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8E9A86),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_formatAmount(value)} ${widget.currency}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8E9A86).withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _isLoading ? null : _prevMonth,
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.accent),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Text(
            _monthLabel,
            style: const TextStyle(
              color: Color(0xFF1C2D11),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: _isLoading || !_canGoNextMonth ? null : _nextMonth,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: _canGoNextMonth
                  ? AppColors.accent
                  : const Color(0xFF8E9A86).withValues(alpha: 0.35),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    const filters = ['Tous', 'OK', 'Depasses'];
    const labels = ['Tous', 'OK', 'Depasses'];
    return Row(
      children: List.generate(filters.length, (i) {
        final f = filters[i];
        final label = labels[i];
        final selected = _filter == f;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(label),
            selected: selected,
            onSelected: _isLoading ? null : (_) => setState(() => _filter = f),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF1C2D11),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            selectedColor: AppColors.accent,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected
                  ? AppColors.accent
                  : const Color(0xFF8E9A86).withValues(alpha: 0.2),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        );
      }),
    );
  }

  Widget _buildBudgetTile(Budget budget) {
    final ui = budget.toUiMap();
    final spent = budget.spent.round();
    final limit = budget.limit.round();
    final displayProgress = budget.progress.clamp(0.0, 1.0);
    final isOver = budget.isOver;
    final remaining = budget.remaining.round();
    final barColor = isOver ? const Color(0xFFC62828) : ui['color'] as Color;

    return Padding(
      padding: EdgeInsets.only(
        left: context.responsive.horizontalPadding,
        right: context.responsive.horizontalPadding,
        bottom: 12,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _openDetail(budget),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOver
                    ? const Color(0xFFC62828).withValues(alpha: 0.25)
                    : const Color(0xFF8E9A86).withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ui['bg'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        ui['icon'] as IconData,
                        color: ui['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ui['title'] as String,
                            style: const TextStyle(
                              color: Color(0xFF1C2D11),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_formatAmount(spent)} / ${_formatAmount(limit)} ${widget.currency}',
                            style: const TextStyle(
                              color: Color(0xFF8E9A86),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(displayProgress * 100).round()} %',
                      style: TextStyle(
                        color: isOver ? const Color(0xFFC62828) : AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: displayProgress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF0F2EF),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isOver
                      ? 'Depasse de ${_formatAmount(-remaining)} ${widget.currency}'
                      : remaining > 0
                          ? 'Il reste ${_formatAmount(remaining)} ${widget.currency}'
                          : 'Budget epuise',
                  style: TextStyle(
                    color: isOver ? const Color(0xFFC62828) : const Color(0xFF7F8E75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8E9A86).withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pie_chart_outline_rounded,
            size: 48,
            color: AppColors.accent.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun budget pour $_monthLabel',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1C2D11),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Creez un budget par categorie avec le bouton + ci-dessus.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF7F8E75), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _loadBudgets,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.accent),
            label: const Text('Reessayer', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}
