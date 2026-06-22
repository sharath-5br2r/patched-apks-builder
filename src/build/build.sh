#!/bin/bash
source ./src/build/utils_mod.sh
dl_cli() {
	case $cli in
		MorpheApp/morphe-cli)
			dl_gh_v2 "MorpheApp/morphe-cli" "latest" "morphe-cli.jar"
			clitype="morphe"
			patchext=".mpp"
			;;
		7723mod/NPatch)
			dl_gh_v2 "7723mod/NPatch" "latest" "npatch.jar" "jar"
			clitype="npatch"
			patchext=".apk"
			;;
		*)
			echo "Unknown CLI, exiting."
			exit 1
			;;
	esac
	cliver=$tag
}
dl_patch() {
	case $source in
		github)
			if [[ -n "$filter" ]]; then
				dl_gh_v2 "$patchsrc" "prerelease" "$patchname$patchext" "$filter"
			else
				dl_gh_v2 "$patchsrc" "prerelease" "$patchname$patchext"
			fi
			;;
		gitlab)
			dl_gl_mod "$patchsrc" "prerelease" "$patchname$patchext"
			;;
		*)
			echo "Unknown patch source, exiting."
			exit 1
			;;
	esac
	patchversion=$tag
}
get_app(){
	case $apksrc in
		apkmirror)
		    get_apk "$pkgname" "$appname-$arch" "$apktype"
			;;
		apkpure)
			get_apkpure "$pkgname" "$appname-$arch" "$apktype"
			;;
		*)
			echo "Unknown APK source, skipping."
			;;
	esac
}
rvpatcher(){
	if [[ $version_cmd == "latest" ]]; then
	   lock_version=1
	elif [[ -n $version_cmd ]]; then
	   eval "$version_cmd"
	fi
	while read -r line; do
        if [[ -z "$lineno" ]]; then
			lineno=1
		fi
		module=$(jq -r '.module // "false"' <<< "$line")
		patchname=$(jq -r '.patchname // ""' <<< "$line")
		patchsrc=$(jq -r '.patchsrc // ""' <<< "$line")
		source=$(jq -r '.source // ""' <<< "$line")
		filter=$(jq -r '.filter // ""' <<< "$line")
		dl_patch
		detect_version_mod "$pkgname" "$patchname.mpp"
		if [[ $lineno -ne 1 ]]; then
		    origapksrc=$apksrc
		    apksrc="repatch"
		fi
		while read -r arch; do
		    get_patches_key "$appname-$patchname"
			get_app
			patch_mod "$appname-$arch" "$patchname" "$clitype"
			if [[ $module == "true" ]]; then
				mv "$patchname.mpp" "$patchname-module.mpp"
				get_patches_key "$appname-$patchname-module"
				patch_mod "$appname-$arch" "$patchname-module" "$clitype"
				make_module "$pkgname" "$appname-$arch" "$patchname-module" "$arch"
			fi

		done < <(jq -r '.[]' <<< "$archs")
		lineno=$((lineno + 1))
		apksrc=$origapksrc

	done < <(jq -c '.[]'  <<< "$patches")
}

npatcher() {
	patchname=$(echo "$patches" | jq -r '.[0].patchname // ""') || true
	patchsrc=$(echo "$patches" | jq -r '.[0].patchsrc // ""') || true
	source=$(echo "$patches" | jq -r '.[0].source // ""')
	filter=$(echo "$patches" | jq -r '.[0].filter // ""') || true
	dl_patch
	get_app
	version="$(java -jar ./APKEditor.jar info -i ./download/$1.apk -version-name)"
	green_log "[+] Patching $1:"
	if [ -f "./download/$1.apk" ]; then
		if [[ ! -f "$2" ]]; then
			red_log "[-] Module not found: $2"
			return 1
		fi
		if [[ "$OSTYPE" == "cygwin" ]]; then
			green_log "[+] Detected Windows environment, using Windows version of npatch"
			java -cp "bcprov.jar;npatch.jar" -Djava.security.properties=bc.security top.nkbe.npatch.patch.NPatch ./download/$1.apk -k ks.keystore  $KEYSTORE_PASS $KEYSTORE_ALIAS $KEYSTORE_PASS -m "$2" -o ./release/
		else
			java -cp "bcprov.jar:npatch.jar" -Djava.security.properties=bc.security top.nkbe.npatch.patch.NPatch ./download/$1.apk -k ks.keystore  $KEYSTORE_PASS $KEYSTORE_ALIAS $KEYSTORE_PASS -m "$2" -o ./release/
		fi
		mv ./release/$1-*-npatched.apk "./release/$1-$3-$version.apk"
		unset lock_version
	else
		red_log "[-] Not found $1.apk"
		exit 1
	fi
}

patcher(){
	query=$appname-$patchname
	pkgname=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].pkgname // "" ') || true
	apktype=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].apktype // "" ') || true
	version_cmd=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].version_cmd // "" ') || true
	archs=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].archs // "" ') || true
	patches=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].patches // "" ') || true
	apksrc=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].apksrc // "" ') || true
	cli=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].cli // "" ') || true	
	
	case $cli in
		MorpheApp/morphe-cli)
			dl_cli
			rvpatcher
			;;
		7723mod/NPatch)
		    dl_cli
			npatcher
			;;
		apksigner.jar)
		    get_app
			arch=$(echo "$archs" | jq -r '.[0]') || true
			version="$(java -jar ./APKEditor.jar info -i ./download/$appname-$arch.apk -version-name)"
			sign "$appname-$arch.apk" "./release/$appname-$arch-signed-$version.apk"
			;;
		*)
			echo "Unknown CLI type, exiting."
			exit 1
			;;
	esac
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
    sign fcl-patched.apk ./release/FCL-release-cod-$tag.apk
}

geode-pubgkr() {
	dl_gh_v2 "geode-sdk/android-launcher" "latest" "geode-orig.apk" "android32" "exclude"
    java -jar APKEditor.jar d -i geode-orig.apk -o geode-src -t xml -dex
    sed -i -e 's/package="com\.geode\.launcher"/package="com.pubg.krmobile"/' -e '/package="com\.pubg\.krmobile"/a\    android:compileSdkVersion="36"\n    android:compileSdkVersionCodename="16"' -e '/android:compileSdkVersion="36"/d' -e '/android:compileSdkVersionCodename="16"/d' -e '0,/package="com\.pubg\.krmobile"/s//android:compileSdkVersion="36"\n    android:compileSdkVersionCodename="16"\n    package="com.pubg.krmobile"/' -e 's/com\.geode\.launcher\.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION/com.pubg.krmobile.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION/g' -e 's/com\.geode\.launcher\.user/com.pubg.krmobile.user/g' -e 's/com\.geode\.launcher\.fileprovider/com.pubg.krmobile.fileprovider/g' -e 's/com\.geode\.launcher\.androidx-startup/com.pubg.krmobile.androidx-startup/g' geode-src/AndroidManifest.xml         
    java -jar APKEditor.jar b -i geode-src -o geode-patched.apk
    sign geode-patched.apk ./release/geode-launcher-pubgkr-$tag.apk
}

winlator-pubgvn() {
	dl_gh_v2 "StevenMXZ/Winlator-Ludashi" "latest" "winlator-orig.apk" "build.apk"
    java -jar APKEditor.jar d -i winlator-orig.apk -o winlator-src -t xml -dex
    sed -i -e 's/package="com\.tencent\.ig"/package="com.vng.pubgmobile"/' -e 's/com\.tencent\.ig\.tileprovider/com.vng.pubgmobile.tileprovider/' -e 's/com\.tencent\.ig\.core\.WinlatorFilesProvider/com.vng.pubgmobile.core.WinlatorFilesProvider/' -e 's/com\.tencent\.ig\.androidx-startup/com.vng.pubgmobile.androidx-startup/' winlator-src/AndroidManifest.xml
    java -jar APKEditor.jar b -i winlator-src -o winlator-patched.apk
    sign winlator-patched.apk ./release/winlator-pubgvn-$tag.apk
}

case "$1" in
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
	    patcher
		;;
esac
