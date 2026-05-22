import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_branding.dart';
import '../app_colors.dart';
import '../responsive.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  static const int _signUpTotalSteps = 3;
  int _signUpStep = 0;

  String _selectedCurrency = 'MGA';
  final List<Map<String, String>> _currencies = [
    {'symbol': 'MGA', 'name': 'Ariary malgache (MGA)'},
    {'symbol': '€', 'name': 'Euro (€)'},
    {'symbol': '\$', 'name': 'Dollar US (\$)'},
    {'symbol': 'FCFA', 'name': 'Franc CFA (FCFA)'},
    {'symbol': 'C\$', 'name': 'Dollar Canadien (C\$)'},
    {'symbol': '£', 'name': 'Livre Sterling (£)'},
    {'symbol': 'CHF', 'name': 'Franc Suisse (CHF)'},
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFormMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _signUpStep = 0;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
      _lastNameController.clear();
      _firstNameController.clear();
      _confirmPasswordController.clear();
      _selectedCurrency = 'MGA';
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _goToSignUpStep(int step) {
    setState(() => _signUpStep = step.clamp(0, _signUpTotalSteps - 1));
  }

  String get _fullName {
    final prenom = _firstNameController.text.trim();
    final nom = _lastNameController.text.trim();
    if (prenom.isEmpty && nom.isEmpty) return '';
    if (prenom.isEmpty) return nom;
    if (nom.isEmpty) return prenom;
    return '$prenom $nom';
  }

  bool _validateSignUpStep(int step) {
    if (step == 1) return _selectedCurrency.isNotEmpty;
    return _formKey.currentState?.validate() ?? false;
  }

  void _handleSignUpBack() {
    if (_signUpStep > 0) {
      _goToSignUpStep(_signUpStep - 1);
    } else {
      _toggleFormMode();
    }
  }

  void _handleSignUpNext() {
    if (!_validateSignUpStep(_signUpStep)) return;
    if (_signUpStep < _signUpTotalSteps - 1) {
      _goToSignUpStep(_signUpStep + 1);
    } else {
      _submitForm();
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          _isSignUp ? 'Compte créé avec succès !' : 'Connexion réussie',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
          userName: _fullName.isNotEmpty ? _fullName : 'Utilisateur démo',
          userEmail: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : 'demo@myjalako.app',
          currency: _selectedCurrency,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailResetController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Mot de passe oublié',
            style: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: dialogFormKey,
            child: TextFormField(
              controller: emailResetController,
              keyboardType: TextInputType.emailAddress,
              decoration: _fieldDecoration(
                hint: 'exemple@email.com',
                icon: Icons.mail_outline_rounded,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'E-mail requis';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: AppColors.mediumGray)),
            ),
            ElevatedButton(
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.accent,
                      content: const Text('Lien de réinitialisation envoyé'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.mediumGray, fontSize: 15),
      prefixIcon: Icon(icon, color: AppColors.lightGray, size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.fieldWhite,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.fieldBorder, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.fieldBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
      ),
      errorStyle: const TextStyle(fontSize: 11),
    );
  }

  Widget _buildCapsLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.lightGray,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, VoidCallback? onTap}) {
    return Material(
      color: AppColors.fieldWhite,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: AppColors.darkText.withOpacity(0.08),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          height: 44,
          width: 44,
          child: Icon(icon, color: AppColors.darkText, size: 22),
        ),
      ),
    );
  }

  Widget _buildSignUpChip() {
    return Material(
      color: AppColors.mintSurface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: _toggleFormMode,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            _isSignUp ? 'Se connecter' : 'Créer un compte',
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.mintSurface,
        border: Border.all(color: AppColors.fieldBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          AppBranding.logoAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.account_balance_wallet_rounded,
            size: 48,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton({required String label, VoidCallback? onPressed}) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 22),
                ],
              ),
      ),
    );
  }

  Widget _buildSignUpProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Étape ${_signUpStep + 1} sur $_signUpTotalSteps',
              style: const TextStyle(
                color: AppColors.mediumGray,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${((_signUpStep + 1) / _signUpTotalSteps * 100).round()} %',
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_signUpStep + 1) / _signUpTotalSteps,
            minHeight: 6,
            backgroundColor: AppColors.fieldBorder,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_signUpTotalSteps, (i) {
            final active = i <= _signUpStep;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: active ? 24 : 8,
              decoration: BoxDecoration(
                color: active ? AppColors.accent : AppColors.fieldBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  String get _signUpStepTitle {
    switch (_signUpStep) {
      case 0:
        return 'Votre profil';
      case 1:
        return 'Votre devise';
      default:
        return 'Sécurisez votre compte';
    }
  }

  String get _signUpStepSubtitle {
    switch (_signUpStep) {
      case 0:
        return 'Indiquez votre nom et prénom pour personnaliser votre espace.';
      case 1:
        return 'Choisissez la monnaie utilisée pour votre budget.';
      default:
        return 'Créez vos identifiants de connexion.';
    }
  }

  Widget _buildSignUpStepContent() {
    switch (_signUpStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCapsLabel('Nom'),
            TextFormField(
              controller: _lastNameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: AppColors.darkText, fontSize: 15),
              decoration: _fieldDecoration(
                hint: 'ex: Rakoto',
                icon: Icons.badge_outlined,
              ),
              validator: (v) =>
                  v == null || v.trim().length < 2 ? 'Nom requis (2 caractères min.)' : null,
            ),
            const SizedBox(height: 20),
            _buildCapsLabel('Prénom'),
            TextFormField(
              controller: _firstNameController,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: AppColors.darkText, fontSize: 15),
              decoration: _fieldDecoration(
                hint: 'ex: Jean',
                icon: Icons.person_outline_rounded,
              ),
              validator: (v) => v == null || v.trim().length < 2
                  ? 'Prénom requis (2 caractères min.)'
                  : null,
              onFieldSubmitted: (_) => _handleSignUpNext(),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCapsLabel('Devise principale'),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: _fieldDecoration(
                hint: 'Devise',
                icon: Icons.monetization_on_outlined,
              ),
              items: _currencies
                  .map((c) => DropdownMenuItem(
                        value: c['symbol'],
                        child: Text(c['name']!),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCurrency = v);
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.mintSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vous pourrez modifier la devise plus tard dans les paramètres.',
                      style: TextStyle(
                        color: AppColors.darkText.withOpacity(0.7),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCapsLabel('Votre e-mail'),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: AppColors.darkText, fontSize: 15),
              decoration: _fieldDecoration(
                hint: 'email@gmail.com',
                icon: Icons.mail_outline_rounded,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'E-mail requis';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                  return 'E-mail invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildCapsLabel('Votre mot de passe'),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: AppColors.darkText, fontSize: 15),
              decoration: _fieldDecoration(
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.lightGray,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Mot de passe requis';
                if (v.length < 6) return '6 caractères minimum';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildCapsLabel('Confirmer le mot de passe'),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              decoration: _fieldDecoration(
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.lightGray,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              validator: (v) => v != _passwordController.text
                  ? 'Les mots de passe ne correspondent pas'
                  : null,
              onFieldSubmitted: (_) => _handleSignUpNext(),
            ),
          ],
        );
    }
  }

  Widget _buildSignUpNavigation() {
    final isLastStep = _signUpStep == _signUpTotalSteps - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_signUpStep > 0) ...[
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => _goToSignUpStep(_signUpStep - 1),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Précédent', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        _buildSubmitButton(
          label: isLastStep ? 'Créer mon compte' : 'Continuer',
          onPressed: _handleSignUpNext,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final horizontalPad = r.isTablet ? 32.0 : (r.isSmallPhone ? 18.0 : 24.0);
    final verticalPad = r.isShortScreen ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: verticalPad),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: r.maxContentWidth),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircleButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: _isSignUp ? _handleSignUpBack : () => Navigator.maybePop(context),
                          ),
                          _buildSignUpChip(),
                        ],
                      ),
                      SizedBox(height: r.isShortScreen ? 20 : 32),
                      Center(child: _buildLogo(r.logoSize)),
                      SizedBox(height: r.isShortScreen ? 12 : 16),
                      Text(
                        AppBranding.appName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: r.titleMedium,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: r.isShortScreen ? 20 : 28),
                      Text(
                        _isSignUp ? _signUpStepTitle : 'Ravi de vous voir !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.darkText,
                          fontSize: r.titleLarge,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: r.isShortScreen ? 8 : 10),
                      Text(
                        _isSignUp
                            ? _signUpStepSubtitle
                            : 'Connectez-vous pour accéder à votre espace et gérer vos finances.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.mediumGray,
                          fontSize: r.bodySize,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: r.isShortScreen ? 24 : 36),
                      if (_isSignUp) ...[
                        _buildSignUpProgress(),
                        const SizedBox(height: 28),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.04, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: KeyedSubtree(
                            key: ValueKey<int>(_signUpStep),
                            child: _buildSignUpStepContent(),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _buildSignUpNavigation(),
                      ] else ...[
                        _buildCapsLabel('Votre e-mail'),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: AppColors.darkText, fontSize: 15),
                          decoration: _fieldDecoration(
                            hint: 'email@gmail.com',
                            icon: Icons.mail_outline_rounded,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'E-mail requis';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                              return 'E-mail invalide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildCapsLabel('Votre mot de passe'),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: AppColors.darkText, fontSize: 15),
                          decoration: _fieldDecoration(
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.lightGray,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Mot de passe requis';
                            if (v.length < 6) return '6 caractères minimum';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _showForgotPasswordDialog,
                            child: const Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.accent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _buildSubmitButton(
                          label: 'Se connecter',
                          onPressed: _submitForm,
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
