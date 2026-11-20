# Igallta VPN

基于 [FlClash](https://github.com/chen08209/FlClash) / mihomo 的 Android 代理客户端，保留 FlClash 的订阅、节点、规则、TUN/VPN、DNS、日志等能力，并把界面改成 Igallta 紫色玻璃主题。

## 界面

- 固定展开的 Igallta 侧边栏：首页、规则、订阅、配置、设置、关于
- 角色立绘 Hero、电源环、延迟与实时上下行
- 代理模式、流量统计、可搜索的节点列表、运行日志
- 节点列表使用真实 mihomo 代理组：点击切换节点，刷新按钮测延迟，搜索按节点名过滤
- 今日 / 本月 / 总流量由 Core 的累计流量增量持久化统计

## 云编译

GitHub Actions 工作流：`.github/workflows/android.yml`

每次手动运行（Actions → Build Igallta VPN APK → Run workflow）或推送 `v*` 标签时，会并行构建：

- `arm64-v8a`：真机 / 平板
- `x86_64`：模拟器

构建产物在对应 run 的 Artifacts 中，文件名分别为 `Igallta-VPN-arm64-v8a.apk` 和 `Igallta-VPN-x86_64.apk`，均由 release keystore 签名。

### 必需的 Repository secrets

| Secret | 内容 |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | `keystore.jks` 的 Base64（`base64 -w0 keystore.jks`） |
| `ANDROID_STORE_PASSWORD` | keystore 口令 |
| `ANDROID_KEY_ALIAS` | `igallta` |
| `ANDROID_KEY_PASSWORD` | key 口令 |

工作流会校验 keystore 存在，缺少 secrets 时直接失败，避免产出 debug 签名或 `.dev` 包名。

### 工具链

工作流固定使用 Flutter `3.47.6`、Go（读取 `core/go.mod`）、Rust `1.99.0`（含 `aarch64-linux-android` / `x86_64-linux-android` target）、Android SDK 37 与 NDK `28.2.13676358`。

## 本地构建

```bash
flutter pub get
flutter build apk --release --target-platform android-arm64 --no-pub
flutter build apk --release --target-platform android-x64 --no-pub
```

Android 签名参数放在 `android/local.properties`，keystore 放在 `android/app/keystore.jks`；这两个文件已被 `.gitignore` 排除。

## 许可与归属

本项目是 FlClash 的衍生作品，遵循上游 **GPL-3.0** 许可证，详见 `LICENSE`。mihomo、FlClash、prism_ui 及角色素材的版权归各自权利人所有。发布衍生 APK 时必须同时提供对应源代码。
