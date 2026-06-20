>[!NOTE]
>### Notable Modifications
>- APK files now include their version in the filename with dedicated releases for each app with the latest version and a archive release
>- Added custom manifest patches.
>- Added local Windows and Android support.
>- Added support for chaining patches (required for Piko).
>- Added root module support

---
## ⚙️ How does this repository work?
Simply, all you need to do is choose the app you want to use  below. Then, it will take you to corresponding release of that app. Just download it.
>[!Note]
>For old versions of apps use [below](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/all)


>[!Tip]
**For obtainium:**
>1. Put the repository link `https://github.com/sharath-5br2r/patched-apks-builder` under **App source URL**
>2. Go to corresponding release and copy part of  name  and paste it into **Filter release titles by regular expression** 
>3. Enable **Use latest asset upload as release date** and **Use release date as version string (pseudo-version)**

> [!NOTE]
>
> If you are an advanced user and want to use custom patches for patching ReVanced apps, read the [Customization Guide](../main/docs/Customization.md).
>
> To run the project locally, see the [Local Guide](../main/docs/Local.md).
>
> To see what to do after forking the repository, refer to the [GitHub Actions Guide](../main/docs/Github-Actions.md).
> 

---

>[!Important]
> All the patching code is open source, and the APK files used for patching are downloaded from trusted sources, so it is safe to use.
>
> License owned by creator. If you like any modded app, please support the original author.
>
> If errors arise in apps try contacting the source patches repo(execpt for custom patches, which use at your own risk)
>
>If you want to use the YouTube or YouTube Music app, you need to download and install [MicroG RE](https://github.com/MorpheApp/MicroG-RE) if unrooted.


---

## Based on

<https://github.com/FiorenMas/Revanced-And-Revanced-Extended-Non-Root> for ReVanced, but slightly modified and specialized.

---
## Patched Apps

- [**Morphe (beta)**](https://github.com/MorpheApp/morphe-patches) — [GPL-3.0](https://github.com/MorpheApp/morphe-patches/blob/main/LICENSE)
  - [YouTube](https://play.google.com/store/apps/details?id=com.google.android.youtube)(universal) – [Download Patched](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/youtube-morphe) (root module and apks)
  - [YouTube Music](https://play.google.com/store/apps/details?id=com.google.android.apps.youtube.music)(x86_64 and arm64) – [Download Patched](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/youtube-music-morphe)  (root module and apks)

- [**Piko**](https://github.com/crimera/piko) — [GPL-3.0](https://github.com/crimera/piko/blob/main/LICENSE) by crimera
  - [X](https://play.google.com/store/apps/details?id=com.twitter.android)(universal) – [Download Patched](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/x-piko) 
    - [X Shim](https://gitlab.com/inotia00/x-shim/) — [GPL-3.0](https://gitlab.com/inotia00/x-shim/-/blob/main/LICENSE) by inotia00 also applied
  - [Instagram](https://play.google.com/store/apps/details?id=com.instagram.android)(x86_64 and arm64) – [Download Patched](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/instagram-piko)

- [**hoo-dles**](https://github.com/hoo-dles/morphe-patches)— [GPL-3.0](https://github.com/hoo-dles/morphe-patches/blob/main/LICENSE)
  - [Prime Video](https://play.google.com/store/apps/details?id=com.amazon.avod.thirdpartyclient) (arm64 only)– [Download Patched](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/prime-video-hoo-dles)
    - [Amazon India](https://play.google.com/store/apps/details?id=in.amazon.mShop.android.shopping) (armv7a+arm64) (signed for compatibility) – [Download Signed](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/amazon-india)
    - [Amazon Alexa](https://play.google.com/store/apps/details?id=com.amazon.dee.app) (universal) (signed for compatibility) – [Download Signed](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/amazon-alexa)

- [**Paresh**](https://gitlab.com/Paresh-Maheshwari/paresh-patches) — [GPL-3.0](https://gitlab.com/Paresh-Maheshwari/paresh-patches/-/blob/main/LICENSE)
  - Proton VPN (universal)
    - Original [Play Store](https://play.google.com/store/apps/details?id=ch.protonvpn.android) [F-Droid](https://f-droid.org/en/packages/ch.protonvpn.android/) [GitHub](https://github.com/ProtonVPN/android-app) – [GPL-3.0](https://github.com/ProtonVPN/android-app/blob/master/LICENSE)
    - [Download Patched](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/protonvpn-paresh)
  - [JioHotstar](https://play.google.com/store/apps/details?id=in.startv.hotstar) (Indian OTT platform) (universal)– [Download Patched](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/jiohotstar-paresh)


### Custom patches

- [Eden Nightly] (Switch Emulator) (PUBG spoof) (arm64 standard)
  - Original [Homepage](https://eden-emu.dev) [Nightly](https://git.eden-emu.dev/eden-ci/nightly/releases)— [GPL-3.0](https://git.eden-emu.dev/eden-emu/eden/src/branch/master/LICENSE.txt
  - [Download Patched](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/eden-pubg)

- Dolphin Emulator (Wii/GameCube Emulator) (arm64+x86_64) (SDK 29, no scoped storage)
  - [Original](https://dolphin-emu.org/download) [Play Store](https://play.google.com/store/apps/details?id=org.dolphinemu.dolphinemu) — [GPL-2.0+ mostly](https://github.com/dolphin-emu/dolphin/blob/master/COPYING)
  - [Download Patched](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/dolphin-sdk-29)

- Fold Craft Launcher (universal) (Minecraft Java Launcher) (CoD spoof)
  - [Original](https://github.com/FCL-Team/FoldCraftLauncher) — [GPL-3.0](https://github.com/FCL-Team/FoldCraftLauncher/blob/main/LICENSE)
  - [Download Patched](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/fcl-cod)

- Geode (Geometry Dash mods) (PUBG KR spoof) (arm64 only)
  - [Original](https://github.com/geode-sdk/android-launcher) — [Boost-1.0](https://github.com/geode-sdk/android-launcher/blob/main/LICENSE.txt)
  - [Download Patched](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/geode-pubgkr)

- Winlator CMOD/Ludashi (Windows Emulator) (PUBG VN spoof) (arm64 only)
  - [Original](https://github.com/StevenMXZ/Winlator-Ludashi) — [MIT](https://github.com/StevenMXZ/Winlator-Ludashi/blob/ludashi-3.0/LICENSE)
  - [Download Patched](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/winlator-pubgvn)

### Xposed patches

- [Discord](https://play.google.com/store/apps/details?id=com.discord) (Revenge) (likely arm64 only)
  - [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/discord-revenge)

## See also

- [LeviLaunchroid Crack + BGMI Spoof](https://github.com/sharath-r7q4/LeviLaunchroid) (Mobile MC Bedrock launcher, get your own MC APK) (arm64 only) — [Apache-2.0](https://github.com/sharath-r7q4/LeviLaunchroid/blob/main/LICENSE)
---
## Libraries/Tools

- **Morphe**
  - [CLI](https://github.com/MorpheApp/morphe-cli) — [GPL-3.0](https://github.com/MorpheApp/morphe-cli/blob/main/LICENSE)
  - [MicroG RE](https://github.com/MorpheApp/MicroG-RE) — [Apache-2.0](https://github.com/MorpheApp/MicroG-RE/blob/main/LICENSE)

- [pup](https://github.com/ericchiang/pup) — [MIT](https://github.com/ericchiang/pup/blob/master/LICENSE)

- [APKEditor](https://github.com/REAndroid/APKEditor) — [Apache-2.0](https://github.com/REAndroid/APKEditor/blob/master/LICENSE)

- [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr) — [MIT](https://github.com/FlareSolverr/FlareSolverr/blob/master/LICENSE)

- [tdl](https://github.com/iyear/tdl) — [AGPL-3.0](https://github.com/iyear/tdl/blob/master/LICENSE)

- [NPatch](https://github.com/7723mod/NPatch) — [GPL-3.0](https://github.com/7723mod/NPatch/blob/main/LICENSE) (for Xposed)

- **Revenge**
  - Code inspired by [Manager](https://github.com/revenge-mod/revenge-manager) — [OSL-3.0](https://github.com/revenge-mod/revenge-manager/blob/main/LICENSE)
  - Actual module: [Xposed](https://github.com/revenge-mod/revenge-xposed) — [OSL-3.0](https://github.com/revenge-mod/revenge-manager/blob/main/LICENSE)

- **j-hc**  [revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module) — [GPL-3.0](https://github.com/j-hc/revanced-magisk-module/blob/main/LICENSE) (taken only module code, available as submodule)

- **0xBadCod3** [Morphe-RVX-NR](https://github.com/0xBadCod3/Morphe-RVX-NR)  — [GPL-3.0](https://github.com/0xBadCod3/Morphe-RVX-NR/blob/main/LICENSE) (inspiration for obtainum compatiblity, also took code for auto update from upstream)

## Inspired by

- [@luxysiv](https://github.com/luxysiv/yt-revanced-nonroot) — [GPL-3.0](https://github.com/luxysiv/revanced-nonroot/blob/main/LICENSE)

- [revanced-build-template](https://github.com/n0k0m3/revanced-build-template) — [GPL-3.0](https://github.com/n0k0m3/revanced-build-template/blob/main/LICENSE)

- [revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module) — [GPL-3.0](https://github.com/j-hc/revanced-magisk-module/blob/main/LICENSE) (CI code,previously based on this repository, now archived)
