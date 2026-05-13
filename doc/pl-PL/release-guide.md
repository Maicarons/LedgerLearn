# LedgerLearn 发布指南

## 概述

本项目使用 `version.json` 作为版本号的唯一来源，通过脚本自动同步到 `pubspec.yaml`、F-Droid 元数据和 App 内显示。

CI/CD 由 GitHub Actions 驱动：

- **CI** (`.github/workflows/ci.yml`) — 每次 PR / push 到 master 时运行静态分析 + 测试
- **Release** (`.github/workflows/release.yml`) — 构建 APK 并发布 GitHub Release

## 发布方式

### 方式一：GitHub Actions 手动触发（推荐）

1. 打开 [Actions → Release](https://github.com/Maicarons/ledgerlearn/actions/workflows/release.yml)
2. 点击 **Run workflow**
3. 选择 `bump_level`：
   | 选项      | 说明             | 示例                                                                            |
   | ------- | -------------- | ----------------------------------------------------------------------------- |
   | `patch` | 修复版            | 0.1.0 → 0.1.1 |
   | `minor` | 功能版            | 0.1.0 → 0.2.0 |
   | `major` | 重大版            | 0.1.0 → 1.0.0 |
   | `none`  | 不升版（仅重新构建当前版本） | —                                                                             |
4. 点击 **Run workflow**

流程自动完成：

- 更新 `version.json`（如选择 bump）
- 同步 `pubspec.yaml` 和 F-Droid 元数据
- 构建 `app-release.apk`
- 创建 GitHub Release 并附上 APK
- 提交版本变更并推送 `vX.Y.Z` 标签

### 方式二：本地手动发布

```bash
# 1. 更新 CHANGELOG.md，在顶部添加新版本的变更说明

# 2. 升版本号
dart run scripts/bump_version.dart patch   # 或 minor / major

# 3. 同步到各目标文件
dart run scripts/sync_version.dart

# 4. 验证无错误
flutter analyze

# 5. 提交并推送标签
git add version.json pubspec.yaml fdroid/ lib/app/config/ CHANGELOG.md
VER=$(jq -r '.version' version.json)
git commit -m "chore(release): bump version to $VER"
git tag v$VER
git push origin master v$VER
```

推送标签后，GitHub Actions 会自动构建 APK 并创建 Release。

## 版本号规则

- 遵循 [语义化版本](https://semver.org/lang/zh-CN/)：`主版本.次版本.修订号`
- `version_code` 为整数，每次发布递增加 1（Android 要求）
- F-Droid 使用 `CurrentVersion` + `CurrentVersionCode`

## 更新 CHANGELOG

每次发布前，在 `CHANGELOG.md` 顶部添加新版本的变更条目：

```markdown
## [1.0.1] - 2025-06-01

### Added
- 新功能描述

### Fixed
- 修复的问题描述

### Changed
- 变更的描述
```

发布后 CHANGELOG 内容会作为 GitHub Release 的发布说明。

## 同步到 F-Droid

1. GitHub Release 发布后，更新 `fdroid/com.yosvu.ledgerlearn.ledgerlearn.yml` 中的 `Builds` 列表：

```yaml
Builds:
  - versionName: '1.0.1'
    versionCode: 2
    commit: v1.0.1
    subdir: .
    ...
```

2. 将更新后的 YAML 提交到 [fdroiddata](https://gitlab.com/fdroid/fdroiddata) 仓库的 Merge Request。

## 相关文件

| 文件                                             | 用途            |
| ---------------------------------------------- | ------------- |
| `version.json`                                 | 版本号唯一来源       |
| `CHANGELOG.md`                                 | 用户可见的变更日志     |
| `scripts/bump_version.dart`                    | 版本号升级工具       |
| `scripts/sync_version.dart`                    | 版本号同步工具       |
| `.github/workflows/release.yml`                | 自动发布工作流       |
| `fdroid/com.yosvu.ledgerlearn.ledgerlearn.yml` | F-Droid 构建元数据 |
