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
check_experimental() {
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
       if [ $exclude="exclude" ]; then
          urls=$(gh release view $tag --repo $repo  --json assets --jq '.assets[] | select(.name | contains("'$filter'") | not)) | .url')
       else
	      urls=$(gh release view $tag --repo $repo  --json assets --jq '.assets[] | select(.name | contains("'$filter'")) | .url')
       fi
	else
	   urls=$(gh release view $tag --repo $repo  --json assets --jq '.assets[] | .url')
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
release_name=$tag
# Modified version of detect_version to handle for a specific file
detect_version_mod() {
	if [ -z "$version" ] && [ "$lock_version" != "1" ]; then
	  for spec in "revanced-cli-|5|*.rvp" "morphe-cli-|1|*.mpp"; do
		IFS="|" read -r jar_prefix min_major patch_glob <<<"$spec"

		if [[ $(ls "${jar_prefix}"*.jar 2>/dev/null) =~ ${jar_prefix}([0-9]+) ]]; then
		  num=${BASH_REMATCH[1]}

		  if [ "$num" -ge "$min_major" ]; then
			if [[ "$jar_prefix" == "morphe-cli-" ]]; then
			  list_patches_flags="list-patches --with-packages --with-versions --with-options --patches"
			elif [ "$num" -ge 6 ]; then
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
		  else
			version=$(jq -r '[.. | objects | select(.name == "'"$1"'" and .versions != null) | .versions[]] | reverse | .[0] // ""' *.json 2>/dev/null | uniq)
		  fi
		fi

		[ -n "$version" ] && break
	  done
	fi
}

# Modified version of patch to  handle custom keystore and file name.
patch_mod() {
	green_log "[+] Patching $1:"
	if [ -f "./download/$1.apk" ]; then
		local p b m ks a pu opt force
		if [ "$3" = inotia ]; then
			p="patch " b="-p $2.rvp" m="" a="" pu="--purge=true" opt="--legacy-options=./src/options/$2.json" force=" --force"
			echo "Patching with Revanced-cli inotia"
		elif [ "$3" = morphe ]; then
			p="patch " b="-p $2.mpp" m="" a=""  pu="--purge=true" opt="--options-file ./src/options/$2.json" force=" --force --continue-on-error"
			echo "Patching with Morphe"
		else
			if [[ $(ls revanced-cli-*.jar) =~ revanced-cli-([0-9]+) ]]; then
				num=${BASH_REMATCH[1]}
				if [ $num -eq 6 ]; then
					p="patch " b="-bp $2.rvp" m="" a="" pu="--purge=true" opt="" force=" --force"
					echo "Patching with Revanced-cli version 6+"
				elif [ $num -eq 5 ]; then
					p="patch " b="-p $2.rvp" m="" a="" pu="--purge=true" opt="" force=" --force"
					echo "Patching with Revanced-cli version 5"
				elif [ $num -eq 4 ]; then
					p="patch " b="--patch-bundle *patch*.jar" m="--merge *integration*.apk " a="" ks=" --keystore=./src/ks.keystore" pu="--purge=true" opt="--options=./src/options/$2.json "
					echo "Patching with Revanced-cli version 4"
				elif [ $num -eq 3 ]; then
					p="patch " b="--patch-bundle *patch*.jar" m="--merge *integration*.apk " a="" ks=" --keystore=./src/_ks.keystore" pu="--purge=true" opt="--options=./src/options/$2.json "
					echo "Patching with Revanced-cli version 3"
				elif [ $num -eq 2 ]; then
					p="" b="--bundle *patch*.jar" m="--merge *integration*.apk " a="--apk " ks=" --keystore=./src/_ks.keystore" pu="--clean" opt="--options=./src/options/$2.json " force=" --experimental"
					echo "Patching with Revanced-cli version 2"
				fi
			fi
		fi
		if [[ "$3" = inotia || "$3" = morphe ]]; then
			unset CI GITHUB_ACTION GITHUB_ACTIONS GITHUB_ACTOR GITHUB_ENV GITHUB_EVENT_NAME GITHUB_EVENT_PATH GITHUB_HEAD_REF GITHUB_JOB GITHUB_REF GITHUB_REPOSITORY GITHUB_RUN_ID GITHUB_RUN_NUMBER GITHUB_SHA GITHUB_WORKFLOW GITHUB_WORKSPACE RUN_ID RUN_NUMBER
		fi
		name_out=$1-$2-$version-p$release_name
		name_in=$1
		eval java -jar *cli*.jar $p$b --keystore=./ks.keystore --keystore-password=$KEYSTORE_PASS --keystore-entry-password=$KEYSTORE_PASS --keystore-entry-alias=$KEYSTORE_ALIAS $m$opt --out=./release/$name_out.apk $excludePatches$includePatches $pu$force $a ./download/$name_in.apk
		unset lock_version
		unset excludePatches
		unset includePatches
	else
		red_log "[-] Not found $1.apk"
		exit 1
	fi
}

# Repach APK with new patch
repatch() {
	mv ./release/$name_out.apk ./download/
	name_in=$name_out
	name_out=$name_out-p$release_name
	patch_mod $name_in $1 $2
}

# Modified version of npatch to handle custom keystore and bouncy castle provider.
npatch_mod() {
	green_log "[+] Patching $1:"
	if [ -f "./download/$1.apk" ]; then
		local module
		if [[ "$2" == *.apk ]]; then
			local -a matches=($2)
			module="${matches[0]}"
		else
			module="$2.apk"
		fi
		if [[ ! -f "$module" ]]; then
			red_log "[-] Module not found: $2"
			return 1
		fi
        mv jar*.jar jar-npatch.jar
		if [[ "$OSTYPE" == "cygwin" ]]; then
			green_log "[+] Detected Windows environment, using Windows version of npatch"
			java -cp "bcprov.jar;jar-npatch.jar" -Djava.security.properties=bc.security top.nkbe.npatch.patch.NPatch ./download/$1.apk -k ks.keystore  $KEYSTORE_PASS $KEYSTORE_ALIAS $KEYSTORE_PASS -m "$module" -o ./release/
		else
			java -cp "bcprov.jar:jar-npatch.jar" -Djava.security.properties=bc.security top.nkbe.npatch.patch.NPatch ./download/$1.apk -k ks.keystore  $KEYSTORE_PASS $KEYSTORE_ALIAS $KEYSTORE_PASS -m "$module" -o ./release/
		fi
		mv ./release/$1-*-npatched.apk "./release/$1-$3-$version.apk"
		unset lock_version
	else
		red_log "[-] Not found $1.apk"
		exit 1
	fi
}

# Make module from patched APK
make_module() {
	release_name=$(echo $release_name | sed 's/"//g')
	local pkg_id=$1 module_name=$2
	if [ -f "./updates/$2-$3.json" ]; then
		yellow_log "[-] Existing update found for $2-$3, incrementing version code"
	   code=$(jq -r '.versionCode' ./updates/$2-$3.json)
	   rm -f ./updates/$2-$3.json
	   code=$((code+1))
	else
		yellow_log "[-] No existing update found for $2-$3, starting with version code 1"
	   code=1
	fi
	green_log "[+] Making module for $2-$3 with version code $code"
	cp -r  rv_module/module/. module
	cp ./release/$2-$3*.apk module/base.apk
	mkdir -p ./module/stock
	cp ./download/$2.apk ./module/stock/base.apk
	echo -e "PKG_NAME=$1\nPKG_VER=$version\nMODULE_ARCH=$5" > ./module/config
	echo -e "id=$2-$3\nname=$2-$3\nversion=$version (patches $3 - $release_name)\nversionCode=$code\nauthor=sharath-5br2r\ndescription=$2 $3 Module\nupdateJson=https://raw.githubusercontent.com/sharath-5br2r/patched-apks-builder/main/updates/$2-$3.json" > ./module/module.prop
	zip -r "./release/$2-$3-$version-p$release_name.zip" ./module/ > /dev/null 2>&1
	rm -rf ./module ./release/$2-$3*.apk
	if [[ $(git config user.name) == "github-actions[bot]" ]]; then 
		git pull
		echo -e "{\n\"version\":\"$version\",\n\"versionCode\":$code,\n\"zipUrl\":\"https://github.com/sharath-5br2r/patched-apks-builder/releases/download/$4/$2-$3-$version-p$release_name.zip\"\n}" > ./updates/$2-$3.json
		git add ./updates/$2-$3.json
		git commit -am "Update $2-$3 module to version $version (patches $3 - $release_name)"
		git push || true
	fi
}