#!/bin/bash
set -e

APP_NAME="EduquestScreenTime"
KEYSTORE="/home/jesse/android-studio-keys/EduquestScreenTime.jks"
ALIAS="key0"
APK_UNSIGNED="app/build/outputs/apk/release/app-release-unsigned.apk"
APK_ALIGNED="app/build/outputs/apk/release/app-release-aligned.apk"
APK_SIGNED="app/build/outputs/apk/release/app-release.apk"

export JAVA_HOME=/opt/java/openjdk-17.0.2_linux-x64_bin/jdk-17.0.2/
export PATH=$JAVA_HOME/bin:$PATH

echo "🔨 Cleaning and building release..."
./gradlew clean assembleRelease

echo "📐 Aligning APK..."
/home/jesse/Android/Sdk/build-tools/36.0.0/zipalign -v -p 4 "$APK_UNSIGNED" "$APK_ALIGNED"

echo "🔏 Signing APK with apksigner..."
/home/jesse/Android/Sdk/build-tools/36.0.0/apksigner sign \
  --ks "$KEYSTORE" \
  --ks-key-alias "$ALIAS" \
  --ks-pass pass:jessejesse \
  --key-pass pass:jessejesse \
  --out "$APK_SIGNED" \
  "$APK_ALIGNED"

echo "🔍 Verifying final APK..."
/home/jesse/Android/Sdk/build-tools/36.0.0/apksigner verify "$APK_SIGNED"

echo "📲 Installing on connected device..."
adb uninstall io.github.childscreentime || true
adb install "$APK_SIGNED"

echo "🎉 Done! Installed $APK_SIGNED on device."

