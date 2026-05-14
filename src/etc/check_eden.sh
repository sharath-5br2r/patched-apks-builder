#!/bin/bash

# Check new Eden Version:

checker(){
	local date1 date2 date1_sec date1_sec ur_repo=$repository tag=
	date1=$(gh run list -R Eden-CI/Workflow -w nightly.yml --status success --limit 1 --json updatedAt  -q ".[0].updatedAt")
	date2=$(gh api repos/$ur_repo/releases |jq -r 'first(.[] | select(.tag_name == "'Eden PUBG'") | .assets[] | .updated_at )')
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
checker