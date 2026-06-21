#!/bin/bash
source ./src/build/utils_mod.sh
adobe-acrobat-hooman(){
	dl_gh_v2 "MorpheApp/morphe-cli" "latest" "morphe-cli.jar" 
	dl_gh_v2 "arandomhooman/hoomans-morphe-patches" "prerelease" "hooman.mpp"
	# Patch Adobe Acrobat Reader:
	_fs_get https://www.apkmirror.com/apk/adobe/adobe-acrobat/feed/
	version=$(curl -s https://www.apkmirror.com/apk/adobe/adobe-acrobat/feed/ -H "Cookie: $FS_COOKIES" -H "User-Agent: $user_agent"   |  tail -n +4 | sed -e 's/^[ \t]*//' | sed -e 's/<title>//' -e 's/<\/title>//' -e 's/<description>/  /' -e 's/<\/description>//' |  grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+*' | sort | tail -n 1)	get_patches_key "adobe-acrobat-hooman"
	echo $version
	get_patches_key "adobe-acrobat-hooman"
	get_apk "com.adobe.reader" "adobe-acrobat" "bundle"
	patch_mod "adobe-acrobat" "hooman" "morphe"
}
speedtest-xtra(){
	dl_gh_v2 "MorpheApp/morphe-cli" "latest" "morphe-cli.jar"
	dl_gh_v2 "BholeyKaBhakt/android-patches-xtra" "prerelease" "xtra.mpp"
	# Patch Speedtest Arm64-v8a:
	detect_version_mod "org.zwanoo.android.speedtest" "xtra.mpp"
	get_patches_key "speedtest-xtra"
	get_apk "org.zwanoo.android.speedtest" "speedtest" "apk" "arm64-v8a"
	patch_mod "speedtest" "xtra" "morphe"
	get_apk "org.zwanoo.android.speedtest" "speedtest" "apk" "x86_64"
	patch_mod "speedtest" "xtra" "morphe"
}
tiktok-icysymmetra() {
	# Patch Tiktok:
	dl_gh_v2 "MorpheApp/morphe-cli" "latest" "morphe-cli.jar"
	dl_gh_v2 "icysymmetra/tiktok-patches-for-morphe" "prerelease" "icysymmetra.mpp"
	detect_version_mod "com.zhiliaoapp.musically" "icysymmetra.mpp"
	get_patches_key "tiktok-icysymmetra"
	get_apk "com.zhiliaoapp.musically" "tiktok" "apk" "arm64-v8a + armeabi-v7a" "nodpi"
	patch_mod "tiktok" "icysymmetra" "morphe"
}
discord-revenge() {
	# Patch Revenge:
	dl_gh_v2 "NPatch/7723mod" "latest"
	dl_gh_v2 "revenge-xposed/revenge-mod" "latest"
	_fs_get https://www.apkmirror.com/apk/discord/discord-chat-for-gamers/feed/
	version=$(curl -s https://www.apkmirror.com/apk/discord/discord-chat-for-gamers/feed/  -H "Cookie: $FS_COOKIES" -H "User-Agent: $user_agent"   |  grep -E '(title>|description>)' | tail -n +4 | sed -e 's/^[ \t]*//' | sed -e 's/<title>//' -e 's/<\/title>//' -e 's/<description>/  /' -e 's/<\/description>//' |  grep -oE '[0-9]+\.[0-9]+.*' |  awk -F ' by' '{print $1}' | grep Beta | head -n 1 )
	get_apk "com.discord" "discord" "bundle"
	npatch_mod "discord" "app-release" "revenge"
}

x-piko() {
	dl_gh_v2 "MorpheApp/morphe-cli" "latest" "morphe-cli.jar"
    dl_gl_mod "inotia00/x-shim" "latest" "shim.mpp"
    # Patch Twitter Piko:
	version="11.99.0-release.1"
    get_apk "com.twitter.android" "x" "bundle"
    patch_mod "x" "shim" "morphe"
	get_patches_key "x-piko"
	dl_gh_v2 "crimera/piko" "prerelease" "piko.mpp"
	repatch "piko" "morphe"
	
}
instagram-piko() {
    dl_gh_v2 "MorpheApp/morphe-cli" "latest" "morphe-cli.jar"
	dl_gh_v2 "crimera/piko" "prerelease" "piko.mpp"
    # Patch Instagram arm64-v8a:
    get_patches_key "instagram-piko"
	detect_version_mod "com.instagram.android" "piko.mpp"
    get_apk "com.instagram.android" "instagram-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi"  "Android 9.0+"
    patch_mod "instagram-arm64-v8a" "piko" "morphe"
	# Patch Instagram x86_64:
	get_apk "com.instagram.android" "instagram-x86_64" "bundle" "x86_64" "120-640dpi"  "Android 9.0+"
	patch_mod "instagram-x86_64" "piko" "morphe"
}
prime-video-hoo-dles() {
	dl_gh_v2 "MorpheApp/morphe-cli" "latest" "morphe-cli.jar"
	dl_gh_v2 "hoo-dles/morphe-patches" "prerelease" "hoo-dles.mpp"
	# Patch Amazon Prime Video Arm64-v8a
	get_patches_key "prime-video-hoo-dles"
	_fs_get https://www.apkmirror.com/apk/amazon-mobile-llc/amazon-prime-video/feed/
	version=$(curl -s https://www.apkmirror.com/apk/amazon-mobile-llc/amazon-prime-video/feed/ -H "Cookie: $FS_COOKIES" -H "User-Agent: $user_agent"   |  grep -E '(title>|description>)' | tail -n +4 | sed -e 's/^[ \t]*//' | sed -e 's/<title>//' -e 's/<\/title>//' -e 's/<description>/  /' -e 's/<\/description>//' |  grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep -v - | head -n 1) 
	get_apk "com.amazon.avod.thirdpartyclient" "prime-video" "apk" "arm64-v8a" "nodpi" "Android 9.0+"
	patch_mod "prime-video" "hoo-dles" "morphe"
}
proton-vpn-paresh() {
	dl_gh_v2 "MorpheApp/morphe-cli" "latest" "morphe-cli.jar"
	dl_gh_v2 "Paresh-Maheshwari/paresh-patches" "prerelease" "paresh.mpp"
	#Patch Proton VPN
	get_patches_key "Proton-VPN-paresh"
	_fs_get https://www.apkmirror.com/apk/proton-technologies-ag/protonvpn-secure-and-free-vpn/feed/
	version=$(curl -s https://www.apkmirror.com/apk/proton-technologies-ag/protonvpn-secure-and-free-vpn/feed/ -H "Cookie: $FS_COOKIES" -H "User-Agent: $user_agent"   |  grep -E '(title>|description>)' | tail -n +4 | sed -e 's/^[ \t]*//' | sed -e 's/<title>//' -e 's/<\/title>//' -e 's/<description>/  /' -e 's/<\/description>//' |  grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -v - | head -n 1) 
	get_apk "ch.protonvpn.android" "protonvpn" "bundle"
	patch_mod "protonvpn" "paresh" "morphe"
}
symfonium-binarymend(){
	dl_gh_v2 "MorpheApp/morphe-cli" "latest" "morphe-cli.jar"
	dl_gh_v2 "binarymend/morphe-patches" "prerelease" "binarymend.mpp"
	get_patches_key "Sympfonium-binarymend"
	detect_version_mod "app.symfonik.music.player" "sympfonium"
	get_apk "app.symfonik.music.player" "sympfonium" "bundle"
	patch_mod "sympfonium" "binarymend" "morphe"
}
youtube-morphe() {
	dl_gh_v2 "MorpheApp/morphe-cli" "latest" "morphe-cli.jar"
	dl_gh_v2 "MorpheApp/morphe-patches" "prerelease" "morphe.mpp"
	# Patch YouTube:
	check_experimental "com.google.android.youtube"
	detect_version_mod "com.google.android.youtube" "morphe.mpp"
	get_patches_key "youtube-morphe"
	get_apk "com.google.android.youtube" "youtube-app" "apk"
	patch_mod "youtube-app" "morphe" "morphe"
	get_patches_key "youtube-morphe-module"
	get_apk "com.google.android.youtube" "youtube-module" "apk"
	patch_mod "youtube-module" "morphe" "morphe"
	make_module "com.google.android.youtube" "youtube-module" "morphe" youtube-morphe
}
youtube-music-morphe() {
	dl_gh_v2 "MorpheApp/morphe-cli" "latest" "morphe-cli.jar"
	dl_gh_v2 "MorpheApp/morphe-patches" "prerelease" "morphe.mpp"
	# Patch YouTube Music x86_64:
	check_experimental "com.google.android.apps.youtube.music"
	detect_version_mod "com.google.android.apps.youtube.music" "morphe.mpp"
	get_patches_key "youtube-music-morphe"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-x86_64" "apk" "x86_64"
	patch_mod "youtube-music-x86_64" "morphe" "morphe"
	# Patch YouTube Music Arm64-v8a:
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64" "apk" "arm64-v8a"
	patch_mod "youtube-music-arm64" "morphe" "morphe"
	# Patch YouTube Music x86_64 module:
	get_apk "com.google.android.apps.youtube.music" "youtube-music-x86_64-module" "apk" "x86_64"
	get_patches_key "youtube-music-morphe-module"
	patch_mod "youtube-music-x86_64-module" "morphe" "morphe"
	make_module "com.google.android.apps.youtube.music" "youtube-music-x86_64-module" "morphe" youtube-music-morphe x86_64
	# Patch YouTube Music Arm64-v8a module:
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-module" "apk" "arm64-v8a"
	patch_mod "youtube-music-arm64-module" "morphe" "morphe"
	make_module "com.google.android.apps.youtube.music" "youtube-music-arm64-module" "morphe" youtube-music-morphe arm64
}
jiohotstar-paresh() {
	dl_gh_v2 "MorpheApp/morphe-cli" "MorpheApp" "latest"
	dl_gl_v2 "Paresh-Maheshwari/paresh-patches" "prerelease" "paresh.mpp"
	# Patch JioHotstar:
	detect_version_mod "in.startv.hotstar" "paresh.mpp"
	get_patches_key "jiohotstar-paresh"
	get_apk "in.startv.hotstar" "jiohotstar" "apk"
	patch_mod "jiohotstar" "paresh" "morphe"
}
amazon-india-signed(){
	_fs_get https://www.apkmirror.com/apk/amazon-mobile-llc/amazon-india-shop-pay/feed/
	version=$(curl -s https://www.apkmirror.com/apk/amazon-mobile-llc/amazon-india-shop-pay/feed/ -H "Cookie: $FS_COOKIES" -H "User-Agent: $user_agent"   |  grep -E '(title>|description>)' | tail -n +4 | sed -e 's/^[ \t]*//' | sed -e 's/<title>//' -e 's/<\/title>//' -e 's/<description>/  /' -e 's/<\/description>//' |  grep -oE '[0-9]+\.[0-9]+.*' |  awk -F ' by' '{print $1}'| head -n 1 )
	get_apk "in.amazon.mShop.android.shopping" "amazon-india" "bundle"
	java -jar APKEditor.jar m -i ./download/amazon-india.apkm -o amazon-india.apk
	sign "amazon-india.apk" ./release/amazon-india-signed-$version.apk
}
amazon-alexa-signed(){
	_fs_get https://www.apkmirror.com/apk/amazon-mobile-llc/amazon-alexa/feed/
	version=$(curl -s https://www.apkmirror.com/apk/amazon-mobile-llc/amazon-alexa/feed/ -H "Cookie: $FS_COOKIES" -H "User-Agent: $user_agent"   |  grep -E '(title>|description>)' | tail -n +4 | sed -e 's/^[ \t]*//' | sed -e 's/<title>//' -e 's/<\/title>//' -e 's/<description>/  /' -e 's/<\/description>//' |  grep -oE '[0-9]+\.[0-9]+.*' |  awk -F ' by' '{print $1}'| head -n 1 )
	get_apk "com.amazon.dee.app" "amazon-alexa" "bundle"
	java -jar APKEditor.jar m -i ./download/amazon-alexa.apkm -o amazon-alexa.apk
	sign "amazon-alexa.apk" ./release/amazon-alexa-signed-$version.apk
}
dolphin-sdk29() {
    _fs_get https://dolphin-emu.org/download/
    export DOLPHIN_LATEST=$(gh release view "Dolphin-SDK29" --json  assets | jq .[].[0].name)
    DOLPHIN_LATEST=${DOLPHIN_LATEST%%.*}
    DOLPHIN_APK_URL=$(echo $html | grep -Eo 'https://dl\.dolphin-emu\.org/builds/[a-z0-9/]+/dolphin-master-[0-9]+-[0-9]+\.apk' | awk -F'[-/.]' '{v=$(NF-2); b=$(NF-1);if (v>V || (v==V && b>B)) {V=v; B=b; U=$0}} END{print U}')
    DOLPHIN_NAME=$(basename "$DOLPHIN_APK_URL" .apk)
    if [[ $DOLPHIN_NAME != $DOLPHIN_LATEST ]] || [[ "$GITHUB_EVENT_NAME" == "workflow_dispatch" ]]; then
        curl -L "$DOLPHIN_APK_URL" -H "Cookie: $FS_COOKIES" -H "User-Agent: $user_agent"  -o dolphin-orig.apk
        java -jar APKEditor.jar d -i dolphin-orig.apk -o dolphin-src -t xml -dex
        sed -i 's/android:targetSdkVersion="[^"]*"/android:targetSdkVersion="29"/g' dolphin-src/AndroidManifest.xml
        java -jar APKEditor.jar b -i dolphin-src -o dolphin-patched.apk
        sign dolphin-patched.apk ./release/$DOLPHIN_NAME-signed.apk
    else
       exit 0
    fi
}

eden-pubg() {
    export EDEN_ID=$(gh run list -R Eden-CI/Workflow -w nightly.yml --status success --limit 1 --json databaseId -q ".[0].databaseId")
    date1=$(gh run list -R Eden-CI/Workflow -w nightly.yml --status success --limit 1 --json updatedAt  -q ".[0].updatedAt")
    export EDEN_NAME=$(gh run view $EDEN_ID -R Eden-CI/Workflow | grep standard.apk | cut -d'-' -f3 )
    gh api "/repos/Eden-CI/Workflow/actions/artifacts/$(gh api repos/Eden-CI/Workflow/actions/runs/$EDEN_ID/artifacts --jq '.artifacts[] | select(.name| contains("standard.apk")) | .id')/zip" > eden-orig.apk
    java -jar APKEditor.jar d -i eden-orig.apk -o eden-src -t xml -dex
    sed -i 's/dev\.eden\.eden_emulator\.nightly/com.tencent.ig/g' eden-src/AndroidManifest.xml
    java -jar APKEditor.jar b -i eden-src -o eden-patched.apk
    sign eden-patched.apk ./release/Eden-Android-pubg-$date1-$EDEN_NAME.apk
}

fcl-cod() {
	dl_gh_v2 "FCL-Team/FoldCraftLauncher" "latest" "fcl-orig.apk" "all"
    java -jar APKEditor.jar d -i fcl-orig.apk -o fcl-src -t xml -dex
    sed -i -e 's/package="com\.tungsten\.fcl"/package="com.activision.callofduty.shooter"/' -e 's/com\.tungsten\.fcl\.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION/com.activision.callofduty.shooter.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION/g' -e 's/com\.tungsten\.fcl\.document\.provider/com.activision.callofduty.shooter.document.provider/g' -e 's/com\.tungsten\.fcl\.provider/com.activision.callofduty.shooter.provider/g' -e 's/com\.tungsten\.fcl\.crashreporterinitprovider/com.activision.callofduty.shooter.crashreporterinitprovider/g' -e 's/com\.tungsten\.fcl\.androidx-startup/com.activision.callofduty.shooter.androidx-startup/g' fcl-src/AndroidManifest.xml
    java -jar APKEditor.jar b -i fcl-src -o fcl-patched.apk
    sign fcl-patched.apk ./release/FCL-release-cod-$release_name.apk
}

geode-pubgkr() {
	dl_gh_v2 "geode-sdk/android-launcher" "latest" "geode-orig.apk" "android32" "exclude"
    java -jar APKEditor.jar d -i geode-orig.apk -o geode-src -t xml -dex
    sed -i -e 's/package="com\.geode\.launcher"/package="com.pubg.krmobile"/' -e '/package="com\.pubg\.krmobile"/a\    android:compileSdkVersion="36"\n    android:compileSdkVersionCodename="16"' -e '/android:compileSdkVersion="36"/d' -e '/android:compileSdkVersionCodename="16"/d' -e '0,/package="com\.pubg\.krmobile"/s//android:compileSdkVersion="36"\n    android:compileSdkVersionCodename="16"\n    package="com.pubg.krmobile"/' -e 's/com\.geode\.launcher\.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION/com.pubg.krmobile.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION/g' -e 's/com\.geode\.launcher\.user/com.pubg.krmobile.user/g' -e 's/com\.geode\.launcher\.fileprovider/com.pubg.krmobile.fileprovider/g' -e 's/com\.geode\.launcher\.androidx-startup/com.pubg.krmobile.androidx-startup/g' geode-src/AndroidManifest.xml         
    java -jar APKEditor.jar b -i geode-src -o geode-patched.apk
    sign geode-patched.apk ./release/geode-launcher-pubgkr-$release_name.apk
}

winlator-pubgvn() {
	dl_gh_v2 "StevenMXZ/Winlator-Ludashi" "latest" "winlator-orig.apk" "build.apk"
    java -jar APKEditor.jar d -i winlator-orig.apk -o winlator-src -t xml -dex
    sed -i -e 's/package="com\.tencent\.ig"/package="com.vng.pubgmobile"/' -e 's/com\.tencent\.ig\.tileprovider/com.vng.pubgmobile.tileprovider/' -e 's/com\.tencent\.ig\.core\.WinlatorFilesProvider/com.vng.pubgmobile.core.WinlatorFilesProvider/' -e 's/com\.tencent\.ig\.androidx-startup/com.vng.pubgmobile.androidx-startup/' winlator-src/AndroidManifest.xml
    java -jar APKEditor.jar b -i winlator-src -o winlator-patched.apk
    sign winlator-patched.apk ./release/winlator-pubgvn-$release_name.apk
}

case "$1" in
    adobe-acrobat-hooman)
		adobe-acrobat-hooman
		;;
	tiktok-icysymmetra)
		tiktok-icysymmetra
		;;
	speedtest-xtra)
		speedtest-xtra
		;;
    discord-revenge)
        discord-revenge
        ;;
	x-piko)
		x-piko
		;;
	instagram-piko)
		instagram-piko
		;;
	prime-video-hoo-dles)
		prime-video-hoo-dles
		;;
	proton-vpn-paresh)
		proton-vpn-paresh
		;;
	jiohotstar-paresh)
		jiohotstar-paresh
		;;
	youtube-morphe)
		youtube-morphe
		;;
	symfonium-binarymend)
		symfonium-binarymend
		;;
	youtube-music-morphe)
		youtube-music-morphe
		;;
	amazon-india-signed)
		amazon-india-signed
		;;
    amazon-alexa-signed)
		amazon-alexa-signed
		;;
    dolphin-sdk29)
        dolphin-sdk29
        ;;
    eden-pubg)
        eden-pubg
        ;;
    fcl-cod)
        fcl-cod
        ;;
    geode-pubgkr)
        geode-pubgkr
        ;;
    winlator-pubgvn)
        winlator-pubgvn
        ;;
esac
