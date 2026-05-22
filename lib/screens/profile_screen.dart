import 'package:flutter/material.dart';
import '../app_branding.dart';
import '../app_colors.dart';
import '../responsive.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String currency;
  final double bottomPadding;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.currency,
    required this.onLogout,
    this.bottomPadding = 0,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _displayName;
  late String _displayEmail;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _displayName = widget.userName;
    _displayEmail = widget.userEmail;
  }

  String get _initials {
    final parts = _displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || _displayName.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  void _showSnack(String message, {IconData icon = Icons.info_outline_rounded}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEditProfileSheet() {
    final nameController = TextEditingController(text: _displayName);
    final emailController = TextEditingController(text: _displayEmail);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
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
              const Text(
                'Modifier le profil',
                style: TextStyle(
                  color: Color(0xFF1C2D11),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildSheetLabel('Nom complet'),
              TextFormField(
                controller: nameController,
                style: const TextStyle(color: Color(0xFF1C2D11)),
                decoration: _buildSheetFieldDecoration(
                  hint: 'Nom & Prénom',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 3) {
                    return 'Le nom doit faire au moins 3 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildSheetLabel('Adresse e-mail'),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Color(0xFF1C2D11)),
                decoration: _buildSheetFieldDecoration(
                  hint: 'exemple@email.com',
                  prefixIcon: Icons.mail_outline_rounded,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Veuillez entrer votre e-mail';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                    return 'Format d\'e-mail incorrect';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      _displayName = nameController.text.trim();
                      _displayEmail = emailController.text.trim();
                    });
                    Navigator.pop(context);
                    _showSnack('Profil mis à jour', icon: Icons.check_circle_outline_rounded);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Enregistrer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetLabel(String text) {
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

  InputDecoration _buildSheetFieldDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8E9A86)),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF8E9A86), size: 20),
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

  void _showCurrencySheet() {
    final currencies = [
      {'symbol': 'MGA', 'name': 'Ariary malgache (MGA)'},
      {'symbol': '€', 'name': 'Euro (€)'},
      {'symbol': '\$', 'name': 'Dollar US (\$)'},
      {'symbol': 'FCFA', 'name': 'Franc CFA (FCFA)'},
      {'symbol': 'C\$', 'name': 'Dollar Canadien (C\$)'},
      {'symbol': '£', 'name': 'Livre Sterling (£)'},
      {'symbol': 'CHF', 'name': 'Franc Suisse (CHF)'},
    ];

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
              'Devise du compte',
              style: TextStyle(
                color: Color(0xFF1C2D11),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Devise actuelle : ${widget.currency}',
              style: const TextStyle(color: Color(0xFF7F8E75), fontSize: 14),
            ),
            const SizedBox(height: 16),
            ...currencies.map((c) {
              final isSelected = c['symbol'] == widget.currency;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.monetization_on_outlined,
                  color: isSelected ? AppColors.accent : const Color(0xFF8E9A86),
                ),
                title: Text(
                  c['name']!,
                  style: TextStyle(
                    color: const Color(0xFF1C2D11),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.accent)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _showSnack(
                    c['symbol'] == widget.currency
                        ? 'Devise déjà sélectionnée'
                        : 'Changement de devise bientôt disponible',
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final h = r.horizontalPadding;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.only(bottom: widget.bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(r),
          Transform.translate(
            offset: const Offset(0, -32),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: h),
              child: _buildProfileCard(),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: h),
            child: _buildStatsRow(),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: h),
            child: _buildSectionTitle('Mon compte'),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: h),
            child: _buildMenuCard([
              _MenuItem(
                icon: Icons.person_outline_rounded,
                title: 'Informations personnelles',
                subtitle: _displayName,
                onTap: _showEditProfileSheet,
              ),
              _MenuItem(
                icon: Icons.lock_outline_rounded,
                title: 'Sécurité',
                subtitle: 'Mot de passe, authentification',
                onTap: () => _showSnack('Paramètres de sécurité bientôt disponibles'),
              ),
              _MenuItem(
                icon: Icons.monetization_on_outlined,
                title: 'Devise',
                subtitle: widget.currency,
                onTap: _showCurrencySheet,
              ),
            ]),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: h),
            child: _buildSectionTitle('Préférences'),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: h),
            child: _buildMenuCard([
              _MenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Alertes budgets et transactions',
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeColor: AppColors.accent,
                  onChanged: (v) {
                    setState(() => _notificationsEnabled = v);
                    _showSnack(
                      v ? 'Notifications activées' : 'Notifications désactivées',
                      icon: Icons.notifications_outlined,
                    );
                  },
                ),
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.fingerprint_rounded,
                title: 'Connexion biométrique',
                subtitle: 'Empreinte ou reconnaissance faciale',
                trailing: Switch(
                  value: _biometricEnabled,
                  activeColor: AppColors.accent,
                  onChanged: (v) {
                    setState(() => _biometricEnabled = v);
                    _showSnack(
                      v ? 'Biométrie activée' : 'Biométrie désactivée',
                      icon: Icons.fingerprint_rounded,
                    );
                  },
                ),
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.language_rounded,
                title: 'Langue',
                subtitle: 'Français',
                onTap: () => _showSnack('Changement de langue bientôt disponible'),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: h),
            child: _buildSectionTitle('Support'),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: h),
            child: _buildMenuCard([
              _MenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Centre d\'aide',
                subtitle: 'FAQ et assistance',
                onTap: () => _showSnack('Centre d\'aide bientôt disponible'),
              ),
              _MenuItem(
                icon: Icons.info_outline_rounded,
                title: 'À propos',
                subtitle: '${AppBranding.appName} v1.0.0',
                onTap: () => _showAboutDialog(),
              ),
              _MenuItem(
                icon: Icons.description_outlined,
                title: 'Conditions d\'utilisation',
                onTap: () => _showSnack('Conditions d\'utilisation bientôt disponibles'),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: h),
            child: OutlinedButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFD32F2F)),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFF8E9A86).withOpacity(0.12)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Text(
              AppBranding.appName,
              style: const TextStyle(
                color: Color(0xFF1C2D11),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Application de gestion de budget personnel.\n\nVersion 1.0.0\n© 2026 Myjalako',
          style: TextStyle(color: Color(0xFF7F8E75), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fermer',
              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppResponsive r) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        r.horizontalPadding,
        r.sp(20),
        r.horizontalPadding,
        r.headerBottomPadding,
      ),
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
            'Mon profil',
            style: TextStyle(
              color: Colors.white,
              fontSize: r.titleMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Paramètres et informations du compte',
            style: TextStyle(
              color: Colors.white70,
              fontSize: r.sp(13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(22),
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
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFFE8F5E9),
              child: Text(
                _initials,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1C2D11),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _displayEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8E9A86),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Membre depuis Mai 2026',
                    style: TextStyle(
                      color: AppColors.accent.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _showEditProfileSheet,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.accent,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'value': '7', 'label': 'Budgets'},
      {'value': '4', 'label': 'Comptes'},
      {'value': widget.currency, 'label': 'Devise'},
    ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: stat == stats.last ? 0 : 8,
              left: stat == stats.first ? 0 : 0,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF8E9A86).withOpacity(0.08)),
            ),
            child: Column(
              children: [
                Text(
                  stat['value']!,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['label']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF8E9A86),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF1C2D11),
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
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
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              if (index > 0)
                Divider(
                  color: const Color(0xFF8E9A86).withOpacity(0.08),
                  height: 1,
                  indent: 56,
                  endIndent: 16,
                ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.trailing == null ? item.onTap : null,
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? const Radius.circular(20) : Radius.zero,
                    bottom: index == items.length - 1 ? const Radius.circular(20) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, color: AppColors.accent, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: Color(0xFF1C2D11),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (item.subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF8E9A86),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (item.trailing != null)
                          item.trailing!
                        else
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF8E9A86),
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });
}
