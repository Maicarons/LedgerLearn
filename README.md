# LedgerLearn — 会计学习模拟应用

一款基于 Flutter 的**多语言会计入门学习应用**，支持中文、English、한국어 三种语言。通过模拟完整的会计记账流程——凭证录入、总账/明细账查询、试算平衡、财务报表生成，并在操作中嵌入会计实务与经济法知识点，实现「做中学」。

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
lib/
├── main.dart                        # 入口 + 底部导航壳
├── app/
│   ├── bindings/app_binding.dart    # GetX 全局依赖注入
│   ├── config/preset_data.dart      # 59 个科目 + 74 条知识卡片的预置数据
│   ├── i18n/
│   │   ├── translations.dart        # GetX Translations 类
│   │   └── locales/                 # zh_CN / en_US / ko_KR 语言文件
│   ├── routes/app_pages.dart        # 16 条命名路由
│   └── theme/app_theme.dart         # Material 3 主题 + 字体配置
├── data/
│   ├── models/                      # Account / Voucher / Entry / KnowledgeCard
│   ├── repositories/                # 数据仓库层，封装存储查询逻辑
│   └── services/
│       ├── database_service.dart    # GetStorage 持久化 + 数据预置
│       ├── remote_knowledge_service.dart  # 联网知识库拉取
│       └── export_service.dart      # CSV/PDF 导出
├── modules/
│   ├── home/         # 首页仪表盘
│   ├── voucher/      # 凭证录入/列表/详情
│   ├── accounts/     # 科目管理/详情
│   ├── ledger/       # 总账/明细账
│   ├── reports/      # 试算平衡/利润表/资产负债表
│   ├── knowledge/    # 知识库浏览/详情
│   └── settings/     # 语言切换/数据重置
└── shared/
    ├── widgets/       # 公共组件（科目选择器等）
    └── utils/         # 工具函数（金额格式化、余额计算）
```

## 快速开始

### 环境要求

- Flutter 3.x（beta 频道），Dart 3.11+
- Android Studio / VS Code
- Android SDK 或 Chrome（Web 模式）

### 运行

```bash
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

### 配置联网知识库

知识库支持从远程 JSON 获取，获取成功后自动覆盖本地数据。获取失败则使用内置预置数据。

1. 将 `assets/data/knowledge_cards.json` 上传到你的服务器
2. 修改 `lib/data/services/remote_knowledge_service.dart` 中的 URL：
   ```dart
   static const String remoteUrl = 'https://你的服务器/knowledge_cards.json';
   ```

## 国际化

使用 GetX 内置的 `Translations` 机制实现三语切换，约 150 个翻译键覆盖所有 UI 文字。科目名称和知识卡片内容采用三语字段存储（`nameZh`/`nameEn`/`nameKo`），根据当前语言动态选取。

语言切换在设置页进行，通过 `Get.updateLocale()` 即时生效，语言偏好持久化到 GetStorage。

## 字体

应用捆绑了以下本地字体，无需联网即可在各平台获得一致的排版效果：

| 字体 | 用途 | 文件 |
|---|---|---|
| **Inter** | 英文、数字（400/500/600/700 字重） | `assets/fonts/Inter-*.ttf` |
| **Noto Sans SC** | 简体中文 | `assets/fonts/NotoSansSC-*.ttf` |
| **Noto Sans KR** | 韩文 | `assets/fonts/NotoSansKR-*.ttf` |

配置方式：`fontFamily: 'Inter'` + `fontFamilyFallback: ['Noto Sans SC', 'Noto Sans KR']`

## 会计科目体系

预置 **59 个标准会计科目**，严格按照企业会计准则分类：

- **资产类**（25 个）：库存现金、银行存款、应收账款、原材料、库存商品、固定资产、累计折旧等
- **负债类**（12 个）：短期借款、应付账款、应付职工薪酬、应交税费、长期借款等
- **所有者权益类**（5 个）：实收资本、资本公积、盈余公积、本年利润、利润分配
- **成本类**（2 个）：生产成本、制造费用
- **损益类**（15 个）：主营业务收入、主营业务成本、销售费用、管理费用、财务费用等

每个科目均包含中英韩三语名称与讲解说明。

## 数据持久化

使用 GetStorage 以 JSON 格式存储全部数据，键值对结构：

| 键 | 内容 |
|---|---|
| `accounts` | 科目列表 |
| `vouchers` | 凭证列表 |
| `knowledge_cards` | 知识卡片列表 |
| `locale` | 语言偏好 |
| `themeMode` | 主题模式（浅色/深色/跟随系统） |
| `colorScheme` | 配色方案 |
| `defaultPeriod` | 默认账期 |

应用首次启动时自动写入预置数据，后续启动读取已有数据。通过设置页可一键重置为初始状态。

## 教学融入设计

- **凭证保存后**：随机弹出会计实务知识点
- **凭证不平衡**：提示「有借必有贷，借贷必相等」并解释借贷记账法
- **报表页面**：点击信息图标查看该报表的解读说明
- **科目详情页**：展示关联的知识卡片
- **明细账/总账页**：悬浮按钮解释会计概念
