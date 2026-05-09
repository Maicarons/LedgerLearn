# LedgerLearn 翻译指南

## 概述

LedgerLearn 使用 [Crowdin](https://crowdin.com) 翻译管理平台管理所有多语言内容。翻译范围包括三个层面：

| 层面 | 源文件 | 格式 | 说明 |
|---|---|---|---|
| **应用 UI 文本** | `i18n/zh_CN.json` | JSON | 151 个翻译键，覆盖所有界面文字 |
| **F-Droid 商店页面** | `fastlane/metadata/android/zh-CN/*.txt` | 纯文本 | 标题、简介、完整描述、更新日志 |
| **项目文档** | `README.md` | Markdown | 项目说明文档 |

源语言为**简体中文（zh-CN）**，目标语言目前包括英文（en-US）和韩文（ko-KR）。

## 参与翻译

### 方式一：Crowdin 在线平台（推荐）

1. 访问 [LedgerLearn Crowdin 项目](https://crowdin.com/project/ledgerlearn)
2. 注册 Crowdin 账号并加入项目
3. 选择目标语言开始翻译
4. 提交翻译后等待审核

无需任何技术背景，直接在浏览器中翻译即可。

### 方式二：直接提交 JSON 文件

如果不使用 Crowdin，也可以直接编辑 `i18n/` 目录下的 JSON 文件并提交 Pull Request：

1. Fork 项目
2. 复制 `i18n/zh_CN.json` 为新语言文件（如 `i18n/ja_JP.json`）
3. 逐条翻译所有 value（保留 key 和 JSON 结构不变）
4. 在 `crowdin.yml` 中添加新语言的映射
5. 运行 `dart run scripts/gen_i18n.dart` 生成 Dart 文件
6. 提交 PR

## 翻译文件结构

### 应用 UI 文本（JSON）

```json
{
  "app_name": "记账学习",
  "save": "保存",
  "voucher_title": "凭证管理",
  ...
}
```

- **key**：翻译键，在 Dart 代码中通过 `'key'.tr` 引用
- **value**：翻译文本
- 支持占位符：`"ledger_detail_for": "明细账 - {account}"` —— `{account}` 会被运行时变量替换
- 键名排序不影响运行时行为，但建议保持与源文件一致以方便对比

### F-Droid 元数据（纯文本）

```
fastlane/metadata/android/<locale>/
├── title.txt               # 应用标题（≤30 字符）
├── short_description.txt   # 简短描述（≤80 字符）
├── full_description.txt    # 完整描述（≤4000 字符）
└── changelogs/
    └── <version_code>.txt  # 版本更新日志
```

## 项目维护者工作流

### 安装 Crowdin CLI

```bash
# macOS / Linux
brew install crowdin

# Windows (scoop)
scoop install crowdin

# 或通过 npm
npm install -g @crowdin/cli
```

### 配置认证

在 CI 环境或本地设置环境变量（由 `crowdin.yml` 引用）：

```bash
export CROWDIN_PROJECT_ID="your_project_id"
export CROWDIN_PERSONAL_TOKEN="your_personal_access_token"
```

或者在项目根目录创建 `crowdin.yml` 同级的 `.crowdin` 环境文件（已在 `.gitignore` 中排除）。

### 推送源文本

修改了源语言（中文）的翻译键或 F-Droid 元数据后：

```bash
# 推送所有源文件到 Crowdin
crowdin push

# 仅推送 UI 文本
crowdin push -s i18n/zh_CN.json

# 仅推送 F-Droid 元数据
crowdin push -s fastlane/metadata/android/zh-CN/
```

### 拉取翻译

审核完成后拉取翻译并生成 Dart 文件：

```bash
# 拉取所有翻译
crowdin pull

# 生成 Dart 翻译文件
dart run scripts/gen_i18n.dart

# 验证生成结果
flutter analyze
```

### 添加新语言

以添加日语（ja_JP）为例：

**步骤 1**：在 `crowdin.yml` 中为新语言添加映射（已预留配置，取消注释即可）

```yaml
languages_mapping:
  two_letters_code:
    ja-JP: ja_JP    # ← 已预留
```

**步骤 2**：在 `scripts/gen_i18n.dart` 的映射表中添加：

```dart
const localeFileMap = {
  // ... 已有语言
  'ja_JP': 'ja_JP.dart',     // 新增
};

const localeVarMap = {
  // ... 已有语言
  'ja_JP': 'jaJP',           // 新增
};
```

**步骤 3**：在 Crowdin 平台上添加日语作为目标语言。

**步骤 4**：翻译完成后拉取并生成：

```bash
crowdin pull
dart run scripts/gen_i18n.dart
```

**步骤 5**：在设置页面中注册新语言选项（参见 `lib/modules/settings/controllers/settings_controller.dart`）。

### 手动编辑 JSON 翻译（不使用 Crowdin CLI）

当直接编辑 `i18n/*.json` 文件后：

```bash
dart run scripts/gen_i18n.dart
```

此脚本会：
1. 读取 `i18n/` 下所有 JSON 文件
2. 为每个文件生成对应的 `lib/app/i18n/locales/<locale>.dart`
3. 自动更新 `lib/app/i18n/translations.dart` 中的语言注册

## 翻译规范

### 通用原则

1. **保持占位符不变**：`{account}` 等 `{...}` 标记不要翻译
2. **保持键名不变**：JSON key 是不可翻译的标识符
3. **长度控制**：UI 文本尽可能简洁，避免因翻译导致布局溢出
4. **一致性**：同一术语在全文中保持相同译法

### 中文（源语言）规范

- 使用中国大陆简体中文表述
- 会计术语严格遵循《企业会计准则》
- 界面文字简洁明了，适合初学者理解

### 术语对照

以下为关键术语的标准译法，请在翻译中保持一致：

| 中文 | English | 한국어 |
|---|---|---|
| 借 / 借方 | Debit / Dr | 차변 |
| 贷 / 贷方 | Credit / Cr | 대변 |
| 凭证 | Voucher | 전표 |
| 分录 | Entry | 분개 |
| 科目 | Account | 계정 |
| 总账 | General Ledger | 총계정원장 |
| 明细账 | Detail Ledger | 보조원장 |
| 试算平衡表 | Trial Balance | 시산표 |
| 利润表 | Income Statement | 손익계산서 |
| 资产负债表 | Balance Sheet | 대차대조표 |
| 资产 | Assets | 자산 |
| 负债 | Liabilities | 부채 |
| 所有者权益 | Owner's Equity | 자본 |
| 期初余额 | Opening Balance | 기초잔액 |
| 期末余额 | Ending Balance | 기말잔액 |

## 代码生成器说明

`scripts/gen_i18n.dart` 是翻译系统的核心工具，负责将 JSON 翻译文件转换为 Flutter 可用的 Dart 代码。

```
i18n/zh_CN.json ──┐
i18n/en_US.json ──┼── gen_i18n.dart ──→ lib/app/i18n/locales/zh_CN.dart
i18n/ko_KR.json ──┤                     lib/app/i18n/locales/en_US.dart
i18n/ja_JP.json ──┘                     lib/app/i18n/locales/ko_KR.dart
                                         lib/app/i18n/translations.dart
```

### 工作原理

1. 扫描 `i18n/` 目录中所有 `.json` 文件
2. 解析 JSON，提取 key-value 对
3. 按 key 排序后生成 `const Map<String, String>` Dart 代码
4. 对特殊字符（`$`、`'`、`\n`）进行转义
5. 自动生成 `translations.dart`，注册所有语言

此脚本每次运行都会**完全覆盖**目标 Dart 文件，因此切勿手动编辑自动生成的文件。

## 版本控制

- ✅ **提交**：`i18n/*.json`、`scripts/gen_i18n.dart`、`crowdin.yml`
- ✅ **提交**：`lib/app/i18n/locales/*.dart`（生成的文件，确保未配置 Crowdin 的开发者也能直接构建）
- ✅ **提交**：`pubspec.lock`（F-Droid 可复现构建需要）
- ❌ **不提交**：Crowdin API token、`.crowdin` 环境文件
