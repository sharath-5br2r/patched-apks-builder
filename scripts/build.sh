#!/bin/bash
source ./scripts/utils.sh
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
	echo -e "CLI: $cli\nVersion: $cliver\n\n" > CHANGELOG.md
}
dl_patch() {
	case $source in
		github)
			if [[ -n "$filter" ]]; then
				dl_gh_v2 "$patchsrc" "prerelease" "$patchname$patchext" "$filter" "$patchexclude"
			else
				dl_gh_v2 "$patchsrc" "prerelease" "$patchname$patchext"
			fi
			changelog_url="https://github.com/$patchsrc/releases/tag/$tag"
			;;
		gitlab)
			dl_gl_mod "$patchsrc" "prerelease" "$patchname$patchext"
			changelog_url="https://gitlab.com/$patchsrc/-/tags/$tag"
			;;
		*)
			echo "Unknown patch source, skipping."
			;;
	esac
	patchversion=$tag
	echo -e "Patch: $patchname\nSource: $patchsrc\nVersion: $patchversion\nChangelog: $changelog_url\n\n" >> CHANGELOG.md
}
get_app(){
	case $apksrc in
		apkmirror)
		    get_apk "$pkgname" "$appname-$arch" "$apktype"
			;;
		apkpure)
			get_apkpure "$pkgname" "$appname-$arch" "$apktype"
			;;
		github)
			dl_gh_v2 "$apprepo" "prerelease" "$appname-$arch.apk"  "$appfilter" "$appexclude"
			;;
		custom)
		    eval "$appdl_cmd"
			;;
		*)
			echo "Unknown APK source, skipping."
			;;
		
	esac
	version=$(java -jar ./APKEditor.jar info -i ./download/$appname-$arch.apk -version-name  -t json | jq -r '.[].VersionName')
	echo -e "App: $appname\nVersion: $version\n\n" >> CHANGELOG.md
	
}
rvpatcher(){
	if [[ $version_cmd == "latest" ]]; then
	   lock_version=1
	elif [[ -n $version_cmd ]]; then
	   eval "$version_cmd"
	fi
	pversion=""
	while read -r line; do
	    if [[ -z $lineno ]]; then
	        lineno=1
	    fi
		patchname=$(jq -r '.patchname // ""' <<< "$line")
		patchsrc=$(jq -r '.patchsrc // ""' <<< "$line")
		source=$(jq -r '.source // ""' <<< "$line")
		filter=$(jq -r '.filter // ""' <<< "$line")
		dl_patch
		pversion="$pversion-p$patchversion"
		if [[ $lineno -eq 1 ]]; then
		    detect_version_mod "$pkgname" "$patchname.mpp"
		fi
		lineno=$((lineno + 1))
	done < <(jq -c '.[]'  <<< "$patches")
	while read -r arch; do
		get_app
		patch_mod
		if [[ -n $module ]]; then
		    makemodule="true"
			patch_mod
			unset makemodule
		fi
	done < <(jq -r '.[]' <<< "$archs")
}

npatcher() {
	patchname=$(echo "$patches" | jq -r '.[0].patchname // ""') || true
	patchsrc=$(echo "$patches" | jq -r '.[0].patchsrc // ""') || true
	source=$(echo "$patches" | jq -r '.[0].source // ""')
	filter=$(echo "$patches" | jq -r '.[0].filter // ""') || true
	dl_patch
	while read -r arch; do
		get_app
		green_log "[+] Patching $appname-$arch:"
		if [[ "$OSTYPE" == "cygwin" ]]; then
			green_log "[+] Detected Windows environment, using Windows version of npatch"
			java -cp "bcprov.jar;npatch.jar" -Djava.security.properties=bc.security top.nkbe.npatch.patch.NPatch ./download/$appname-$arch.apk -k ks.keystore  $KEYSTORE_PASS $KEYSTORE_ALIAS $KEYSTORE_PASS -m "$patchname.apk" -o ./release/
		else
			java -cp "bcprov.jar:npatch.jar" -Djava.security.properties=bc.security top.nkbe.npatch.patch.NPatch ./download/$appname-$arch.apk -k ks.keystore  $KEYSTORE_PASS $KEYSTORE_ALIAS $KEYSTORE_PASS -m "$patchname.apk" -o ./release/
		fi
		mv ./release/$appname-$arch-*-npatched.apk "./release/$appname-$arch-$patchname-$version-$patchversion.apk"
		unset lock_version	
	done < <(jq -r '.[]' <<< "$archs")

}	
patcher(){
	query=$appname-$patchname
	pkgname=$(cat build.json | jq -r --arg 'query' "$query" '.[$query].pkgname // "" ') || true
	apktype=$(cat build.json | jq -r --arg 'query' "$query" '.[$query].apktype // "" ') || true
	version_cmd=$(cat build.json | jq -r --arg 'query' "$query" '.[$query].version_cmd // "" ') || true
	archs=$(cat build.json | jq -r --arg 'query' "$query" '.[$query].archs // "" ') || true
	patches=$(cat build.json | jq -r --arg 'query' "$query" '.[$query].patches // "" ') || true
	apksrc=$(cat build.json | jq -r --arg 'query' "$query" '.[$query].apksrc // "" ') || true
	cli=$(cat build.json | jq -r --arg 'query' "$query" '.[$query].cli // "" ') || true	
	module=$(cat build.json | jq -r --arg 'query' "$query" '.[$query].module // "" ') || true
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
		    while read -r arch; do
				get_app
				sign "$appname-$arch.apk" "./release/$appname-$arch-signed-$version.apk"
			done < <(jq -r '.[]' <<< "$archs")
			;;
		*)
			echo "Unknown CLI type, exiting."
			exit 1
			;;
	esac
}
patcher
