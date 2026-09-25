import 'entry.dart';

class Voucher {
  String id;
  DateTime date;
  String summary;
  List<Entry> entries;
  String? attachedKnowledge;

  Voucher({
    required this.id,
    required this.date,
    required this.summary,
    required this.entries,
    this.attachedKnowledge,
  });

  int get totalDebitCents =>
      entries.where((e) => e.isDebit).fold(0, (sum, e) => sum + e.amountCents);

  int get totalCreditCents =>
      entries.where((e) => !e.isDebit).fold(0, (sum, e) => sum + e.amountCents);

  double get totalDebit => totalDebitCents / 100.0;

  double get totalCredit => totalCreditCents / 100.0;

  /// Exact balance check in cents (no float epsilon).
  bool get isBalanced => totalDebitCents == totalCreditCents;

  int get year => date.year;
  int get month => date.month;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'summary': summary,
        'entries': entries.map((e) => e.toJson()).toList(),
        'attachedKnowledge': attachedKnowledge,
      };

  factory Voucher.fromJson(Map<String, dynamic> json) => Voucher(
        id: json['id'],
        date: DateTime.parse(json['date']),
        summary: json['summary'],
        entries: (json['entries'] as List)
            .map((e) => Entry.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        attachedKnowledge: json['attachedKnowledge'],
      );
}
