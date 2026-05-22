import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';
import '../responsive.dart';

class NewAccountScreen extends StatefulWidget {
  final String currency;

  const NewAccountScreen({super.key, required this.currency});

  @override
  State<NewAccountScreen> createState() => _NewAccountScreenState();
}

class _NewAccountScreenState extends State<NewAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bankController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');

  int _selectedPresetIndex = 0;

  static const List<Map<String, dynamic>> _presets = [
    {
      'title': 'Courant',
      'name': 'Compte courant',
      'bank': 'BFV-SG',
      'icon': Icons.account_balance_rounded,
      'color': AppColors.accent,
      'bg': Color(0xFFE8F5E9),
    },
    {
      'title': 'Épargne',
      'name': 'Épargne',
      'bank': 'BNI Madagascar',
      'icon': Icons.savings_outlined,
      'color': Color(0xFF2E7D32),
      'bg': Color(0xFFE8F5E9),
    },
    {
      'title': 'Mobile',
      'name': 'Mvola',
      'bank': 'Mobile money',
      'icon': Icons.phone_android_rounded,
      'color': Color(0xFF1976D2),
      'bg': Color(0xFFE3F2FD),
    },
    {
      'title': 'Espèces',
      'name': 'Espèces',
      'bank': 'Portefeuille',
      'icon': Icons.payments_outlined,
      'color': Color(0xFFF57C00),
      'bg': Color(0xFFFFECE0),
    },
    {
      'title': 'Autre',
      'name': '',
      'bank': '',
      'icon': Icons.account_balance_wallet_outlined,
      'color': Color(0xFF607D8B),
      'bg': Color(0xFFECEFF1),
    },
  ];

  @override
  void initState() {
    super.initState();
    _applyPreset(0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bankController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _applyPreset(int index) {
    final preset = _presets[index];
    setState(() {
      _selectedPresetIndex = index;
      if (preset['title'] == 'Autre') {
        _nameController.clear();
        _bankController.clear();
      } else {
        _nameController.text = preset['name'] as String;
        _bankController.text = preset['bank'] as String;
      }
    });
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
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Color(0xFFD32F2F), fontSize: 12),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final balanceText = _balanceController.text.trim();
    final balance = balanceText.isEmpty
        ? 0.0
        : double.parse(balanceText);
    final preset = _presets[_selectedPresetIndex];

    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'bank': _bankController.text.trim(),
      'balance': balance,
      'icon': preset['icon'] as IconData,
      'color': preset['color'] as Color,
      'bg': preset['bg'] as Color,
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final preset = _presets[_selectedPresetIndex];
    final displayName = _nameController.text.isEmpty
        ? 'Mon compte'
        : _nameController.text;
    final displayBank = _bankController.text.isEmpty
        ? 'Établissement'
        : _bankController.text;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Nouveau compte',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: r.pageInsets(bottom: 32, top: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8E9A86).withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: preset['bg'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        preset['icon'] as IconData,
                        color: preset['color'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aperçu',
                            style: TextStyle(
                              color: Color(0xFF8E9A86),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Color(0xFF1C2D11),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$displayBank • ${widget.currency}',
                            style: const TextStyle(
                              color: Color(0xFF7F8E75),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Type de compte',
                style: TextStyle(
                  color: Color(0xFF1C2D11),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _presets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final p = _presets[index];
                    final selected = _selectedPresetIndex == index;
                    return GestureDetector(
                      onTap: () => _applyPreset(index),
                      child: Container(
                        width: 72,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFE8F5E9) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? AppColors.accent
                                : const Color(0xFF8E9A86).withOpacity(0.15),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              p['icon'] as IconData,
                              color: p['color'] as Color,
                              size: 22,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p['title'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFF1C2D11),
                                fontSize: 10,
                                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Nom du compte',
                style: TextStyle(
                  color: Color(0xFF1C2D11),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                decoration: _fieldDecoration(
                  hint: 'Ex. Compte courant, Mvola…',
                  icon: Icons.label_outline_rounded,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Indiquez un nom pour le compte';
                  }
                  if (v.trim().length < 2) {
                    return 'Le nom doit contenir au moins 2 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Banque ou établissement',
                style: TextStyle(
                  color: Color(0xFF1C2D11),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bankController,
                onChanged: (_) => setState(() {}),
                decoration: _fieldDecoration(
                  hint: 'Ex. BFV-SG, BNI, Mvola…',
                  icon: Icons.account_balance_outlined,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Indiquez la banque ou l\'établissement';
                  }
                  if (v.trim().length < 2) {
                    return 'Au moins 2 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Solde initial',
                style: TextStyle(
                  color: Color(0xFF1C2D11),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Montant actuellement disponible sur ce compte',
                style: TextStyle(color: Color(0xFF7F8E75), fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _fieldDecoration(
                  hint: '0 (${widget.currency})',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 0) {
                    return 'Le solde doit être positif ou nul';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Le compte apparaîtra dans votre liste et sera inclus dans le solde total.',
                        style: TextStyle(
                          color: Color(0xFF355E3D),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Créer le compte',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
