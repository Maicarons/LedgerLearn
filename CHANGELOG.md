# Changelog

All notable changes to LedgerLearn will be documented in this file.

## [0.3.1] - 2026-09-25

### Fixed
- Fastlane `en-US` short description shortened to under 80 characters (F-Droid bot)
- Gradle wrapper uses official `services.gradle.org` distribution URL
- Gradle wrapper `distributionSha256Sum` pinned (fixes `insecure-gradlew` / non-standard source)
- Application ID set to `cn.yosvu.ledgerlearn`

### Changed
- Store icons regenerated from project `logo.png` (512×512 F-Droid icon)
- Phone screenshots for store listing

## [0.3.0] - 2026-09-20

### Added
- Practice module: 10 business-scenario drills with auto-grading (account + direction + balance + amount)
- Wrong-answer book with explanations and one-tap clear
- Period-end closing wizard: guided 3-step close (revenue → expense → net profit)
- Home dashboard: 6-period debit/credit trend chart (fl_chart)
- Reports: expense mix and asset structure pie charts
- Chart of accounts: +3 ASBE accounts (Contract Assets 1331, Financial Liabilities Held for Trading 2101, Contract Liabilities 2314) → 62 total
- i18n: 76 new UI keys in all 6 app locales (298 keys each)
- CI: GitHub Pages web deploy workflow
- Tests: 40+ unit tests covering money cents, models, i18n parity, practice grading

### Changed
- Money is stored as integer cents (`Entry.amountCents`, `Account.openingBalanceCents`) with legacy JSON migration
- Voucher balance checks are exact (cents), no float epsilon
- `window_manager` is desktop-only (guarded) — safer on mobile/web
- Remote knowledge base prefers versioned jsDelivr tags over `@master`
- CLAUDE.md rewritten to match the real architecture

### Removed
- Unused dependencies: hive, hive_flutter, hive_generator, flutter_slidable, build_runner

## [0.2.0] - 2026-09-09

### Added
- Voucher templates: 4 new common business templates (pay wages, record depreciation, pay taxes, transfer COGS) — 8 in total
- Voucher list: search by summary or account (name/code)
- Voucher detail: related knowledge cards recommended from the accounts used in the voucher
- Learning progress: track vouchers created and knowledge cards read, with 5 unlockable achievement badges shown on the Settings page

## [0.1.2] - 2026-09-09

### Fixed
- Home page: "Quick Actions" section title was hardcoded Chinese; now translated
- Trial balance / income statement / balance sheet: account names now display in the current language instead of always Chinese
- Balance sheet: amounts were always formatted with the zh_CN locale; now follow the selected language
- Report views: hardcoded "Export CSV" tooltips and export result dialogs are now translated
- CSV export: all headers, section labels, and file names were hardcoded Chinese; now localized per language
- Ledger and voucher list: year/month filter labels were hardcoded; now translated
- Voucher form: "select an account" validation message and template summaries now use translation keys
- Settings: theme mode labels, learning progress count, and language list entries now translated
- Settings: app version was hardcoded as 1.0.0; now reads the real version (0.1.2)

## [0.1.1] - 2026-05-19

### Added
- Windows: portrait aspect ratio lock (9:16) via window_manager
- App icon for all platforms (Android, iOS, Windows, macOS, Linux, Web)
- CI: multi-platform analyze, test, and build verification (ubuntu/windows/macos)
- Release: multi-platform artifact builds (APK, AAB, Linux, Web, Windows, macOS, iOS)
- README: project logo and platform/community badges

### Changed
- Home page: centered title, gradient wave AppBar background, refined card styling

### Security
- Updated dependencies

## [0.1.0] - 2026-05-13

### Added
- Initial release of LedgerLearn
- Voucher management with debit/credit validation
- 59 preset standard accounts per China's ASBE classification
- General ledger and subsidiary ledger views
- Trial balance, income statement, and balance sheet
- 74 trilingual knowledge cards with Markdown rendering
- CSV/PDF export for all report types
- Chinese, English, Korean language support
- Light/dark/system theme modes
- Offline-first with local storage
