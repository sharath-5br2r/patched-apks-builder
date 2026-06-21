#!/bin/bash
source ./src/build/utils_mod.sh
dl_cli() {
	case $cli in
		MorpheApp/morphe-cli)
			dl_gh_v2 "MorpheApp/morphe-cli" "latest" "morphe-cli.jar"
			clitype="morphe"
			;;
		*)
			echo "Unknown CLI, exiting."
			exit 1
			;;
	esac
	cliver=$tag
}
dl_patch() {
	case $patchsrc in
		github)
		    dl_gh_v2 "$patches" "prerelease" "$patchname.mpp"
			;;
		gitlab)
			dl_gl_v2 "$patches" "prerelease" "$patchname.mpp"
			;;
		*)
			echo "Unknown patch source, exiting."
			exit 1
			;;
	esac
	patchver=$tag
}
patcher(){
	dl_cli
	dl_patch
	if [[ -n $version_cmd ]]; then
	   eval "$version_cmd"
	fi
	detect_version_mod "$pkgname" "$patchname.mpp"
	if [[ -z $archs ]]; then
	   get_patches_key "$pkgname-$patchname"
	   get_apk "$pkgname" "$appname" "$apktype" 
	   patch_mod "$appname" "$patchname" "$clitype"
       if [[ $module="true" ]]; then
	    get_patches_key "$pkgname-$patchname-module"
	    patch_mod "$appname" "$patchname" "$clitype"
	    make_module "$pkgname" "$appname" "$patchname" "$clitype" "$archs"
	   fi
	else
		for arch in $archs
		do
		    get_patches_key "$pkgname-$patchname"
			get_apk "$pkgname" "$appname" "$apktype" "$arch"
			patch_mod "$appname" "$patchname" "$clitype"
			if [[ $module="true" ]]; then
				get_patches_key "$pkgname-$patchname-module"
				patch_mod "$appname" "$patchname" "$clitype"
				make_module "$pkgname" "$appname" "$patchname" "$clitype" "$arch"
			fi
		done
	fi
}
get_vars(){
	query=$appname-$patchname
	pkgname=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].pkgname')
	apktype=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].apktype')
	archs=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].archs')
	version_cmd=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].version_cmd')
	module=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].module')
	patchsrc=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].patchsrc')
	patches=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].patches')
	apksrc=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].apksrc')
	cli=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].cli')

}
morphe-patch(){
	get_vars
	patcher
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
	dl_morphe_cli
    dl_gl_mod "inotia00/x-shim" "latest" "shim.mpp"
    # Patch Twitter Piko:
	version="11.99.0-release.1"
    get_apk "com.twitter.android" "x" "bundle"
    patch_mod "x" "shim" "morphe"
	get_patches_key "x-piko"
	dl_gh_v2 "crimera/piko" "prerelease" "piko.mpp"
	repatch "piko" "morphe"
	
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
    discord-revenge)
        discord-revenge
        ;;
	x-piko)
		x-piko
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
	*)
	    if [[ -n $2 ]]; then
	        morphe-patch
	    else
	        echo "Not Implemented"
			exit 1
	    fi
		;;
esac
