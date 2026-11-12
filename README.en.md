# Mouse Battery Bar

[简体中文](README.md) · **English**

Build a lightweight **macOS menu bar battery indicator** for your own wireless mouse. It reads battery data through native macOS interfaces without installing the manufacturer's driver. Give the prompt below to a coding assistant that can run commands on your Mac to build an app for your model.

By default, the app samples every five minutes, releases the receiver after each reading, and pauses its timer while the display sleeps. It uses system frameworks with no third-party runtime or helper process. The compressed installer for the dual-architecture Rapoo VT9PRO example was about 44 KiB. Other profiles may differ in size.

![Mouse Battery Bar · VT9PRO](docs/images/menu-preview.png)

Example VT9PRO menu, rendered from a recorded 53% battery report.

## Copy this prompt into your AI assistant

Replace the bracketed text with your device details. If you're unsure, enter “unknown” and let the assistant identify the connected device.

```text
Use the GitHub template capton586/mouse-battery-bar
https://github.com/capton586/mouse-battery-bar
to build a macOS menu bar battery app for my [brand and full model] connected via [Bluetooth / USB receiver / unknown].

Open or clone that repository, read docs/adapt.en.md, identify my mouse, and verify one fresh battery
reading from that specific device. Build for this mouse using native macOS interfaces without a vendor driver.
Keep device-specific logic in src/MouseProfile.m, the five-minute default interval, and the time of the last
successful reading. Build the .app, test it on my hardware, and give me the source and reproducible commands.
If the mouse exposes no verifiable battery data, tell me where verification stopped.
```

## Build and run

On macOS 13 or later, install Apple's Command Line Tools (`xcode-select --install`) and run these commands from the repository directory.

```sh
./scripts/build.sh
"build/Mouse Battery Bar.app/Contents/MacOS/MouseBatteryBar" --print
open "build/Mouse Battery Bar.app"
```

`--print` reads the battery once. Use `--status` to include DPI when the device reports it. Click the mouse icon to refresh, change the sampling interval, or enable launch at login. After a failed sample, the menu bar shows a dash and the menu retains the last successful reading and its time. For receivers that also identify as keyboards, macOS may ask you to enable the app in **Privacy & Security → Input Monitoring** and relaunch it.

## Example and releases

The included reader has been tested with a Rapoo VT9PRO USB receiver (`24AE:185A`). Other mice need a verified source of battery data. GitHub Releases provides the template source. After testing your own reader, run `./scripts/dmg.sh` to package your app as a DMG.

[Use this template](https://github.com/capton586/mouse-battery-bar/generate) · [Adaptation guide](docs/adapt.en.md) · [MIT license](LICENSE)
