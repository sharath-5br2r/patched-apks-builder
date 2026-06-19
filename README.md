>[!NOTE]
>### Notable Modifications
>- Replaced the hardcoded keystore with a keystore stored in GitHub Secrets.
>- Moved patch configuration from separate files into a single file.
>- APK files now include their version in the filename.
>- Dedicated releases for each app with the latest version and a archive release
>- Added support for Archive.org APK repositories (currently unused).
>- Simplified the repository and reduced the number of supported apps.
>- Added custom manifest patches.
>- Added full Windows x64 and Linux ARM64 support, along with the existing Linux x64 support (requires MSYS2 on Windows and FlareSolverr) and Android ARM64 support.
>- Added support for chaining patches (required for Piko).
## ⚙️ How does this repository work?
Simply, all you need to do is choose the app you want to use  below. Then, it will take you to corresponding release of that app. Just download it.
>[!Note]
>For old versions of apps use [below](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/all)


>[!Note]
**For obtainium:**
>1. Put the repository link `https://github.com/sharath-5br2r/patched-apks-builder` under **App source URL**
>2. Go to corresponding release and copy part of  name  and paste it into **Filter release titles by regular expression** 
>3. Enable **Use latest asset upload as release date** and **Use release date as version string (pseudo-version)**

> [!NOTE]
> If you want to use the YouTube, YouTube Music, or Google Photos app, you need to download and install [MicroG RE](https://github.com/MorpheApp/MicroG-RE).
>
> If you are an advanced user and want to use custom patches for patching ReVanced apps, read the [Customization Guide](../main/docs/Customization.md).
>
> This repository is like any other patch repository. It does not create new releases; it only uploads new files to existing releases.
>
> All the code is open source, and the APK files used for patching are downloaded from trusted sources, so it is safe to use.
>
> To run the project locally, see the [Local Guide](../main/docs/Local.md).
>
> To see what to do after forking the repository, refer to the [GitHub Actions Guide](../main/docs/Github-Actions.md).

---

## Based on

<https://github.com/FiorenMas/Revanced-And-Revanced-Extended-Non-Root> for ReVanced, but slightly modified and specialized.

## Patched Apps

- **Morphe**
  - YouTube (universal) – [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/youtube-morphe)
  - YouTube Music (x86_64 and arm64) – [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/youtube-music-morphe)

- **Piko**
  - X (universal)– [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/x-piko)
  - Instagram (x86_64 and arm64) – [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/instagram-piko)

- **hoo-dles**
  - Prime Video (arm64 only)– [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/prime-video-hoo-dles)
    - Amazon India (armv7a+arm64) (signed for compatibility) – [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/amazon-india)
    - Amazon Alexa (universal) (signed for compatibility) – [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/amazon-alexa)

- **Paresh**
  - Proton VPN (universal) – [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/protonvpn-paresh)
  - JioHotstar (Indian OTT platform) (universal)– [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/jiohotstar-paresh)

- **binarymend**
  - Symfonium (music player) (**NOT FUNCTIONAL**)

### Custom patches

- Eden Nightly (Switch Emulator) (PUBG spoof) (arm64 standard)
  - [Original](https://eden-emu.dev)
  - [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/eden-pubg)

- Dolphin Emulator (Wii/GameCube Emulator) (arm64+x86_64) (SDK 29, no scoped storage)
  - [Original](https://dolphin-emu.org)
  - [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/dolphin-sdk-29)

- Fold Craft Launcher (universal) (Minecraft Java Launcher) (CoD spoof)
  - [Original](https://github.com/FCL-Team/FoldCraftLauncher)
  - [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/fcl-cod)

- Geode (Geometry Dash mods) (PUBG KR spoof) (arm64 only)
  - [Original](https://github.com/geode-sdk/android-launcher)
  - [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/geode-pubgkr)

- Winlator CMOD/Ludashi (Windows Emulator) (PUBG VN spoof) (arm64 only)
  - [Original](https://github.com/StevenMXZ/Winlator-Ludashi)
  - [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/winlator-pubgvn)

### Xposed patches

- Discord (Revenge) (likely arm64 only)
  - [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/discord-revenge)

## See also

- [LeviLaunchroid Crack + BGMI Spoof](https://github.com/sharath-r7q4/LeviLaunchroid) (Mobile MC Bedrock launcher, get your own MC APK) (arm64 only)
  - [Apache-2.0](https://github.com/sharath-r7q4/LeviLaunchroid/blob/main/LICENSE)

## Actively Used Libraries

- **Morphe**
  - [Patches](https://github.com/MorpheApp/morphe-patches) — [GPL-3.0](https://github.com/MorpheApp/morphe-patches/blob/main/LICENSE)
  - [CLI](https://github.com/MorpheApp/morphe-cli) — [GPL-3.0](https://github.com/MorpheApp/morphe-cli/blob/main/LICENSE)
  - [MicroG RE](https://github.com/MorpheApp/MicroG-RE) — [Apache-2.0](https://github.com/MorpheApp/MicroG-RE/blob/main/LICENSE)

- **crimera**
  - [Piko Patches](https://github.com/crimera/piko) — [GPL-3.0](https://github.com/crimera/piko/blob/main/LICENSE)

- **inotia00**
  - [Piko Shim](https://gitlab.com/inotia00/piko-shim/) — GPL-3.0

- **hoo-dles**
  - [Patches](https://github.com/hoo-dles/morphe-patches) — [GPL-3.0](https://github.com/hoo-dles/morphe-patches/blob/main/LICENSE)

- **Paresh-Maheshwari**
  - [Patches](https://gitlab.com/Paresh-Maheshwari/paresh-patches) — [GPL-3.0](https://gitlab.com/Paresh-Maheshwari/paresh-patches/-/blob/main/LICENSE)

- [pup](https://github.com/ericchiang/pup) — [MIT](https://github.com/ericchiang/pup/blob/master/LICENSE)

- [APKEditor](https://github.com/REAndroid/APKEditor) — [Apache-2.0](https://github.com/REAndroid/APKEditor/blob/master/LICENSE)

- [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr) — [MIT](https://github.com/FlareSolverr/FlareSolverr/blob/master/LICENSE)

- [tdl](https://github.com/iyear/tdl) — [AGPL-3.0](https://github.com/iyear/tdl/blob/master/LICENSE)

- [NPatch](https://github.com/7723mod/NPatch) — [GPL-3.0](https://github.com/7723mod/NPatch/blob/main/LICENSE) (for Xposed)

- **Revenge**
  - Code inspired by [Manager](https://github.com/revenge-mod/revenge-manager) — [OSL-3.0](https://github.com/revenge-mod/revenge-manager/blob/main/LICENSE)
  - Actual module: [Xposed](https://github.com/revenge-mod/revenge-xposed) — [OSL-3.0](https://github.com/revenge-mod/revenge-manager/blob/main/LICENSE)

### Dormant libraries/resources used in this repository

<details>
<summary>indrastorms</summary>

[Patches](https://github.com/indrastorms/Dropped-Patches) — [GPL-3.0](https://github.com/indrastorms/Dropped-Patches/blob/main/LICENSE)

</details>

<details>
<summary>Aunali321</summary>

[Patches](https://github.com/Aunali321/ReVancedExperiments) — [GPL-3.0](https://github.com/Aunali321/ReVancedExperiments/blob/main/LICENSE)

</details>

<details>
<summary>scrazzz</summary>

[Patches](https://github.com/scrazzz/my-revanced-patches) — [GPL-3.0](https://github.com/scrazzz/my-revanced-patches/blob/main/LICENSE)

</details>

<details>
<summary>RookieEnough</summary>

[Patches](https://github.com/RookieEnough/De-ReVanced) — [GPL-3.0](https://github.com/RookieEnough/De-ReVanced/blob/main/LICENSE)

</details>

<details>
<summary>gnadgnaoh</summary>

[Patches](https://github.com/gnadgnaoh/NexAlloy) — [GPL-3.0](https://github.com/gnadgnaoh/NexAlloy/blob/main/LICENSE)

</details>

## Inspired by

- [@luxysiv](https://github.com/luxysiv/yt-revanced-nonroot) — [GPL-3.0](https://github.com/luxysiv/revanced-nonroot/blob/main/LICENSE)

- [revanced-build-template](https://github.com/n0k0m3/revanced-build-template) — [GPL-3.0](https://github.com/n0k0m3/revanced-build-template/blob/main/LICENSE)

- [revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module) — [GPL-3.0](https://github.com/j-hc/revanced-magisk-module/blob/main/LICENSE) (previously based on this repository, now archived)
