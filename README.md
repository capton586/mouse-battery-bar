# Mouse Battery Bar

**简体中文** · [English](README.en.md)

为自己的无线鼠标做一个轻量的 **macOS 菜单栏电量应用**。它通过 macOS 自带的接口读取鼠标上报的电量，无需安装厂商驱动。把下面的提示词交给能在你 Mac 上运行命令的 AI，就可以从识别设备开始，为你的型号构建应用。

默认每 5 分钟读取一次，读完就释放接收器，屏幕休眠时暂停定时采样。本地适配版只依赖系统框架。发布的 VT9PRO 版额外包含 Sparkle，用于在应用内更新。

![Mouse Battery Bar · VT9PRO](docs/images/menu-preview.png)

VT9PRO 菜单示例，使用实机记录的 53% 电量报告。

## 复制给 AI

把方括号里的内容换成自己的设备信息。如果不清楚型号，可以写「未知」，让 AI 先检查连接的设备。

```text
请使用 GitHub 模板 capton586/mouse-battery-bar
https://github.com/capton586/mouse-battery-bar
在我的 Mac 上为 [品牌和完整型号]（[蓝牙 / USB 接收器 / 未知]）构建菜单栏电量应用。

请先打开或克隆上述仓库，阅读 docs/adapt.md，识别我的鼠标并取得一次可确认属于它的真实电量。
只适配这只鼠标，使用 macOS 原生接口，无需厂商驱动。将型号相关逻辑放进 src/MouseProfile.m，
保留默认 5 分钟采样和上次成功读取的时间。请运行 scripts/dmg.sh 构建 .app，并将同一份 .app 打包为个人 .dmg。交付两者、源码和复现命令。
请从 .dmg 将应用安装到「应用程序」，从那里启动，在菜单栏确认一次真实电量并记录结果。
若设备没有上报可验证的电量，请说明卡在哪一步。
```

## 构建与使用

需要 macOS 13 或更高版本，以及 Apple Command Line Tools（可用 `xcode-select --install` 安装）。在仓库目录执行：

```sh
./scripts/dmg.sh
```

脚本在 `build/` 中生成 **Mouse Battery Bar.app** 和包含它的 **MouseBatteryBar-版本号.dmg**。打开 DMG，将应用拖入「应用程序」，推出 DMG，再从「应用程序」启动。点鼠标图标的「立即刷新」，确认菜单里出现电量和新的读取时间。

若提示权限不足，在「系统设置 → 隐私与安全性 → 输入监控」允许刚安装的 **Mouse Battery Bar**，按提示退出并重新打开。此前给终端或旧版应用的授权可能不适用于安装版。若提示安全输入正在使用，完成密码输入、离开密码框，再移动鼠标并刷新。采样失败时，菜单栏继续显示上次成功读取的百分比，重启应用也能保留。点开菜单可查看读数时间和本次失败原因。首次成功采样前显示「—」。

调试时，可执行 `"/Applications/Mouse Battery Bar.app/Contents/MacOS/MouseBatteryBar" --print` 读取一次电量。`--status` 还会显示设备提供的 DPI。安装验收以菜单栏里实际显示的新读数为准。

## 示例与发布

仓库内置的读取器已在雷柏 VT9PRO 的 USB 接收器（`24AE:185A`）上验证。其他鼠标需要先确认自己的电量来源。[GitHub Releases](https://github.com/capton586/mouse-battery-bar/releases) 同时提供模板源码和标有型号的 `MouseBatteryBar-VT9PRO-版本号.dmg`。接收器匹配的用户首次安装这个 DMG 后，可在鼠标菜单里点 **检查更新…**。应用运行时默认约每天自动检查一次，可分别开关自动检查和自动下载。Sparkle 会验证签名并处理安装与重启。自己适配的型号可以用下面的提示词升级。

## 让 AI 更新已有的个人版本

```text
请用 capton586/mouse-battery-bar 的最新稳定发行版升级我已有的 macOS 鼠标电量应用。
上游仓库 https://github.com/capton586/mouse-battery-bar
我的本地项目是 [路径或 fork 地址]，鼠标是 [完整型号和连接方式]。
请确认当前基于哪个上游版本，获取最新稳定版，说明从哪个版本升级到哪个版本。
合并适用的改动，保留我的本地修改、src/MouseProfile.m、bundle ID、偏好设置和已有更新渠道。
仅上游发布的 VT9PRO 专版使用其更新源。请按我的型号运行 scripts/dmg.sh，交付更新后的 .app
和包含同一份应用的个人 .dmg。从 DMG 安装并从「应用程序」启动，验证一次真实电量和读数时间。
如果采样失败，验证菜单栏仍显示上次成功的电量、时间没有被刷新。反馈上游标签、产物路径和验证结果。
```

[维护者发布 VT9PRO 签名更新的步骤](docs/vt9pro-release.md)

[使用此模板创建仓库](https://github.com/capton586/mouse-battery-bar/generate) · [适配指南](docs/adapt.md) · [进阶功能与验证进度](docs/roadmap.md) · [MIT 许可证](LICENSE)
