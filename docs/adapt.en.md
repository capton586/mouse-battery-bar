# Adapt the reader to one mouse

1. Identify the exact model, connection type and firmware version if available. Check whether macOS already exposes a battery value for that device. Bluetooth, wired USB and receiver mode can expose different identifiers and protocols.
2. For a USB receiver, run `hidutil list` and note the vendor ID, product ID and interface usage. Several interfaces can share a name. Use the HID descriptor or model-specific protocol documentation to find the battery report. Verify that the reading belongs to the mouse rather than a keyboard, headset or the Mac.
3. Implement `MouseName` and `ReadBattery` in `src/MouseProfile.m`. On success, return nil and set `MouseReading.percent` to the newly reported percentage. Set `dpi` to zero when unavailable. On failure, return a message explaining why. Check report identity, length and range. Only display 0% when the device actually reports zero.
4. Give your build its own `CFBundleIdentifier` in `Info.plist`. Build with `./scripts/build.sh` and run the executable with `--print`. Compare several fresh samples with a trusted reference. A receiver light can corroborate a range. Check sleep, disconnect, reconnect and recovery, then run scripts/dmg.sh and deliver the .app and .dmg. Install from the DMG into Applications and launch that copy. Verify a new reading time in the menu and test the refresh action.
5. If you add DPI, USB polling rate or button configuration, verify the relevant fields for that hardware and firmware. Before adding writes, record the original setting and verify that it can be restored. Battery sampling interval (minutes), USB polling rate (Hz) and sensor DPI are separate settings.

## Verified example

On the Rapoo VT9PRO receiver `24ae:185a`, the vendor report shares an HID interface with a keyboard collection. The reader opens it in shared mode and listens for input report `0xBB`. In the sample `BB B0 42 00 19 01 35`, the last byte encodes 53%, and bytes 3 and 4 (zero-based, including the report ID) encode 6400 DPI in little-endian order. macOS can pass the report ID separately or include it in the buffer. Each sample waits up to 14 seconds for a fresh report and then releases the interface.

The field layout is also described in [Device Battery Tray’s read_rapoo implementation](https://github.com/Tsifrokayf/Device-Battery-Tray/blob/main/lamzu_tray.py).
