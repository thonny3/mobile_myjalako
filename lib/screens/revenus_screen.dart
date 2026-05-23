import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../demo_data.dart';
import '../models/revenu.dart';
import '../responsive.dart';
import '../services/auth_service.dart';
import '../services/revenu_service.dart';
import 'new_revenu_screen.dart';
import 'revenu_detail_screen.dart';

class RevenusScreen extends StatefulWidget {
  final String currency;
  final double bottomPadding;

  const RevenusScreen({
    super.key,
    required this.currency,
    this.bottomPadding = 0,
  });

  @override
  State<RevenusScreen> createState() => RevenusScreenState();
}

class RevenusScreenState extends State<RevenusScreen> {
  void reload() => _loadRevenus();
  void openNewRevenu() => _openNewRevenu();

  bool _isLoading = true;
  String? _errorMessage;
  List<Revenu> _revenus = [];

  @override
  void initState() {
    super.initState();
    _loadRevenus();
  }

  double get _monthlyTotal =>
      _revenus.where((r) => r.isCurrentMonth).fold(0.0, (s, r) => s + r.montant);

  List<Revenu> get _monthlyRevenus =>
      _revenus.where((r) => r.isCurrentMonth).toList();

  Future<void> _loadRevenus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await RevenuService.getAll();
      if (!mounted) return;
      setState(() {
        _revenus = list;
        _isLoading = false;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _revenus = [];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger les revenus : $e';
        _revenus = [];
      });
    }
  }

  Future<void> _openNewRevenu() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => NewRevenuScreen(currency: widget.currency),
      ),
    );

    if (created != true || !mounted) return;

    await _loadRevenus();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Revenu enregistré avec succès'),
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
      onRefresh: _loadRevenus,
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
                              : '${_monthlyRevenus.length} entrée${_monthlyRevenus.length > 1 ? 's' : ''}',
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
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: _isLoading ? null : _openNewRevenu,
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
            else if (_monthlyRevenus.isEmpty)
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
            'Revenus',
            style: TextStyle(
              color: Colors.white,
              fontSize: r.titleMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Suivez vos entrées d\'argent',
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
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Color(0xFF2E7D32),
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
        itemCount: _monthlyRevenus.length,
        separatorBuilder: (_, __) => Divider(
          color: const Color(0xFF8E9A86).withValues(alpha: 0.08),
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final revenu = _monthlyRevenus[index];
          final item = revenu.toUiMap();
          return ListTile(
            onTap: () => _openRevenuDetail(revenu),
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
              '+ ${DemoData.formatAmount(item['amount'] as int)} ${widget.currency}',
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openRevenuDetail(Revenu revenu) async {
    if (revenu.idRevenu <= 0) return;

    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => RevenuDetailScreen(
          idRevenu: revenu.idRevenu,
          currency: widget.currency,
        ),
      ),
    );

    if (changed == true && mounted) {
      await _loadRevenus();
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
            onPressed: _loadRevenus,
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
            Icons.trending_up_rounded,
            size: 48,
            color: AppColors.accent.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aucun revenu ce mois-ci',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1C2D11),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ajoutez un revenu avec le bouton + ci-dessus.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF7F8E75), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
