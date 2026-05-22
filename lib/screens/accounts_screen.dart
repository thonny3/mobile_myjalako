import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../demo_data.dart';
import '../responsive.dart';
import '../services/auth_service.dart';
import '../services/compte_service.dart';
import '../utils/compte_ui.dart';
import 'new_account_screen.dart';

class AccountsScreen extends StatefulWidget {
  final String currency;
  final double bottomPadding;

  const AccountsScreen({
    super.key,
    required this.currency,
    this.bottomPadding = 0,
  });

  @override
  State<AccountsScreen> createState() => AccountsScreenState();
}

class AccountsScreenState extends State<AccountsScreen> {
  void openNewAccount() => _openNewAccount();

  bool _showBalances = true;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  double get _totalBalance =>
      _accounts.fold(0.0, (sum, a) => sum + (a['balance'] as double));

  String _formatAmount(double amount) => DemoData.formatAmount(amount);

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await CompteService.getMyAccounts();
      if (!mounted) return;
      setState(() {
        _accounts = list.map((c) => c.toUiMap()).toList();
        _isLoading = false;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _accounts = [];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger les comptes : $e';
        _accounts = [];
      });
    }
  }

  Future<void> _openNewAccount() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => NewAccountScreen(currency: widget.currency),
      ),
    );

    if (created != true || !mounted) return;

    await _loadAccounts();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Compte créé avec succès'),
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
      onRefresh: _loadAccounts,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mes comptes',
                    style: TextStyle(
                      color: Color(0xFF1C2D11),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _isLoading ? '…' : '${_accounts.length} comptes',
                    style: const TextStyle(
                      color: Color(0xFF8E9A86),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
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
            else if (_accounts.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: h),
                child: _buildEmptyCard(),
              )
            else
              ..._accounts.map((a) => _buildAccountTile(a, h)),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: h),
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _openNewAccount,
                icon: const Icon(Icons.add_rounded, color: AppColors.accent),
                label: const Text(
                  'Ajouter un compte',
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
            onPressed: _loadAccounts,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.accent),
            label: const Text('Réessayer', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8E9A86).withValues(alpha: 0.1)),
      ),
      child: const Text(
        'Aucun compte pour le moment. Créez votre premier compte.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF7F8E75), fontSize: 13),
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
            'Comptes',
            style: TextStyle(
              color: Colors.white,
              fontSize: r.titleMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gérez vos comptes et soldes',
            style: TextStyle(
              color: Colors.white70,
              fontSize: r.sp(13),
            ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Solde total',
                style: TextStyle(
                  color: Color(0xFF8E9A86),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showBalances = !_showBalances),
                child: Icon(
                  _showBalances ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: const Color(0xFF8E9A86),
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _showBalances
                  ? '${_formatAmount(_totalBalance)} ${widget.currency}'
                  : '•••••• ${widget.currency}',
              style: TextStyle(
                color: Color(0xFF1C2D11),
                fontSize: context.responsive.balanceAmountSize,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Répartition sur ${_accounts.length} comptes actifs',
            style: const TextStyle(
              color: Color(0xFF7F8E75),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile(Map<String, dynamic> account, double hPad) {
    final balance = account['balance'] as double;
    final type = account['type'] as String? ?? '';
    return Padding(
      padding: EdgeInsets.only(left: hPad, right: hPad, bottom: 12),
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
              border: Border.all(color: const Color(0xFF8E9A86).withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: account['bg'] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    account['icon'] as IconData,
                    color: account['color'] as Color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account['name'] as String,
                        style: const TextStyle(
                          color: Color(0xFF1C2D11),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CompteUi.formatTypeLabel(type),
                        style: const TextStyle(
                          color: Color(0xFF8E9A86),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _showBalances
                      ? '${_formatAmount(balance)} ${widget.currency}'
                      : '••••',
                  style: const TextStyle(
                    color: Color(0xFF1C2D11),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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
