# LedgerLearn — 记账学习模拟应用

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Crowdin](https://badges.crowdin.net/ledgerlearn/localized.svg)](https://crowdin.com/project/ledgerlearn)

一款面向**中国内地会计初学者**的多语言会计入门学习应用，支持中文、英文、韩文。通过模拟完整的会计记账流程——凭证录入、总账/明细账查询、试算平衡、财务报表生成，并在操作中嵌入会计实务与经济法知识点，实现「做中学」。

> ⚠️ **适用地区说明**：本程序的科目体系、会计准则和知识内容均基于**中国企业会计准则（ASBE）**和中国大陆会计从业要求，主要面向中国内地的会计学习者。其他国家/地区的会计准则可能存在差异，请谨慎参考。

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
| **会计科目** | 59 个预置标准科目（资产/负债/权益/成本/损益），支持自定义科目 |
| **总账/明细账** | 按科目汇总的总账，按凭证逐笔展示的明细账 |
| **财务报表** | 试算平衡表、利润表、资产负债表，附教学解读 |
| **知识库** | 74 条三语知识卡片（会计实务 + 经济法），支持 Markdown 渲染，支持联网更新 |
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
├── i18n/                               # 📦 Crowdin 翻译源文件（JSON）
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
│   └── com.yosvu.ledgerlearn.ledgerlearn.yml  # fdroiddata 提交用元数据
├── crowdin.yml                         # Crowdin 翻译平台配置
├── lib/
│   ├── main.dart                       # 入口 + 底部导航壳
│   ├── app/
│   │   ├── bindings/app_binding.dart   # GetX 全局依赖注入
│   │   ├── config/preset_data.dart     # 59 个科目 + 74 条知识卡片的预置数据
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

## 翻译（Crowdin）

本项目使用 [Crowdin](https://crowdin.com) 翻译平台管理多语言内容。翻译范围包括：

- **应用 UI 文本** — `i18n/*.json`
- **F-Droid 商店页面文本** — `fastlane/metadata/android/*.txt`
- **项目文档** — `README.md`

### 翻译工作流

```bash
# 1. 从 Crowdin 拉取最新翻译
crowdin pull

# 2. 从 JSON 生成 Dart 翻译文件
dart run scripts/gen_i18n.dart

# 3. 更新源文本后推送至 Crowdin
crowdin push

# 4. 添加新语言只需在 crowdin.yml 中配置，然后拉取 + 生成即可
```

### 当前支持的语言

| 语言 | 代码 | 状态 |
|---|---|---|
| 🇨🇳 简体中文（源语言） | `zh_CN` | ✅ 完成 |
| 🇺🇸 English | `en_US` | ✅ 完成 |
| 🇰🇷 한국어 | `ko_KR` | ✅ 完成 |
| 🇯🇵 日本語 | `ja_JP` | 🔜 Crowdin 待翻译 |
| 🇻🇳 Tiếng Việt | `vi_VN` | 🔜 Crowdin 待翻译 |
| 🇹🇭 ไทย | `th_TH` | 🔜 Crowdin 待翻译 |

### 参与翻译

1. 访问 [LedgerLearn Crowdin 项目](https://crowdin.com/project/ledgerlearn)
2. 选择目标语言并开始翻译
3. 翻译审核通过后，将合并到主分支

## 会计科目体系

预置 **59 个标准会计科目**，严格按照**中国企业会计准则**分类：

- **资产类**（25 个）：库存现金、银行存款、应收账款、原材料、库存商品、固定资产、累计折旧等
- **负债类**（12 个）：短期借款、应付账款、应付职工薪酬、应交税费、长期借款等
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

- **凭证保存后**：随机弹出会计实务知识点
- **凭证不平衡**：提示「有借必有贷，借贷必相等」并解释借贷记账法
- **报表页面**：点击信息图标查看该报表的解读说明
- **科目详情页**：展示关联的知识卡片
- **明细账/总账页**：悬浮按钮解释会计概念

## 发布到 F-Droid

`fdroid/` 目录下的 YAML 文件已准备就绪，可直接提交到 [fdroiddata](https://gitlab.com/fdroid/fdroiddata) 仓库的 Merge Request。

```bash
# 预览 F-Droid 元数据
cat fdroid/com.yosvu.ledgerlearn.ledgerlearn.yml

# 本地验证构建（需要 fdroidserver）
fdroid build com.yosvu.ledgerlearn.ledgerlearn
```

商店页面文本（fastlane 格式）存放于 `fastlane/metadata/android/`。

## 许可证

[GNU General Public License v3.0](LICENSE)

Copyright (C) 2025 Maicarorns

LedgerLearn is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
