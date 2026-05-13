# LedgerLearn 开发文档

## 项目概述

LedgerLearn 是一个基于 Flutter + GetX 的多语言会计学习应用。支持 Android / iOS / Web / Windows / macOS / Linux 六个平台。

## 技术栈

| 层级       | 技术                                                          |
| -------- | ----------------------------------------------------------- |
| UI 框架    | Flutter 3.x (Material 3) |
| 状态管理     | GetX (Rx 响应式)                            |
| 路由管理     | GetX (GetPage)                           |
| 依赖注入     | GetX (Bindings)                          |
| 国际化      | GetX (Translations)                      |
| 本地存储     | GetStorage                                                  |
| HTTP 客户端 | GetConnect                                                  |
| 字体       | Inter + Noto Sans SC/KR (本地捆绑)           |
| Markdown | flutter_markdown                       |
| PDF 导出   | pdf                                                         |
| 分析       | flutter_lints                          |

## 环境搭建

### 前提条件

- Flutter 3.x beta 频道 (Dart 3.11+)
- Android Studio / VS Code
- 各平台对应的 SDK

> 各平台 Release 构建（签名、F-Droid 适配等）的完整说明见 [构建指南](build-guide.md)。

### 安装依赖

```bash
flutter pub get
```

### 运行

```bash
# Chrome (最快)
flutter run -d chrome

# Android 模拟器
flutter run

# Windows Desktop
flutter run -d windows

# 指定设备
flutter run -d <device_id>
```

### 构建

```bash
flutter build apk        # Android APK
flutter build web        # Web
flutter build windows    # Windows
```

## 项目架构

采用 Clean Architecture + GetX 分层：

```
lib/
├── app/           # 应用配置层
│   ├── bindings/  # 全局依赖注入
│   ├── config/    # 预置数据常量
│   ├── i18n/      # 国际化翻译文件（由 scripts/gen_i18n.dart 自动生成）
│   ├── routes/    # 路由表
│   └── theme/     # 主题配置
├── data/          # 数据层
│   ├── models/    # 数据模型 (Account, Voucher, Entry, KnowledgeCard)
│   ├── repositories/  # 数据仓库 (封装存储查询逻辑)
│   └── services/  # 服务层 (DatabaseService, ExportService, RemoteKnowledgeService)
├── modules/       # 功能模块 (home/voucher/accounts/ledger/reports/knowledge/settings)
│   ├── */controllers/  # GetxController
│   ├── */views/        # 页面 Widget
│   └── */bindings/     # 模块绑定
└── shared/        # 共享组件
    ├── widgets/   # 公共 Widget (AccountPicker 等)
    └── utils/     # 工具函数 (金额格式化、余额计算)
```

> 翻译工作流和添加新语言的详细说明参见 [翻译指南](translation-guide.md)，构建和发布说明参见 [构建指南](build-guide.md)。

## 模块说明

### 数据模型

#### Account (会计科目)

```dart
class Account {
  String id;           // 科目编码 (如 1001)
  String nameZh;       // 中文名称
  String nameEn;       // 英文名称
  String nameKo;       // 韩文名称
  String category;     // asset/liability/equity/cost/pl
  int type;            // 1=资产 2=负债 3=权益 4=成本 5=损益(收入) 6=损益(费用)
  double openingBalance;
  bool isSystem;       // 系统预置科目不可删除
}
```

#### Voucher (记账凭证)

```dart
class Voucher {
  String id;           // 凭证号 (格式: 年月+4位流水)
  DateTime date;
  String summary;      // 摘要
  List<Entry> entries; // 分录列表
}

class Entry {
  String accountId;
  String accountName;
  bool isDebit;        // true=借 false=贷
  double amount;
}
```

#### KnowledgeCard (知识卡片)

```dart
class KnowledgeCard {
  String id;
  String titleZh/titleEn/titleKo;       // 三语标题
  String contentZh/contentEn/contentKo; // 三语内容 (Markdown)
  String category;    // accounting_practice / economic_law / tax
  String? relatedAccountId;
}
```

### 数据流

```
View (Widget)
  ├→ GetX Controller (Rx variables)
  │     └→ Repository (data logic)
  │           └→ DatabaseService (GetStorage persistence)
  └→ UI 自动更新 (Obx)
```

### 国际化

- 所有 UI 文字使用 `.tr` 获取翻译：`'voucher_title'.tr`
- 翻译源文件为 `i18n/*.json`（JSON 格式），由 Crowdin 平台管理
- Dart 文件 `lib/app/i18n/locales/` 由 `scripts/gen_i18n.dart` 从 JSON 自动生成
- 动态数据（科目名、知识卡片）使用三语字段存储，通过 `locale` 参数选择
- 语言切换：`Get.updateLocale(Locale(lang, region))`
- 详细的翻译工作流参见 [翻译指南](translation-guide.md)

### 联网知识库

```
RemoteKnowledgeService
  ├→ fetchKnowledgeCards()
  │     ├→ GET remoteUrl (10s timeout)
  │     ├→ 成功 → 返回 List<KnowledgeCard>
  │     └→ 失败 → 返回 null
  └→ DatabaseService._refreshKnowledge()
        ├→ 远程成功 → 覆盖本地存储
        └→ 远程失败 → 使用内置 presetKnowledgeCards
```

### 导出功能

`ExportService` 提供 CSV 和 PDF 两种导出：

- 文件保存到 `getApplicationDocumentsDirectory()`
- 文件名包含时间戳
- CSV 带 BOM 头（Excel 兼容）

### 主题和字体

- 主色调：蓝色系 (`Color(0xFF1565C0)`)
- 字体：`Inter` (主) + `Noto Sans SC` + `Noto Sans KR` (后备)
- 字体文件位于 `assets/fonts/`，在 `pubspec.yaml` 中注册

## 添加新功能指南

### 添加新模块

1. 在 `lib/modules/` 下创建目录
2. 创建 `controllers/`, `views/`, `bindings/` 子目录
3. 在 `app/routes/app_pages.dart` 添加路由
4. 如需翻译，在 `app/i18n/locales/` 三个语言文件中添加翻译键

### 添加新知识卡片

1. 在 `app/config/preset_data.dart` 的 `presetKnowledgeCards` 列表中添加
2. 更新 `assets/data/knowledge_cards.json` 以支持远程更新

### 添加新语言

参见 [翻译指南 — 添加新语言](translation-guide.md#添加新语言)。简要流程：

1. 在 Crowdin 平台添加目标语言并完成翻译
2. 在 `scripts/gen_i18n.dart` 中添加语言映射
3. 运行 `crowdin pull && dart run scripts/gen_i18n.dart`
4. 在设置页面的语言选项中注册新语言

## 注意事项

1. **金额计算**：以 double 存储，比较时使用 `(a - b).abs() < 0.001` 避免浮点误差
2. **GetStorage 初始化**：必须 `await GetStorage.init()` 后才能读写
3. **Obx 使用**：`Obx` 内部必须包含至少一个 `.obs` 响应式变量
4. **跨模块引用**：使用相对路径 import，避免循环依赖
