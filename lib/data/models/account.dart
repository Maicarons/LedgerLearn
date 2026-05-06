class Account {
  String id;
  String nameZh;
  String nameEn;
  String nameKo;
  String category; // 'asset','liability','equity','cost','pl'
  String? subCategory;
  int type; // 1=asset,2=liability,3=equity,4=cost,5=income,6=expense
  double openingBalance;
  bool isSystem;
  String? explanationZh;
  String? explanationEn;
  String? explanationKo;

  Account({
    required this.id,
    required this.nameZh,
    required this.nameEn,
    required this.nameKo,
    required this.category,
    this.subCategory,
    required this.type,
    this.openingBalance = 0,
    this.isSystem = false,
    this.explanationZh,
    this.explanationEn,
    this.explanationKo,
  });

  String getName(String locale) {
    switch (locale) {
      case 'zh_CN':
        return nameZh;
      case 'en_US':
        return nameEn;
      case 'ko_KR':
        return nameKo;
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
        'openingBalance': openingBalance,
        'isSystem': isSystem,
        'explanationZh': explanationZh,
        'explanationEn': explanationEn,
        'explanationKo': explanationKo,
      };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'],
        nameZh: json['nameZh'],
        nameEn: json['nameEn'],
        nameKo: json['nameKo'],
        category: json['category'],
        subCategory: json['subCategory'],
        type: json['type'],
        openingBalance: (json['openingBalance'] ?? 0).toDouble(),
        isSystem: json['isSystem'] ?? false,
        explanationZh: json['explanationZh'],
        explanationEn: json['explanationEn'],
        explanationKo: json['explanationKo'],
      );
}
