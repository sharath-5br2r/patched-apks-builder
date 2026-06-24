#!/bin/bash
query=$1
jsonl=$(gh release download $1 --pattern "version.jsonl" --clobber)
while read -r line; do
    patchname=$(jq -r '.patchname // ""' <<< "$line")
    patchsrc=$(jq -r '.patchsrc // ""' <<< "$line")
    version=$(jq -r '.version // ""' <<< "$line")
    source=$(jq -r '.source // ""' <<< "$line")
    case $source in
        "github")
            tag=$(gh release list --repo $repo --limit 1 --json tagName --jq '.[].tagName')
	        ;;
        "gitlab")
            repo=${repo//\//%2F}
            api_url="https://gitlab.com/api/v4/projects/$repo/releases"
            releases=$(wget -qO- "$api_url")
            tag=$(echo "$release" | jq -r '.tag_name')
            ;;
    esac
    
    if [ "$tag" != "$version" ] && [ "$tag" = "$(echo -e "$tag\n$version" | sort -V | tail -n1)" ]; then
        echo "new_patch=1" >> $GITHUB_OUTPUT
        echo -e "\e[32mNew patch, building...\e[0m"
    else
        echo "new_patch=0" >> $GITHUB_OUTPUT
        echo -e "\e[31mNo new patch, skipping build.\e[0m"
    fi

done <<< "$jsonl"