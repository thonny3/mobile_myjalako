class DashboardSummary {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpenses;

  const DashboardSummary({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
  });

  static double _parseNum(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalBalance: _parseNum(json['totalBalance']),
      monthlyIncome: _parseNum(json['monthlyIncome']),
      monthlyExpenses: _parseNum(json['monthlyExpenses']),
    );
  }
}
