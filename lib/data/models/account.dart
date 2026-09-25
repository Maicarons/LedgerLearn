class Account {
  String id;
  String nameZh;
  String nameEn;
  String nameKo;
  String category; // 'asset','liability','equity','cost','pl'
  String? subCategory;
  int type; // 1=asset,2=liability,3=equity,4=cost,5=income,6=expense
  int openingBalanceCents;
  bool isSystem;
  String? explanationZh;
  String? explanationEn;
  String? explanationKo;

  double get openingBalance => openingBalanceCents / 100.0;

  Account({
    required this.id,
    required this.nameZh,
    required this.nameEn,
    required this.nameKo,
    required this.category,
    this.subCategory,
    required this.type,
    double? openingBalance,
    int? openingBalanceCents,
    this.isSystem = false,
    this.explanationZh,
    this.explanationEn,
    this.explanationKo,
  }) : openingBalanceCents =
            openingBalanceCents ?? ((openingBalance ?? 0) * 100).round();

  String getName(String locale) {
    switch (locale) {
      case 'zh_CN':
        return nameZh;
      case 'en_US':
        return nameEn;
      case 'ko_KR':
        return nameKo;
      case 'ja_JP':
      case 'vi_VN':
      case 'th_TH':
        return nameEn;
      default:
        return nameZh;
    }
  }

  String getExplanation(String locale) {
    switch (locale) {
      case 'zh_CN':
        return explanationZh ?? '';
      case 'en_US':
        return explanationEn ?? '';
      case 'ko_KR':
        return explanationKo ?? '';
      case 'ja_JP':
      case 'vi_VN':
      case 'th_TH':
        return explanationEn ?? '';
      default:
        return explanationZh ?? '';
    }
  }

  String get typeNameKey {
    switch (type) {
      case 1:
        return 'account_type_asset';
      case 2:
        return 'account_type_liability';
      case 3:
        return 'account_type_equity';
      case 4:
        return 'account_type_cost';
      case 5:
        return 'account_type_income';
      case 6:
        return 'account_type_expense';
      default:
        return 'account_type_asset';
    }
  }

  String get categoryKey {
    switch (category) {
      case 'asset':
        return 'category_asset';
      case 'liability':
        return 'category_liability';
      case 'equity':
        return 'category_equity';
      case 'cost':
        return 'category_cost';
      case 'pl':
        return 'category_pl';
      default:
        return 'category_asset';
    }
  }

  /// Whether this account normally has a debit balance
  bool get normallyDebit => type == 1 || type == 4 || type == 6;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameZh': nameZh,
        'nameEn': nameEn,
        'nameKo': nameKo,
        'category': category,
        'subCategory': subCategory,
        'type': type,
        'openingBalanceCents': openingBalanceCents,
        'openingBalance': openingBalance,
        'isSystem': isSystem,
        'explanationZh': explanationZh,
        'explanationEn': explanationEn,
        'explanationKo': explanationKo,
      };

  factory Account.fromJson(Map<String, dynamic> json) {
    final cents = json['openingBalanceCents'];
    int openingCents;
    if (cents is int) {
      openingCents = cents;
    } else {
      final legacy = (json['openingBalance'] ?? 0).toDouble();
      openingCents = (legacy * 100).round();
    }
    return Account(
      id: json['id'],
      nameZh: json['nameZh'],
      nameEn: json['nameEn'],
      nameKo: json['nameKo'],
      category: json['category'],
      subCategory: json['subCategory'],
      type: json['type'],
      openingBalanceCents: openingCents,
      isSystem: json['isSystem'] ?? false,
      explanationZh: json['explanationZh'],
      explanationEn: json['explanationEn'],
      explanationKo: json['explanationKo'],
    );
  }
}
