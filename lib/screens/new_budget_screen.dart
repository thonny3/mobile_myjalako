import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../models/budget.dart';
import '../models/depense.dart';
import '../responsive.dart';
import '../services/auth_service.dart';
import '../services/budget_service.dart';
import '../services/depense_service.dart';

class NewBudgetScreen extends StatefulWidget {
  final String currency;
  final DateTime? selectedMonth;

  const NewBudgetScreen({
    super.key,
    required this.currency,
    this.selectedMonth,
  });

  @override
  State<NewBudgetScreen> createState() => _NewBudgetScreenState();
}

class _NewBudgetScreenState extends State<NewBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();

  bool _isLoadingData = true;
  bool _isSubmitting = false;
  List<CategorieDepense> _categories = [];
  int? _selectedCategoryId;

  DateTime get _month {
    final m = widget.selectedMonth;
    if (m != null) return DateTime(m.year, m.month);
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  static const _monthLabels = [
    'Janvier',
    'Fevrier',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Aout',
    'Septembre',
    'Octobre',
    'Novembre',
    'Decembre',
  ];

  String get _monthLabel =>
      '${_monthLabels[_month.month - 1]} ${_month.year}';

  CategorieDepense? get _selectedCategory {
    if (_selectedCategoryId == null) return null;
    for (final c in _categories) {
      if (c.id == _selectedCategoryId) return c;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await DepenseService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _selectedCategoryId =
            categories.isNotEmpty ? categories.first.id : null;
        _isLoadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingData = false);
      _showError('Impossible de charger les categories : $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFD32F2F),
        content: Text(message),
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
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      _showError('Selectionnez une categorie');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await BudgetService.create(
        idCategorieDepense: _selectedCategoryId!,
        mois: BudgetService.formatMoisApi(_month),
        montantMax: double.parse(_limitController.text.trim()),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _showError('Erreur : $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final cat = _selectedCategory;
    final style = cat != null
        ? Budget.styleForCategory(cat.nom)
        : Budget.styleForCategory('');

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Nouveau budget',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _categories.isEmpty
              ? Center(
                  child: Padding(
                    padding: r.pageInsets(),
                    child: const Text(
                      'Aucune categorie de depense disponible.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF7F8E75)),
                    ),
                  ),
                )
              : SingleChildScrollView(
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
                            border: Border.all(
                              color: const Color(0xFF8E9A86).withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: style['bg'] as Color,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  style['icon'] as IconData,
                                  color: style['color'] as Color,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Apercu',
                                      style: TextStyle(
                                        color: Color(0xFF8E9A86),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      cat?.nom ?? 'Categorie',
                                      style: const TextStyle(
                                        color: Color(0xFF1C2D11),
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$_monthLabel • ${widget.currency}',
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
                          'Categorie',
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
                            itemCount: _categories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final c = _categories[index];
                              final s = Budget.styleForCategory(c.nom);
                              final selected = _selectedCategoryId == c.id;
                              return GestureDetector(
                                onTap: () => setState(
                                  () => _selectedCategoryId = c.id,
                                ),
                                child: Container(
                                  width: 80,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFFE8F5E9)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.accent
                                          : const Color(0xFF8E9A86)
                                              .withValues(alpha: 0.15),
                                      width: selected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        s['icon'] as IconData,
                                        color: s['color'] as Color,
                                        size: 22,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        c.nom,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: const Color(0xFF1C2D11),
                                          fontSize: 9,
                                          fontWeight: selected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
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
                          'Plafond mensuel',
                          style: TextStyle(
                            color: Color(0xFF1C2D11),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _limitController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: _fieldDecoration(
                            hint: 'Montant maximum (${widget.currency})',
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Indiquez le plafond du budget';
                            }
                            final n = int.tryParse(v.trim());
                            if (n == null || n <= 0) {
                              return 'Le plafond doit etre superieur a 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.accent,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Les depenses de la categorie seront comptees automatiquement ce mois-ci.',
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
                                  'Creer le budget',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
