import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../demo_data.dart';
import '../models/transaction_item.dart';
import '../responsive.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import 'depense_detail_screen.dart';
import 'new_depense_screen.dart';
import 'new_revenu_screen.dart';
import 'revenu_detail_screen.dart';

class TransactionsScreen extends StatefulWidget {
  final String currency;
  final double bottomPadding;
  final ValueChanged<List<Map<String, dynamic>>>? onListChanged;

  const TransactionsScreen({
    super.key,
    required this.currency,
    this.onListChanged,
    this.bottomPadding = 0,
  });

  @override
  State<TransactionsScreen> createState() => TransactionsScreenState();
}

class TransactionsScreenState extends State<TransactionsScreen> {
  void showAddMenu() => _showTypePicker();
  void reload() => _loadTransactions();

  bool _isLoading = true;
  String? _errorMessage;
  List<TransactionItem> _transactions = [];

  List<TransactionItem> get _monthlyTransactions =>
      _transactions.where((t) => t.isCurrentMonth).toList();

  double get _monthlyIncome => _monthlyTransactions
      .where((t) => !t.isExpense)
      .fold(0.0, (s, t) => s + t.montant);

  double get _monthlyExpenses => _monthlyTransactions
      .where((t) => t.isExpense)
      .fold(0.0, (s, t) => s + t.montant.abs());

  double get _monthlyNet => _monthlyIncome - _monthlyExpenses;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _notifyParent() {
    widget.onListChanged?.call(
      TransactionService.toUiList(_transactions),
    );
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await TransactionService.getAll();
      if (!mounted) return;
      setState(() {
        _transactions = list;
        _isLoading = false;
      });
      _notifyParent();
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _transactions = [];
      });
      _notifyParent();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger les transactions : $e';
        _transactions = [];
      });
      _notifyParent();
    }
  }

  Future<void> _openNewTransaction({required bool isIncome}) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => isIncome
            ? NewRevenuScreen(currency: widget.currency)
            : NewDepenseScreen(currency: widget.currency),
      ),
    );

    if (created != true || !mounted) return;

    await _loadTransactions();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isIncome ? 'Revenu enregistré' : 'Dépense enregistrée'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openDetail(TransactionItem item) async {
    if (item.isRevenu) {
      final changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => RevenuDetailScreen(
            idRevenu: item.idTransaction,
            currency: widget.currency,
          ),
        ),
      );
      if (changed == true && mounted) await _loadTransactions();
      return;
    }

    if (item.isDepense) {
      final changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => DepenseDetailScreen(
            idDepense: item.idTransaction,
            currency: widget.currency,
          ),
        ),
      );
      if (changed == true && mounted) await _loadTransactions();
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Détail non disponible pour : ${item.typeLabel}'),
        backgroundColor: const Color(0xFF8E9A86),
      ),
    );
  }

  void _showTypePicker() {
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
                  color: const Color(0xFF8E9A86).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Type de transaction',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1C2D11),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choisissez s\'il s\'agit d\'un revenu ou d\'une dépense',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7F8E75), fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildTypeOption(
              title: 'Revenu',
              subtitle: 'Salaire, vente, remboursement…',
              icon: Icons.trending_up_rounded,
              color: const Color(0xFF2E7D32),
              bg: const Color(0xFFE8F5E9),
              isIncome: true,
            ),
            const SizedBox(height: 12),
            _buildTypeOption(
              title: 'Dépense',
              subtitle: 'Courses, transport, factures…',
              icon: Icons.trending_down_rounded,
              color: const Color(0xFFD32F2F),
              bg: const Color(0xFFFFEBEE),
              isIncome: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bg,
    required bool isIncome,
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _openNewTransaction(isIncome: isIncome);
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF7F8E75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final h = r.horizontalPadding;

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: _loadTransactions,
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
                child: _buildSummaryCard(r),
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
                              : '${_monthlyTransactions.length} opération${_monthlyTransactions.length > 1 ? 's' : ''}',
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
                      onTap: _isLoading ? null : _showTypePicker,
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
            else if (_monthlyTransactions.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: h),
                child: _buildEmptyCard(),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: h),
                child: _buildList(r),
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
            'Transactions',
            style: TextStyle(
              color: Colors.white,
              fontSize: r.titleMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Historique de vos opérations',
            style: TextStyle(color: Colors.white70, fontSize: r.sp(13)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AppResponsive r) {
    final net = _monthlyNet;
    final isPositive = net >= 0;

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
            decoration: BoxDecoration(
              color: isPositive
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.swap_horiz_rounded,
              color: isPositive
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFD32F2F),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solde ce mois-ci',
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
                      : '${net >= 0 ? '+' : '-'} ${DemoData.formatAmount(net.abs())} ${widget.currency}',
                  style: TextStyle(
                    color: isPositive
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFD32F2F),
                    fontSize: r.balanceAmountSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isLoading && _monthlyTransactions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '+ ${DemoData.formatAmount(_monthlyIncome)}  ·  - ${DemoData.formatAmount(_monthlyExpenses)}',
                    style: const TextStyle(
                      color: Color(0xFF7F8E75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(AppResponsive r) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8E9A86).withValues(alpha: 0.08)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _monthlyTransactions.length,
        separatorBuilder: (_, __) => Divider(
          color: const Color(0xFF8E9A86).withValues(alpha: 0.08),
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final item = _monthlyTransactions[index];
          final ui = item.toUiMap();
          return ListTile(
            onTap: () => _openDetail(item),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ui['bg'] as Color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                ui['icon'] as IconData,
                color: ui['fg'] as Color,
                size: 20,
              ),
            ),
            title: Text(
              ui['title'] as String,
              style: const TextStyle(
                color: Color(0xFF1C2D11),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              ui['subtitle'] as String,
              style: const TextStyle(color: Color(0xFF8E9A86), fontSize: 12),
            ),
            trailing: Text(
              '${DemoData.formatSignedAmount(ui['amount'] as int)} ${widget.currency}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: item.isExpense
                    ? const Color(0xFF1C2D11)
                    : const Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: r.sp(13),
              ),
            ),
          );
        },
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
            Icons.swap_horiz_rounded,
            size: 48,
            color: AppColors.accent.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aucune transaction ce mois-ci',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1C2D11),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ajoutez un revenu ou une dépense avec le bouton + ci-dessus.',
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
            onPressed: _loadTransactions,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.accent),
            label: const Text('Réessayer', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}
