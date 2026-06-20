## GitHub Actions

This repository uses GitHub Actions to automate APK patching. If you want your own version, follow the steps below.

## Required Secrets

To create secrets, go to the **Settings** tab, then select **Actions** under **Secrets and variables** in the **Security and quality** section. Then click **New repository secret**.

The following secrets are required:

- `KEYSTORE`: Base64-encoded version of your BKS keystore. Use:
  ```sh
  base64 ks.keystore
  ```
- `KEYSTORE_ALIAS`: Signing alias of the keystore.
- `KEYSTORE_PASS`: Password of the keystore.

## Syntax

- `.github/workflows/manual-patch.yml` contains every patch you need to manually patch.

  To add a new app:
  - Copy any one of the existing blocks.
  - Modify the `if` trigger to the name of your app.
  - Modify `build.sh` to point to your app.
  - Rename the release to your app.
  - Remember to modify the `options:` of the `org:` block and the `org` in the `if:` statement.

  It can be triggered manually using the **Actions** menu or from other workflows.

- `src/etc/check.sh` is the checker scrupt for GitHub and GitLab, respectively, used to determine whether a new app should be built.

  Syntax:
  ```sh
  bash src/etc/check.sh $source $reponame $channel $urtag
  ```

  > Where:
  > - `$source` is either `gh` for github, `gl` for gitlab and `eden` is purpose built for eden emulator ci.
  > - `$reponame` is formatted as `Owner/Repo`.
  > - `$channel` is either `latest`, `prerelease`, or `$remotetag`, which is the tag of the remote repository.
  > - `$urtag` is the name of the tag where the APK is present in your repository.

- `.github/workflows/new_ci.yml` checks for new patches on GitHub/GitLab every 4 hours and runs some patches always

  To add a new app:
  - Copy one of the existing check blocks.
  - Modify the patch repository, APK pattern, and release tag used by the checkers.
  - Add your check output at the end of the `check:` job.
  - Copy a patching block and modify its check variable in the `if:` field and the `org:` field.

- `.github/workflows/ci_.yml` and  `.github/workflows/ci.yml` are untouched upstream files to maintain merge compatiblity.

## Instructions

1. Select the **Actions** tab.
2. Select the **Manual Patch** workflow.
3. Click **Run workflow**.
4. Select your app or `all` to patch all apps.
