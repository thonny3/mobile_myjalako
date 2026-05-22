import 'package:flutter/material.dart';
import '../app_branding.dart';
import '../app_colors.dart';
import '../demo_data.dart';
import '../responsive.dart';
import 'accounts_screen.dart';
import 'budgets_screen.dart';
import 'new_budget_screen.dart';
import 'login_screen.dart';
import 'objectifs_screen.dart';
import 'profile_screen.dart';
import 'transactions_screen.dart';
import 'transfer_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String currency;

  const HomeScreen({
    super.key,
    this.userName = 'Utilisateur démo',
    this.userEmail = 'demo@myjalako.app',
    this.currency = 'MGA',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _sectionAccueil = 0;
  static const int _sectionComptes = 1;
  static const int _sectionRevenus = 2;
  static const int _sectionDepenses = 3;
  static const int _sectionTransactions = 4;
  static const int _sectionBudget = 5;
  static const int _sectionObjectifs = 6;
  static const int _sectionProfil = 7;
  static const int _sectionParametres = 8;
  static const int _sectionTransfert = 9;
  static const int _sectionAjouter = 10;

  static const _bottomNavAccueil = 0;
  static const _bottomNavTransactions = 1;
  static const _bottomNavPlus = 2;
  static const _bottomNavComptes = 3;
  static const _bottomNavProfil = 4;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _transactionsKey = GlobalKey<TransactionsScreenState>();
  final _accountsKey = GlobalKey<AccountsScreenState>();
  int _sectionIndex = _sectionAccueil;
  bool _showBalance = true;
  List<Map<String, dynamic>> _transactions = List<Map<String, dynamic>>.from(
    DemoData.demoTransactions.map((t) => Map<String, dynamic>.from(t)),
  );

  int get _totalRevenues => _transactions
      .where((t) => (t['amount'] as int) > 0)
      .fold(0, (sum, t) => sum + (t['amount'] as int));

  int get _totalExpenses => _transactions
      .where((t) => (t['amount'] as int) < 0)
      .fold(0, (sum, t) => sum + (t['amount'] as int).abs());

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _navigateFromDrawer(int index) {
    Navigator.of(context).pop();
    setState(() => _sectionIndex = index);
  }

  int _bottomNavSelectedIndex() {
    switch (_sectionIndex) {
      case _sectionAccueil:
        return _bottomNavAccueil;
      case _sectionTransactions:
        return _bottomNavTransactions;
      case _sectionComptes:
        return _bottomNavComptes;
      case _sectionProfil:
        return _bottomNavProfil;
      default:
        return _bottomNavAccueil;
    }
  }

  void _onBottomNavTap(int navIndex) {
    if (navIndex == _bottomNavPlus) {
      _showPlusMenu();
      return;
    }
    final section = switch (navIndex) {
      _bottomNavAccueil => _sectionAccueil,
      _bottomNavTransactions => _sectionTransactions,
      _bottomNavComptes => _sectionComptes,
      _bottomNavProfil => _sectionProfil,
      _ => _sectionAccueil,
    };
    setState(() => _sectionIndex = section);
  }

  void _showPlusMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          _hPad + 4,
          20,
          _hPad + 4,
          32 + MediaQuery.of(context).padding.bottom,
        ),
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
              'Que souhaitez-vous ajouter ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1C2D11),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildPlusOption(
              title: 'Transaction',
              subtitle: 'Revenu ou dépense',
              icon: Icons.swap_horiz_rounded,
              color: AppColors.accent,
              bg: const Color(0xFFE8F5E9),
              onTap: () {
                Navigator.pop(context);
                setState(() => _sectionIndex = _sectionTransactions);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _transactionsKey.currentState?.showAddMenu();
                });
              },
            ),
            const SizedBox(height: 10),
            _buildPlusOption(
              title: 'Transfert',
              subtitle: 'Entre vos comptes',
              icon: Icons.send_rounded,
              color: const Color(0xFF1976D2),
              bg: const Color(0xFFE3F2FD),
              onTap: () {
                Navigator.pop(context);
                setState(() => _sectionIndex = _sectionTransfert);
              },
            ),
            const SizedBox(height: 10),
            _buildPlusOption(
              title: 'Budget',
              subtitle: 'Nouvelle catégorie',
              icon: Icons.pie_chart_outline_rounded,
              color: const Color(0xFF7B1FA2),
              bg: const Color(0xFFF3E5F5),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewBudgetScreen(currency: widget.currency),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildPlusOption(
              title: 'Compte',
              subtitle: 'Nouveau compte bancaire',
              icon: Icons.account_balance_wallet_outlined,
              color: const Color(0xFF8E9A86),
              bg: const Color(0xFFF5F7F4),
              onTap: () async {
                Navigator.pop(context);
                setState(() => _sectionIndex = _sectionComptes);
                await Future.delayed(Duration.zero);
                if (!mounted) return;
                _accountsKey.currentState?.openNewAccount();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlusOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
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
                      style: const TextStyle(color: Color(0xFF7F8E75), fontSize: 12),
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

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFF8E9A86).withOpacity(0.12)),
        ),
        title: const Text(
          "Déconnexion",
          style: TextStyle(color: Color(0xFF1C2D11), fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Êtes-vous sûr de vouloir vous déconnecter de votre compte ?",
          style: TextStyle(color: Color(0xFF7F8E75)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Annuler",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Se déconnecter"),
          ),
        ],
      ),
    );
  }

  AppResponsive get _r => context.responsive;
  double get _hPad => _r.horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final bottomNavPadding = _r.bottomNavHeight;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9F8),
      drawer: _buildSidebar(),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: _r.maxContentWidth,
            ),
            child: IndexedStack(
              index: _sectionIndex,
              children: [
                _buildDashboardTab(bottomNavPadding),
                AccountsScreen(
                  key: _accountsKey,
                  currency: widget.currency,
                  bottomPadding: bottomNavPadding,
                ),
                _buildRevenusTab(bottomNavPadding),
                _buildDepensesTab(bottomNavPadding),
                TransactionsScreen(
                  key: _transactionsKey,
                  currency: widget.currency,
                  bottomPadding: bottomNavPadding,
                  transactions: _transactions,
                  onTransactionsChanged: (list) {
                    setState(() => _transactions = list);
                  },
                ),
                BudgetsScreen(
                  currency: widget.currency,
                  bottomPadding: bottomNavPadding,
                ),
                ObjectifsScreen(
                  currency: widget.currency,
                  bottomPadding: bottomNavPadding,
                ),
                ProfileScreen(
                  userName: widget.userName,
                  userEmail: widget.userEmail,
                  currency: widget.currency,
                  bottomPadding: bottomNavPadding,
                  onLogout: _logout,
                ),
                _buildParametresTab(bottomNavPadding),
                TransferScreen(
                  currency: widget.currency,
                  bottomPadding: bottomNavPadding,
                ),
                _buildComingSoonTab('Ajouter', Icons.add_circle_outline_rounded, bottomNavPadding),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    final selected = _bottomNavSelectedIndex();
    final fabSize = _r.isSmallPhone ? 50.0 : 56.0;
    final fabLift = 18.0;
    final barHeight = 60.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFF8E9A86).withOpacity(0.12)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: barHeight + fabLift * 0.5,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Padding(
                padding: EdgeInsets.only(top: fabLift * 0.25, bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildNavItem(
                        index: _bottomNavAccueil,
                        selected: selected,
                        icon: Icons.home_rounded,
                        label: 'Accueil',
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        index: _bottomNavTransactions,
                        selected: selected,
                        icon: Icons.swap_horiz_rounded,
                        label: _r.isSmallPhone ? 'Transac.' : 'Transactions',
                      ),
                    ),
                    SizedBox(width: fabSize + 12),
                    Expanded(
                      child: _buildNavItem(
                        index: _bottomNavComptes,
                        selected: selected,
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Comptes',
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        index: _bottomNavProfil,
                        selected: selected,
                        icon: Icons.person_outline_rounded,
                        label: 'Profil',
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -fabLift,
                left: 0,
                right: 0,
                child: Center(
                  child: Material(
                    elevation: 6,
                    shadowColor: AppColors.accent.withOpacity(0.35),
                    color: AppColors.accent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => _onBottomNavTap(_bottomNavPlus),
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: fabSize,
                        height: fabSize,
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: _r.isSmallPhone ? 28 : 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required int selected,
    required IconData icon,
    required String label,
  }) {
    final isActive = selected == index;
    final color = isActive ? AppColors.accent : const Color(0xFF8E9A86);

    return InkWell(
      onTap: () => _onBottomNavTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: _r.isSmallPhone ? 21 : 24),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: _r.navLabelSize,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(double bottomNavPadding) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.only(bottom: bottomNavPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGreenHeader(),
          Transform.translate(
            offset: const Offset(0, -28),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _hPad),
              child: _buildBalanceCard(),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _hPad),
            child: _buildQuickActions(),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _hPad),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Budget Mensuel",
                  style: TextStyle(
                    color: Color(0xFF1C2D11),
                    fontSize: _r.sectionTitleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: const Text(
                    "Détails",
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _hPad),
            child: _buildBudgetCard(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _hPad),
            child: _buildBudgetCard(
              title: 'Transport',
              spent: DemoData.transportSpent,
              limit: DemoData.transportLimit,
              progress: DemoData.transportSpent / DemoData.transportLimit,
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _hPad),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transactions récentes",
                  style: TextStyle(
                    color: Color(0xFF1C2D11),
                    fontSize: _r.sectionTitleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: const Text(
                    "Tout voir",
                    style: TextStyle(
                      color: Color(0xFF8E9A86),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _hPad),
            child: _buildTransactionsCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: _r.headerInsets(),
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
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: _r.titleMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String amount,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8E9A86),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Color(0xFF1C2D11),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenusTab(double bottomPadding) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPageHeader('Revenus', 'Suivez vos entrées d\'argent'),
          Transform.translate(
            offset: const Offset(0, -24),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _hPad),
              child: _buildSummaryCard(
                label: 'Total ce mois-ci',
                amount: '${DemoData.formatAmount(_totalRevenues)} ${widget.currency}',
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFF2E7D32),
                iconBg: const Color(0xFFE8F5E9),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _hPad),
            child: _buildIncomeExpenseList(isIncome: true),
          ),
        ],
      ),
    );
  }

  Widget _buildDepensesTab(double bottomPadding) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPageHeader('Dépenses', 'Contrôlez vos sorties d\'argent'),
          Transform.translate(
            offset: const Offset(0, -24),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: _hPad),
              child: _buildSummaryCard(
                label: 'Total ce mois-ci',
                amount: '${DemoData.formatAmount(_totalExpenses)} ${widget.currency}',
                icon: Icons.trending_down_rounded,
                iconColor: const Color(0xFFD32F2F),
                iconBg: const Color(0xFFFFEBEE),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _hPad),
            child: _buildIncomeExpenseList(isIncome: false),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseList({required bool isIncome}) {
    final items = _transactions.where((tx) {
      final amount = tx['amount'] as int;
      return isIncome ? amount > 0 : amount < 0;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8E9A86).withOpacity(0.08)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(
          color: const Color(0xFF8E9A86).withOpacity(0.08),
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final tx = items[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tx['bg'] as Color,
                shape: BoxShape.circle,
              ),
              child: Icon(tx['icon'] as IconData, color: tx['fg'] as Color, size: 20),
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
                color: isIncome ? const Color(0xFF2E7D32) : const Color(0xFF1C2D11),
                fontWeight: FontWeight.bold,
                fontSize: _r.sp(13),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParametresTab(double bottomPadding) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPageHeader('Paramètres', 'Préférences de l\'application'),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _hPad),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF8E9A86).withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    Icons.monetization_on_outlined,
                    'Devise',
                    widget.currency,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildSettingsTile(
                    Icons.language_rounded,
                    'Langue',
                    'Français',
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildSettingsTile(
                    Icons.notifications_outlined,
                    'Notifications',
                    'Activées',
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildSettingsTile(
                    Icons.dark_mode_outlined,
                    'Thème',
                    'Clair',
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildSettingsTile(
                    Icons.lock_outline_rounded,
                    'Sécurité',
                    'Mot de passe, biométrie',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFFE8F5E9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.accent, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1C2D11),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF8E9A86), fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF8E9A86)),
      onTap: () {},
    );
  }

  Widget _buildComingSoonTab(String title, IconData icon, double bottomPadding) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: const Color(0xFF8E9A86).withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1C2D11),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bientôt disponible',
                style: TextStyle(color: Color(0xFF7F8E75), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildSidebar() {
    final menuItems = [
      {'label': 'Accueil', 'icon': Icons.home_rounded, 'index': _sectionAccueil},
      {'label': 'Mes comptes', 'icon': Icons.account_balance_wallet_outlined, 'index': _sectionComptes},
      {'label': 'Revenus', 'icon': Icons.trending_up_rounded, 'index': _sectionRevenus},
      {'label': 'Dépenses', 'icon': Icons.trending_down_rounded, 'index': _sectionDepenses},
      {'label': 'Transactions', 'icon': Icons.swap_horiz_rounded, 'index': _sectionTransactions},
      {'label': 'Transfert d\'argent', 'icon': Icons.send_rounded, 'index': _sectionTransfert},
      {'label': 'Budget', 'icon': Icons.pie_chart_outline_rounded, 'index': _sectionBudget},
      {'label': 'Objectifs', 'icon': Icons.flag_outlined, 'index': _sectionObjectifs},
      {'label': 'Profil', 'icon': Icons.person_outline_rounded, 'index': _sectionProfil},
      {'label': 'Paramètres', 'icon': Icons.settings_outlined, 'index': _sectionParametres},
    ];

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(_hPad, 24, _hPad, 24),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.userEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                AppBranding.appName,
                style: const TextStyle(
                  color: Color(0xFF8E9A86),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: menuItems.map((item) {
                  final index = item['index'] as int;
                  final isSelected = _sectionIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      leading: Icon(
                        item['icon'] as IconData,
                        color: isSelected ? AppColors.accent : const Color(0xFF8E9A86),
                      ),
                      title: Text(
                        item['label'] as String,
                        style: TextStyle(
                          color: const Color(0xFF1C2D11),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      tileColor: isSelected ? const Color(0xFFE8F5E9) : null,
                      onTap: () => _navigateFromDrawer(index),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Color(0xFFD32F2F)),
              title: const Text(
                'Se déconnecter',
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildGreenHeader() {
    final logoSize = _r.isSmallPhone ? 30.0 : 36.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(_hPad, 14, _hPad, 44),
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _buildHeaderIconButton(
              icon: Icons.menu_rounded,
              onTap: _openDrawer,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: logoSize,
                width: logoSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    AppBranding.logoAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.account_balance_wallet_rounded,
                      size: logoSize * 0.55,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppBranding.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _r.sp(14),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _buildHeaderIconButton(
              icon: Icons.logout_rounded,
              onTap: _logout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    "Solde Total",
                    style: TextStyle(
                      color: Color(0xFF8E9A86),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showBalance = !_showBalance;
                      });
                    },
                    child: Icon(
                      _showBalance ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xFF8E9A86),
                      size: 18,
                    ),
                  ),
                ],
              ),
              // Light green percentage badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF2E7D32),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "+2.5%",
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Large main amount
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _showBalance
                  ? "${DemoData.formatAmount(DemoData.totalBalance)} ${widget.currency}"
                  : "•••••• ${widget.currency}",
              style: TextStyle(
                color: Color(0xFF1C2D11),
                fontSize: _r.balanceAmountSize,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: const Color(0xFF8E9A86).withOpacity(0.12), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Revenues Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Revenus",
                      style: TextStyle(
                        color: Color(0xFF8E9A86),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _showBalance
                          ? "${DemoData.formatAmount(DemoData.revenues)} ${widget.currency}"
                          : "•••••• ${widget.currency}",
                      style: const TextStyle(
                        color: Color(0xFF1C2D11),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Vertical Divider Line
              Container(
                height: 36,
                width: 1,
                color: const Color(0xFF8E9A86).withOpacity(0.12),
              ),
              // Expenses Column
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Dépenses",
                        style: TextStyle(
                          color: Color(0xFF8E9A86),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _showBalance
                            ? "${DemoData.formatAmount(DemoData.expenses)} ${widget.currency}"
                            : "•••••• ${widget.currency}",
                        style: const TextStyle(
                          color: Color(0xFF1C2D11),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actionSize = _r.quickActionSize;
    final actions = [
      {'name': 'Envoyer', 'icon': Icons.north_east_rounded, 'section': _sectionTransfert},
      {'name': 'Recevoir', 'icon': Icons.south_west_rounded, 'section': _sectionTransfert},
      {'name': 'Ajouter', 'icon': Icons.add_rounded, 'section': null, 'plus': true},
      {'name': 'Plus', 'icon': Icons.more_horiz_rounded, 'section': null},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((act) {
        final section = act['section'] as int?;
        final openPlus = act['plus'] == true;
        return Column(
          children: [
            InkWell(
              onTap: () {
                if (openPlus) {
                  _showPlusMenu();
                } else if (section != null) {
                  setState(() => _sectionIndex = section);
                } else {
                  _openDrawer();
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: actionSize,
                width: actionSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF8E9A86).withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Icon(
                  act['icon'] as IconData,
                  color: AppColors.accent,
                  size: _r.isSmallPhone ? 20 : 22,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              act['name'] as String,
              style: TextStyle(
                color: Color(0xFF1C2D11),
                fontSize: _r.labelSize,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBudgetCard({
    String title = 'Alimentation',
    int spent = DemoData.foodSpent,
    int limit = DemoData.foodLimit,
    double? progress,
  }) {
    final displayProgress = progress ?? (limit > 0 ? spent / limit : 0.0);
    final remaining = limit - spent;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8E9A86).withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1C2D11),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${DemoData.formatAmount(spent)} ${widget.currency} / ${DemoData.formatAmount(limit)} ${widget.currency}",
                style: const TextStyle(
                  color: Color(0xFF8E9A86),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: displayProgress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFF0F2EF),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            remaining > 0
                ? "Il vous reste ${DemoData.formatAmount(remaining)} ${widget.currency} pour ce mois-ci."
                : "Budget dépassé de ${DemoData.formatAmount(-remaining)} ${widget.currency}.",
            style: const TextStyle(
              color: Color(0xFF7F8E75),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsCard() {
    final txs = _transactions.take(5).toList();

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
          )
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: txs.length,
        separatorBuilder: (context, index) => Divider(
          color: const Color(0xFF8E9A86).withOpacity(0.08),
          height: 1,
          indent: 20,
          endIndent: 20,
        ),
        itemBuilder: (context, index) {
          final tx = txs[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Custom themed circle icon
                Container(
                  padding: const EdgeInsets.all(10),
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
                const SizedBox(width: 14),
                // Titles Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['title'] as String,
                        style: const TextStyle(
                          color: Color(0xFF1C2D11),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tx['subtitle'] as String,
                        style: const TextStyle(
                          color: Color(0xFF8E9A86),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Amount Column
                Text(
                  "${DemoData.formatSignedAmount(tx['amount'] as int)} ${widget.currency}",
                  style: TextStyle(
                    color: (tx['isExpense'] as bool) ? const Color(0xFF1C2D11) : const Color(0xFF2E7D32),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
