import 'package:get/get.dart';
import '../../data/services/database_service.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/voucher_repository.dart';
import '../../data/repositories/knowledge_repository.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Reuse the already-initialized DatabaseService from main()
    final db = Get.find<DatabaseService>();

    final accountRepo = AccountRepository(db);
    Get.put(accountRepo, permanent: true);

    final knowledgeRepo = KnowledgeRepository(db);
    Get.put(knowledgeRepo, permanent: true);

    final voucherRepo = VoucherRepository(db);
    Get.put(voucherRepo, permanent: true);
  }
}
