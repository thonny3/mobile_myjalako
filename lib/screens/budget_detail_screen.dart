import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../demo_data.dart';
import '../models/budget.dart';
import '../responsive.dart';
import '../services/auth_service.dart';
import '../services/budget_service.dart';

class BudgetDetailScreen extends StatefulWidget {
  final int idBudget;
  final String currency;

  const BudgetDetailScreen({
    super.key,
    required this.idBudget,
    required this.currency,
  });

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();

  Budget? _budget;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final budget = await BudgetService.getById(widget.idBudget);
      if (!mounted) return;
      setState(() {
        _budget = budget;
        _limitController.text = budget.limit.round().toString();
        _isLoading = false;
      });
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
        _errorMessage = 'Impossible de charger le budget : $e';
      });
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving || _budget == null) {
      return;
    }

    final newMax = double.parse(_limitController.text.trim());
    final spent = _budget!.spent;
    final newRestant = (newMax - spent).clamp(0.0, double.infinity);

    setState(() => _isSaving = true);
    try {
      await BudgetService.update(
        idBudget: _budget!.idBudget,
        montantMax: newMax,
        montantRestant: newRestant,
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le budget ?'),
        content: const Text(
          'Cette action est definitive. Le budget sera retire de la liste.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await BudgetService.delete(widget.idBudget);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _showError('Erreur : $e');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
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
        title: const Text(
          'Detail budget',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading && _budget != null && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () => setState(() {
                        _isEditing = false;
                        _limitController.text =
                            _budget!.limit.round().toString();
                      }),
              child: const Text('Annuler', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: r.pageInsets(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFD32F2F)),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _loadData,
                          child: const Text('Reessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(r),
    );
  }

  Widget _buildContent(AppResponsive r) {
    final budget = _budget!;
    final style = Budget.styleForCategory(budget.categorie);
    final progress = budget.progress.clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: r.pageInsets(bottom: 32, top: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF8E9A86).withValues(alpha: 0.08),
                ),
              ),
              child: Column(
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
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    budget.categorie,
                    style: const TextStyle(
                      color: Color(0xFF1C2D11),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${DemoData.formatAmount(budget.spent)} / ${DemoData.formatAmount(budget.limit)} ${widget.currency}',
                    style: const TextStyle(
                      color: Color(0xFF8E9A86),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFF0F2EF),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        budget.isOver
                            ? const Color(0xFFC62828)
                            : style['color'] as Color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    budget.isOver
                        ? 'Depasse de ${DemoData.formatAmount(-budget.remaining)} ${widget.currency}'
                        : 'Il reste ${DemoData.formatAmount(budget.remaining)} ${widget.currency}',
                    style: TextStyle(
                      color: budget.isOver
                          ? const Color(0xFFC62828)
                          : const Color(0xFF7F8E75),
                      fontSize: 13,
                    ),
                  ),
                ],
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
              enabled: _isEditing,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F7F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),
              validator: (v) {
                if (!_isEditing) return null;
                if (v == null || v.trim().isEmpty) return 'Plafond requis';
                final n = int.tryParse(v.trim());
                if (n == null || n <= 0) return 'Montant invalide';
                return null;
              },
            ),
            if (_isEditing) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
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
                        'Enregistrer',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _isDeleting ? null : _confirmDelete,
              icon: _isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFD32F2F)),
              label: const Text(
                'Supprimer le budget',
                style: TextStyle(color: Color(0xFFD32F2F)),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFD32F2F)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
