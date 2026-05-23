import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../models/compte.dart';
import '../models/revenu.dart';
import '../responsive.dart';
import '../services/auth_service.dart';
import '../services/compte_service.dart';
import '../services/revenu_service.dart';

class NewRevenuScreen extends StatefulWidget {
  final String currency;

  const NewRevenuScreen({super.key, required this.currency});

  @override
  State<NewRevenuScreen> createState() => _NewRevenuScreenState();
}

class _NewRevenuScreenState extends State<NewRevenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceController = TextEditingController();
  final _montantController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoadingData = true;
  bool _isSubmitting = false;
  List<CategorieRevenu> _categories = [];
  List<Compte> _comptes = [];
  int? _selectedCategoryId;
  int? _selectedCompteId;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    try {
      final results = await Future.wait([
        RevenuService.getCategories(),
        CompteService.getMyAccounts(),
      ]);
      if (!mounted) return;
      final categories = results[0] as List<CategorieRevenu>;
      final comptes = results[1] as List<Compte>;
      setState(() {
        _categories = categories;
        _comptes = comptes;
        _selectedCategoryId =
            categories.isNotEmpty ? categories.first.id : null;
        _selectedCompteId = comptes.isNotEmpty ? comptes.first.idCompte : null;
        _isLoadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingData = false);
      _showError('Impossible de charger le formulaire : $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: const Color(0xFFD32F2F), content: Text(message)),
    );
  }

  String _formatDateApi(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _formatDateLabel(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.accent),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    if (_selectedCategoryId == null) {
      _showError('Choisissez une catégorie');
      return;
    }
    if (_selectedCompteId == null) {
      _showError('Créez d\'abord un compte pour enregistrer un revenu');
      return;
    }

    final montant =
        double.parse(_montantController.text.trim().replaceAll(',', '.'));

    setState(() => _isSubmitting = true);

    try {
      await RevenuService.create(
        montant: montant,
        source: _sourceController.text.trim(),
        dateRevenu: _formatDateApi(_selectedDate),
        idCategorieRevenu: _selectedCategoryId!,
        idCompte: _selectedCompteId!,
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
      _showError('Erreur : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nouveau revenu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                r.horizontalPadding,
                24,
                r.horizontalPadding,
                32,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Source',
                      style: TextStyle(
                        color: Color(0xFF1C2D11),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _sourceController,
                      style: const TextStyle(color: Color(0xFF1C2D11)),
                      decoration: _fieldDecoration(
                        hint: 'Ex. Salaire, vente…',
                        icon: Icons.label_outline_rounded,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Indiquez une source';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Montant (${widget.currency})',
                      style: const TextStyle(
                        color: Color(0xFF1C2D11),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _montantController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                      ],
                      style: const TextStyle(color: Color(0xFF1C2D11)),
                      decoration: _fieldDecoration(
                        hint: 'ex: 500000',
                        icon: Icons.payments_outlined,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Entrez un montant';
                        final n = double.tryParse(v.trim().replaceAll(',', '.'));
                        if (n == null || n <= 0) return 'Montant invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Date',
                      style: TextStyle(
                        color: Color(0xFF1C2D11),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      color: const Color(0xFFF5F7F4),
                      borderRadius: BorderRadius.circular(30),
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(30),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: Color(0xFF8E9A86),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _formatDateLabel(_selectedDate),
                                style: const TextStyle(
                                  color: Color(0xFF1C2D11),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Catégorie',
                      style: TextStyle(
                        color: Color(0xFF1C2D11),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdown<int>(
                      value: _selectedCategoryId,
                      hint: 'Choisir une catégorie',
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.nom),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Compte',
                      style: TextStyle(
                        color: Color(0xFF1C2D11),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _comptes.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Aucun compte disponible. Créez un compte avant d\'ajouter un revenu.',
                              style: TextStyle(color: Color(0xFF7F8E75), fontSize: 13),
                            ),
                          )
                        : _buildDropdown<int>(
                            value: _selectedCompteId,
                            hint: 'Choisir un compte',
                            items: _comptes
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.idCompte,
                                    child: Text(c.nom),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _selectedCompteId = v),
                          ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: _isSubmitting || _comptes.isEmpty ? null : _submit,
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
                              'Enregistrer le revenu',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F4),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: Color(0xFF8E9A86))),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
