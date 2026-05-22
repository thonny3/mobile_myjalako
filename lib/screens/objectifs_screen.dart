import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../demo_data.dart';
import '../responsive.dart';

class ObjectifsScreen extends StatefulWidget {
  final String currency;
  final double bottomPadding;

  const ObjectifsScreen({
    super.key,
    required this.currency,
    this.bottomPadding = 0,
  });

  @override
  State<ObjectifsScreen> createState() => _ObjectifsScreenState();
}

class _ObjectifsScreenState extends State<ObjectifsScreen> {
  String _filter = 'Tous';

  final List<Map<String, dynamic>> _goals =
      List<Map<String, dynamic>>.from(DemoData.demoGoals);

  int get _totalTarget => _goals.fold(0, (s, g) => s + (g['target'] as int));
  int get _totalSaved => _goals.fold(0, (s, g) => s + (g['saved'] as int));
  int get _totalRemaining => _totalTarget - _totalSaved;

  double get _globalProgress =>
      _totalTarget > 0 ? (_totalSaved / _totalTarget).clamp(0.0, 1.0) : 0.0;

  int get _completedCount =>
      _goals.where((g) => (g['saved'] as int) >= (g['target'] as int)).length;

  List<Map<String, dynamic>> get _filteredGoals {
    return _goals.where((g) {
      final saved = g['saved'] as int;
      final target = g['target'] as int;
      final isComplete = saved >= target;
      switch (_filter) {
        case 'Atteints':
          return isComplete;
        case 'En cours':
          return !isComplete;
        default:
          return true;
      }
    }).toList();
  }

  void _showAddGoalSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF8E9A86).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nouvel objectif',
              style: TextStyle(
                color: Color(0xFF1C2D11),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'La création d\'objectifs personnalisés sera disponible prochainement.',
              style: TextStyle(color: Color(0xFF7F8E75), fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final h = r.horizontalPadding;
    final filtered = _filteredGoals;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
            child: _buildFilterChips(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mes objectifs (${filtered.length})',
                  style: const TextStyle(
                    color: Color(0xFF1C2D11),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_completedCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_completedCount atteint${_completedCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
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
                  'Aucun objectif pour ce filtre.',
                  style: TextStyle(
                    color: const Color(0xFF8E9A86).withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...filtered.map(_buildGoalTile),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: h),
            child: OutlinedButton.icon(
              onPressed: _showAddGoalSheet,
              icon: const Icon(Icons.add_rounded, color: AppColors.accent),
              label: const Text(
                'Créer un objectif',
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
            'Objectifs',
            style: TextStyle(
              color: Colors.white,
              fontSize: r.titleMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Épargnez pour vos projets de vie',
            style: TextStyle(color: Colors.white70, fontSize: r.sp(13)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
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
                'Progression globale',
                style: TextStyle(
                  color: Color(0xFF8E9A86),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(_globalProgress * 100).round()} %',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
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
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryStat(
                  'Épargné',
                  _totalSaved,
                  AppColors.accent,
                ),
              ),
              Container(
                height: 36,
                width: 1,
                color: const Color(0xFF8E9A86).withOpacity(0.12),
              ),
              Expanded(
                child: _buildSummaryStat(
                  'Restant',
                  _totalRemaining > 0 ? _totalRemaining : 0,
                  const Color(0xFF2E7D32),
                ),
              ),
              Container(
                height: 36,
                width: 1,
                color: const Color(0xFF8E9A86).withOpacity(0.12),
              ),
              Expanded(
                child: _buildSummaryStat(
                  'Cible',
                  _totalTarget,
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
          '${DemoData.formatAmount(value)} ${widget.currency}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Tous', 'En cours', 'Atteints'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final selected = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f),
              selected: selected,
              onSelected: (_) => setState(() => _filter = f),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFE8F5E9),
              checkmarkColor: AppColors.accent,
              labelStyle: TextStyle(
                color: selected ? AppColors.accent : const Color(0xFF8E9A86),
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: selected
                    ? AppColors.accent
                    : const Color(0xFF8E9A86).withOpacity(0.2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalTile(Map<String, dynamic> goal) {
    final saved = goal['saved'] as int;
    final target = goal['target'] as int;
    final progress = target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;
    final isComplete = saved >= target;
    final remaining = target - saved;
    final barColor = isComplete ? const Color(0xFF2E7D32) : goal['color'] as Color;

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
                color: isComplete
                    ? const Color(0xFF2E7D32).withOpacity(0.25)
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
                        color: goal['bg'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        goal['icon'] as IconData,
                        color: goal['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal['title'] as String,
                            style: const TextStyle(
                              color: Color(0xFF1C2D11),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            goal['deadline'] as String,
                            style: TextStyle(
                              color: isComplete
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFF8E9A86),
                              fontSize: 12,
                              fontWeight:
                                  isComplete ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isComplete)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Atteint',
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Text(
                        '${(progress * 100).round()} %',
                        style: const TextStyle(
                          color: AppColors.accent,
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
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF0F2EF),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${DemoData.formatAmount(saved)} / ${DemoData.formatAmount(target)} ${widget.currency}',
                      style: const TextStyle(
                        color: Color(0xFF8E9A86),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      isComplete
                          ? 'Objectif atteint'
                          : 'Il reste ${DemoData.formatAmount(remaining)} ${widget.currency}',
                      style: TextStyle(
                        color: isComplete
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF7F8E75),
                        fontSize: 12,
                        fontWeight:
                            isComplete ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
