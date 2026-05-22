import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';
import '../models/compte.dart';
import '../responsive.dart';
import '../services/auth_service.dart';
import '../services/compte_service.dart';
import '../utils/compte_ui.dart';

class NewAccountScreen extends StatefulWidget {
  final String currency;

  const NewAccountScreen({super.key, required this.currency});

  @override
  State<NewAccountScreen> createState() => _NewAccountScreenState();
}

class _NewAccountScreenState extends State<NewAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');

  int _selectedPresetIndex = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _applyPreset(0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  CompteTypeStyle get _selectedPreset => CompteUi.presets[_selectedPresetIndex];

  void _applyPreset(int index) {
    final preset = CompteUi.presets[index];
    setState(() {
      _selectedPresetIndex = index;
      if (preset.type == 'autre') {
        _nameController.clear();
      } else {
        _nameController.text = preset.defaultNom;
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFD32F2F),
        content: Text(message),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    final balanceText = _balanceController.text.trim();
    final solde = balanceText.isEmpty ? 0.0 : double.parse(balanceText);
    final preset = _selectedPreset;

    setState(() => _isSubmitting = true);

    try {
      await CompteService.create(
        nom: _nameController.text.trim(),
        solde: solde,
        type: preset.type,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showError('Erreur lors de la création : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final preset = _selectedPreset;
    final displayName = _nameController.text.isEmpty
        ? 'Mon compte'
        : _nameController.text;

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
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
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
                  border: Border.all(color: const Color(0xFF8E9A86).withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: preset.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        preset.icon,
                        color: preset.color,
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
                            '${preset.label} • ${widget.currency}',
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
                  itemCount: CompteUi.presets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final p = CompteUi.presets[index];
                    final selected = _selectedPresetIndex == index;
                    return GestureDetector(
                      onTap: _isSubmitting ? null : () => _applyPreset(index),
                      child: Container(
                        width: 72,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFE8F5E9) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? AppColors.accent
                                : const Color(0xFF8E9A86).withValues(alpha: 0.15),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(p.icon, color: p.color, size: 22),
                            const SizedBox(height: 6),
                            Text(
                              p.label,
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
                enabled: !_isSubmitting,
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
                'Solde initial',
                style: TextStyle(
                  color: Color(0xFF1C2D11),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _balanceController,
                enabled: !_isSubmitting,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: _fieldDecoration(
                  hint: '0 (${widget.currency})',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = double.tryParse(v.trim().replaceAll(',', '.'));
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
                        'Le compte sera enregistré sur le serveur avec nom, solde et type.',
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
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
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
