# 光序

这是一个基于 Flutter 的跨平台移动应用程序，旨在提供课程信息、日程安排、成绩查询、校园服务等功能。

## 主要功能

- **课程管理**：展示课程列表，包括课程名称、时间、地点等信息。
- **日程安排**：提供日程设置和展示功能。
- **考试信息**：显示考试安排。
- **待办事项**：管理日常任务。
- **成绩查询**：查看个人成绩。
- **校园巴士信息**：提供校园巴士时刻表。
- **个人资料页面**：展示用户个人信息。
- **链接页面**：提供有用的外部链接。
- **其他功能**：包括电力图表、通知服务等。

## Android 特定功能

- **TodayCoursesWidgetProvider**：提供了一个 AppWidget，用于在 Android 桌面上显示当天的课程。
- **CourseListRemoteViewsService** 和 **CourseListRemoteViewsFactory**：支持 AppWidget 的远程视图服务和数据绑定。
- **暗色主题支持**：所有Android组件均支持暗色主题，能够根据系统设置自动适配亮色和暗色主题。

## 开发环境

- Flutter SDK
- Android Studio / Xcode（根据目标平台）
- Git

## 安装步骤

1. 确保你已经安装了 [Flutter SDK](https://flutter.dev/docs/get-started/install)。
2. 克隆仓库：
   ```bash
   git clone https://gitee.com/luckyfishisdashen/iOSClub.AppMobile.git
   ```
3. 进入项目目录：
   ```bash
   cd iOSClub.AppMobile
   ```
4. 获取依赖：
   ```bash
   flutter pub get
   ```
5. 运行应用：
   ```bash
   flutter run
   ```

## env注意

```env
# 可选值: 
# - gitee (默认，使用Gitee发行版更新)
# - appstore (应用商店版本，不检查更新)
UPDATE_CHANNEL=gitee
```

## 打包与发布

1. Windows (msix):

   ```bash
   dart run msix:create --store
   ```

2. Android (apk):
   ```bash
   flutter build apk --obfuscate --split-debug-info=xx --no-tree-shake-icons --target-platform android-arm64 --split-per-abi
   ```
   
可以加入 `--dart-define=UPDATE_CHANNEL=appstore` 来表明使用应用商店版本
   
3. Android (aab):
   ```bash
   flutter build appbundle --obfuscate --split-debug-info=xx --no-tree-shake-icons --target-platform android-arm64
   ```

4. Web (wasm):

   ```bash
   flutter build web --no-tree-shake-icons --wasm
   ```

5. macOS

   ```bash
   flutter build macos --no-tree-shake-icons --release
   ```
   
6. iOS (ipa):
   ```bash
   flutter build ipa --no-tree-shake-icons
   ```

7. Linux
   ```bash
   flutter build linux
   ```


统一入口是 `scripts/release.sh`。脚本会先执行 `flutter clean` 和 `flutter pub get`，再把产物复制到 `dist/`（可用 `--skip-clean` 跳过清理）。

```bash
# 查看帮助
scripts/release.sh --help

# 构建单个平台，或构建当前主机支持的全部平台
scripts/release.sh build android-apk
scripts/release.sh build android-aab --channel appstore
scripts/release.sh build all --output-dir ./dist
```

支持的目标：`android-apk`、`android-aab`、`ios`、`macos`、`windows`、`linux`、`web` 和 `all`。`all` 会构建 Android、Web 以及当前主机的原生平台；iOS/macOS 需要 macOS + Xcode，Windows/Linux 需要对应操作系统。Windows 目标会在 `flutter build windows` 后运行 `msix:create --store`，Web 目标生成 WASM 压缩包。

`release <target>` 会构建后按渠道分派：`android-apk` 传自建平台，`ios` / `macos` 传 App Store Connect，其余目标只构建不上传。

### 上传到服务器

产物上传到自建发布平台：先登录换 token，再创建 Release，最后逐个上传文件。默认只上传 Android APK——App 内更新下载的就是 APK，AAB 只发 Google Play，Apple 的 `.ipa` / `.pkg` 只走 App Store Connect。需要的环境变量：

| 变量 | 说明 |
| --- | --- |
| `RELEASE_SERVER_API` | API 根地址，默认 `http://localhost:5046` |
| `RELEASE_SERVER_USERNAME` / `RELEASE_SERVER_PASSWORD` | 平台登录账号 |
| `RELEASE_APP_ID` | 应用 id，取自 `GET /api/App` |
| `RELEASE_CHANNEL_ID` | 渠道 id，取自 `GET /api/Channel` |
| `RELEASE_ID` | 展示给用户的版本号，默认取 `pubspec.yaml` 里的 version |
| `RELEASE_NAME` | Release 名称，默认为 `RELEASE_ID` |
| `RELEASE_DESCRIPTION` | Release 说明，可留空 |
| `RELEASE_UPLOAD_NAME_PREFIX` | 上传文件名的前缀，默认 `Downloader` |
| `RELEASE_UPLOAD_PATTERNS` | 上传哪些产物，空格分隔的 glob，默认 `*.apk`；填 `'*'` 可恢复成上传 `dist/` 里的全部文件 |

```bash
RELEASE_SERVER_API='https://example.com' \
RELEASE_SERVER_USERNAME='root' \
RELEASE_SERVER_PASSWORD='***' \
RELEASE_APP_ID='...' \
RELEASE_CHANNEL_ID='...' \
  scripts/release.sh upload-server --output-dir ./dist
```

上传依赖 `curl` 和 `jq`。每次执行都会在平台上新建一条 Release，重复执行会产生重复记录。

### 上传到 App Store Connect

需要在 App Store Connect 创建 API Key，并准备 `.p8` 文件。脚本通过临时目录让 `xcrun altool` 找到密钥，不会复制或提交密钥到仓库：

```bash
ASC_API_KEY_ID='ABC1234567' \
ASC_ISSUER_ID='YOUR_ISSUER_UUID' \
ASC_API_KEY_PATH="$HOME/keys/AuthKey_ABC1234567.p8" \
  scripts/release.sh release ios
```

`release ios` 会构建 IPA 后直接上传 App Store Connect，不经过自建平台。`release macos` 同理，但必须加 `--asc-cloud-signing`——不加时产物是 `.app` 打的 `.zip`，没有可上传的 `.pkg`，脚本会直接报错。整个流程可先加 `--dry-run` 检查命令而不执行。

只上传已有产物时用 `upload-asc`，它按目标挑选文件并决定 altool 的 `--type`：

| 目标 | 上传的文件 | `altool --type` |
| --- | --- | --- |
| `ios`（默认） | `dist/*.ipa` | `ios` |
| `macos` | `dist/*.pkg` | `osx` |

macOS 上架 App Store 必须先打成 `.pkg`（App Store 导出产物），`flutter build macos` 直接产出的 `.app` 不能提交。

```bash
ASC_API_KEY_ID='ABC1234567' ASC_ISSUER_ID='YOUR_ISSUER_UUID' \
ASC_API_KEY_PATH="$HOME/keys/AuthKey_ABC1234567.p8" \
  scripts/release.sh upload-asc macos --output-dir ./dist
```

#### 先验证 API Key

拿到 Key ID 和 Issuer ID 不等于能用：真正决定成败的是三者是否配对，以及 Key 的角色够不够云端签名。`scripts/verify_asc_key.sh` 直接用 `.p8` 签一个 ES256 JWT 去问 App Store Connect，除了 `openssl` / `curl` / `jq` 不需要额外工具：

```bash
ASC_API_KEY_ID='ABC1234567' \
ASC_ISSUER_ID='YOUR_ISSUER_UUID' \
ASC_API_KEY_PATH="$HOME/keys/AuthKey_ABC1234567.p8" \
  scripts/verify_asc_key.sh com.example.iosClubApp
```

它依次报告三件事，任一项预示失败就以非零码退出：

1. **认证**：Key ID / Issuer ID / `.p8` 是否配对（`401` 即三者不匹配）
2. **签名资源权限**：能否读取证书与描述文件。`403` 可以确定角色不足；但反过来读取成功不代表够用——Developer 角色同样能读，创建描述文件的权限无法在不产生副作用的前提下探测，所以 Key 的角色请直接在 ASC 的 Integrations 页面核对（角色在创建 Key 时选定且不可修改，是 Developer 就得吊销重建）
3. **app 记录**：传入 bundle id 时检查 ASC 里是否存在对应记录，缺失则上传会被拒

在 CI 里 `build-apple` 也会先跑同一个脚本（不传 bundle id，避免 app 记录变更时误伤发布），这样 Key 失效时几秒就报错，而不是等十几分钟的 macOS 构建跑完才失败。注意脚本只能预测，不能替代真跑一次：云端签名是否真能签下来，只有 `xcodebuild archive` 走完才算数。

#### CI 上的云端签名

CI 里没有本机的证书和描述文件，用 `--asc-cloud-signing` 让 Xcode 通过 API Key 向 App Store Connect 申请：脚本执行 `flutter build <target> --config-only` 之后直接调 `xcodebuild archive` 和 `-exportArchive`，并带上 `-allowProvisioningUpdates -authenticationKeyPath/-ID/-IssuerID`。`flutter build ipa` 传不了这些参数（`FLUTTER_XCODE_` 前缀只能映射成 build settings，不是命令行 flag），所以这条路绕开了它。

```bash
ASC_API_KEY_ID='ABC1234567' ASC_ISSUER_ID='YOUR_ISSUER_UUID' \
ASC_API_KEY_PATH="$HOME/keys/AuthKey_ABC1234567.p8" \
  scripts/release.sh build ios --asc-cloud-signing --channel appstore
ASC_API_KEY_ID='ABC1234567' ASC_ISSUER_ID='YOUR_ISSUER_UUID' \
ASC_API_KEY_PATH="$HOME/keys/AuthKey_ABC1234567.p8" \
  scripts/release.sh upload-asc ios
```

前提：该 API Key 是 Team Key 且角色为 Admin 或 App Manager。签名用的团队 id 默认从 `*/Runner.xcodeproj/project.pbxproj` 的 `DEVELOPMENT_TEAM` 读取，可用 `ASC_TEAM_ID` 覆盖。

### 推 tag 自动发布（GitHub Actions）

推送 tag（`1.2.1` 或 `v1.2.1`）时，`.github/workflows/release.yml` 会调用 `scripts/release.sh` 完成打包与发布：`prepare` 先解析 tag 并校验版本，随后 `build-android`、`build-linux`、`build-apple` 并行构建。Android 的 APK 汇总后上传自建平台并创建 GitHub Release，Linux 产物只挂 GitHub Release，Apple 则由 `build-apple` 直接上传 App Store Connect。

两条渠道相互独立：Apple 失败不会阻断 GitHub Release 与自建平台的发布，反之亦然——App Store 用户不该被 Android 的签名问题拖住，哪条红了看 job 名即可。Apple 用 `--channel appstore` 构建（App Store 版本关闭应用内更新检查），且不上传自建平台；自建平台也只收 Android APK，AAB 与 Linux 压缩包都不进（`RELEASE_UPLOAD_PATTERNS` 可调整）。

```bash
git tag -a 1.2.2 -m '修复若干已知问题'   # tag 说明会作为发布说明同步到平台和 GitHub
git push github 1.2.2
```

工作流只比较版本号里 `+` 之前的部分（`1.2.2` 对应 `1.2.2+2026090421`）。如果 tag 与 `pubspec.yaml` 的 `version` 不一致，会在任何上传发生之前直接失败——平台上的 `releaseId` 取自 tag、App 内上报的版本取自 `pubspec.yaml`，两者不一致会让更新检查失效。

构建产物：`app-arm64-v8a-release.apk`、`app-armeabi-v7a-release.apk`、`app-x86_64-release.apk`、`app-release.aab`、`ios_club_app-linux-x64.tar.gz`。挂到 GitHub Release 上时会加上版本号前缀（如 `ios_club_app-1.2.2-android-arm64-v8a.apk`），传给自建平台的仍是原始文件名（自建平台只收 APK）。Apple 的 `.ipa` / `.pkg` 只送 App Store Connect，不挂到 GitHub Release。

需要在仓库 Settings → Secrets and variables → Actions 中配置：

| Secret | 说明 |
| --- | --- |
| `RELEASE_SERVER_API` | 自建平台 API 根地址 |
| `RELEASE_SERVER_USERNAME` / `RELEASE_SERVER_PASSWORD` | 平台登录账号 |
| `RELEASE_APP_ID` | 应用 id |
| `RELEASE_CHANNEL_ID` | 渠道 id |
| `ANDROID_KEYSTORE_BASE64` | `android/keys/upload-keystore.jks` 的 base64 |
| `ANDROID_KEYSTORE_PASSWORD` | 密钥库密码（`storePassword`） |
| `ANDROID_KEY_ALIAS` | 密钥别名（`keyAlias`，如 `upload`） |
| `ANDROID_KEY_PASSWORD` | 密钥密码（`keyPassword`） |
| `ASC_API_KEY_ID` | App Store Connect API Key 的 Key ID |
| `ASC_ISSUER_ID` | App Store Connect 的 Issuer ID |
| `ASC_API_KEY_P8_BASE64` | `.p8` 私钥的 base64 |

生成密钥库的 base64（macOS 用 `base64 -i`，Linux 用 `base64 -w0`）：

```bash
base64 -i android/keys/upload-keystore.jks | tr -d '\n' | pbcopy
base64 -i "$HOME/keys/AuthKey_ABC1234567.p8" | tr -d '\n' | pbcopy
```

发布顺序是先上传自建平台、成功之后才创建 GitHub Release。平台上传失败时工作流会失败并且不会创建 Release，避免出现「GitHub 上能看到版本、App 内却检查不到更新」的状态。修复后在 Actions 页面 Re-run 即可；注意重跑会再建一条平台 Release 记录，如果上次已经建过需要先去平台删掉。

也可以手动触发：Actions → Release → Run workflow，但必须选中一个 tag，选分支会在发布前直接报错。

注意：上传到 App Store Connect 只是把构建送进 TestFlight/构建列表，**不会自动提交审核或发布**，这一步仍需在 App Store Connect 里手动完成。

## 贡献指南

欢迎贡献代码和报告问题。请遵循以下步骤：

1. Fork 仓库。
2. 创建新分支。
3. 提交你的更改。
4. 创建 Pull Request。

## 许可证

本项目采用 MIT 许可证。详情请查看 [LICENSE](LICENSE) 文件。
