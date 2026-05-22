import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';
import '../demo_data.dart';
import '../responsive.dart';

class TransactionsScreen extends StatefulWidget {
  final String currency;
  final double bottomPadding;
  final List<Map<String, dynamic>> transactions;
  final ValueChanged<List<Map<String, dynamic>>> onTransactionsChanged;

  const TransactionsScreen({
    super.key,
    required this.currency,
    required this.transactions,
    required this.onTransactionsChanged,
    this.bottomPadding = 0,
  });

  @override
  State<TransactionsScreen> createState() => TransactionsScreenState();
}

class TransactionsScreenState extends State<TransactionsScreen> {
  void showAddMenu() => _showTypePicker();

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
                  color: const Color(0xFF8E9A86).withOpacity(0.3),
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
          _showTransactionForm(isIncome: isIncome);
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
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

  void _showTransactionForm({required bool isIncome}) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final accent = isIncome ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);
    final accentBg = isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 28,
        ),
        child: Form(
          key: formKey,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isIncome ? 'Nouveau revenu' : 'Nouvelle dépense',
                    style: const TextStyle(
                      color: Color(0xFF1C2D11),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildLabel('Libellé'),
              TextFormField(
                controller: titleController,
                style: const TextStyle(color: Color(0xFF1C2D11)),
                decoration: _fieldDecoration(
                  hint: 'ex: Salaire, Courses…',
                  icon: Icons.label_outline_rounded,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Entrez un libellé';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildLabel('Montant (${widget.currency})'),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Color(0xFF1C2D11)),
                decoration: _fieldDecoration(
                  hint: 'ex: 150000',
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
              _buildLabel('Note (optionnel)'),
              TextFormField(
                controller: noteController,
                style: const TextStyle(color: Color(0xFF1C2D11)),
                decoration: _fieldDecoration(
                  hint: 'Détails supplémentaires',
                  icon: Icons.notes_outlined,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  final amount = int.parse(amountController.text.trim());
                  final now = TimeOfDay.now();
                  final subtitle = noteController.text.trim().isNotEmpty
                      ? noteController.text.trim()
                      : 'Aujourd\'hui, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

                  final newTx = {
                    'title': titleController.text.trim(),
                    'subtitle': subtitle,
                    'amount': isIncome ? amount : -amount,
                    'icon': isIncome
                        ? Icons.account_balance_wallet_outlined
                        : Icons.shopping_bag_outlined,
                    'bg': accentBg,
                    'fg': accent,
                    'isExpense': !isIncome,
                  };

                  final updated = [newTx, ...widget.transactions];
                  widget.onTransactionsChanged(updated);
                  Navigator.pop(sheetContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      content: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isIncome ? 'Revenu ajouté' : 'Dépense ajoutée',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isIncome ? AppColors.accent : const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isIncome ? 'Enregistrer le revenu' : 'Enregistrer la dépense',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1C2D11),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8E9A86)),
      prefixIcon: Icon(icon, color: const Color(0xFF8E9A86), size: 20),
      filled: true,
      fillColor: const Color(0xFFF5F7F4),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
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
    final txs = widget.transactions;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: EdgeInsets.only(bottom: widget.bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
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
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: h),
            child: ElevatedButton.icon(
              onPressed: _showTypePicker,
              icon: const Icon(Icons.add_rounded, size: 22),
              label: const Text(
                'Ajouter une transaction',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historique (${txs.length})',
                  style: const TextStyle(
                    color: Color(0xFF1C2D11),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (txs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'Aucune transaction pour le moment.',
                  style: TextStyle(
                    color: const Color(0xFF8E9A86).withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: h),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8E9A86).withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: txs.length,
                  separatorBuilder: (_, __) => Divider(
                    color: const Color(0xFF8E9A86).withOpacity(0.08),
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    final isExpense = tx['isExpense'] as bool;
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tx['bg'] as Color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          tx['icon'] as IconData,
                          color: tx['fg'] as Color,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        tx['title'] as String,
                        style: const TextStyle(
                          color: Color(0xFF1C2D11),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        tx['subtitle'] as String,
                        style: const TextStyle(color: Color(0xFF8E9A86), fontSize: 12),
                      ),
                      trailing: Text(
                        '${DemoData.formatSignedAmount(tx['amount'] as int)} ${widget.currency}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isExpense ? const Color(0xFF1C2D11) : const Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                          fontSize: r.sp(13),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
