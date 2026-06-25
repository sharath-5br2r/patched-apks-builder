#!/bin/bash
echo "[+] Fetching all releases..."
releases=$(gh release list --limit 1000 | awk '{print $1}')

if [ -n "$releases" ]; then
for tag in $releases; do
    echo "[+] Deleting release and tag: $tag"
    gh release delete "$tag" --yes --cleanup-tag || true
done
else
echo "[*] No releases found to delete."
fi

# In case there are tags without releases
echo "[+] Fetching remaining tags..."
tags=$(git ls-remote --tags origin | awk -F/ '{print $3}' | grep -v "\^{}" || true)
if [ -n "$tags" ]; then
for tag in $tags; do
    echo "[+] Deleting orphan tag: $tag"
    git push origin --delete "$tag" || true
done
else
echo "[*] No orphan tags found to delete."
fi