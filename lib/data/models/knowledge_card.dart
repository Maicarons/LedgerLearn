class KnowledgeCard {
  String id;
  String title;
  String content;
  String category;
  String? relatedAccountId;
  String? relatedSubject;

  KnowledgeCard({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.relatedAccountId,
    this.relatedSubject,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'category': category,
        'relatedAccountId': relatedAccountId,
        'relatedSubject': relatedSubject,
      };

  factory KnowledgeCard.fromJson(Map<String, dynamic> json) => KnowledgeCard(
        id: json['id'],
        title: json['title'] ?? json['titleZh'] ?? '',
        content: json['content'] ?? json['contentZh'] ?? '',
        category: json['category'] ?? '',
        relatedAccountId: json['relatedAccountId'],
        relatedSubject: json['relatedSubject'] ?? json['relatedSubjectZh'],
      );
}
