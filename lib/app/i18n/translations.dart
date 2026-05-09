import 'package:get/get.dart';
import 'locales/en_US.dart';
import 'locales/ko_KR.dart';
import 'locales/zh_CN.dart';

class LedgerLearnTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'ko_KR': koKR,
        'zh_CN': zhCN,
      };
}
