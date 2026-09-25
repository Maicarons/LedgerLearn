# Translation Guide (GitHub Pull Request)

LedgerLearn translations are contributed by the community via **GitHub Pull Request**. We do not use a third-party translation platform.

## Scope

| Layer | Path | Notes |
|---|---|---|
| App UI | `i18n/<locale>.json` | Interface strings (key/value) |
| Knowledge cards | `knowledge_card/<locale>.json` | Markdown lessons |
| Store listing | `fastlane/metadata/android/<locale>/` | F-Droid / stores |
| Docs | `doc/<locale>/README.md`, etc. | Reading material |

Source language is **Simplified Chinese** (`zh-CN`). Key names follow `i18n/zh-CN.json`.

## How to contribute

1. **Fork** [Maicarons/ledgerlearn](https://github.com/Maicarons/ledgerlearn) and create a branch, e.g. `l10n/ja-JP`
2. **Edit** the target locale files. Keep keys identical to `zh-CN`; change values only:
   ```bash
   $EDITOR i18n/ja-JP.json
   $EDITOR knowledge_card/ja-JP.json   # optional
   ```
3. **Generate** Dart locales and verify:
   ```bash
   dart run scripts/gen_i18n.dart
   flutter analyze
   flutter test test/i18n_parity_test.dart
   ```
4. **Open a PR** with a title like `l10n(ja-JP): improve UI strings`
   - Translation-only changes
   - Note uncertain terms in the PR description
5. After review and merge, strings ship with the next build

## Adding a new language

1. Copy `i18n/zh-CN.json` → `i18n/xx-XX.json` and translate values
2. Optionally copy `knowledge_card/zh-CN.json` → `knowledge_card/xx-XX.json`
3. Register the locale in `scripts/gen_i18n.dart` (three maps):
   - `localeFileMap`: `'xx-XX': 'xx_xx.dart'`
   - `localeVarMap`: `'xx-XX': 'xxXX'`
   - `dartLocaleKey`: `'xx-XX': 'xx_XX'`
4. Add a language option in `settings_view.dart` plus `settings_language_xx` keys in all locales
5. Run `dart run scripts/gen_i18n.dart` and keep `flutter test` green

## Style

- Never change key names
- Keep placeholders such as `@count`, `@amount`, `@profit` intact
- Prefer terminology used by local accounting textbooks; ask in the PR if unsure
- Do not commit empty strings; fall back to English if needed

## Checklist

```bash
dart run scripts/gen_i18n.dart
flutter test
flutter analyze
```

## Scope of commits

- ✅ `i18n/*.json`, `knowledge_card/*.json`, `lib/app/i18n/locales/*.dart`, `doc/**`, `fastlane/metadata/**`
- ✅ New language: maps in `scripts/gen_i18n.dart`
- ❌ Unrelated code, build outputs, secrets

## Questions

Open an [Issue](https://github.com/Maicarons/ledgerlearn/issues) or discuss in the PR.
