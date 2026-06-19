# How to customize this repo

> [!IMPORTANT]
> Remember to append your apps onto `utils.sh` for simplicity.

> [!NOTE]
> Custom patches are made using [Apktool M](https://maximoff.su/apktool/?lang=en), diff, and then ChatGPT to generate a sed patch for that diff.

## `src/build/utils.sh` syntax

- Download from GitHub `dl_gh $repo $owner $tag`
  - where `$repo` refers to the repository
  - `$owner` refers to the owner of such repository
  - `$tag` refers to the version/github tag of the required binary
  - `$tag` can also contain `latest` to download the latest stable release
  - `prerelease` for the latest prerelease
- GitLab syntax is similar but replace `dl_gh` with `dl_gl`
- For APKMirror APK downloads, first see `src/build/apps.json` to know the template of links, then after adding apps use `get_apk $apppkgname $appname $filetype $arch $dpi $androidversion`
  - where `$apppkgname` refers to the Android package name
  - `$appname` refers to the friendly app name and see build scripts for details
  - `$filetype` is either `bundle`, `bundle_extract`, or `apk` depending upon the app
  - `$arch`, `$dpi`, and `$androidversion` are optional and are needed in some cases; refer to build scripts at `src/build` for more info
- For apkpure, syntax is similar but replace with `dl_apkpure`
- `get_patches_key $appname-$patchname` is used to initialise custom options
  - where `$appname` refers to the provided app name and `$patchname` refers to the provided patch name
- `patch $apkname $patchname $cli` refers to the main ReVanced patching command
  - where `$apkname` is the name of the APK
  - `$patchname` is the name of the patches bundle
  - `$cli` is the name of the patcher; it can be `revanced` or `morphe`
  - if `$apkname` is `repatch`, it takes the previous APK and patches it with a different patch
- `check_experimental $apppkgname` is specific to Morphe experimental app versions to get the latest experimental version from the readme
- `_fs_get $url` is usage of flaresolverr against `$url`, which is protected by anti-bot measures; it outputs `$html` and `$FS_COOKIES` for content and cookies respectively
- `npatch $baseapkname $moduleapkname $modulename` is used for Xposed patches
  - where `$baseapkname` refers to the original APK name
  - `$moduleapkname` refers to the name of the module APK
  - `$modulename` is a fancy name of the module
- `sign $input $output` is used to sign an app that is usually custom patched, with `$input` and `$output` referring to APKs

> [!REMEMBER]
> Remember to set `$version` before revanced/npatch to get the name of the original app version at the end of revanced/morphe/Xposed patches. Refer to `src/build/build.sh` for more info. Use it as a template for getting started.

## `src/build/build.sh` syntax

> [!SYNTAX]
> The script can be launched as `src/build/build.sh $appname-$patchname`

- First there are functions to download dependencies
- Then there are main patching blocks
- Then there are case blocks for the script to be executed with a specific patch

## For ReVanced/Morphe patches

1. If you want an `options.json`, put it as `$patches-name.json` in `src/options`, where `$patches-name` refers to patch names like `piko`, `revanced`, `morphe`, etc. For example: `src/options/morphe.json`
2. For simple patch exclusion/inclusion, check `src/options/$(appname-patchname)/exclude-patches` and `include-patches` respectively
   - Syntax for those files is one patch per line with options separated with `|`
   - For example: `Custom branding|-OappName="YouTube ReVanced" -OiconPath=ReVanced*Logo`
3. If you want to add new apps, see the syntax of `utils.sh` above

## KeyStore

You need a keystore to patch and sign apps. Morphe/ReVanced CLI automatically creates one, but for safe updates you need your own.

To create a keystore, refer online and try to use GUI utilities such as https://keystore-explorer.org/

You will provide an alias and password when generating a certificate and keystore.

The keystore must be in the form of BKS (Bouncy Castle KeyStore) for compatibility with Morphe/ReVanced CLI.
