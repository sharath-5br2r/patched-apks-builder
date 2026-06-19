# How to run this project locally

## Dependencies

- `git`
- `wget`
- `curl`
- GitHub CLI (`gh`)
- `bash`
- FlareSolverr
- Java (any JDK is OK)

Some of the tools can be downloaded on Windows via Git Bash/MSYS2.

For Termux, run:

```sh
pkg install git wget curl gh bash openjdk-25
```

Then download my fork of [FlareSolverr](https://github.com/sharath-5br2r/FlareSolverr-Termux) and install the remaining dependencies:

```sh
pkg install chromium python
```

Start FlareSolverr before running the scripts. On Termux:

```sh
python src/flaresolverr.py
```

## Steps

### Step 1: Clone this repository or your fork with submodules

```sh
git clone https://github.com/sharath-5br2r/patched-apks-builder --recurse-submodules
```

### Step 2: Configure the project

- Copy `.env.example` to `.env` and edit it to your liking.
- Place your BKS keystore as `ks.keystore` in the root of the repository.

### Step 3: Start the build script

```sh
bash src/build/build.sh $app_name
```

Where `$app_name` is one of the app names described in `build.sh`.

Example:

```sh
bash src/build/build.sh youtube-morphe
```

### Step 4: Get the output

The generated APKs will be available in:

```text
./build/*.apk
```

If module is generated, it is at 

```text
./build/*.zip
```