# 翻译指南（GitHub Pull Request）

LedgerLearn 的多语言内容由**社区通过 GitHub Pull Request 贡献**，不使用第三方翻译平台。

## 翻译范围

| 层级 | 路径 | 说明 |
|---|---|---|
| 应用 UI | `i18n/<locale>.json` | 界面文案（键值对） |
| 知识卡片 | `knowledge_card/<locale>.json` | 教学内容 Markdown |
| 商店文案 | `fastlane/metadata/android/<locale>/` | F-Droid / 应用商店 |
| 项目文档 | `doc/<locale>/README.md` 等 | 阅读文档 |

源语言为 **简体中文**（`zh-CN`），键名以 `i18n/zh-CN.json` 为准。

## 贡献步骤

1. **Fork** [Maicarons/ledgerlearn](https://github.com/Maicarons/ledgerlearn)，创建分支，例如 `l10n/ja-JP`
2. **编辑**目标语言文件，键名必须与 `zh-CN` 完全一致，只改值：
   ```bash
   $EDITOR i18n/ja-JP.json
   $EDITOR knowledge_card/ja-JP.json   # 可选
   ```
3. **生成 Dart 语言包**并自检：
   ```bash
   dart run scripts/gen_i18n.dart
   flutter analyze
   flutter test test/i18n_parity_test.dart
   ```
4. **提交 PR**，标题建议：`l10n(ja-JP): improve UI strings`
   - 只包含翻译相关改动
   - 说明译文来源或存疑处
5. 维护者审阅合并后，文案随下次构建生效

## 新增一门语言

1. 复制 `i18n/zh-CN.json` 为 `i18n/xx-XX.json`，翻译所有值
2. 如需知识卡片：复制 `knowledge_card/zh-CN.json` 为 `knowledge_card/xx-XX.json`
3. 在 `scripts/gen_i18n.dart` 中注册（三处 map）：
   - `localeFileMap`：`'xx-XX': 'xx_xx.dart'`
   - `localeVarMap`：`'xx-XX': 'xxXX'`
   - `dartLocaleKey`：`'xx-XX': 'xx_XX'`
4. 在设置页语言列表增加选项（`settings_view.dart` + 六语 `settings_language_xx` 键）
5. 运行 `dart run scripts/gen_i18n.dart`，保证 `flutter test` 通过

## 文案规范

- 保持键名不变，只翻译值
- 占位符 `@count`、`@amount`、`@profit` 等必须原样保留
- 会计术语尽量贴近当地教材/准则习惯；拿不准可保留英文并加 PR 评论
- 不要提交空字符串；缺译时可暂用英文

## 本地校验清单

```bash
dart run scripts/gen_i18n.dart
flutter test          # 含 i18n 键对齐测试
flutter analyze
```

## 提交范围

- ✅ 提交：`i18n/*.json`、`knowledge_card/*.json`、`lib/app/i18n/locales/*.dart`、`doc/**`、`fastlane/metadata/**`
- ✅ 新语言：`scripts/gen_i18n.dart` 映射表
- ❌ 不提交：无关代码、构建产物、密钥

## 问题反馈

翻译疑问请开 [Issue](https://github.com/Maicarons/ledgerlearn/issues) 或在 PR 中讨论。
