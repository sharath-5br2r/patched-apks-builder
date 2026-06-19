#!/bin/bash

# Check new patch:
get_date_gh() {
	json=$(wget -qO- "https://api.github.com/repos/$1/releases")
	if [ ! -z $3 ]; then
		case "$2" in
			latest)
				updated_at=$(echo "$json" | jq -r 'first(.[] | select(.prerelease == false) | .assets[] | select(.name | test("'$3'")) | .updated_at)')
				;;
			prerelease)
				updated_at=$(echo "$json" | jq -r 'first(.[] | select(.prerelease == true) | .assets[] | select(.name | test("'$3'")) | .updated_at)')
				;;
			*)
				updated_at=$(echo "$json" | jq -r '[.[] | select(.tag_name == "'$2'") | .assets[] | select(.name | test("'$3'"))] | sort_by(.updated_at) | last | .updated_at')
				;;
		esac
	else
		case "$2" in
			latest)
				updated_at=$(echo "$json" | jq -r 'first(.[] | select(.prerelease == false) | .assets[] | select(.name | .updated_at )')
				;;
			prerelease)
				updated_at=$(echo "$json" | jq -r 'first(.[] | select(.prerelease == true) | .assets[] | select(.name | .updated_at )')
				;;
			*)
				updated_at=$(echo "$json" | jq -r '[.[] | select(.tag_name == "'$2'") | .assets[] | select(.name | test("'$3'"))] | sort_by(.updated_at) | last | .updated_at')
				;;
		esac
	fi
	echo "$updated_at"
}
get_date_gl() {
	local project_path
	project_path=$(echo "$1" | sed 's|/|%2F|g')
	json=$(wget -qO- "https://gitlab.com/api/v4/projects/${project_path}/releases")
	case "$2" in
		latest)
			updated_at=$(echo "$json" | jq -r 'first(.[] | select(.tag_name | test("-dev") | not) | select(.assets.links[] | .name | test("'"$3"'")) | .released_at)')
			;;
		prerelease)
			updated_at=$(echo "$json" | jq -r 'first(.[] | select(.tag_name | test("-dev")) | select(.assets.links[] | .name | test("'"$3"'")) | .released_at)')
			;;
		*)
			updated_at=$(echo "$json" | jq -r 'first(.[] | select(.tag_name == "'"$2"'") | select(.assets.links[] | .name | test("'"$3"'")) | .released_at)')
			;;
	esac
	echo "$updated_at"
}
checker_gh(){
	local date1 date2 date1_sec date2_sec repo=$1 ur_repo=$repository 
	date1=$(get_date_gh "$repo" "$2" "^(.*\\\.jar|.*\\\.rvp|.*\\\.mpp|.*\\\.apk)$")
	date2=$(get_date_gh "$ur_repo" "$3" )
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
checker_gl(){
	local date1 date2 date1_sec date2_sec repo=$1 ur_repo=$repository check=$3
	date1=$(get_date_gl "$repo" "$2" "^(.*\\\.jar|.*\\\.rvp|.*\\\.mpp|.*\\\.apk)$")
	date2=$(get_date_gh "$ur_repo" "$3" "apk")
	[[ "$date1" == "null" ]] && date1=""
	[[ "$date2" == "null" ]] && date2=""
	if [ -z "$date1" ]; then
		echo -e "\e[31mCould not get date from GitLab for $repo\e[0m"
		return 1
	fi
	date1_sec=$(date -d "$date1" +%s)
	if [ -z "$date2" ]; then
		echo "new_patch=1" >> $GITHUB_OUTPUT
		echo -e "\e[32mNew patch, building...\e[0m"
		return
	fi
	date2_sec=$(date -d "$date2" +%s)
	if [ "$date1_sec" -gt "$date2_sec" ]; then
		echo "new_patch=1" >> $GITHUB_OUTPUT
		echo -e "\e[32mNew patch, building...\e[0m"
	else
		echo "new_patch=0" >> $GITHUB_OUTPUT
		echo -e "\e[32mOld patch, not build.\e[0m"
	fi
}

checker_eden(){
	local date1 date2 date1_sec date2_sec ur_repo=$repository
	date1=$(gh run list -R Eden-CI/Workflow -w nightly.yml --status success --limit 1 --json updatedAt  -q ".[0].updatedAt")
	date2=$(get_date_gh "$ur_repo" "eden-pubg" )
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
case $1 in
	gh)
		checker_gh $2 $3 $4
		;;
	gl)
		checker_gl $2 $3 $4
		;;
	eden)
		checker_eden
		;;
esac


