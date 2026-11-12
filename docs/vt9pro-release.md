# Publishing the VT9PRO edition · 发布 VT9PRO 版

The release channel is for the Rapoo VT9PRO receiver `24AE:185A`. Other builds use `./scripts/dmg.sh` with their own profile. 此渠道仅适用于这只接收器；其他型号按 README 的升级提示词同步源码。

1. Increase both version fields in `Info.plist`. Sparkle compares the integer `CFBundleVersion`. 每次发布都要递增构建号。
2. On the signing Mac, build the release and sign the exact DMG and feed. 使用钥匙串账户 `capton586.mouse-battery-bar.vt9pro`，私钥保存在本机。

   ```sh
   MOUSE_CHANNEL=vt9pro ./scripts/dmg.sh
   ./scripts/sign-vt9pro.sh
   cp build/vt9pro/vt9pro.xml updates/vt9pro.xml
   ```

3. Commit the code and signed feed together. Tag that commit as `v<version>` and push the tag. Create its GitHub Release and upload the same signed DMG. Publish the release, then push the commit to `main` to activate the new feed. 先上传并发布已经签名的安装包，再推送 main，让应用查到的新版本始终可下载。
4. Check for updates from the previous installed VT9PRO edition. Confirm the version, receiver battery reading and saved preferences. 从上一版安装的应用检查更新，核对版本、电量和偏好设置。

Edits to the DMG or feed require a new signature. Keep a secure backup of the signing key under the maintainer's control. 修改安装包或更新清单后都需要重新签名。新渠道应使用自己的密钥和更新地址。
