import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../demo_data.dart';
import '../responsive.dart';
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
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  String _filter = 'Tous';

  final List<Map<String, dynamic>> _budgets =
      List<Map<String, dynamic>>.from(DemoData.demoBudgets);

  int get _totalLimit => _budgets.fold(0, (s, b) => s + (b['limit'] as int));
  int get _totalSpent => _budgets.fold(0, (s, b) => s + (b['spent'] as int));
  int get _totalRemaining => _totalLimit - _totalSpent;

  double get _globalProgress =>
      _totalLimit > 0 ? (_totalSpent / _totalLimit).clamp(0.0, 1.0) : 0.0;

  List<Map<String, dynamic>> get _filteredBudgets {
    return _budgets.where((b) {
      final spent = b['spent'] as int;
      final limit = b['limit'] as int;
      final progress = limit > 0 ? spent / limit : 0.0;
      switch (_filter) {
        case 'Dépassés':
          return progress > 1.0;
        case 'OK':
          return progress <= 0.75;
        default:
          return true;
      }
    }).toList();
  }

  int get _overBudgetCount =>
      _budgets.where((b) => (b['spent'] as int) > (b['limit'] as int)).length;

  String _formatAmount(num amount) => DemoData.formatAmount(amount);

  Future<void> _openNewBudget() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => NewBudgetScreen(currency: widget.currency),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _budgets.insert(0, result);
      _filter = 'Tous';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Budget « ${result['title']} » créé avec succès'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final h = r.horizontalPadding;
    final filtered = _filteredBudgets;

    return SingleChildScrollView(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Catégories (${filtered.length})',
                  style: const TextStyle(
                    color: Color(0xFF1C2D11),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_overBudgetCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_overBudgetCount dépassé${_overBudgetCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Color(0xFFC62828),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: h, vertical: 32),
              child: Center(
                child: Text(
                  'Aucun budget pour ce filtre.',
                  style: TextStyle(
                    color: const Color(0xFF8E9A86).withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...filtered.map(_buildBudgetTile),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: h),
            child: OutlinedButton.icon(
              onPressed: _openNewBudget,
              icon: const Icon(Icons.add_rounded, color: AppColors.accent),
              label: const Text(
                'Créer un budget',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.accent, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
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
            'Suivez vos dépenses par catégorie',
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
        border: Border.all(color: const Color(0xFF8E9A86).withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                  '${(_globalProgress * 100).round()} %',
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
              value: _globalProgress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: const Color(0xFFF0F2EF),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSummaryStat('Dépensé', _totalSpent, const Color(0xFF1C2D11))),
              Container(
                height: 36,
                width: 1,
                color: const Color(0xFF8E9A86).withOpacity(0.12),
              ),
              Expanded(
                child: _buildSummaryStat(
                  'Restant',
                  _totalRemaining,
                  _totalRemaining >= 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                ),
              ),
              Container(
                height: 36,
                width: 1,
                color: const Color(0xFF8E9A86).withOpacity(0.12),
              ),
              Expanded(child: _buildSummaryStat('Plafond', _totalLimit, const Color(0xFF8E9A86))),
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
        border: Border.all(color: const Color(0xFF8E9A86).withOpacity(0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.accent),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Text(
            'Mai 2026',
            style: TextStyle(
              color: Color(0xFF1C2D11),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.accent),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    const filters = ['Tous', 'OK', 'Dépassés'];
    return Row(
      children: filters.map((f) {
        final selected = _filter == f;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(f),
            selected: selected,
            onSelected: (_) => setState(() => _filter = f),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF1C2D11),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            selectedColor: AppColors.accent,
            backgroundColor: Colors.white,
            checkmarkColor: Colors.white,
            side: BorderSide(
              color: selected ? AppColors.accent : const Color(0xFF8E9A86).withOpacity(0.2),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBudgetTile(Map<String, dynamic> budget) {
    final spent = budget['spent'] as int;
    final limit = budget['limit'] as int;
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.2) : 0.0;
    final displayProgress = progress.clamp(0.0, 1.0);
    final isOver = spent > limit;
    final remaining = limit - spent;
    final barColor = isOver ? const Color(0xFFC62828) : budget['color'] as Color;

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
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOver
                    ? const Color(0xFFC62828).withOpacity(0.25)
                    : const Color(0xFF8E9A86).withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
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
                        color: budget['bg'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        budget['icon'] as IconData,
                        color: budget['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budget['title'] as String,
                            style: const TextStyle(
                              color: Color(0xFF1C2D11),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$spent / $limit ${widget.currency}',
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
                      ? 'Dépassé de ${-remaining} ${widget.currency}'
                      : remaining > 0
                          ? 'Il reste $remaining ${widget.currency}'
                          : 'Budget épuisé',
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
}
