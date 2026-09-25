# F-Droid 上架 — 提交包

目标 Application ID：**`cn.yosvu.ledgerlearn`**  
源码：https://github.com/Maicarons/ledgerlearn · License：GPL-3.0-only

| 文件 | 用途 |
|---|---|
| `cn.yosvu.ledgerlearn.yml` | 复制到 fdroiddata 的 `metadata/` |
| **`MR_BODY.md`** | **最终 MR 标题 + 正文（按模板写好，直接粘贴）** |
| `README.md` | 本说明 |

---

## 提交步骤（GitLab）

1. 打开并 Fork：https://gitlab.com/fdroid/fdroiddata  
2. 在 fork 中新建分支：`cn.yosvu.ledgerlearn`  
3. 添加文件 **`metadata/cn.yosvu.ledgerlearn.yml`**，内容 = 本目录同名文件  
4. 对 `fdroid/fdroiddata` 开 Merge Request  
5. **标题与正文** 使用 `MR_BODY.md` 中的最终版（见文件内 `Title` / `Body`）  
6. 等待 packager 审阅；可同步在 [RFP](https://gitlab.com/fdroid/rfp/-/issues) 发一条 Request for Packaging（正文也在 `MR_BODY.md`）

---

## 可选本地校验

```bash
# 需要 fdroidserver
pip install git+https://gitlab.com/fdroid/fdroidserver.git
fdroid checkupdates cn.yosvu.ledgerlearn
fdroid build --verbose cn.yosvu.ledgerlearn
```

---

## 上架后

- 打 git tag 发版 → `UpdateCheckMode: Tags` 自动开更新 MR  
- 同步 `fastlane/.../changelogs/<versionCode>.txt`


---

## 一、提交前检查（本仓库侧）

| 项 | 状态 |
|---|---|
| 开源许可 GPL-3.0 | ✅ |
| Application ID `cn.yosvu.ledgerlearn` | ✅ |
| fastlane 商店文案 | ✅ 多语言 title/short/full |
| fastlane icon | ✅ `en-US/images/icon.png` |
| 手机截图 | ⚠️ **建议补齐** `en-US/images/phoneScreenshots/1.png …` |
| Build metadata | ✅ `fdroid/submission/cn.yosvu.ledgerlearn.yml` |
| 可从源码构建（Flutter） | ✅ `flutter build apk --release` |
| 无强制专有后端 | ✅ 离线优先 |

---

## 二、补齐截图（强烈建议）

放到仓库：

```
fastlane/metadata/android/en-US/images/icon.png          # 512×512 已有
fastlane/metadata/android/en-US/images/phoneScreenshots/1.png
fastlane/metadata/android/en-US/images/phoneScreenshots/2.png
fastlane/metadata/android/en-US/images/phoneScreenshots/3.png
```

截图建议：首页品牌区 / 凭证录入 / 分录练习 / 报表图表。  
Windows 调试包可截竖屏窗口（约 540×960）。

---

## 三、fdroiddata Merge Request（GitLab）

1. 注册/登录 **GitLab**，Fork：https://gitlab.com/fdroid/fdroiddata  
2. 创建分支，例如 `add-ledgerlearn`  
3. 将本目录文件复制为：
   ```
   metadata/cn.yosvu.ledgerlearn.yml
   ```
4. 本地校验（需 [fdroidserver](https://gitlab.com/fdroid/fdroidserver)）：
   ```bash
   fdroid checkupdates cn.yosvu.ledgerlearn
   fdroid build --verbose cn.yosvu.ledgerlearn
   ```
5. 提交 MR，标题：
   ```
   Add LedgerLearn (accounting learning simulation)
   ```
6. MR 说明模板见下方「四、MR 描述」

---

## 四、MR 描述（可直接粘贴）

```markdown
## Adding a new app

- **App name:** LedgerLearn
- **Application ID:** cn.yosvu.ledgerlearn
- **Source:** https://github.com/Maicarons/ledgerlearn
- **License:** GPL-3.0-only
- **Category:** Education

### Description

Multilingual accounting learning simulator for beginners (China ASBE).
Offline-first: vouchers, ledgers, reports, practice drills, knowledge cards.

### Why include it?

Free/open-source educational tool for accounting students; no ads/trackers;
works fully offline (optional knowledge update from public repo).

### Build

Flutter project. Metadata file: `metadata/cn.yosvu.ledgerlearn.yml`
Current release tag: `v0.3.0` (versionCode 4).

I can run `fdroid build` locally if needed. Screenshots are in upstream
`fastlane/metadata/android/en-US/images/`.

### Checklist

- [x] App is FOSS (GPL-3.0)
- [x] No proprietary dependencies required to build
- [x] Upstream metadata in fastlane format
- [x] Builds from source with Flutter
```

---

## 五、元数据注意点

- 文件名必须是 **`cn.yosvu.ledgerlearn.yml`**（与 Application ID 一致）
- `Builds[].commit` 使用 git tag（如 `v0.3.0`），便于 `UpdateCheckMode: Tags` 自动更新
- Flutter 构建产物路径：
  `build/app/outputs/flutter-apk/app-release.apk`
- 若 `fdroid build` 对 Flutter 参数报错，参考 fdroiddata 中现有 Flutter 应用 metadata 的 `gradle`/`sudo`/`prebuild` 配置微调

---

## 六、上架后

1. 合并后主仓库收录，客户端可搜索 **LedgerLearn**
2. 以后发版：打 tag → UpdateCheck bot 自动开更新 MR
3. 保持 `fastlane/.../changelogs/<versionCode>.txt` 与 GitHub Release 同步

---

## 七、可选：自建 F-Droid 仓库（先分发）

```bash
mkdir -p repo/metadata
cp fdroid/submission/cn.yosvu.ledgerlearn.yml repo/metadata/
# 在 repo 目录准备 APK 或用 fdroidserver 构建
fdroid update
```

将仓库 URL 加入 F-Droid 客户端即可安装；主仓库通过后再统一。
