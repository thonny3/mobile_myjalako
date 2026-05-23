import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../demo_data.dart';
import '../models/depense.dart';
import '../responsive.dart';
import '../services/auth_service.dart';
import '../services/depense_service.dart';
import 'new_depense_screen.dart';
import 'depense_detail_screen.dart';

class DepensesScreen extends StatefulWidget {
  final String currency;
  final double bottomPadding;

  const DepensesScreen({
    super.key,
    required this.currency,
    this.bottomPadding = 0,
  });

  @override
  State<DepensesScreen> createState() => DepensesScreenState();
}

class DepensesScreenState extends State<DepensesScreen> {
  void reload() => _loadDepenses();
  void openNewDepense() => _openNewDepense();

  bool _isLoading = true;
  String? _errorMessage;
  List<Depense> _depenses = [];

  @override
  void initState() {
    super.initState();
    _loadDepenses();
  }

  double get _monthlyTotal =>
      _depenses.where((r) => r.isCurrentMonth).fold(0.0, (s, r) => s + r.montant);

  List<Depense> get _monthlyDepenses =>
      _depenses.where((r) => r.isCurrentMonth).toList();

  Future<void> _loadDepenses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await DepenseService.getAll();
      if (!mounted) return;
      setState(() {
        _depenses = list;
        _isLoading = false;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _depenses = [];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger les dépenses : $e';
        _depenses = [];
      });
    }
  }

  Future<void> _openNewDepense() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => NewDepenseScreen(currency: widget.currency),
      ),
    );

    if (created != true || !mounted) return;

    await _loadDepenses();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Dépense enregistrée avec succès'),
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

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: _loadDepenses,
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
                child: _buildTotalCard(),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ce mois-ci',
                          style: TextStyle(
                            color: Color(0xFF1C2D11),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isLoading
                              ? '…'
                              : '${_monthlyDepenses.length} dépense${_monthlyDepenses.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Color(0xFF8E9A86),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: const Color(0xFFD32F2F).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: _isLoading ? null : _openNewDepense,
                      borderRadius: BorderRadius.circular(14),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.add_rounded,
                          color: Color(0xFFD32F2F),
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
            else if (_monthlyDepenses.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: h),
                child: _buildEmptyCard(),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: h),
                child: _buildList(),
              ),
            const SizedBox(height: 8),
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
            'Dépenses',
            style: TextStyle(
              color: Colors.white,
              fontSize: r.titleMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Contrôlez vos sorties d\'argent',
            style: TextStyle(color: Colors.white70, fontSize: r.sp(13)),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_down_rounded,
              color: Color(0xFFD32F2F),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total ce mois-ci',
                  style: TextStyle(
                    color: Color(0xFF8E9A86),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isLoading
                      ? '…'
                      : '${DemoData.formatAmount(_monthlyTotal)} ${widget.currency}',
                  style: TextStyle(
                    color: const Color(0xFF1C2D11),
                    fontSize: context.responsive.balanceAmountSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8E9A86).withValues(alpha: 0.08)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _monthlyDepenses.length,
        separatorBuilder: (_, __) => Divider(
          color: const Color(0xFF8E9A86).withValues(alpha: 0.08),
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final depense = _monthlyDepenses[index];
          final item = depense.toUiMap();
          return ListTile(
            onTap: () => _openDepenseDetail(depense),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item['bg'] as Color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['icon'] as IconData,
                color: item['fg'] as Color,
                size: 20,
              ),
            ),
            title: Text(
              item['title'] as String,
              style: const TextStyle(
                color: Color(0xFF1C2D11),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              item['subtitle'] as String,
              style: const TextStyle(color: Color(0xFF8E9A86), fontSize: 12),
            ),
            trailing: Text(
              '- ${DemoData.formatAmount(item['amount'] as int)} ${widget.currency}',
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openDepenseDetail(Depense depense) async {
    if (depense.idDepense <= 0) return;

    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DepenseDetailScreen(
          idDepense: depense.idDepense,
          currency: widget.currency,
        ),
      ),
    );

    if (changed == true && mounted) {
      await _loadDepenses();
    }
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
            onPressed: _loadDepenses,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.accent),
            label: const Text('Réessayer', style: TextStyle(color: AppColors.accent)),
          ),
        ],
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
            Icons.trending_down_rounded,
            size: 48,
            color: const Color(0xFFD32F2F).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aucune dépense ce mois-ci',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1C2D11),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ajoutez une dépense avec le bouton + ci-dessus.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF7F8E75), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
