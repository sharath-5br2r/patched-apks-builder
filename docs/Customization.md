# How to customize this repo
>[!Important]
>Remember to append your apps onto utils.sh for simplicity 

>[!Note]
>Custom patches are made using [Apktool M](https://maximoff.su/apktool/?lang=en), diff and then ChatGPT to generate sed patch for that diff
## `src/build/utils.sh` syntax
- Download from GitHub `dl_gh $repo $owner $tag` 
  >where `$repo` refers to repository
    `$owner` refers to owner of such repository
    `$tag` refers to version/github tag of required binary
    `$tag` can also contain `latest` to download latest stable release
    `prerelease` for latest prerelease 
- Gitlab syntax is similar but replace `dl_gh` with `dl_gl`
-  For APKMirror APK downloads first see `src/build/apps.json` to know about template of links, then after adding apps use `get_apk $apppkgname $appname $filetype $arch $dpi $androidversion`
  >   Where `$apppkgname` refers to Android package name
  >   `$appname` refer to friendly app name and see build scripts for
  >   `$filetype`  it is either `bundle` or `bundle_extract` or `apk` depending upon app
  >   `$arch $dpi $androidversion` is optional and is needed in some cases refer build scripts at `src/build` for more info
- For apkpure syntax is similar but replace with `dl_apkpure`
- `get_patches_key $appname-$patchname` is used to initialise custom options 
  >  where `$appname` refers to provided app name and `$patchname` refers to provided patch name
- `patch $apkname $patchname $cli` refers to main revnaced patching command 
  > where `$apkname` is name of apk
  >`$patchname` is name of patches bundle
  > `$cli` is name of patcher it can be `revanced` or `morphe` 
  > If `$apkname` is `repatch` it takes previous apk and patches it with a different patch
- `check_experimental $apppkgname` is specific to morphe experimental app versions to get latest experimental version from readme.
- `_fs_get $url` is usage of flaresolverr against `$url` which is protected by anti bot measures it outputs as `$html` and `$FS_COOKIES` for content and cookies respectively.
- `npatch $baseapkname $moduleapkname $modulename` is used for xposed patches 
    >where `$baseapkname` refers to original apk name
    >`$moduleapkname` refers to name of module apk
    >`$modulename` is fancy name of module
- `sign $input $output` is used to sign a app that is usually custom patched with `$input` and `$output` refering to apks

>[!Remember]
>Remeber to set `$version` before revanced/npatch to get name of  original app version at end of revanced/morphe/xposed patches. Refer `src/build/build.sh` for more info. Use it as a template for getting version from APKMirror feeds.

## `src\build\build.sh` syntax

>[!Syntax]
>The script can be launched as `src\build\build.sh $appname-$patchname`

- First there are functions to download Dependencies 
- Then there are main patching blocks
- Then there case blocks for the script to be executed with a specific patch

## For ReVanced/Morphe patches
1. If you want a `options.json` put it as `$patches-name.json` in `src/options` where `$patches-name` refers to patches name like `piko`, `revanced`, `morphe` etc. eg. `src/options/morphe.json`
2. For simple patch exclusion/inclusion check `src/options/$(appname-patchname)/exclude-patches` and `include-patches` respectively 
    - Syntax for that files is patch in one line with options sperated with `|` 
    - for eg: `Custom branding|-OappName="YouTube ReVanced" -OiconPath=ReVanced*Logo`
3. If you want to add new apps, see syntax of `utils.sh` above
## KeyStore
 You need a keystore to patch and sign apps. Morphe/ReVanced cli automatically creates it but for safe updates you need your own.
 To create a keystore, refer online and try to use GUI utilities such as https://keystore-explorer.org/
 You will provide a alias and password when generating a certificate and keystore 
 The keystore must be in the form of BKS(Bouncy Castle KeyStore) for compatiblity with Morphe/ReVanced CLI.
