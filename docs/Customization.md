# How to customize this repo

> [!IMPORTANT]
> Remember to append your apps onto `utils.sh` for simplicity.

> [!NOTE]
> Custom patches are made using [Apktool M](https://maximoff.su/apktool/?lang=en), diff, and then ChatGPT to generate a `sed` patch for that diff.

## `src/build/utils.sh` syntax

- Download from GitHub: `dl_gh $repo $owner $tag`
  > Where:
  > - `$repo` refers to the repository.
  > - `$owner` refers to the owner of the repository.
  > - `$tag` refers to the version/GitHub tag of the required binary.
  > - `$tag` can also be:
  >   - `latest` for the latest stable release.
  >   - `prerelease` for the latest prerelease.

- GitLab syntax is similar, but replace `dl_gh` with `dl_gl`.

- For APKMirror APK downloads, first see `src/build/apps.json` to know the template of links. Then, after adding apps, use:
  ```sh
  get_apk $apppkgname $appname $filetype $arch $dpi $androidversion
  ```
  > Where:
  > - `$apppkgname` refers to the Android package name.
  > - `$appname` refers to the friendly app name.
  > - `$filetype` is either `bundle`, `bundle_extract`, or `apk`, depending upon the app.
  > - `$arch`, `$dpi`, and `$androidversion` are optional and are needed in some cases. Refer to the build scripts in `src/build` for more information.

- For APKPure, the syntax is similar, but replace it with `dl_apkpure`.

- `get_patches_key $appname-$patchname` is used to initialize custom options.
  > Where:
  > - `$appname` refers to the provided app name.
  > - `$patchname` refers to the provided patch name.

- `patch $apkname $patchname $cli` refers to the main ReVanced patching command.
  > Where:
  > - `$apkname` is the name of the APK.
  > - `$patchname` is the name of the patches bundle.
  > - `$cli` is the name of the patcher. It can be `revanced` or `morphe`.
  > - If `$apkname` is `repatch`, it takes the previous APK and patches it with a different patch.

- `check_experimental $apppkgname` is specific to Morphe experimental app versions to get the latest experimental version from the README.

- `_fs_get $url` uses FlareSolverr against `$url`, which is protected by anti-bot measures. It outputs the content as `$html` and cookies as `$FS_COOKIES`.

- `npatch $baseapkname $moduleapkname $modulename` is used for Xposed patches.
  > Where:
  > - `$baseapkname` refers to the original APK name.
  > - `$moduleapkname` refers to the module APK name.
  > - `$modulename` is the fancy name of the module.

- `sign $input $output` is used to sign an app, usually one that has been custom patched, where `$input` and `$output` refer to APKs.

> [!IMPORTANT]
> Remember to set `$version` before `revanced`/`npatch` to get the original app version appended to the end of ReVanced/Morphe/Xposed patches. Refer to `src/build/build.sh` for more information. Use it as a template for obtaining the version from APKMirror feeds.

## `src/build/build.sh` syntax

> [!NOTE]
> The script can be launched as:
> ```sh
> src/build/build.sh $appname-$patchname
> ```

- First, there are functions to download dependencies.
- Then, there are the main patching blocks.
- Finally, there are case blocks for executing the script with a specific patch.

## For ReVanced/Morphe patches

1. If you want an `options.json`, put it as `$patches-name.json` in `src/options`, where `$patches-name` refers to the patches name (e.g. `piko`, `revanced`, `morphe`). For example:
   ```
   src/options/morphe.json
   ```

2. For simple patch inclusion/exclusion, check:
   - `src/options/$(appname-patchname)/exclude-patches`
   - `src/options/$(appname-patchname)/include-patches`

   - Syntax for these files:
     - One patch per line, with options separated by `|`.
     - Example:
       ```
       Custom branding|-OappName="YouTube ReVanced" -OiconPath=ReVanced*Logo
       ```

3. If you want to add new apps, see the `utils.sh` syntax above.

## KeyStore

You need a keystore to patch and sign apps. The Morphe/ReVanced CLI automatically creates one, but for safe updates you should use your own.

To create a keystore, refer online and try to use GUI utilities such as <https://keystore-explorer.org/>.

You will provide an alias and password when generating a certificate and keystore.

The keystore must be in the BKS (Bouncy Castle KeyStore) format for compatibility with the Morphe/ReVanced CLI.
