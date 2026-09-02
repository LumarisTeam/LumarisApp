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

### 上传到服务器

先构建产物，再设置目标地址。默认使用 `scp`，也支持 `rsync` 或 HTTP PUT（`curl`）：

```bash
RELEASE_SERVER_URL='user@example.com:/srv/releases/ios-club' \
  scripts/release.sh upload-server

RELEASE_SERVER_METHOD=curl \
RELEASE_SERVER_URL='https://upload.example.com/releases' \
RELEASE_SERVER_TOKEN="$UPLOAD_TOKEN" \
  scripts/release.sh upload-server
```

### 上传到 App Store Connect

需要在 App Store Connect 创建 API Key，并准备 `.p8` 文件。脚本通过临时目录让 `xcrun altool` 找到密钥，不会复制或提交密钥到仓库：

```bash
RELEASE_SERVER_URL='user@example.com:/srv/releases/ios-club' \
ASC_API_KEY_ID='ABC1234567' \
ASC_ISSUER_ID='YOUR_ISSUER_UUID' \
ASC_API_KEY_PATH="$HOME/keys/AuthKey_ABC1234567.p8" \
  scripts/release.sh release ios
```

`release ios` 会构建 IPA、上传服务器（需同时设置 `RELEASE_SERVER_URL`），然后上传 App Store Connect。若只上传已有 IPA，使用 `scripts/release.sh upload-asc`。整个流程可先加 `--dry-run` 检查命令而不执行。

## 贡献指南

欢迎贡献代码和报告问题。请遵循以下步骤：

1. Fork 仓库。
2. 创建新分支。
3. 提交你的更改。
4. 创建 Pull Request。

## 许可证

本项目采用 MIT 许可证。详情请查看 [LICENSE](LICENSE) 文件。
