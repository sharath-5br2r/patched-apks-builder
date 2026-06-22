#!/bin/bash
source ./src/build/utils.sh

#Check if ks.keystore file exists
if [ ! -f ks.keystore ]; then
	echo "[-] Missing ks.keystore file. Please provide the keystore file."
fi
if [ -f .env ]; then
	source .env
fi

# Setup Bouncy Castle Provider
bcversion=$(curl -fsSL https://repo1.maven.org/maven2/org/bouncycastle/bcprov-jdk18on/maven-metadata.xml | grep -oPm1 '(?<=<release>)[^<]+')
echo -e "\e[32m[+] Downloading Bouncy Castle Provider\e[0m"
wget -qO bcprov.jar "https://repo1.maven.org/maven2/org/bouncycastle/bcprov-jdk18on/$bcversion/bcprov-jdk18on-$bcversion.jar"
LAST_PROV=$(grep "^security.provider\." "$JAVA_HOME/conf/security/java.security"  | grep -oP '(?<=security\.provider\.)\d+' | sort -n | tail -1)
echo "security.provider.$((LAST_PROV+1))=org.bouncycastle.jce.provider.BouncyCastleProvider"  > bc.security

#Setup Apksigner
if [ ! -f apksigner.jar ]; then
	wget -qO sdk.zip "https://dl.google.com/android/repository/build-tools_r37_linux.zip"
	unzip -q -j sdk.zip android-37.0/lib/apksigner.jar
	rm -f ./sdk.zip
fi

# Sign APK
sign() {
	if [ $OSTYPE == "cygwin" ]; then
		java -cp "bcprov.jar;apksigner.jar" com.android.apksigner.ApkSignerTool sign --ks-provider-class org.bouncycastle.jce.provider.BouncyCastleProvider  --provider-class org.bouncycastle.jce.provider.BouncyCastleProvider --ks ks.keystore --ks-type BKS --ks-key-alias $KEYSTORE_ALIAS --ks-pass pass:$KEYSTORE_PASS --in "$1" --out "$2"
    else
        java -cp "bcprov.jar:apksigner.jar" com.android.apksigner.ApkSignerTool sign --ks-provider-class org.bouncycastle.jce.provider.BouncyCastleProvider  --provider-class org.bouncycastle.jce.provider.BouncyCastleProvider --ks ks.keystore --ks-type BKS --ks-key-alias $KEYSTORE_ALIAS --ks-pass pass:$KEYSTORE_PASS --in "$1" --out "$2"
	fi
}

# Check Experimental app version for Morphe
get_experimental_version() {
 prefer_version=$(curl  https://raw.githubusercontent.com/MorpheApp/morphe-patches/refs/tags/$(gh release list --limit 1  --repo MorpheApp/morphe-patches | awk '{print $1}')/patches-list.json  | jq --arg pkg $1 -r '[.patches[].compatiblePackages[]? | select(.packageName == $pkg) | .targets[] | select(.isExperimental == true).version] | unique | sort_by(split(".") | map(tonumber)) | last')
}

# custom version of dl_gh to download with filter and output
dl_gh_v2(){
	local repo="$1"
    tag="$2"
	if [ "$tag" == "latest" ]; then
	   tag=$(gh release list --repo $repo --exclude-pre-releases --limit 1 --json tagName --jq '.[].tagName')
	elif [ "$tag" == "prerelease" ]; then
	   tag=$(gh release list --repo $repo --limit 1 --json tagName --jq '.[].tagName')
	fi
	local output=$3
	local filter=$4
    local exclude=$5
	if [ -n "$filter" ]; then
       if [[ "$exclude" == "exclude" ]]; then
          urls=$(gh release view $tag --repo $repo  --json assets | jq --arg filter "$filter" -r '.assets[] | select(.name | contains($filter) | not ) | .url')
       else
	      urls=$(gh release view $tag --repo $repo  --json assets | jq --arg filter "$filter" -r '.assets[] | select(.name | contains($filter)) | .url')
       fi
	else
	   urls=$(gh release view $tag --repo $repo  --json assets | jq -r '.assets[] | .url')
	fi
	if [[  ! "$urls" == *$'\n'* ]]; then
	   if [ -n $output ]; then
	        name=$(basename "$urls")
	        green_log "[+] Downloading $name from $repo $tag to $output"
	    	wget -qO $output $urls
	   else
	        name=$(basename "$urls")
	        green_log "[+] Downloading $name from $repo $tag"
	        wget -q $urls
       fi
	else
	   for url in $urls; do
	        name=$(basename "$url")
			green_log "[+] Downloading $name from $repo $tag"
	        wget -q $url
	   done
	fi

}

# Modifed version of dl_gl to include tag and custom domain
dl_gl_mod() {
  local repo=$1 tag=${2:-latest} output=$3 domain=$4
  if [ -z "$domain" ]; then
    domain="gitlab.com"
  fi
  repo=${repo//\//%2F}
  local api_url="https://$domain/api/v4/projects/$repo/releases"

  local releases
  releases=$(wget -qO- "$api_url")

  local release
  if [[ "$tag" == "latest" ]]; then
    release=$(echo "$releases" | jq -r '[.[] | select(.tag_name | test("-dev") | not)][0]')
  elif [[ "$tag" == "prerelease" ]]; then
    release=$(echo "$releases" | jq -r '[.[] | select(.tag_name )][0]')
  else
    release=$(wget -qO- "$api_url/$tag")
  fi

  if [[ -z "$release" ]] || [[ "$release" == "null" ]]; then
    red_log "[-] No matching release found for $owner/$repo ($tag)"
    return 1
  fi

  tag=$(echo "$release" | jq -r '.tag_name')
  local urls
  urls=$(echo "$release" | jq -r '.assets.links[] | "\(.direct_asset_url // .url)"')
  if [[  ! "$urls" == *$'\n'*  ]]; then
    if [ -n $output ]; then
        name=$(basename "$urls")
        green_log "[+] Downloading $name from $repo $tag to $output"
        wget -qO $output $urls
    else
        name=$(basename "$urls")
        green_log "[+] Downloading $name from $repo $tag"
        wget -q $urls
    fi
  else
    for url in $urls; do
        name=$(basename "$url")
        green_log "[+] Downloading $name from $repo $tag"
        wget -q $url
    done
  fi
}
# Modified version of detect_version to handle for a specific file
detect_version_mod() {
	    if [ -z "$version" ] && [ "$lock_version" != "1" ]; then
			if [[ "$clitype" == "morphe" ]]; then
				list_patches_flags="list-patches --with-packages --with-versions --with-options --patches"
			elif [ "$cliver" -ge 6 ]; then
				list_patches_flags="list-patches --packages --versions --options -bp"
			else
				list_patches_flags="list-patches --with-packages --with-versions"
			fi
			version=$(java -jar *cli*.jar $list_patches_flags $2 | awk -v pkg="$1" '
				BEGIN { found = 0; printing = 0 }
				/^Index:/ { if (printing) exit; found = 0 }
				/Package name: / { if ($3 == pkg) found = 1 }
				/Compatible versions:/ { if (found) printing = 1; next }
				printing && $1 ~ /^[0-9]+\./ { print $1 }
			' | sort -V | tail -n1)				
		fi
}

# Modified version of patch to  handle custom keystore and file name.
patch_mod() {
	if [ $1 == "repatch" ]; then
	 	mv ./release/$name_out.apk ./download/
		name_in=$name_out
		name_out="$name_out-p$patchversion"
	else 
		version=$(java -jar ./APKEditor.jar info -i ./release/$1.apk -version-name)
		name_out="$1-$2-$version-p$patchversion"
		name_in=$1
    fi
	if [ -f "./download/$1.apk" ]; then
		local p b m ks a pu opt force
		if [ "$3" = inotia ]; then
			p="patch " b="-p $2.rvp" m="" a="" pu="--purge=true" opt="--legacy-options=./src/options/$2.json" force=" --force"
			toolmsg= "Revanced-cli inotia"
		elif [ "$3" = morphe ]; then
		    p="patch " b="-p $2.mpp" m="" a="" pu="--purge=true" opt="--options-file ./src/options/$2.json" force=" --force --continue-on-error"
			toolmsg="Morphe"
		else
			if [[ $(ls revanced-cli-*.jar) =~ revanced-cli-([0-9]+) ]]; then
				num=${BASH_REMATCH[1]}
				if [ $num -eq 6 ]; then
					p="patch " b="-bp $2.rvp" m="" a="" pu="--purge=true" opt="" force=" --force"
					toolmsg="Revanced-cli"
				elif [ $num -eq 5 ]; then
					p="patch " b="-p $2.rvp" m="" a="" pu="--purge=true" opt="" force=" --force"
					toolmsg="Revanced-cli"
				elif [ $num -eq 4 ]; then
					p="patch " b="--patch-bundle *patch*.jar" m="--merge *integration*.apk " a="" ks=" --keystore=./src/ks.keystore" pu="--purge=true" opt="--options=./src/options/$2.json "
					toolmsg="Revanced-cli"
				elif [ $num -eq 3 ]; then
					p="patch " b="--patch-bundle *patch*.jar" m="--merge *integration*.apk " a="" ks=" --keystore=./src/_ks.keystore" pu="--purge=true" opt="--options=./src/options/$2.json "
					toolmsg="Revanced-cli"
				elif [ $num -eq 2 ]; then
					p="" b="--bundle *patch*.jar" m="--merge *integration*.apk " a="--apk " ks=" --keystore=./src/_ks.keystore" pu="--clean" opt="--options=./src/options/$2.json " force=" --experimental"
					toolmsg="Revanced-cli"
				fi
			fi
		fi
		if [[ "$3" = inotia || "$3" = morphe ]]; then
			unset CI GITHUB_ACTION GITHUB_ACTIONS GITHUB_ACTOR GITHUB_ENV GITHUB_EVENT_NAME GITHUB_EVENT_PATH GITHUB_HEAD_REF GITHUB_JOB GITHUB_REF GITHUB_REPOSITORY GITHUB_RUN_ID GITHUB_RUN_NUMBER GITHUB_SHA GITHUB_WORKFLOW GITHUB_WORKSPACE RUN_ID RUN_NUMBER
		fi
		green_log "[+] Patching $name_in with $toolmsg $cliver and $patchname $patchversion"
		eval java -jar *cli*.jar $p$b --keystore=./ks.keystore --keystore-password=$KEYSTORE_PASS --keystore-entry-password=$KEYSTORE_PASS --keystore-entry-alias=$KEYSTORE_ALIAS $m$opt --out=./release/$name_out.apk $excludePatches$includePatches $pu$force $a ./download/$name_in.apk
		unset lock_version
		unset excludePatches
		unset includePatches
	else
		red_log "[-] Not found $1.apk"
		exit 1
	fi
}


# Modified version of npatch to handle custom keystore and bouncy castle provider.


# Make module from patched APK
make_module() {
	patchversion=$(echo $patchversion | sed 's/"//g')
	local pkg_id=$1 module_name=$2
    code=$(gh api /repos/sharath-5br2r/patched-apks-builder/releases/tags/$2-$3 | jq -r '.assets[]? | select(.name == "update-$4.json") | .url' | xargs wget -qO- | jq -r '.versionCode // 0') || yes
	if [ -z "$code" ] ; then
		code=1
	else
		code=$((code + 1))
	fi
	green_log "[+] Making module for $2-$3 with version code $code"
	cp -r  rv_module/module/. module
	cp ./release/$2*$3*.apk module/base.apk
	mkdir -p ./module/stock
	cp ./download/$2.apk ./module/stock/base.apk
	if [[ $4 != "arm64-v8a" && $4 != "armeabi-v7a" && $4 != "x86_64" && $4 != "x86" ]]; then
		archname=""
	else
		archname=$4
	fi
	echo -e "PKG_NAME=$1\nPKG_VER=$version-p$patchversion\nMODULE_ARCH=$archname" > ./module/config
	echo -e "id=$2-$3\nname=$2-$3\nversion=$version (patches $3 - $tag)\nversionCode=$code\nauthor=sharath-5br2r\ndescription=$2 $3 Module\nupdateJson=https://github.com/sharath-5br2r/patched-apks-builder/releases/tag/$2-$3/update-$4.json" > ./module/module.prop
	zip -r "./release/$2-$3-$version-p$patchversion.zip" ./module/ > /dev/null 2>&1
	green_log "[+] Module created: ./release/$2-$3-$version-p$patchversion.zip"
	rm -rf ./module ./release/$2-$3*.apk
	echo -e "{\n\"version\":\"$version\",\n\"versionCode\":$code,\n\"zipUrl\":\"https://github.com/sharath-5br2r/patched-apks-builder/releases/download/$2-$3/$2-$3-$version-p$patchversion.zip\"\n}" > ./release/update-$4.json
}

finish() {
    echo -e "cli"
    echo -e "{ \"appname\": \"$appname\", \"patchname\": \"$patchname\" , \"appversion\": \"$version\" , \"patchversion\": \"$release_name\" }" > ./release/version.json
}