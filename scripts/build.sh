#!/bin/bash
if [[ -n $1 ]] && [[ -n $2 ]]; then
	appname=$1
	patchname=$2
fi
configfile="build.toml"
source ./scripts/utils.sh
dl_cli() {
	case $cli in
		MorpheApp/morphe-cli)
			dl_gh_v2 "MorpheApp/morphe-cli" "latest" "morphe-cli.jar"
			cliType="morphe"
			patchExt=".mpp"
			;;
		ReVanced/revanced-cli)
			dl_gh_v2 "ReVanced/revanced-cli" "latest" "revanced-cli.jar"
			cliType="revanced"
			patchExt=".rvp"
			;;
		7723mod/NPatch)
			dl_gh_v2 "7723mod/NPatch" "latest" "npatch.jar" "jar"
			cliType="npatch"
			patchExt=".apk"
			;;
		*)
			echo "Unknown CLI, exiting."
			exit 1
			;;
	esac
	cliVer=$tag
	echo -e "CLI: $cli\nVersion: $cliVer\n\n" >> CHANGELOG.md
	echo -e "{ \"cli\": \"$cli\", \"version\": \"$cliVer\" }" >> ./release/version.jsonl
}
dl_patch() {
	name=$(jq -r '.name // ""' <<< "$line")
	repo=$(jq -r '.repo // ""' <<< "$line")
	src=$(jq -r '.src // ""' <<< "$line")
	filter=$(jq -r '.filter // ""' <<< "$line")
	excludeFilter=$(jq -r '.excludeFilter // ""' <<< "$line")	
	case $src in
		github)
			eval dl_gh_v2 "$repo" "$tag" "$patchname$patchExt" $filter $excludeFilter
			changelog_url="https://github.com/$patchsrc/releases/tag/$tag"
			;;
		gitlab)
			dl_gl_mod "$repo" "$tag" "$patchname$patchExt"
			changelog_url="https://gitlab.com/$patchsrc/-/tags/$tag"
			;;
		*)
			echo "Unknown patch source, skipping."
			;;
	esac
	patchVersion=$tag
	echo -e "{ \"patchname\": \"$patchname\", \"patchsrc\": \"$repo\", \"source\": \"$src\", \"version\": \"$patchVersion\" }" >> ./release/version.jsonl
	echo -e "Patch: $patchname\nSource: $repo($src)\nVersion: $patchVersion\nChangelog: $changelog_url\n\n" >> CHANGELOG.md
}
get_app(){
	appPkgName=$(yq eval '.[strenv(query)].appPkgName' $configfile) || true
	apkType=$(yq eval '.[strenv(query)].apkType' $configfile) || true
	appVersion=$(yq eval '.[strenv(query)].appVersion' $configfile) || true
	apkSrc=$(yq eval '.[strenv(query)].apkSrc' $configfile) || true
	apkArchs=$(yq eval '.[strenv(query)].apkArchs' -o=j -I=0 $configfile) || true
	apkDLParams=$(yq eval '.[strenv(query)].apkDLParams' -o=j -I=0 $configfile) || true
	if [[ $appVersion == "latest" ]]; then
	   lock_version=1
	elif [[ -n $appVersionCmd ]]; then
	   eval "$appVersionCmd"
	elif [[ $cliType == "morphe" ]] || [[ $cliType == "revanced" ]]; then
	   detect_version_mod "$appPkgName" "$patchname$patchExt"
	fi
	while read -r arch; do
		case $apkSrc in
			apkmirror)
				eval get_apk "$appPkgName" "$appname-$arch" "$apkType" "$arch" $apkDLParams
				;;
			apkpure)
				eval get_apkpure "$appPkgName" "$appname-$arch" "$apkType" "$arch" $apkDLParams
				;;
			github)
				eval dl_gh_v2 "$appRepo" "$appTag" "$appname-$arch.apk" $apkDLParams
				;;
			custom)
				eval "$apkDLcmd"
				;;
			*)
				echo "Unknown APK source, skipping."
				;;
			esac
			appVersion=$(java -jar ./APKEditor.jar info -i ./download/$appname-$arch.apk -version-name  -t json | jq -r '.[].VersionName')
			echo -e "{ \"appname\": \"$appname\", \"appVersion\": \"$appVersion\" , \"arch\": \"$arch\", \"apkSrc\": \"$apkSrc\", \"appRepo\": \"$appRepo\", \"appTag\": \"$appTag\", \"apkDLParams\": \"$apkDLParams\" }" >> ./release/version.jsonl
	done < <(jq -r '.[]' <<< "$apkArchs")
	echo -e "App: $appname\nVersion: $appVersion\n\n" >> CHANGELOG.md
}
rvpatcher(){
    get_app
	pversion=""
	while read -r line; do
	    if [[ -z $lineno ]]; then
	        lineno=1
	    fi
		dl_patch
		pversion="$pversion-p$patchVersion"
		if [[ $lineno -eq 1 ]]; then
		    detect_version_mod "$appPkgName" "$name.mpp"
		fi
		lineno=$((lineno + 1))
	done < <(jq -c '.[]'  <<< "$patches")
	while read -r arch; do
		patch_mod
		if [[ $buildModule == "true" ]]; then
		    makeModule="true"
			patch_mod
			unset makeModule
		fi
	done < <(jq -r '.[]' <<< "$archs")
}

npatcher() {
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
		mv ./release/$appname-$arch-*-npatched.apk "./release/$appname-$arch-$patchname-$appVersion-$patchVersion.apk"
		unset lock_version	
	done < <(jq -r '.[]' <<< "$archs")

}	
patcher(){
	export query=$appname-$patchname
	archs=$(yq eval '.[strenv(query)].archs' -o=j -I=0 $configfile) || true
	patches=$(yq eval '.[strenv(query)].patches' -o=j -I=0 $configfile) || true
	apkSrc=$(yq eval '.[strenv(query)].apkSrc' $configfile) || true
	cli=$(yq eval '.[strenv(query)].cli' $configfile) || true	
	buildModule=$(yq eval '.[strenv(query)].buildModule' $configfile) || true
	case $cli in
		MorpheApp/morphe-cli)
			dl_cli
			rvpatcher
			;;
		ReVanced/revanced-cli)
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
				sign "./download/$appname-$arch.apk" "./release/$appname-$arch-signed-$version.apk"
				rm -f "./release/*.idsig"
			done < <(jq -r '.[]' <<< "$archs")
			;;
		*)
			echo "Unknown CLI type, exiting."
			exit 1
			;;
	esac
}
patcher
