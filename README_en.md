# LedgerLearn — Accounting Learning Simulation

<p align="center">
  <img src="logo.png" alt="LedgerLearn Logo" width="128" height="128">
</p>

<p align="center">
  <b>English</b> · <a href="README.md">中文</a> · <a href="README_ko.md">한국어</a>
</p>

<p align="center">
  <a href="https://github.com/Maicarons/ledgerlearn/releases"><img src="https://img.shields.io/github/v/release/Maicarons/ledgerlearn?color=blue&label=Release" alt="GitHub Release"></a>
  <a href="https://github.com/Maicarons/ledgerlearn/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-GPLv3-blue.svg" alt="License: GPL v3"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://maicarons.github.io/LedgerLearn/"><img src="https://img.shields.io/badge/Web-Demo-4285F4?logo=googlechrome&logoColor=white" alt="Web Demo"></a>
</p>

A multilingual **accounting learning simulator** for beginners (China ASBE). Learn double-entry bookkeeping by doing: vouchers, ledgers, trial balance, and financial statements — with practice drills and knowledge cards along the way.

> ⚠️ **Regional scope**: Chart of accounts and content follow **China's Accounting Standards for Business Enterprises (ASBE)**. Other jurisdictions may differ.

## Downloads

| Platform | Source |
|---|---|
| Android | [GitHub Releases](https://github.com/Maicarons/ledgerlearn/releases) · F-Droid (in review) |
| Web | [Live demo](https://maicarons.github.io/LedgerLearn/) |
| Desktop / iOS | Build from source (see below) |

## Features

| Module | Description |
|---|---|
| **Dashboard** | Period overview: voucher count, debit/credit totals, balance status, 6-period trend chart |
| **Vouchers** | Create/edit/delete, dynamic entries, balance check, 8 business templates, search |
| **Accounts** | 62 ASBE accounts (assets / liabilities / equity / cost / P&L), custom accounts |
| **Ledgers** | General ledger and subsidiary (detail) ledger |
| **Reports** | Trial balance, income statement, balance sheet, expense/asset charts, period-end closing wizard |
| **Practice** | 10 scenario drills with auto-grading and a wrong-answer book |
| **Knowledge** | 70+ multilingual cards (practice / law / tax), Markdown, optional remote updates |
| **Export** | CSV / PDF for vouchers, ledgers, and reports |
| **Settings** | zh / en / ko / ja / vi / th UI, light/dark/system themes, data reset |

## Tech stack

Flutter 3.x · GetX (state / routing / i18n) · GetStorage · fl_chart · pdf · intl

## Quick start

```bash
git clone https://github.com/Maicarons/ledgerlearn.git
cd ledgerlearn
flutter pub get
flutter analyze
flutter test
flutter run -d chrome      # or windows / android
```

## Translations

Community translations via **GitHub Pull Request** (no third-party platform).

1. Fork → edit `i18n/<locale>.json` (keys must match `zh-CN`)
2. `dart run scripts/gen_i18n.dart`
3. Open a PR titled `l10n(<locale>): …`

See [doc/translation-guide.md](doc/translation-guide.md).

## Project layout

```
lib/
├── app/           # routes, theme, i18n, preset accounts
├── data/          # models, repositories, services
├── modules/       # home, voucher, accounts, ledger, reports, practice, knowledge, settings, about
└── shared/        # widgets, money helpers
i18n/              # UI strings (JSON)
knowledge_card/    # lesson cards (JSON)
```

## License

[GNU GPL v3.0](LICENSE) · Copyright (C) 2026 Maicarons
