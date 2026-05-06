class Entry {
  String accountId;
  String accountName;
  bool isDebit;
  double amount;

  Entry({
    required this.accountId,
    required this.accountName,
    required this.isDebit,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'accountName': accountName,
        'isDebit': isDebit,
        'amount': amount,
      };

  factory Entry.fromJson(Map<String, dynamic> json) => Entry(
        accountId: json['accountId'],
        accountName: json['accountName'],
        isDebit: json['isDebit'],
        amount: (json['amount'] ?? 0).toDouble(),
      );
}
