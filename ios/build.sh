#!/bin/bash
# TwinDesk for iOS 15+: an unsigned IPA (dist/TwinDesk.ipa) for TrollStore. Needs Xcode (the Build
# iOS workflow has it) and XcodeGen (brew install xcodegen).
set -euo pipefail
cd "$(dirname "$0")"
xcodegen generate --quiet
rm -rf build dist
xcodebuild -project TwinDesk.xcodeproj -scheme TwinDesk -configuration Release -sdk iphoneos \
  -destination 'generic/platform=iOS' -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" \
  ${VERSION:+MARKETING_VERSION=$VERSION} ${BUILD_NUMBER:+CURRENT_PROJECT_VERSION=$BUILD_NUMBER} \
  build | (command -v xcbeautify >/dev/null && xcbeautify || cat)
APP=build/Build/Products/Release-iphoneos/TwinDesk.app
mkdir -p dist/Payload
cp -R "$APP" dist/Payload/
(cd dist && zip -qry TwinDesk.ipa Payload && rm -rf Payload)
python3 - "$PWD/dist/TwinDesk.ipa" <<'PY'
import plistlib
import sys
import zipfile

ipa = sys.argv[1]
bundles = {
    "Payload/TwinDesk.app/Info.plist": "TwinDesk.app",
    "Payload/TwinDesk.app/PlugIns/Share.appex/Info.plist": "Share.appex",
    "Payload/TwinDesk.app/PlugIns/Broadcast.appex/Info.plist": "Broadcast.appex",
}

def version_tuple(value):
    try:
        return tuple(int(part) for part in str(value).split("."))
    except ValueError:
        return ()

with zipfile.ZipFile(ipa) as archive:
    names = set(archive.namelist())
    for plist_path, bundle_name in bundles.items():
        if plist_path not in names:
            raise SystemExit(f"IPA is missing {bundle_name}: {plist_path}")
        info = plistlib.loads(archive.read(plist_path))
        minimum = info.get("MinimumOSVersion")
        if not minimum or not version_tuple(minimum) or version_tuple(minimum) > (15, 0):
            raise SystemExit(f"{bundle_name} MinimumOSVersion is {minimum!r}, expected 15.0 or lower")
        print(f"{bundle_name}: MinimumOSVersion {minimum}")
PY
ls -lh dist/TwinDesk.ipa
