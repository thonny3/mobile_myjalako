import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../demo_data.dart';
import '../models/compte.dart';
import '../models/depense.dart';
import '../responsive.dart';
import '../services/auth_service.dart';
import '../services/compte_service.dart';
import '../services/depense_service.dart';

class DepenseDetailScreen extends StatefulWidget {
  final int idDepense;
  final String currency;

  const DepenseDetailScreen({
    super.key,
    required this.idDepense,
    required this.currency,
  });

  @override
  State<DepenseDetailScreen> createState() => _DepenseDetailScreenState();
}

class _DepenseDetailScreenState extends State<DepenseDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _montantController = TextEditingController();

  Depense? _depense;
  List<CategorieDepense> _categories = [];
  List<Compte> _comptes = [];
  DateTime? _selectedDate;
  int? _selectedCategoryId;
  int? _selectedCompteId;

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _hasChanges = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        DepenseService.getById(widget.idDepense),
        DepenseService.getCategories(),
        CompteService.getMyAccounts(),
      ]);
      if (!mounted) return;
      setState(() {
        _categories = results[1] as List<CategorieDepense>;
        _comptes = results[2] as List<Compte>;
        _isLoading = false;
      });
      _applyDepense(results[0] as Depense);
      if (mounted) setState(() {});
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
        _errorMessage = 'Impossible de charger la dépense : $e';
      });
    }
  }

  Depense _withResolvedLabels(Depense depense) {
    String? catNom = depense.categorieNom;
    if ((catNom == null || catNom.isEmpty) && depense.idCategorieDepense != null) {
      for (final c in _categories) {
        if (c.id == depense.idCategorieDepense) {
          catNom = c.nom;
          break;
        }
      }
    }
    String? compteNom = depense.compteNom;
    if ((compteNom == null || compteNom.isEmpty) && depense.idCompte != null) {
      for (final c in _comptes) {
        if (c.idCompte == depense.idCompte) {
          compteNom = c.nom;
          break;
        }
      }
    }
    return depense.copyWith(categorieNom: catNom, compteNom: compteNom);
  }

  void _applyDepense(Depense depense) {
    _depense = _withResolvedLabels(depense);
    _descriptionController.text = depense.description;
    _montantController.text = depense.montant == depense.montant.roundToDouble()
        ? depense.montant.round().toString()
        : depense.montant.toString();
    _selectedDate = depense.dateDepense ?? DateTime.now();
    _selectedCategoryId = depense.idCategorieDepense;
    _selectedCompteId = depense.idCompte;
  }

  String _formatDateApi(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _formatDateLabel(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

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

  Future<void> _pickDate() async {
    final initial = _selectedDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving || _depense == null) return;
    if (_selectedCategoryId == null || _selectedCompteId == null || _selectedDate == null) {
      _showError('Complétez tous les champs');
      return;
    }

    final montant =
        double.parse(_montantController.text.trim().replaceAll(',', '.'));

    setState(() => _isSaving = true);

    try {
      await DepenseService.update(
        idDepense: widget.idDepense,
        montant: montant,
        description: _descriptionController.text.trim(),
        dateDepense: _formatDateApi(_selectedDate!),
        idCategorieDepense: _selectedCategoryId!,
        idCompte: _selectedCompteId!,
      );
      final updated = await DepenseService.getById(widget.idDepense);
      if (!mounted) return;
      _applyDepense(updated);
      setState(() {
        _isSaving = false;
        _isEditing = false;
        _hasChanges = true;
      });
      _showSuccess('Dépense modifiée avec succès');
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
          'Supprimer la dépense',
          style: TextStyle(color: Color(0xFF1C2D11), fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Voulez-vous supprimer « ${_depense?.description ?? 'cette dépense'} » ? Le solde du compte sera ajusté.',
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
    await _deleteDepense();
  }

  Future<void> _deleteDepense() async {
    setState(() => _isDeleting = true);

    try {
      await DepenseService.delete(widget.idDepense);
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

  Future<void> _cancelEdit() async {
    try {
      final fresh = await DepenseService.getById(widget.idDepense);
      if (!mounted) return;
      _applyDepense(fresh);
      setState(() => _isEditing = false);
    } catch (_) {
      if (mounted) setState(() => _isEditing = false);
    }
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
          _isEditing ? 'Modifier la dépense' : 'Détail de la dépense',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (!_isLoading && _depense != null && !_isEditing)
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
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_depense == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: r.pageInsets(bottom: 32, top: 20),
      child: _isEditing ? _buildEditForm() : _buildDetailView(),
    );
  }

  Widget _buildDetailView() {
    final depense = _depense!;

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
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.trending_down_rounded,
                  color: Color(0xFFD32F2F),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                depense.description.isNotEmpty ? depense.description : 'Dépense',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1C2D11),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (depense.categorieNom != null && depense.categorieNom!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  depense.categorieNom!,
                  style: const TextStyle(color: Color(0xFF8E9A86), fontSize: 14),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                '- ${DemoData.formatAmount(depense.montant)} ${widget.currency}',
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Montant',
                style: TextStyle(color: Color(0xFF7F8E75), fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildInfoRow(
          'Date',
          depense.dateDepense != null
              ? _formatDateLabel(depense.dateDepense!)
              : '—',
        ),
        _buildInfoRow(
          'Description',
          depense.description.isNotEmpty ? depense.description : '—',
        ),
        _buildInfoRow(
          'Catégorie',
          depense.categorieNom?.isNotEmpty == true ? depense.categorieNom! : '—',
        ),
        _buildInfoRow(
          'Compte',
          depense.compteNom?.isNotEmpty == true ? depense.compteNom! : '—',
        ),
        _buildInfoRow(
          'Montant',
          '${DemoData.formatAmount(depense.montant)} ${widget.currency}',
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => setState(() => _isEditing = true),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Modifier'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
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
            'Supprimer la dépense',
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              color: Color(0xFF1C2D11),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            style: const TextStyle(color: Color(0xFF1C2D11)),
            decoration: _fieldDecoration(
              hint: 'Description de la dépense',
              icon: Icons.label_outline_rounded,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Indiquez une description';
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
              hint: 'Montant',
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
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF8E9A86),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? _formatDateLabel(_selectedDate!)
                          : 'Choisir une date',
                      style: const TextStyle(color: Color(0xFF1C2D11), fontSize: 15),
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
            hint: 'Catégorie',
            items: _categories
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nom)))
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
          _buildDropdown<int>(
            value: _selectedCompteId,
            hint: 'Compte',
            items: _comptes
                .map((c) => DropdownMenuItem(value: c.idCompte, child: Text(c.nom)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCompteId = v),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Enregistrer les modifications',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
          ),
        ],
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
