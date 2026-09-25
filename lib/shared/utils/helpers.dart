String getLocalizedAccountName(Map<String, dynamic> account, String locale) {
  switch (locale) {
    case 'zh_CN':
      return account['nameZh'] ?? '';
    case 'en_US':
      return account['nameEn'] ?? '';
    case 'ko_KR':
      return account['nameKo'] ?? '';
    case 'ja_JP':
    case 'vi_VN':
    case 'th_TH':
      // Account master data is trilingual; fall back to English for other UIs.
      return account['nameEn'] ?? account['nameZh'] ?? '';
    default:
      return account['nameZh'] ?? '';
  }
}

/// Convert yuan (double) to integer cents.
int yuanToCents(num yuan) => (yuan * 100).round();

/// Convert integer cents to yuan.
double centsToYuan(int cents) => cents / 100.0;

String formatCurrency(double amount, String locale) {
  // Compute from cents so display never shows float noise (e.g. 0.30000000004).
  final cents = yuanToCents(amount);
  final negative = cents < 0;
  final absCents = cents.abs();
  final intPart = (absCents ~/ 100).toString();
  final decPart = (absCents % 100).toString().padLeft(2, '0');

  final buffer = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(intPart[i]);
  }

  return '${negative ? '-' : ''}$buffer.$decPart';
}

/// Format integer cents directly (preferred for calculations).
String formatCents(int cents, String locale) =>
    formatCurrency(centsToYuan(cents), locale);

/// Determine if an account type normally carries a debit balance
bool isNormallyDebit(int type) => type == 1 || type == 4 || type == 6;

/// Calculate ending balance for an account given opening and period activity.
/// All values are in yuan (display units). Internally rounded to cents.
double calculateEndingBalance({
  required double opening,
  required double totalDebit,
  required double totalCredit,
  required bool normallyDebit,
}) {
  final o = yuanToCents(opening);
  final d = yuanToCents(totalDebit);
  final c = yuanToCents(totalCredit);
  final ending = normallyDebit ? o + d - c : o + c - d;
  return centsToYuan(ending);
}

/// Exact ending balance in cents.
int calculateEndingBalanceCents({
  required int openingCents,
  required int totalDebitCents,
  required int totalCreditCents,
  required bool normallyDebit,
}) {
  if (normallyDebit) {
    return openingCents + totalDebitCents - totalCreditCents;
  }
  return openingCents + totalCreditCents - totalDebitCents;
}
