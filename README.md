# Mouse Battery Bar

**简体中文** · [English](README.en.md)

为自己的无线鼠标做一个轻量的 **macOS 菜单栏电量应用**。它通过 macOS 自带的接口读取鼠标上报的电量，无需安装厂商驱动。把下面的提示词交给能在你 Mac 上运行命令的 AI，就可以从识别设备开始，为你的型号构建应用。

默认每 5 分钟读取一次，读完就释放接收器，屏幕休眠时暂停定时采样。应用使用系统原生框架，无第三方运行时或后台辅助进程。雷柏 VT9PRO 示例的双架构压缩安装包约 44 KiB，其他型号的大小取决于适配代码。

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
保留默认 5 分钟采样和上次成功读取的时间。请构建 .app、实机验证，并给我源码和复现命令。
若设备没有上报可验证的电量，请说明卡在哪一步。
```

## 构建与使用

需要 macOS 13 或更高版本，以及 Apple Command Line Tools（可用 `xcode-select --install` 安装）。在仓库目录执行：

```sh
./scripts/build.sh
"build/Mouse Battery Bar.app/Contents/MacOS/MouseBatteryBar" --print
open "build/Mouse Battery Bar.app"
```

`--print` 读取一次电量；`--status` 还会显示设备提供的 DPI。点击菜单栏的鼠标图标可以立即刷新、调整采样间隔或开启登录启动。采样失败时图标显示「—」，菜单内保留上次成功读数和时间。有些接收器也会被 macOS 识别为键盘，系统可能要求在「隐私与安全性 → 输入监控」中允许该应用并重启。

## 示例与发布

仓库内置的读取器已在雷柏 VT9PRO 的 USB 接收器（`24AE:185A`）上验证。其他鼠标需要先确认自己的电量来源。GitHub Releases 提供模板源码。完成适配后，运行 `./scripts/dmg.sh` 即可生成自己型号的 DMG。

[使用此模板创建仓库](https://github.com/capton586/mouse-battery-bar/generate) · [适配指南](docs/adapt.md) · [进阶功能与验证进度](docs/roadmap.md) · [MIT 许可证](LICENSE)
