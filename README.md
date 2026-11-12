# Mouse Battery Bar

把无线鼠标的剩余电量放进 macOS 菜单栏。一份构建只服务一只鼠标。随仓库提供的实例在雷柏 VT9PRO 的 USB 接收器（`24AE:185A`）上实测过；其他型号可以让 AI 替换设备读取代码，沿用菜单栏和采样逻辑。

## 构建并读取

需要 macOS 13 或更高版本，以及 Apple Command Line Tools（首次可运行 `xcode-select --install`）。无需 Homebrew 或第三方库。

```sh
./scripts/build.sh
"build/Mouse Battery Bar.app/Contents/MacOS/MouseBatteryBar" --print
open "build/Mouse Battery Bar.app"
```

`--print` 从接收器读取一次新数据后退出。菜单栏默认每 5 分钟采一次，可切换为 10、15 或 30 分钟，也能立即刷新。鼠标休眠时可能需要移动一下。采样失败时菜单栏显示「—」，菜单内保留上次成功读数和时间。部分复合 USB 接收器在 macOS 中也被识别为键盘，需要在「系统设置 → 隐私与安全性 → 输入监控」允许应用并重启。终端和双击启动的应用可能需要各自授权。

## 让 AI 为你的鼠标构建

复制下面这段话给能读取本机硬件的 AI 编程工具，再补上鼠标底部型号和连接方式：

> 在我这台 Mac 上，参考这个仓库，为我的「品牌／完整型号／蓝牙或 USB 接收器」制作菜单栏电量应用。请按 docs/adapt.md 识别真实设备，先验证一次电量，再修改 src/MouseProfile.m，只支持我正在用的鼠标。保留上次读数时间、休眠提示和 5 分钟采样。给我可运行的 .app、源码、构建命令和实机结果；缺少可靠读数时说明卡在哪一步。

[设备适配与验收](docs/adapt.md) · [MIT 许可证](LICENSE)
