#!/bin/bash

resp=$(gh  release view $1  --json body --jq '.body')
read -r repo version < <(
awk -v patch="$2" '
$1=="Patch:" && $2==patch {
    getline; sub(/^Source:[[:space:]]*/, ""); repo=$0
    getline; sub(/^Version:[[:space:]]*/, ""); print repo, $0
    exit
}' <<<"$resp"
)
echo "Repo: $repo"
echo "Version: $version"