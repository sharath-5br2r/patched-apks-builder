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
				dl_gh_v2 "$patchsrc" "prerelease" "$patchname$patchext" "$filter" "$patchexclude"
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

	case $source in
	    github)
	        changelog_url="https://github.com/$patchsrc/releases/tag/$patchversion"
	        ;;
	    gitlab)
	        changelog_url="https://gitlab.com/$patchsrc/-/releases/$patchversion"
	        ;;
	esac
	echo -e "CLI: $cli $cliver\nPatches: $patchsrc $patchversion \n[Changelog]($changelog_url)\n App: $appname $version" > CHANGELOG.md
	echo -e "{ \"appname\": \"$appname\", \"patchname\": \"$patchname\" , \"appversion\": \"$version\" , \"patchversion\": \"$release_name\" }" > ./release/version.json
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
		if [ -f "./download/$appname-$arch.apk" ]; then
			if [[ ! -f "$2" ]]; then
				red_log "[-] Module not found: $2"
				return 1
			fi
			if [[ "$OSTYPE" == "cygwin" ]]; then
				green_log "[+] Detected Windows environment, using Windows version of npatch"
				java -cp "bcprov.jar;npatch.jar" -Djava.security.properties=bc.security top.nkbe.npatch.patch.NPatch ./download/$appname-$arch.apk -k ks.keystore  $KEYSTORE_PASS $KEYSTORE_ALIAS $KEYSTORE_PASS -m "$2" -o ./release/
			else
				java -cp "bcprov.jar:npatch.jar" -Djava.security.properties=bc.security top.nkbe.npatch.patch.NPatch ./download/$appname-$arch.apk -k ks.keystore  $KEYSTORE_PASS $KEYSTORE_ALIAS $KEYSTORE_PASS -m "$2" -o ./release/
			fi
			mv ./release/$appname-$arch-*-npatched.apk "./release/$appname-$arch-$patchname-$version-$patchversion.apk"
			unset lock_version
		else
			red_log "[-] Not found $appname-$arch.apk"
			exit 1
		fi	
	done < <(jq -r '.[]' <<< "$archs")

	
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
	module=$(cat src/build/vars.json | jq -r --arg 'query' "$query" '.[$query].module // "" ') || true
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
			version="$(java -jar ./APKEditor.jar info -i ./download/$appname-$arch.apk -version-name -t json | jq -r '.[].VersionName')"
			sign "$appname-$arch.apk" "./release/$appname-$arch-signed-$version.apk"
			;;
		*)
			echo "Unknown CLI type, exiting."
			exit 1
			;;
	esac
}
patcher
