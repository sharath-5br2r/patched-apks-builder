# How to run this project locally
## Dependencies
- git
- wget
- curl
- github cli
- bash
- flaresolverr
- java(any jdk is ok)
Some of the tools can be downloaded on windows via git bash/msys2
For termux run ``` pkg install git wget curl gh  bash openjdk-25``` and download my fork of [flaresolverr](https://github.com/sharath-5br2r/FlareSolverr-Termux)and ``` pkg install chromium python```
Start flaresolverr before running scripts, on termux it is by ```python src/flaresolverr.py ```

## Steps
### Step 1: Clone this repo or your fork
```
git clone https://github.com/sharath-5br2r/patched-apks-builder
```
### Step 2: Copy and edit .env.example to .env and edit to your liking. Also put your bks keystore as `ks.keystore` at root of repository.
### Step 3: Start the build script with arugments
``` 
bash src/build/build.sh $app_name
```
where $app_name is described in build.sh
Eg: youtube-morphe
### Step 3: Get outputs at ./build/*.apk
