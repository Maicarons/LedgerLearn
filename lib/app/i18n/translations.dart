import 'package:get/get.dart';
import 'locales/zh_CN.dart';
import 'locales/en_US.dart';
import 'locales/ko_KR.dart';

class LedgerLearnTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'zh_CN': zhCN,
        'en_US': enUS,
        'ko_KR': koKR,
      };
}
