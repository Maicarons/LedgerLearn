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

  double get totalDebit => entries
      .where((e) => e.isDebit)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalCredit => entries
      .where((e) => !e.isDebit)
      .fold(0.0, (sum, e) => sum + e.amount);

  bool get isBalanced =>
      (totalDebit - totalCredit).abs() < 0.001;

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
            .map((e) => Entry.fromJson(e))
            .toList(),
        attachedKnowledge: json['attachedKnowledge'],
      );
}
