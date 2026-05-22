import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';
import '../demo_data.dart';
import '../responsive.dart';

class TransferScreen extends StatefulWidget {
  final String currency;
  final double bottomPadding;

  const TransferScreen({
    super.key,
    required this.currency,
    this.bottomPadding = 0,
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _labelController = TextEditingController();

  late List<Map<String, dynamic>> _accounts;
  int? _fromIndex;
  int? _toIndex;

  final List<Map<String, dynamic>> _recentTransfers = [
    {
      'from': 'Compte courant',
      'to': 'Mvola',
      'amount': 250000,
      'date': 'Hier, 09:15',
      'label': 'Recharge mobile',
    },
    {
      'from': 'Épargne',
      'to': 'Compte courant',
      'amount': 1500000,
      'date': '12 mai, 16:40',
      'label': 'Virement mensuel',
    },
  ];

  @override
  void initState() {
    super.initState();
    _accounts = List<Map<String, dynamic>>.from(
      DemoData.demoAccounts.map((a) => Map<String, dynamic>.from(a)),
    );
    if (_accounts.length >= 2) {
      _fromIndex = 0;
      _toIndex = 1;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  String _formatAmount(num amount) => DemoData.formatAmount(amount);

  void _swapAccounts() {
    if (_fromIndex == null || _toIndex == null) return;
    setState(() {
      final tmp = _fromIndex;
      _fromIndex = _toIndex;
      _toIndex = tmp;
    });
  }

  void _submitTransfer() {
    if (!_formKey.currentState!.validate()) return;
    if (_fromIndex == null || _toIndex == null) {
      _showMessage('Sélectionnez les comptes source et destination.', isError: true);
      return;
    }
    if (_fromIndex == _toIndex) {
      _showMessage('Les comptes source et destination doivent être différents.', isError: true);
      return;
    }

    final amount = int.parse(_amountController.text.trim());
    final from = _accounts[_fromIndex!];
    final to = _accounts[_toIndex!];
    final fromBalance = from['balance'] as double;

    if (amount > fromBalance) {
      _showMessage('Solde insuffisant sur ${from['name']}.', isError: true);
      return;
    }

    final now = TimeOfDay.now();
    final label = _labelController.text.trim().isNotEmpty
        ? _labelController.text.trim()
        : 'Transfert';

    setState(() {
      from['balance'] = fromBalance - amount;
      to['balance'] = (to['balance'] as double) + amount;
      _recentTransfers.insert(0, {
        'from': from['name'] as String,
        'to': to['name'] as String,
        'amount': amount,
        'date':
            'Aujourd\'hui, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        'label': label,
      });
      _amountController.clear();
      _labelController.clear();
    });

    _showMessage(
      '${_formatAmount(amount)} ${widget.currency} transférés vers ${to['name']}',
    );
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

  InputDecoration _fieldDecoration({required String hint, required IconData icon}) {
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
              child: _buildTransferForm(r, h),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: h),
            child: Text(
              'Transferts récents',
              style: TextStyle(
                color: const Color(0xFF1C2D11),
                fontSize: r.sectionTitleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_recentTransfers.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: h, vertical: 24),
              child: Center(
                child: Text(
                  'Aucun transfert pour le moment.',
                  style: TextStyle(
                    color: const Color(0xFF8E9A86).withOpacity(0.8),
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
            'Virez entre vos comptes en toute sécurité',
            style: TextStyle(color: Colors.white70, fontSize: r.sp(13)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferForm(AppResponsive r, double hPad) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAccountDropdown(
              label: 'Compte source',
              valueIndex: _fromIndex,
              excludeIndex: _toIndex,
              onChanged: (v) => setState(() => _fromIndex = v),
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
                    child: Icon(Icons.swap_vert_rounded, color: AppColors.accent, size: 24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildAccountDropdown(
              label: 'Compte destination',
              valueIndex: _toIndex,
              excludeIndex: _fromIndex,
              onChanged: (v) => setState(() => _toIndex = v),
            ),
            if (_fromIndex != null) ...[
              const SizedBox(height: 12),
              Text(
                'Solde disponible : ${_formatAmount(_accounts[_fromIndex!]['balance'] as double)} ${widget.currency}',
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
              'Libellé (optionnel)',
              style: TextStyle(
                color: const Color(0xFF8E9A86),
                fontSize: r.labelSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _labelController,
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
                onPressed: _submitTransfer,
                icon: const Icon(Icons.send_rounded, size: 20),
                label: const Text(
                  'Effectuer le transfert',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
    required int? valueIndex,
    required int? excludeIndex,
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
              value: valueIndex,
              hint: const Text('Choisir un compte', style: TextStyle(color: Color(0xFF8E9A86))),
              items: List.generate(_accounts.length, (i) {
                if (i == excludeIndex) return null;
                final acc = _accounts[i];
                return DropdownMenuItem(
                  value: i,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: acc['bg'] as Color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          acc['icon'] as IconData,
                          color: acc['color'] as Color,
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
                              acc['name'] as String,
                              style: const TextStyle(
                                color: Color(0xFF1C2D11),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${_formatAmount(acc['balance'] as double)} ${widget.currency}',
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
              }).whereType<DropdownMenuItem<int>>().toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransferTile(Map<String, dynamic> transfer, double hPad) {
    return Padding(
      padding: EdgeInsets.only(left: hPad, right: hPad, bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF8E9A86).withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.swap_horiz_rounded, color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transfer['label'] as String,
                    style: const TextStyle(
                      color: Color(0xFF1C2D11),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${transfer['from']} → ${transfer['to']}',
                    style: const TextStyle(color: Color(0xFF8E9A86), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transfer['date'] as String,
                    style: const TextStyle(color: Color(0xFF7F8E75), fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              '- ${_formatAmount(transfer['amount'] as int)}',
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
