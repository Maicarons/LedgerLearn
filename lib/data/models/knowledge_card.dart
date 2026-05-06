class KnowledgeCard {
  String id;
  String titleZh;
  String titleEn;
  String titleKo;
  String contentZh;
  String contentEn;
  String contentKo;
  String category; // 'accounting_practice' or 'economic_law'
  String? relatedAccountId;
  String? relatedSubjectZh;
  String? relatedSubjectEn;
  String? relatedSubjectKo;

  KnowledgeCard({
    required this.id,
    required this.titleZh,
    required this.titleEn,
    required this.titleKo,
    required this.contentZh,
    required this.contentEn,
    required this.contentKo,
    required this.category,
    this.relatedAccountId,
    this.relatedSubjectZh,
    this.relatedSubjectEn,
    this.relatedSubjectKo,
  });

  String getTitle(String locale) {
    switch (locale) {
      case 'zh_CN':
        return titleZh;
      case 'en_US':
        return titleEn;
      case 'ko_KR':
        return titleKo;
      default:
        return titleZh;
    }
  }

  String getContent(String locale) {
    switch (locale) {
      case 'zh_CN':
        return contentZh;
      case 'en_US':
        return contentEn;
      case 'ko_KR':
        return contentKo;
      default:
        return contentZh;
    }
  }

  String getRelatedSubject(String locale) {
    switch (locale) {
      case 'zh_CN':
        return relatedSubjectZh ?? '';
      case 'en_US':
        return relatedSubjectEn ?? '';
      case 'ko_KR':
        return relatedSubjectKo ?? '';
      default:
        return relatedSubjectZh ?? '';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleZh': titleZh,
        'titleEn': titleEn,
        'titleKo': titleKo,
        'contentZh': contentZh,
        'contentEn': contentEn,
        'contentKo': contentKo,
        'category': category,
        'relatedAccountId': relatedAccountId,
        'relatedSubjectZh': relatedSubjectZh,
        'relatedSubjectEn': relatedSubjectEn,
        'relatedSubjectKo': relatedSubjectKo,
      };

  factory KnowledgeCard.fromJson(Map<String, dynamic> json) => KnowledgeCard(
        id: json['id'],
        titleZh: json['titleZh'],
        titleEn: json['titleEn'],
        titleKo: json['titleKo'],
        contentZh: json['contentZh'],
        contentEn: json['contentEn'],
        contentKo: json['contentKo'],
        category: json['category'],
        relatedAccountId: json['relatedAccountId'],
        relatedSubjectZh: json['relatedSubjectZh'],
        relatedSubjectEn: json['relatedSubjectEn'],
        relatedSubjectKo: json['relatedSubjectKo'],
      );
}
