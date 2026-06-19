### This repository uses GitHub actions for automating patching of apks. If you want your own version follow the steps.
## Required Secrets
 To create secrets, go to `Settings` tab then Select `Actions` under `Secrets and Variables` under `Security and quality`. Then click `New repository secret`
 Here are following secrets
 - KEYSTORE: base64 encoded version of your bks keystore. use `base64 ks.keystore`
 - KEYSTORE_ALIAS: signing alias of keystore
 - KEYSTORE_PASS: password of keystore
## Syntax
- `.github/workflows/manual-patch.yml` contains every patch you need to manually patch. To add a new app copy any one of the blocks, modify if trigger to name of your app,  modify `build.sh` to point at your app and rename releases to your app. It is triggered manually using Actions menu and from other workflows. Remember to modify `options:` of `org:` block and `org` at `if:` statement.
- `src/etc/ci.sh` and `src/etc/_ci.sh` are checkers for GitHub and GitLab respectively to check whether to build a new app. The syntax is `bash src/etc/ci.sh $reponame $channel $pattern $urtag`
  > where `$reponame` is formatted as Owner/Repo
  >   `$channel` is either `latest`, `prerelease` or `$remotetag` which is the tag of remote repo
  >   `$pattern` is name of released apk pattern
  >   `$urtag` is name of tag where is apk is present in your repo
 
- `.github/workflows/ci.yml` contains code that checks for new patches on GitHub/GitLab every 4 hrs. Copy each block and modify patch repo, apk pattern and release tag for checkers, then add your check output at end of `check:` job and finally copy patching block and edit your check variable  at `if:` field and `org:` field.
- `.github/workflows/ci_.yml` contains code that always runs every 4 hrs. It is used for apps that dont have a proper way to check for latest version. Just copy a block and modify `org:` field
## Instructions
 Select `Actions` tab and then select `Manual Patch` workflow
 Hit `Run workflow` and select ur app/all to patch apps.
