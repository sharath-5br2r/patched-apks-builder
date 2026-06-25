#!/bin/bash

# Check new patch:
get_date_gl() {
	local project_path
	project_path=$(echo "$1" | sed 's|/|%2F|g')
	json=$(wget -qO- "https://gitlab.com/api/v4/projects/${project_path}/releases")
	case "$2" in
		latest)
			updated_at=$(echo "$json" | jq -r 'first(.[] | select(.tag_name | test("-dev") | not) | select(.assets.links[] | .name | test("'"$3"'")) | .released_at)')
			;;
		prerelease)
			updated_at=$(echo "$json" | jq -r 'first(.[] | select(.tag_name | select(.assets.links[] | .name | test("'"$3"'")) | .released_at)')
			;;
		*)
			updated_at=$(echo "$json" | jq -r 'first(.[] | select(.tag_name == "'"$2"'") | select(.assets.links[] | .name | test("'"$3"'")) | .released_at)')
			;;
	esac
	echo "$updated_at"
}

get_date_gh() {
	json=$(wget -qO- "https://api.github.com/repos/$1/releases")
	case "$2" in
		latest)
			updated_at=$(echo "$json" | jq -r 'first(.[] | select(.prerelease == false) | .assets[] | select(.name | test("'$3'")) | .updated_at)')
			;;
		prerelease)
			updated_at=$(echo "$json" | jq -r 'first(.[] | .assets[] | select(.name | test("'$3'")) | .updated_at)')
			;;
		*)
			updated_at=$(echo "$json" | jq -r 'first(.[] | select(.tag_name == "'$2'") | .assets[] | select(.name | test("'$3'")) | .updated_at)')
			;;
	esac
	echo "$updated_at"
}
get_date(){
	case $4 in
	   github)
			get_date_gh "$1" "$2" "$3"
			;;
	   gitlab)
			get_date_gl "$1" "$2" "$3"
			;;
	   eden)
	        echo "$(gh run list -R Eden-CI/Workflow -w nightly.yml --status success --limit 1 --json updatedAt  -q ".[0].updatedAt")"
			;;
	esac
}
checker(){
	local date1 date2 date1_sec date1_sec repo=$1 ur_repo=$repository ur_release=$3
	date1=$(get_date "$repo" "$2" "^(.*\\\.jar|.*\\\.rvp|.*\\\.mpp|.*\\\.apk)$")
	date2=$(get_date_gh "$ur_repo" "$ur_release" "(.*\\\.apk)$")
	date1_sec=$(date -d "$date1" +%s)
	date2_sec=$(date -d "$date2" +%s)
	if [ -z "$date2" ] || [ "$date1_sec" -gt "$date2_sec" ]; then
		echo "new_patch=1" >> $GITHUB_OUTPUT
		echo -e "\e[32mNew patch, building...\e[0m"
	elif [ "$date1_sec" -lt "$date2_sec" ]; then
		echo "new_patch=0" >> $GITHUB_OUTPUT
		echo -e "\e[32mOld patch, not build.\e[0m"
	fi
}

checker $1 $2 $3 $4
