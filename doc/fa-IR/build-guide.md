# LedgerLearn 构建指南

## 环境要求

| 工具          | 版本                          | 说明                         |
| ----------- | --------------------------- | -------------------------- |
| Flutter SDK | 3.x beta 频道 | Dart 3.11+ |
| Android SDK | API 34+                     | `ANDROID_HOME` 已配置         |
| JDK         | 17                          | 编译 Android 必需              |
| Git         | 2.x         | 获取源码和依赖                    |
| Crowdin CLI | 最新版                         | 翻译管理（可选，仅翻译工作需要）           |

### 环境检查

```bash
flutter doctor -v
```

确保至少 `Android toolchain` 和所需的桌面平台工具链通过检查。

## 获取源码

```bash
git clone https://github.com/Maicarons/ledgerlearn.git
cd ledgerlearn
flutter pub get
```

## 平台构建

### Android APK（通用）

```bash
# Debug 构建（快速测试）
flutter build apk --debug

# Release 构建（发布用）
flutter build apk --release

# 分 ABI 构建（减小包体积，推荐）
flutter build apk --release --split-per-abi
```

产物路径：

| 构建类型                        | 路径                                                          |
| --------------------------- | ----------------------------------------------------------- |
| 通用 APK                      | `build/app/outputs/flutter-apk/app-release.apk`             |
| arm64-v8a                   | `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`   |
| armeabi-v7a                 | `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` |
| x86_64 | `build/app/outputs/flutter-apk/app-x86_64-release.apk`      |

### Android App Bundle（Google Play）

```bash
flutter build appbundle --release
```

产物路径：`build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

产物路径：`build/ios/iphoneos/Runner.app`

> 注意：iOS 构建需要 macOS + Xcode，且需在 `ios/Runner.xcworkspace` 中配置签名团队。

### Web

```bash
flutter build web --release
```

产物路径：`build/web/`

### Windows

```bash
flutter build windows --release
```

产物路径：`build/windows/x64/runner/Release/`

### Linux

```bash
flutter build linux --release
```

产物路径：`build/linux/x64/release/bundle/`

### macOS

```bash
flutter build macos --release
```

产物路径：`build/macos/Build/Products/Release/`

## Android 签名配置

### 生成签名密钥

```bash
keytool -genkey -v -keystore ledgerlearn.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias ledgerlearn
```

### 配置 Gradle 签名

创建 `android/key.properties`：

```properties
storePassword=<密钥库密码>
keyPassword=<密钥密码>
keyAlias=ledgerlearn
storeFile=<密钥库文件路径>
```

> ⚠️ `key.properties` 已在 `.gitignore` 中排除，切勿提交到版本控制。

修改 `android/app/build.gradle.kts`，在 `android` 块之前添加：

```kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

并在 `buildTypes.release` 中配置：

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = keystoreProperties["storeFile"] != null ?
            file(keystoreProperties["storeFile"] as String) : null
        storePassword = keystoreProperties["storePassword"] as String
    }
}
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

## F-Droid 发布构建

F-Droid 需要**可复现构建**。关键要求：

### 1. 无网络依赖的离线构建

F-Droid 构建服务器在无网络环境下运行 `flutter pub get` 之前会预先下载所有依赖。确保：

```bash
# 本地验证离线构建能力
flutter pub cache repair
flutter pub get --offline
```

### 2. 发布版本标签

```bash
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
```

标签名称与 `fdroid/com.yosvu.ledgerlearn.ledgerlearn.yml` 中的 `commit` 字段对应。

### 3. F-Droid 元数据验证

```bash
# 安装 fdroidserver（需要 Python 3）
pip install fdroidserver

# 验证元数据语法
fdroid readmeta fdroid/com.yosvu.ledgerlearn.ledgerlearn.yml
```

### 4. 提交到 fdroiddata

1. Fork [fdroiddata](https://gitlab.com/fdroid/fdroiddata)
2. 将 `fdroid/com.yosvu.ledgerlearn.ledgerlearn.yml` 复制到 `metadata/` 目录
3. 创建 Merge Request

详细的 F-Droid 提交流程参见：[F-Droid Submission Guide](https://f-droid.org/en/docs/Submitting_to_F-Droid_Quick_Start_Guide/)

## 翻译文件生成

构建前确保翻译文件是最新的：

```bash
# 如果参与了 Crowdin 翻译项目
crowdin pull                        # 拉取最新翻译
dart run scripts/gen_i18n.dart      # 生成 Dart 翻译文件

# 检查生成结果
flutter analyze
```

## 代码质量

```bash
# 静态分析
flutter analyze

# 格式化
dart format lib/

# 运行测试
flutter test
```

## CI/CD 建议

### GitHub Actions 最小配置

```yaml
name: Build APK
on:
  push:
    tags: ['v*']
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: beta
      - run: flutter pub get
      - run: flutter build apk --release --split-per-abi
      - uses: softprops/action-gh-release@v1
        with:
          files: build/app/outputs/flutter-apk/*.apk
```

## 常见问题

**Q: `flutter build apk` 报签名错误？**
A: 检查 `android/key.properties` 是否存在且路径正确。如果没有该文件，会使用 debug 签名构建（仅供本地测试）。

**Q: F-Droid 构建失败？**
A: 常见原因：(1) 依赖有网络访问 (2) Gradle 版本不兼容 (3) `pubspec.lock` 未提交到仓库。确保 `pubspec.lock` 已提交，所有依赖均来自 pub.dev 或已镜像。

**Q: 构建产物体积过大？**
A: 使用 `--split-per-abi` 分 ABI 构建，单个 APK 约 20-30 MB。字体文件是体积最大的资源。
