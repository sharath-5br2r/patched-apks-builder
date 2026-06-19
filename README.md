
> [!NOTE]
> If you want to use the YouTube, YouTube Music or Google Photos app, you need to download and install [MicroG RE](https://github.com/MorpheApp/MicroG-RE)
> 
> If you are an advanced user and you want to use custom patches for patching revanced apps, you should read [Customization Guide](../main/docs/Customization.md)
>
> This repository is  like any other repository. It does not create new releases; it only releases new files.
> 
> All the code is open-source, clearly, and the APK files used for patching are downloaded from a trusted site, so it is totally safe for you to use.
> 
> To run locally see [Local Guide](../main/docs/Local.md)
> 
> To see what to do after forking repo refer [GitHub Actions Guide](../main/docs/Github-Actions.md)






---
## Based on https://github.com/FiorenMas/Revanced-And-Revanced-Extended-Non-Root for revanced but slightly modified and specialised.

## Added custom manifest patches

### Notable Modifications
- Replaced hardcoded keystore with keystore stored in secrets.
- Moved patches stuff from seperate files into a single file.
- APK Files now have versions in their name
- Dedicates releases for each app with link to latest app
- Added suport for Archive.org apk repositories(unused)
- Simplified repo and reduced no of apps
- Added custom patches
- Added full windows x64 and linux arm64 support along with existing linux x64 (requires msys2 on windows and flaresolverr) and android arm64 support
- Added support for chaining patches(required for piko)
## Patched Apps
- Morphe
  - YouTube [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/youtube-morphe)
  - YouTube Music [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/youtube-music-morphe)
- Piko
  - X  [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/x-piko)
  - Instagram  [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/instagram-piko)
- hoo-dles
  - Prime Video  [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/prime-video-hoo-dles)
    - Amazon India signed for compatibilty  [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/amazon-india)
    - Amazon Alexa signed for compatibility  [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/amazon-alexa)
- Paresh
  - Proton VPN  [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/protonvpn-paresh)
  - JioHotstar (Indian OTT Platform) [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/jiohotstar-paresh)
- binarymend
  - Symfonium (music player) (**NOT FUNCTIONAL**)
- ### Custom patches
  - Eden Nightly (Switch Emulator) (PUBG Spoof) [Original](https://eden-emu.dev) [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/eden-pubg)
  - Dolphin Emulator (Wii/GameCube Emulator) (SDK 29 no scoped storage) [Original](https://dolphin-emu.org) [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/dolphin-sdk-29)
  - Fold Craft Launcher (Minecraft Java Launcher) (CoD spoof) [Original](https://github.com/FCL-Team/FoldCraftLauncher)[Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/fcl-cod)
  - Geode (Geometry Dash mods) (PUBG KR Spoof) [Original](https://github.com/geode-sdk/android-launcher) [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/geode-pubgkr)
  - Winlator CMOD/Ludashi (Windows Emulator) (PUBG VN Spoof) [Original](https://github.com/StevenMXZ/Winlator-Ludashi) [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/winlator-pubgvn)
  ### Xposed  patches 
  - Discord (Revenge) [Download](https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/discord-revenge)
### See also:
[LeviLaunchroid Crack+BGMI Spoof](https://github.com/sharath-r7q4/LeviLaunchroid) [Apache-2.0](https://github.com/sharath-r7q4/LeviLaunchroid/blob/main/LICENSE) (Mobile MC Bedrock Launcher,Get ur own MC APK) 
## Actively Used Libraries
- Morphe
  - [Patches](https://github.com/MorpheApp/morphe-patches) - [GPL-3.0](https://github.com/MorpheApp/morphe-patches/blob/main/LICENSE)
  - [CLI](https://github.com/MorpheApp/morphe-cli) - [GPL-3.0](https://github.com/MorpheApp/morphe-cli/blob/main/LICENSE)
  - [MicroG RE](https://github.com/MorpheApp/MicroG-RE) - [Apache-2.0](https://github.com/MorpheApp/MicroG-RE/blob/main/LICENSE)
- crimera [Piko Patches](https://github.com/crimera/piko) - [GPL-3.0](https://github.com/crimera/piko/blob/main/LICENSE)
- inotia00 [Piko Shim](https://gitlab.com/inotia00/piko-shim/) - GPL-3.0
- hoo-dles
[Patches](https://github.com/hoo-dles/morphe-patches) - [GPL-3.0](https://github.com/hoo-dles/morphe-patches/blob/main/LICENSE)
- Paresh-Maheshwari
[Patches](https://gitlab.com/Paresh-Maheshwari/paresh-patches) - [GPL-3.0](https://gitlab.com/Paresh-Maheshwari/paresh-patches/-/blob/main/LICENSE)
- [pup](https://github.com/ericchiang/pup) - [MIT](https://github.com/ericchiang/pup/blob/master/LICENSE)
- [APKEditor](https://github.com/REAndroid/APKEditor) - [Apache-2.0](https://github.com/REAndroid/APKEditor/blob/master/LICENSE)
- [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr) - [MIT](https://github.com/FlareSolverr/FlareSolverr/blob/master/LICENSE)
- [tdl](https://github.com/iyear/tdl) - [AGPL-3.0](hhttps://github.com/iyear/tdl/blob/master/LICENSE)
- [NPatch](https://github.com/7723mod/NPatch) - [GPL-3.0](https://github.com/7723mod/NPatch/blob/main/LICENSE) (for Xposed)
- Revenge
Code inspired from [Manager](https://github.com/revenge-mod/revenge-manager) - [OSL-3.0](https://github.com/revenge-mod/revenge-manager/blob/main/LICENSE)
 Actual Module [Xposed](https://github.com/revenge-mod/revenge-xposed) - [OSL-3.0](https://github.com/revenge-mod/revenge-manager/blob/main/LICENSE)
### Dormant Libraries, resources using in this repository:

<details>
  <summary>indrastorms</summary>

[Patches](https://github.com/indrastorms/Dropped-Patches) - [GPL-3.0](https://github.com/indrastorms/Dropped-Patches/blob/main/LICENSE)

</details>

<details>
  <summary>Aunali321</summary>

[Patches](https://github.com/Aunali321/ReVancedExperiments) - [GPL-3.0](https://github.com/Aunali321/ReVancedExperiments/blob/main/LICENSE)

</details>

<details>
  <summary>scrazzz</summary>

[Patches](https://github.com/scrazzz/my-revanced-patches) - [GPL-3.0](https://github.com/scrazzz/my-revanced-patches/blob/main/LICENSE)

</details>

<details>
  <summary>RookieEnough</summary>

[Patches](https://github.com/RookieEnough/De-ReVanced) - [GPL-3.0](https://github.com/RookieEnough/De-ReVanced/blob/main/LICENSE)

</details>

<details>
  <summary>gnadgnaoh</summary>

[Patches](https://github.com/gnadgnaoh/NexAlloy) - [GPL-3.0](https://github.com/gnadgnaoh/NexAlloy/blob/main/LICENSE)

</details>

## Inspired by:

[@luxysiv](https://github.com/luxysiv/yt-revanced-nonroot) - [GPL-3.0](https://github.com/luxysiv/revanced-nonroot/blob/main/LICENSE)

[revanced-build-template](https://github.com/n0k0m3/revanced-build-template) - [GPL-3.0](https://github.com/n0k0m3/revanced-build-template/blob/main/LICENSE)

[revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module) - [GPL-3.0](https://github.com/j-hc/revanced-magisk-module/blob/main/LICENSE)(previously based on, now archived old repo)


