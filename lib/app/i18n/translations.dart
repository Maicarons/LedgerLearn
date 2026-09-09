import 'package:get/get.dart';
import 'locales/en_us.dart';
import 'locales/ja_jp.dart';
import 'locales/ko_kr.dart';
import 'locales/th_th.dart';
import 'locales/vi_vn.dart';
import 'locales/zh_cn.dart';

class LedgerLearnTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'ja_JP': jaJP,
        'ko_KR': koKR,
        'th_TH': thTH,
        'vi_VN': viVN,
        'zh_CN': zhCN,
      };

  /// Look up a translation for a specific locale without changing the
  /// current app locale. Falls back to zh_CN, then the key itself.
  static String tr(String key, String locale) {
    final maps = LedgerLearnTranslations().keys;
    final map = maps[locale] ?? maps['zh_CN'];
    return map?[key] ?? key;
  }
}
