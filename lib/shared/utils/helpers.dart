String getLocalizedAccountName(Map<String, dynamic> account, String locale) {
  switch (locale) {
    case 'zh_CN':
      return account['nameZh'] ?? '';
    case 'en_US':
      return account['nameEn'] ?? '';
    case 'ko_KR':
      return account['nameKo'] ?? '';
    default:
      return account['nameZh'] ?? '';
  }
}

String formatCurrency(double amount, String locale) {
  final absAmount = amount.abs();
  String formatted;
  if (locale == 'zh_CN') {
    formatted = absAmount.toStringAsFixed(2);
  } else {
    formatted = absAmount.toStringAsFixed(2);
  }

  final parts = formatted.split('.');
  final intPart = parts[0];
  final decPart = parts.length > 1 ? '.${parts[1]}' : '.00';

  final buffer = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(intPart[i]);
  }

  return '${amount < 0 ? '-' : ''}$buffer$decPart';
}

/// Determine if an account type normally carries a debit balance
bool isNormallyDebit(int type) => type == 1 || type == 4 || type == 6;

/// Calculate ending balance for an account given opening and period activity
double calculateEndingBalance({
  required double opening,
  required double totalDebit,
  required double totalCredit,
  required bool normallyDebit,
}) {
  if (normallyDebit) {
    return opening + totalDebit - totalCredit;
  } else {
    return opening + totalCredit - totalDebit;
  }
}
