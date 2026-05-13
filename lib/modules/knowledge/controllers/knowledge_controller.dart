import 'package:get/get.dart';
import '../../../data/models/knowledge_card.dart';
import '../../../data/repositories/knowledge_repository.dart';

class KnowledgeController extends GetxController {
  final KnowledgeRepository repo = Get.find<KnowledgeRepository>();
  final cards = <KnowledgeCard>[].obs;
  final selectedCategory = 'all'.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCards();
  }

  void loadCards() {
    cards.value = repo.getAll();
  }

  List<KnowledgeCard> get filteredCards {
    var list = cards.toList();

    if (selectedCategory.value != 'all') {
      list = list.where((k) => k.category == selectedCategory.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((k) {
        return k.title.toLowerCase().contains(q) ||
            k.content.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }
}
