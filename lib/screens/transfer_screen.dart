import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../demo_data.dart';
import '../models/compte.dart';
import '../models/transfert.dart';
import '../responsive.dart';
import '../services/auth_service.dart';
import '../services/compte_service.dart';
import '../services/transfert_service.dart';

class TransferScreen extends StatefulWidget {
  final String currency;
  final double bottomPadding;
  final VoidCallback? onTransferComplete;

  const TransferScreen({
    super.key,
    required this.currency,
    this.bottomPadding = 0,
    this.onTransferComplete,
  });

  @override
  State<TransferScreen> createState() => TransferScreenState();
}

class TransferScreenState extends State<TransferScreen> {
  void reload() => _loadData();

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _labelController = TextEditingController();

  List<Compte> _comptes = [];
  List<TransfertHistorique> _recentTransfers = [];
  int? _fromCompteId;
  int? _toCompteId;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Compte? _compteById(int? id) {
    if (id == null) return null;
    for (final c in _comptes) {
      if (c.idCompte == id) return c;
    }
    return null;
  }

  void _initDefaultAccounts() {
    if (_comptes.length < 2) {
      _fromCompteId = _comptes.isNotEmpty ? _comptes.first.idCompte : null;
      _toCompteId = null;
      return;
    }
    _fromCompteId ??= _comptes[0].idCompte;
    _toCompteId ??= _comptes[1].idCompte;
    if (_fromCompteId == _toCompteId) {
      _toCompteId = _comptes
          .firstWhere((c) => c.idCompte != _fromCompteId,
              orElse: () => _comptes[1])
          .idCompte;
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        CompteService.getMyAccounts(),
        TransfertService.getHistorique(),
      ]);
      if (!mounted) return;
      final comptes = results[0] as List<Compte>;
      final historique = results[1] as List<TransfertHistorique>;
      setState(() {
        _comptes = comptes;
        _recentTransfers = historique;
        _initDefaultAccounts();
        _isLoading = false;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _comptes = [];
        _recentTransfers = [];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger les donnees : $e';
        _comptes = [];
        _recentTransfers = [];
      });
    }
  }

  String _formatAmount(num amount) => DemoData.formatAmount(amount);

  void _swapAccounts() {
    if (_fromCompteId == null || _toCompteId == null) return;
    setState(() {
      final tmp = _fromCompteId;
      _fromCompteId = _toCompteId;
      _toCompteId = tmp;
    });
  }

  Future<void> _submitTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromCompteId == null || _toCompteId == null) {
      _showMessage('Selectionnez les comptes source et destination.',
          isError: true);
      return;
    }
    if (_fromCompteId == _toCompteId) {
      _showMessage('Les comptes source et destination doivent etre differents.',
          isError: true);
      return;
    }

    final amount = double.parse(_amountController.text.trim());
    final from = _compteById(_fromCompteId)!;
    final to = _compteById(_toCompteId)!;

    if (amount > from.solde) {
      _showMessage('Solde insuffisant sur ${from.nom}.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await TransfertService.transferCompteToCompte(
        idCompteSource: _fromCompteId!,
        idCompteCible: _toCompteId!,
        montant: amount,
      );
      if (!mounted) return;

      final label = _labelController.text.trim().isNotEmpty
          ? _labelController.text.trim()
          : 'Transfert';

      _amountController.clear();
      _labelController.clear();

      await _loadData();
      widget.onTransferComplete?.call();

      if (!mounted) return;
      _showMessage(
        '${_formatAmount(amount)} ${widget.currency} transferes vers ${to.nom} ($label)',
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      _showMessage(e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Erreur : $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFD32F2F) : AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8E9A86), fontSize: 15),
      prefixIcon: Icon(icon, color: const Color(0xFF8E9A86), size: 20),
      filled: true,
      fillColor: const Color(0xFFF5F7F4),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final h = r.horizontalPadding;

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: _loadData,
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
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                          ),
                        ),
                      )
                    : _errorMessage != null
                        ? _buildErrorCard(_errorMessage!)
                        : _comptes.length < 2
                            ? _buildNeedAccountsCard()
                            : _buildTransferForm(r),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: h),
              child: Text(
                'Transferts recents',
                style: TextStyle(
                  color: const Color(0xFF1C2D11),
                  fontSize: r.sectionTitleSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (!_isLoading && _errorMessage == null)
              if (_recentTransfers.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: h, vertical: 24),
                  child: Center(
                    child: Text(
                      'Aucun transfert pour le moment.',
                      style: TextStyle(
                        color: const Color(0xFF8E9A86).withValues(alpha: 0.8),
                        fontSize: r.bodySize,
                      ),
                    ),
                  ),
                )
              else
                ..._recentTransfers.map((t) => _buildTransferTile(t, h)),
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
            'Transfert d\'argent',
            style: TextStyle(
              color: Colors.white,
              fontSize: r.titleMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Virez entre vos comptes en toute securite',
            style: TextStyle(color: Colors.white70, fontSize: r.sp(13)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF8E9A86).withValues(alpha: 0.08)),
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
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.accent),
            label: const Text('Reessayer', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedAccountsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF8E9A86).withValues(alpha: 0.08)),
      ),
      child: const Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 48, color: AppColors.accent),
          SizedBox(height: 12),
          Text(
            'Au moins 2 comptes requis',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1C2D11),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Creez un second compte dans la section Comptes pour effectuer un transfert.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF7F8E75), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferForm(AppResponsive r) {
    final from = _compteById(_fromCompteId);

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAccountDropdown(
              label: 'Compte source',
              valueId: _fromCompteId,
              excludeId: _toCompteId,
              onChanged: (v) => setState(() => _fromCompteId = v),
            ),
            const SizedBox(height: 8),
            Center(
              child: Material(
                color: AppColors.mintSurface,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: _swapAccounts,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.swap_vert_rounded,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildAccountDropdown(
              label: 'Compte destination',
              valueId: _toCompteId,
              excludeId: _fromCompteId,
              onChanged: (v) => setState(() => _toCompteId = v),
            ),
            if (from != null) ...[
              const SizedBox(height: 12),
              Text(
                'Solde disponible : ${_formatAmount(from.solde)} ${widget.currency}',
                style: TextStyle(
                  color: const Color(0xFF7F8E75),
                  fontSize: r.labelSize,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Montant (${widget.currency})',
              style: TextStyle(
                color: const Color(0xFF8E9A86),
                fontSize: r.labelSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !_isSubmitting,
              style: const TextStyle(
                color: Color(0xFF1C2D11),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: _fieldDecoration(
                hint: 'ex: 50000',
                icon: Icons.payments_outlined,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Entrez un montant';
                final n = int.tryParse(v.trim());
                if (n == null || n <= 0) return 'Montant invalide';
                return null;
              },
            ),
            const SizedBox(height: 14),
            Text(
              'Libelle (optionnel)',
              style: TextStyle(
                color: const Color(0xFF8E9A86),
                fontSize: r.labelSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _labelController,
              enabled: !_isSubmitting,
              style: const TextStyle(color: Color(0xFF1C2D11)),
              decoration: _fieldDecoration(
                hint: 'ex: Recharge Mvola',
                icon: Icons.label_outline_rounded,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitTransfer,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  _isSubmitting ? 'Transfert en cours…' : 'Effectuer le transfert',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
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

  Widget _buildAccountDropdown({
    required String label,
    required int? valueId,
    required int? excludeId,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8E9A86),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7F4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: valueId,
              hint: const Text(
                'Choisir un compte',
                style: TextStyle(color: Color(0xFF8E9A86)),
              ),
              items: _comptes.where((c) => c.idCompte != excludeId).map((acc) {
                final ui = acc.toUiMap();
                return DropdownMenuItem(
                  value: acc.idCompte,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ui['bg'] as Color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          ui['icon'] as IconData,
                          color: ui['color'] as Color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              acc.nom,
                              style: const TextStyle(
                                color: Color(0xFF1C2D11),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${_formatAmount(acc.solde)} ${widget.currency}',
                              style: const TextStyle(
                                color: Color(0xFF8E9A86),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransferTile(TransfertHistorique transfer, double hPad) {
    return Padding(
      padding: EdgeInsets.only(left: hPad, right: hPad, bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF8E9A86).withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transfer.label,
                    style: const TextStyle(
                      color: Color(0xFF1C2D11),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transfer.routeLabel,
                    style: const TextStyle(color: Color(0xFF8E9A86), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (transfer.dateLabel.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      transfer.dateLabel,
                      style: const TextStyle(color: Color(0xFF7F8E75), fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '- ${_formatAmount(transfer.montant)}',
              style: const TextStyle(
                color: Color(0xFF1C2D11),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
