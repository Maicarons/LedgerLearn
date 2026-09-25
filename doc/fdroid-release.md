# F-Droid 发布指南（LedgerLearn）

调研自官方文档（2026-09）：
- [Submitting to F-Droid Quick Start Guide](https://f-droid.org/en/docs/Submitting_to_F-Droid_Quick_Start_Guide/)
- [Build Metadata Reference](https://f-droid.org/en/docs/Build_Metadata_Reference/)
- [fdroiddata CONTRIBUTING](https://gitlab.com/fdroid/fdroiddata/-/blob/master/CONTRIBUTING.md)

## 结论（本仓库现状）

| 项 | 状态 |
|---|---|
| 开源许可 GPL-3.0 | ✅ |
| 源码公开（GitHub） | ✅ |
| `fastlane/metadata/android/*` 商店文案 | ✅ 已有多语言 |
| `fdroid/*.yml` 构建元数据草稿 | ✅ 需更新 versionCode/commit |
| 已提交 fdroiddata MR | ⏳ 待提交 |
| F-Droid 上架 | ⏳ 审核中/未提交 |

## 发布路径（推荐）

### A. 标准：提交 fdroiddata（主仓库收录）

1. **准备合规**
   - 许可证清晰（GPL-3.0-only）
   - 无专有依赖 / 非自由网络服务强依赖（GetStorage 本地 OK；远程知识库应可离线）
   - Application ID 稳定：`cn.yosvu.ledgerlearn`

2. **上游元数据（已在本仓库）** — `fastlane/metadata/android/<locale>/`
   - `title.txt` / `short_description.txt` / `full_description.txt`
   - `changelogs/<versionCode>.txt`
   - `images/icon.png`、`images/phoneScreenshots/*.png`

3. **写 Build Metadata**（放 fdroiddata）
   - 文件名必须是 Application ID：`metadata/cn.yosvu.ledgerlearn.yml`
   - 字段：`Categories` `License` `AuthorName` `SourceCode` `IssueTracker` `Changelog`
   - `RepoType: git` + `Repo`
   - `Builds:` 每个 APK 一段：`versionName` `versionCode` `commit`（建议 git tag）
   - Flutter 项目用官方模板中的 `gradle`/`flutter` 构建方式，或自定义 `prebuild`/`build`
   - 配置 `AutoUpdateMode` / `UpdateCheckMode`（Tag 或 Tags），后续发版可自动开 MR

4. **本地验证**（需 [fdroidserver](https://gitlab.com/fdroid/fdroidserver)）
   ```bash
   # 克隆 fdroiddata
   git clone https://gitlab.com/fdroid/fdroiddata.git
   cd fdroiddata
   cp /path/to/ledgerlearn/fdroid/cn.yosvu.ledgerlearn.yml \
      metadata/cn.yosvu.ledgerlearn.yml
   fdroid checkupdates cn.yosvu.ledgerlearn
   fdroid build --verbose cn.yosvu.ledgerlearn
   ```

5. **提 Merge Request**
   - 在 GitLab fork `fdroiddata` → 分支 → 添加/更新 metadata → MR
   - 标题：`Add LedgerLearn (accounting learning)` 或 `Update LedgerLearn to 0.3.0`
   - 说明：许可、无跟踪、离线优先、截图链接

6. **审核与上架**
   - 审核周期常为数周；会要求修复 metadata / 构建问题
   - 合并后进入主仓库，客户端可搜索安装

### B. 自建 F-Droid 仓库（快、可先用）

```bash
# 在独立仓库放 metadata/ 与 APK（或让 fdroidserver 构建）
fdroid update
# 将 repo url 加入 F-Droid 客户端
```
适合先行分发；主仓库收录后再并入。

## 本仓库 YAML 需更新的点

当前 `fdroid/cn.yosvu.ledgerlearn.yml`：

- `versionName/versionCode/commit` 仍是 `0.0.1` → 改为当前 release tag（如 `0.3.0` / `4` / `v0.3.0`）
- Description 中「59 accounts / 74 cards」应同步为 **62 科目**、知识卡与练习功能
- 增加 `AutoUpdateMode: Version` 或 `Tags` + `UpdateCheckMode: Tags`
- 确认 `Builds` 的 gradle/flutter 参数能通过 `fdroid build`

## 发版检查清单

- [ ] 打 git tag（`vX.Y.Z`）并 GitHub Release
- [ ] 更新 `fastlane/.../changelogs/<versionCode>.txt`
- [ ] 更新 fdroid metadata 的 Builds 段
- [ ] `fdroid build` 本地通过
- [ ] 提交 fdroiddata MR

## 注意

- F-Droid **自己从源码构建**，不直接用你 GitHub Release 的 APK（除非做可重复构建对照）
- 避免在源码中夹带二进制；字体等资产需许可兼容
- `UpdateCheckMode` 用 Tags 时，打 tag 后 bot 会自动开更新 MR
