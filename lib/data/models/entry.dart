/// Monetary amounts are stored as integer cents to avoid floating-point drift.
/// UI and reports convert to yuan via [amount] / [formatCurrency].
class Entry {
  String accountId;
  String accountName;
  bool isDebit;
  int amountCents;

  double get amount => amountCents / 100.0;

  Entry({
    required this.accountId,
    required this.accountName,
    required this.isDebit,
    double? amount,
    int? amountCents,
  }) : amountCents = amountCents ?? ((amount ?? 0) * 100).round();

  /// Preferred factory when the yuan value is already known as a double.
  factory Entry.fromYuan({
    required String accountId,
    required String accountName,
    required bool isDebit,
    required double amount,
  }) =>
      Entry(
        accountId: accountId,
        accountName: accountName,
        isDebit: isDebit,
        amountCents: (amount * 100).round(),
      );

  Entry copyWith({
    String? accountId,
    String? accountName,
    bool? isDebit,
    int? amountCents,
  }) =>
      Entry(
        accountId: accountId ?? this.accountId,
        accountName: accountName ?? this.accountName,
        isDebit: isDebit ?? this.isDebit,
        amountCents: amountCents ?? this.amountCents,
      );

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'accountName': accountName,
        'isDebit': isDebit,
        'amountCents': amountCents,
        // Keep legacy key so older builds can still read migrated data.
        'amount': amount,
      };

  factory Entry.fromJson(Map<String, dynamic> json) {
    final cents = json['amountCents'];
    if (cents is int) {
      return Entry(
        accountId: json['accountId'],
        accountName: json['accountName'],
        isDebit: json['isDebit'],
        amountCents: cents,
      );
    }
    // Legacy double yuan storage → migrate to cents.
    final legacy = (json['amount'] ?? 0).toDouble();
    return Entry(
      accountId: json['accountId'],
      accountName: json['accountName'],
      isDebit: json['isDebit'],
      amountCents: (legacy * 100).round(),
    );
  }
}
