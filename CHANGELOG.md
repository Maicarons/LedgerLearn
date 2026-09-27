# Changelog

All notable changes to LedgerLearn will be documented in this file.

## [0.8.2] - 2026-09-27

### Fixed
- **Web build broken by SQLite imports**: split `LocalStore` into platform implementations via conditional imports
  - IO (mobile/desktop): SQLite `SqliteLocalStore`
  - Web: GetStorage-backed `WebLocalStore` (no `dart:io` / `sqflite` in the browser tree)
- `.gitignore` rewritten as UTF-8 (Flutter tooling crash on garbled encoding)

## [0.8.1] - 2026-09-26

### Changed
- **Storage migrated from GetStorage to SQLite** (`sqflite` + `sqflite_common_ffi` on desktop)
  - Schema: `kv` (settings/streak/SRS) + `documents` (accounts, vouchers, knowledge)
  - In-memory cache keeps synchronous repository APIs
  - Legacy GetStorage data is migrated automatically on first launch
  - Web keeps GetStorage as a fallback (SQLite unavailable in browsers without wasm setup)
- Practice attempts, learning streak and SRS schedule now persist in SQLite

### Added
- `LocalStore` SQLite wrapper with transactional bulk replace
- SQLite unit tests (kv + documents CRUD)

## [0.8.0] - 2026-09-26

### Added
- **Global search**: search vouchers (id/summary/account), accounts (code/names) and knowledge cards from Home; results deep-link into detail pages
- **CSV voucher import**: paste CSV in Settings → Data; supports simple `date,summary,debit_account,credit_account,amount` form and multi-line `voucher_id,date,summary,account_id,direction,amount` form with per-row validation
- **BookQueryService**: structured query helpers (keyword voucher search, account balances, vouchers-by-account, monthly counts) isolating read paths from storage
- i18n: 19 new UI keys in all 6 app locales (619 keys each)

### Notes
- Storage remains GetStorage JSON; query/search layers are backend-agnostic so a future SQLite swap only touches the repository implementation.

## [0.7.0] - 2026-09-26

### Added
- **Spaced-repetition review**: SM-2-lite scheduling (ease / interval / due date) for knowledge cards
- **Review session UI**: quiz + Again / Hard / Good / Easy grading, summary and restart
- **Knowledge quiz bank expanded to 16 questions** covering accounting equation, depreciation, AR, contra-accounts, payroll, VAT, CIT, closing entries
- **Home review entry**: "Start review" shortcut with due-card count badge
- Knowledge page app-bar shortcut to review
- i18n: 63 new UI keys in all 6 app locales (600 keys each)

### Changed
- Review and practice streak both feed the daily learning streak

## [0.6.0] - 2026-09-26

### Added
- **Year-end closing workbench**: guided annual close — revenue → expenses → transfer profit → 10% statutory surplus reserve, with per-step voucher save
- **Comparative statements**: income statement and balance sheet now show prior-period column with deltas
- **Financial ratios report**: current / quick ratio, debt ratio, gross & net margin, inventory turnover with teaching hints
- **Voucher efficiency**: 8 new templates (bad debt, write-off, prepay/advance, loan, interest, fixed asset, close expense) → 16 total; **copy voucher** and **red-letter reverse**
- **Knowledge quick check**: one-question quiz after reading key knowledge cards (6 built-in)
- **Learning streak**: daily activity streak badge on Home; quiz + practice pass count toward the day
- i18n: 92 new UI keys in all 6 app locales (537 keys each)

### Changed
- Reports hub lists cash flow, ratios, monthly close and year-end close
- `IncomeItem` carries `prevAmount` for comparative display

## [0.5.0] - 2026-09-26

### Added
- **Learning path**: 6 themed chapters (cash → purchases/sales → expenses → tax/financing → long-term assets → cost/closing) with progressive unlock
- **Mastery stars**: 0–3 stars per drill derived from attempts (first-try = ★★★)
- **Quiz mode**: random 5-question session weighted toward weak drills; finish summary with retry
- **Wrong-answer retry**: one-tap quiz over recent failed scenarios
- **Practice achievements**: first pass, 10 passed, all 22 passed, quiz-ready (now 9 badges total)
- **Home "Today's learning" card**: next recommended drill + continue / quiz shortcuts
- Bottom navigation now includes **Practice** (accounts remain on Home quick actions)
- i18n: 35 new UI keys in all 6 app locales (445 keys each)

### Changed
- Practice list is grouped by chapter with lock states and knowledge-card shortcuts
- `PracticeScenario` carries `chapterId`; pure helpers `chapterIdOf` / `isChapterUnlockedPure` / `scoreStars` for testability

## [0.4.0] - 2026-09-26

### Added
- **Book backup & restore**: export the full ledger (accounts, vouchers, learning progress, practice attempts, settings) as JSON; restore by pasting the backup content (Settings → Data)
- **Cash flow statement**: simplified direct-method report (operating / investing / financing) with line-item breakdown and cash reconciliation check
- **Practice drills expanded to 22 scenarios**: bad-debt provision & write-off, prepayments & advances, short-term loan & interest accrual, VAT payment, material sales, fixed/intangible asset purchases, expense closing, notes receivable
- **Wrong-answer book attribution**: shows which account codes were missing or unexpected in a failed attempt
- i18n: 78 new UI keys in all 6 app locales (410 keys each)

### Changed
- `PracticeGrader.grade` now returns structured results (problems + missing/unexpected account ids); `gradeProblems` kept as a thin wrapper
- `PracticeAttempt` JSON carries `missingAccountIds` / `unexpectedAccountIds` for review

## [0.3.2] - 2026-09-27

### Fixed
- F-Droid metadata Categories set to Science and Education (valid category)
- Pin Flutter 3.41.9 in CI workflows so fdroiddata can extract it

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
