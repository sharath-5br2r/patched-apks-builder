#!/bin/bash
if [[ -n $1 ]] && [[ -n $2 ]]; then
	appname=$1
	patchname=$2
fi
configfile="build.toml"
source ./src/build/utils.sh
patch_mod() {
	name_in=$appname-$arch
	orig_name_in=$appname-$arch
	name_out="$name_in"
	local p b m ks a pu opt force
	if [ "$cliType" = "morphe" ]; then
		pu="--purge=true" force=" --force --continue-on-error"
		toolmsg="Morphe"
	elif [ "$cliType" = "revanced" ]; then
		b="-bp $name.rvp" pu="--purge=true"  force=" --force"
		toolmsg="Revanced"
	fi
	if [[ "$clitype" = morphe ]]; then
		unset CI GITHUB_ACTION GITHUB_ACTIONS GITHUB_ACTOR GITHUB_ENV GITHUB_EVENT_NAME GITHUB_EVENT_PATH GITHUB_HEAD_REF GITHUB_JOB GITHUB_REF GITHUB_REPOSITORY GITHUB_RUN_ID GITHUB_RUN_NUMBER GITHUB_SHA GITHUB_WORKFLOW GITHUB_WORKSPACE RUN_ID RUN_NUMBER
	fi
	if [[ $makeModule == "true" ]]; then
		name_out="$name_in-module"
	fi
	options=""
	pname=""
	rootCliOptions=""
	if [[ "$cliType" == "morphe" ]]; then
		while read -r line; do
			cliOptions=$(jq -r '.cliOptions // ""' <<< "$line")
			name=$(jq -r '.name // ""' <<< "$line")
			options="$options -p $name.mpp $cliOptions"  
			pname="$pname-$name"
			rootCliOptions="$rootCliOptions $(jq -r '.rootCliOptions // ""' <<< "$line")"
		done < <(jq -c '.[]'  <<< "$patches")
		name_out="$name_out$pname-$appVersion$pversion"
	else
		rootCliOptions=$(jq -r '.rootCliOptions // ""' < <(jq -c '.[0]'  <<< "$patches"))
		cliOptions=$(jq -r '.cliOptions // ""' < <(jq -c '.[0]'  <<< "$patches"))
		pname=$(jq -r '.name // ""' < <(jq -c '.[0]'  <<< "$patches"))
		pversion=$patchversion
		name_out="$name_out-$pname-$appVersion-p$patchversion"
		options="$b $cliOptions"
	fi   
	if [[ $makeModule == "true" ]]; then
		options="$options $rootCliOptions"
	fi
	green_log "[+] Patching $name_in with $toolmsg $cliVer and $pname $pversion"
	eval java -jar *cli*.jar patch --keystore=./ks.keystore --keystore-password=$KEYSTORE_PASS --keystore-entry-password=$KEYSTORE_PASS --keystore-entry-alias=$KEYSTORE_ALIAS  --out=./release/$name_out.apk $options $pu$force $a ./download/$name_in.apk
	unset lock_version
	unset options
	if [[ $makeModule == "true" && -f ./release/$name_out.apk ]]; then
		repotag="$appname$pname"
		code=$(gh api "/repos/$repository/releases/tags/$repotag" | jq -r '.assets[]? | select(.name == "update-$arch.json") | .url' | xargs wget -qO- | jq -r '.versionCode // 0') || yes
		if [ -z "$code" ] ; then
			code=1
		else
			code=$((code + 1))
		fi
		green_log "[+] Making module for $name_in with version code $code"
		git clone https://github.com/j-hc/revanced-magisk-module --depth 1 rv_module > /dev/null 2>&1
		cp -r  rv_module/module/. module
		cp ./release/$name_out.apk module/base.apk
		mkdir -p ./module/stock
		cp ./download/$name_in.apk ./module/stock/base.apk
		if [[ $arch != "arm64-v8a" && $arch != "armeabi-v7a" && $arch != "x86_64" && $arch != "x86" ]]; then
			archname=""
		else
			archname=$arch
		fi
		echo -e "PKG_NAME=$appPkgName\nPKG_VER=$appVersion\nMODULE_ARCH=$archname" > ./module/config
		echo -e "id=$appname-$arch\nname=$appname$pname\nversion=$version (patches $pname - $pversion)\nversionCode=$code\nauthor=sharath-5br2r\ndescription=$appname $pname Module\nupdateJson=https://github.com/$repository/releases/tag/$repotag/update-$arch.json" > ./module/module.prop
		zip -r "./release/$name_out.zip" ./module/ > /dev/null 2>&1
		echo -e "{\n\"version\":\"$version\",\n\"versionCode\":$code,\n\"zipUrl\":\"https://github.com/$repository/releases/download/$repotag/$name_out.zip\"\n}" > ./release/update-$arch.json
		green_log "[+] Module created: ./release/$name_out.zip"
		rm -rf ./module ./release/$name_out.apk ./rv_module
	fi
}

dl_cli() {
	case $cliType in
		morphe)
			dl_gh "morphe-cli" "MorpheApp" "latest"
			patchExt=".mpp"
			;;
		revanced)
			dl_gh "revanced-cli" "ReVanced" "latest"
			patchExt=".rvp"
			;;
		npatch)
			dl_gh "NPatch" "7723mod" "latest" "npatch.jar" "jar"
			patchExt=".apk"
			;;
		*)
			echo "Unknown CLI, exiting."
			exit 1
			;;
	esac
	cliVer=$tag
	echo -e "CLI: $cliType\nVersion: $cliVer\n\n" >> CHANGELOG.md
}
dl_patch() {
	name=$(jq -r '.name // ""' <<< "$line")
	repo=$(jq -r '.repo // ""' <<< "$line")
	owner=$(jq -r '.owner // ""' <<< "$line")
	tag=$(jq -r '.tag // ""' <<< "$line")
	src=$(jq -r '.src // ""' <<< "$line")
	filter=$(jq -r '.filter // ""' <<< "$line")
	excludeFilter=$(jq -r '.excludeFilter // ""' <<< "$line")	
	case $src in
		github)
			eval dl_gh "$repo" "$owner" "$tag" "$name$patchExt" $filter $excludeFilter
			changelog_url="https://github.com/$owner/$repo/releases/tag/$tag"
			;;
		gitlab)
			dl_gl "$repo" "$owner" "$tag" "$name$patchExt"
			changelog_url="https://gitlab.com/$owner/$repo/-/tags/$tag"
			;;
		*)
			echo "Unknown patch source, skipping."
			;;
	esac
	patchVersion=$tag
	echo -e "Patch: $patchname\nSource: $owner/$repo($src)\nVersion: $patchVersion\nChangelog: $changelog_url\n\n" >> CHANGELOG.md
}
get_app(){
	appPkgName=$(yq eval -e  '.[strenv(query)].appPkgName' $configfile) || appPkgName=
	apkType=$(yq eval -e '.[strenv(query)].apkType' $configfile) || apkType=
	appVersion=$(yq eval -e '.[strenv(query)].appVersion' $configfile) || appVersion=
	appVersionCmd=$(yq eval -e '.[strenv(query)].appVersionCmd' $configfile) || appVersionCmd=
	apkSrc=$(yq eval -e '.[strenv(query)].apkSrc' $configfile) || apkSrc=
	archs=$(yq eval -e '.[strenv(query)].archs' -o=j -I=0 $configfile) || archs=
	apkDLParams=$(yq eval -e '.[strenv(query)].apkDLParams' $configfile) || apkDLParams=
	appRepo=$(yq eval -e '.[strenv(query)].appRepo' $configfile) || appRepo=
	appOwner=$(yq eval -e '.[strenv(query)].appOwner' $configfile) || appOwner=
	appTag=$(yq eval -e '.[strenv(query)].appTag' $configfile) || appTag=
	if [[ $appVersion == "latest" ]]; then
	   lock_version=1
	elif [[ -n $appVersionCmd ]]; then
	   eval "$appVersionCmd"
	elif [[ $cliType == "morphe" ]] || [[ $cliType == "revanced" ]]; then
	   detect_version "$appPkgName" "$patchname$patchExt"
	fi
	    
	while read -r arch; do
		case $apkSrc in
			apkmirror)
				eval get_apk "$appPkgName" "$appname-$arch" "$apkType" $arch $apkDLParams
				;;
			apkpure)
				eval get_apkpure "$appPkgName" "$appname-$arch" "$apkType" $arch $apkDLParams
				;;
			google_play)
			    eval get_apk_chplay "$appPkgName" "$appname-$arch" "$apkType" $apkDLParams
				;;
			github)
				eval dl_gh "$appRepo" "$appOwner" "$appTag" "$appname-$arch.apk" $apkDLParams
				;;
			custom)
				eval "$apkDLcmd"
				;;
			*)
				echo "Unknown APK source, skipping."
				;;
			esac
			appVersion=$(java -jar ./APKEditor.jar info -i ./download/$appname-$arch.apk -version-name  -t json | jq -r '.[].VersionName')
	done < <(jq -r '.[]' <<< "$archs")
	echo -e "App: $appname\nVersion: $appVersion\n\n" >> CHANGELOG.md
}
rvpatcher(){
	pversion=""
	while read -r line; do
	    if [[ -z $lineno ]]; then
	        lineno=1
	    fi
		dl_patch
		pversion="$pversion-p$patchVersion"
		lineno=$((lineno + 1))
	done < <(jq -c '.[]'  <<< "$patches")
	get_app
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
	get_app
	while read -r arch; do
		green_log "[+] Patching $appname-$arch:"
		if [[ "$OSTYPE" == "cygwin" ]]; then
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
	archs=$(yq eval '.[strenv(query)].archs' -o=j -I=0 $configfile) || archs=
	patches=$(yq eval '.[strenv(query)].patches' -o=j -I=0 $configfile) || patches=
	apkSrc=$(yq eval '.[strenv(query)].apkSrc' $configfile) || apkSrc=
	cliType=$(yq eval '.[strenv(query)].cliType' $configfile) || cliType=
	buildModule=$(yq eval '.[strenv(query)].buildModule' $configfile) || buildModule=
	case $cliType in
		morphe)
			dl_cli
			rvpatcher
			;;
		revanced)
			dl_cli
			rvpatcher
			;;
		npatch)
		    dl_cli
			npatcher
			;;
		apksigner)
			get_app
            while read -r arch; do
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
