import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../demo_data.dart';
import '../models/compte.dart';
import '../responsive.dart';
import '../services/auth_service.dart';
import '../services/compte_service.dart';
import '../utils/compte_ui.dart';

class AccountDetailScreen extends StatefulWidget {
  final int idCompte;
  final String currency;

  const AccountDetailScreen({
    super.key,
    required this.idCompte,
    required this.currency,
  });

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  Compte? _compte;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _hasChanges = false;
  int _selectedPresetIndex = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _loadAccount() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final compte = await CompteService.getById(widget.idCompte);
      if (!mounted) return;
      _applyCompte(compte);
      setState(() => _isLoading = false);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger le compte : $e';
      });
    }
  }

  void _applyCompte(Compte compte) {
    _compte = compte;
    _nameController.text = compte.nom;
    _balanceController.text = compte.solde == compte.solde.roundToDouble()
        ? compte.solde.round().toString()
        : compte.solde.toString();
    _selectedPresetIndex = CompteUi.presetIndexForType(compte.type);
  }

  CompteTypeStyle get _style =>
      _compte != null ? CompteUi.styleForType(_compte!.type) : CompteUi.presets.first;

  CompteTypeStyle get _selectedPreset => CompteUi.presets[_selectedPresetIndex];

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: const Color(0xFFD32F2F), content: Text(message)),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.accent, content: Text(message)),
    );
  }

  InputDecoration _fieldDecoration({required String hint, required IconData icon}) {
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
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving || _compte == null) return;

    final soldeText = _balanceController.text.trim().replaceAll(',', '.');
    final solde = soldeText.isEmpty ? 0.0 : double.parse(soldeText);

    setState(() => _isSaving = true);

    try {
      await CompteService.update(
        idCompte: widget.idCompte,
        nom: _nameController.text.trim(),
        solde: solde,
        type: _selectedPreset.type,
      );
      final updated = await CompteService.getById(widget.idCompte);
      if (!mounted) return;
      _applyCompte(updated);
      setState(() {
        _isSaving = false;
        _isEditing = false;
        _hasChanges = true;
      });
      _showSuccess('Compte modifié avec succès');
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showError('Erreur lors de la modification : $e');
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Supprimer le compte',
          style: TextStyle(color: Color(0xFF1C2D11), fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Voulez-vous supprimer « ${_compte?.nom ?? 'ce compte'} » ? Cette action est irréversible.',
          style: const TextStyle(color: Color(0xFF7F8E75)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF8E9A86))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);

    try {
      await CompteService.delete(widget.idCompte);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      _showError('Erreur lors de la suppression : $e');
    }
  }

  void _cancelEdit() {
    if (_compte != null) _applyCompte(_compte!);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context, _hasChanges),
        ),
        title: Text(
          _isEditing ? 'Modifier le compte' : 'Détail du compte',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (!_isLoading && _compte != null && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: _isSaving ? null : _cancelEdit,
            ),
        ],
      ),
      body: _buildBody(r),
    );
  }

  Widget _buildBody(AppResponsive r) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: r.pageInsets(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFD32F2F)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAccount,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_compte == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: r.pageInsets(bottom: 32, top: 20),
      child: _isEditing ? _buildEditForm() : _buildDetailView(),
    );
  }

  Widget _buildDetailView() {
    final style = _style;
    final compte = _compte!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF8E9A86).withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: style.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(style.icon, color: style.color, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                compte.nom,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1C2D11),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                CompteUi.formatTypeLabel(compte.type),
                style: const TextStyle(color: Color(0xFF8E9A86), fontSize: 14),
              ),
              const SizedBox(height: 20),
              Text(
                '${DemoData.formatAmount(compte.solde)} ${widget.currency}',
                style: const TextStyle(
                  color: Color(0xFF1C2D11),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Solde actuel',
                style: TextStyle(color: Color(0xFF7F8E75), fontSize: 13),
              ),
              if (compte.accessRole != null && compte.accessRole!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Rôle : ${compte.accessRole}',
                    style: const TextStyle(
                      color: Color(0xFF355E3D),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildInfoRow('Nom', compte.nom),
        _buildInfoRow('Type', CompteUi.formatTypeLabel(compte.type)),
        _buildInfoRow(
          'Solde',
          '${DemoData.formatAmount(compte.solde)} ${widget.currency}',
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => setState(() => _isEditing = true),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Modifier'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isDeleting ? null : _confirmDelete,
          icon: _isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD32F2F)),
                )
              : const Icon(Icons.delete_outline_rounded, color: Color(0xFFD32F2F)),
          label: const Text(
            'Supprimer le compte',
            style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Color(0xFFD32F2F)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8E9A86).withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF8E9A86),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: Color(0xFF1C2D11),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    final preset = _selectedPreset;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: preset.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(preset.icon, color: preset.color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _nameController.text.isEmpty ? 'Compte' : _nameController.text,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C2D11),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
                  onTap: _isSaving
                      ? null
                      : () => setState(() => _selectedPresetIndex = index),
                  child: Container(
                    width: 72,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFE8F5E9) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? AppColors.accent : const Color(0xFF8E9A86).withValues(alpha: 0.15),
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
                          style: TextStyle(
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
          const SizedBox(height: 20),
          const Text(
            'Nom du compte',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C2D11)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            enabled: !_isSaving,
            onChanged: (_) => setState(() {}),
            decoration: _fieldDecoration(
              hint: 'Nom du compte',
              icon: Icons.label_outline_rounded,
            ),
            validator: (v) {
              if (v == null || v.trim().length < 2) {
                return 'Nom requis (2 caractères min.)';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Solde',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C2D11)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _balanceController,
            enabled: !_isSaving,
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
              if (n == null) return 'Montant invalide';
              return null;
            },
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Enregistrer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
