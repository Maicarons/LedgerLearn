# LedgerLearn — 记账学习模拟应用

<p align="center">
  <img src="logo.png" alt="LedgerLearn Logo" width="128" height="128">
</p>

<p align="center">
  <b>中文</b> · <a href="README_en.md">English</a> · <a href="README_ko.md">한국어</a>
</p>

<p align="center">
  <a href="https://github.com/Maicarons/ledgerlearn/releases"><img src="https://img.shields.io/github/v/release/Maicarons/ledgerlearn?color=blue&label=Release" alt="GitHub Release"></a>
  <a href="https://github.com/Maicarons/ledgerlearn/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-GPLv3-blue.svg" alt="License: GPL v3"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart"></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android-34A853?logo=android&logoColor=white" alt="Android">
  <img src="https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows&logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/Platform-macOS-000000?logo=apple&logoColor=white" alt="macOS">
  <img src="https://img.shields.io/badge/Platform-iOS-999999?logo=apple&logoColor=white" alt="iOS">
  <img src="https://img.shields.io/badge/Platform-Linux-FCC624?logo=linux&logoColor=black" alt="Linux">
  <img src="https://img.shields.io/badge/Platform-Web-4285F4?logo=googlechrome&logoColor=white" alt="Web">
</p>

<p align="center">
  <a href="https://github.com/Maicarons/ledgerlearn/stargazers"><img src="https://img.shields.io/github/stars/Maicarons/ledgerlearn?style=social" alt="GitHub Stars"></a>
  <a href="https://f-droid.org"><img src="https://img.shields.io/badge/Available%20on-F--Droid-1976D2?logo=f-droid&logoColor=white" alt="F-Droid"></a>
  <a href="https://github.com/Maicarons/ledgerlearn/pulls"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome"></a>
</p>

一款面向**中国内地会计初学者**的多语言会计入门学习应用，支持多语言。通过模拟完整的会计记账流程——凭证录入、总账/明细账查询、试算平衡、财务报表生成，并在操作中嵌入会计实务与经济法知识点，实现「做中学」。

> ⚠️ **适用地区说明**：本程序的科目体系、会计准则和知识内容均基于中国企业会计准则（ASBE）和中国大陆会计从业要求，主要面向中国内地的会计学习者。其他国家/地区的会计准则可能存在差异，请谨慎参考。

## 下载

| 平台 | 来源 |
|---|---|
| Android | [F-Droid](https://f-droid.org)（审核中） / [GitHub Releases](https://github.com/Maicarons/ledgerlearn/releases) |
| 其他平台 | 参见[构建说明](#构建)自行编译 |

## 功能概览

| 模块 | 功能描述 |
|---|---|
| **首页仪表盘** | 当前账期概览：凭证数量、借贷方合计、试算平衡状态；快捷入口 |
| **凭证管理** | 新建/编辑/删除记账凭证，动态分录行，借贷平衡校验，4 种业务模板 |
| **会计科目** | 62 个预置标准科目（资产/负债/权益/成本/损益），支持自定义科目 |
| **总账/明细账** | 按科目汇总的总账，按凭证逐笔展示的明细账 |
| **财务报表** | 试算平衡表、利润表、资产负债表，附教学解读 |
| **知识库** | 74 条多语言知识卡片（会计实务 + 经济法 + 税务），支持 Markdown 渲染，支持联网更新 |
| **分录练习** | 10 个业务场景闯关，自动判分 + 错题本 |
| **期末结转** | 三步向导：结转收入 → 费用 → 本年利润 |
| **图表** | 首页近 6 期借贷趋势、费用构成 / 资产结构饼图 |
| **导出** | 凭证列表、总账/明细账、试算平衡表、利润表、资产负债表导出为 CSV/PDF |
| **设置** | 中/英/韩语言实时切换，浅色/深色/跟随系统主题，数据重置 |

## 技术栈

- **框架**：Flutter 3.x（Dart 3）
- **状态管理 / 路由 / 依赖注入 / 国际化**：GetX
- **本地存储**：GetStorage
- **HTTP 客户端**：GetConnect（GetX 内置）
- **Markdown 渲染**：flutter_markdown
- **PDF 导出**：pdf
- **图表**：fl_chart
- **列表滑动手势**：flutter_slidable
- **日期/数字格式化**：intl
- **文件路径**：path_provider
- **静态分析**：flutter_lints

## 项目结构

```
├── i18n/                               # 📦 社区翻译源文件（JSON，PR 贡献）
│   ├── zh_CN.json                      # 源语言：简体中文
│   ├── en_US.json                      # 英文翻译
│   └── ko_KR.json                      # 韩文翻译
├── scripts/
│   └── gen_i18n.dart                   # JSON → Dart 翻译代码生成器
├── fastlane/metadata/android/
│   ├── zh-CN/                          # F-Droid 元数据（源语言/中文）
│   ├── en-US/                          # F-Droid 元数据（英文）
│   └── ko-KR/                          # F-Droid 元数据（韩文）
├── fdroid/
│   └── cn.yosvu.ledgerlearn.yml  # fdroiddata 提交用元数据
├── ├── lib/
│   ├── main.dart                       # 入口 + 底部导航壳
│   ├── app/
│   │   ├── bindings/app_binding.dart   # GetX 全局依赖注入
│   │   ├── config/preset_data.dart     # 62 个科目预置数据
│   │   ├── i18n/
│   │   │   ├── translations.dart       # GetX Translations 类（由 gen_i18n.dart 生成）
│   │   │   └── locales/                # 各语言 Dart 文件（由 gen_i18n.dart 生成）
│   │   ├── routes/app_pages.dart       # 16 条命名路由
│   │   └── theme/app_theme.dart        # Material 3 主题 + 字体配置
│   ├── data/
│   │   ├── models/                     # Account / Voucher / Entry / KnowledgeCard
│   │   ├── repositories/               # 数据仓库层
│   │   └── services/
│   │       ├── database_service.dart   # GetStorage 持久化 + 数据预置
│   │       ├── remote_knowledge_service.dart  # 联网知识库拉取
│   │       └── export_service.dart     # CSV/PDF 导出
│   ├── modules/
│   │   ├── home/         # 首页仪表盘
│   │   ├── voucher/      # 凭证录入/列表/详情
│   │   ├── accounts/     # 科目管理/详情
│   │   ├── ledger/       # 总账/明细账
│   │   ├── reports/      # 试算平衡/利润表/资产负债表
│   │   ├── knowledge/    # 知识库浏览/详情
│   │   └── settings/     # 语言切换/数据重置
│   └── shared/
│       ├── widgets/       # 公共组件（科目选择器等）
│       └── utils/         # 工具函数（金额格式化、余额计算）
└── assets/
    ├── fonts/             # Inter / Noto Sans SC / Noto Sans KR 字体
    └── data/              # 预置数据（knowledge_cards.json）
```

## 快速开始

### 环境要求

- Flutter 3.x（beta 频道），Dart 3.11+
- Android Studio / VS Code
- Android SDK 或 Chrome（Web 模式）

### 运行

```bash
git clone https://github.com/Maicarons/ledgerlearn.git
cd ledgerlearn

# 安装依赖
flutter pub get

# 代码检查
flutter analyze

# 在 Chrome 中运行（无需 Android 模拟器）
flutter run -d chrome

# 在 Android 设备/模拟器运行
flutter run

# 构建 APK
flutter build apk
```

## 翻译（GitHub PR）

翻译由社区通过 **GitHub Pull Request** 贡献，不依赖第三方翻译平台。

### 翻译范围

- **应用 UI 文本** — `i18n/*.json`
- **知识卡片** — `knowledge_card/*.json`
- **商店/文档** — `fastlane/metadata/android/*`、`doc/*/README.md`

### 如何贡献翻译

1. Fork 本仓库并创建分支（如 `l10n/ja-JP`）
2. 编辑目标语言 JSON（源语言为 `i18n/zh-CN.json`，键名保持一致）：
   ```bash
   # 例：完善日语 UI 文案
   $EDITOR i18n/ja-JP.json
   # 如需同步知识卡片
   $EDITOR knowledge_card/ja-JP.json
   ```
3. 生成 Dart 语言包并自检：
   ```bash
   dart run scripts/gen_i18n.dart
   flutter analyze
   flutter test
   ```
4. 提交 PR（标题建议：`l10n(ja-JP): improve UI strings`）
   - 仅改翻译相关文件，勿夹带无关代码
   - 新增语言：同时在 `scripts/gen_i18n.dart` 的 locale 映射表中注册
5. 维护者审阅后合并；合并后 `git pull` 即可看到最新文案

### 本地工作流

```bash
# 1. 修改 i18n/*.json 或 knowledge_card/*.json
# 2. 从 JSON 生成 Dart 翻译文件
dart run scripts/gen_i18n.dart

# 3. 检查键完整性（测试会比对六语键集合）
flutter test test/i18n_parity_test.dart
```

### 当前支持的语言

| 语言 | 代码 | 状态 |
|---|---|---|
| 🇨🇳 简体中文（源语言） | `zh_CN` | ✅ 完成 |
| 🇺🇸 English | `en_US` | ✅ 完成 |
| 🇰🇷 한국어 | `ko_KR` | ✅ 完成 |
| 🇯🇵 日本語 | `ja_JP` | ✅ 基础完成，欢迎润色 |
| 🇻🇳 Tiếng Việt | `vi_VN` | ✅ 基础完成，欢迎润色 |
| 🇹🇭 ไทย | `th_TH` | ✅ 基础完成，欢迎润色 |

欢迎通过 PR 补充 `doc/` 下更多语言的 README，或修正既有译文。


## 会计科目体系

预置 **62 个标准会计科目**，严格按照**中国企业会计准则**分类：

- **资产类**（26 个）：库存现金、银行存款、应收账款、合同资产、原材料、库存商品、固定资产、累计折旧等
- **负债类**（14 个）：短期借款、应付账款、合同负债、交易性金融负债、应付职工薪酬、应交税费、长期借款等
- **所有者权益类**（5 个）：实收资本、资本公积、盈余公积、本年利润、利润分配
- **成本类**（2 个）：生产成本、制造费用
- **损益类**（15 个）：主营业务收入、主营业务成本、销售费用、管理费用、财务费用等

每个科目均包含中英韩三语名称与讲解说明。

## 数据持久化

使用 GetStorage 以 JSON 格式存储全部数据：

| 键 | 内容 |
|---|---|
| `accounts` | 科目列表 |
| `vouchers` | 凭证列表 |
| `knowledge_cards` | 知识卡片列表 |
| `locale` | 语言偏好 |
| `themeMode` | 主题模式 |
| `colorScheme` | 配色方案 |
| `defaultPeriod` | 默认账期 |

首次启动时自动写入预置数据，后续启动读取已有数据。通过设置页可一键重置为初始状态。

## 教学融入设计

- **分录练习**：10 个真实业务场景，自动判分（科目/方向/平衡/金额），错题本可复盘
- **期末结转向导**：三步生成结转凭证（收入 → 费用 → 本年利润）
- **凭证保存后**：随机弹出会计实务知识点
- **凭证不平衡**：提示「有借必有贷，借贷必相等」并解释借贷记账法
- **报表页面**：点击信息图标查看该报表的解读说明；费用/资产饼图辅助理解结构
- **科目详情页**：展示关联的知识卡片
- **明细账/总账页**：悬浮按钮解释会计概念

## Web 试用

推送到 `master` 或打 `v*` 标签后，GitHub Actions 会自动构建并部署到 GitHub Pages（路径 `/LedgerLearn/`）。也可本地执行：

```bash
flutter build web --release
```

## 发布到 F-Droid

`fdroid/` 目录已备好构建元数据草稿。完整流程见 **[doc/fdroid-release.md](doc/fdroid-release.md)**（含 fdroiddata MR、fastlane 元数据与本地 `fdroid build` 验证）。

```bash
# 本地验证（需安装 fdroidserver）
fdroid build cn.yosvu.ledgerlearn
```

商店页面文本（fastlane 格式）存放于 `fastlane/metadata/android/`。

## 许可证

[GNU General Public License v3.0](LICENSE)

Copyright (C) 2026 Maicarorns

LedgerLearn is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
