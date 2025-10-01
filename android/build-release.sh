#!/bin/bash
set -e

APP_NAME="QuestCraft"
KEYSTORE="/home/jesse/android-studio-keys/EduQuestLuanti.jks"
ALIAS="key0"

APK_UNSIGNED="app/build/outputs/apk/release/app-release-unsigned.apk"
APK_ALIGNED="app/build/outputs/apk/release/app-release-aligned.apk"
APK_SIGNED="app/build/outputs/apk/release/app-release.apk"

AAB_UNSIGNED="app/build/outputs/bundle/release/app-release.aab"
AAB_SIGNED="app/build/outputs/bundle/release/app-release-signed.aab"

export JAVA_HOME=/opt/java/openjdk-17.0.2_linux-x64_bin/jdk-17.0.2/
export PATH=$JAVA_HOME/bin:$PATH

SIGN_AAB=false
if [ "$1" == "--sign" ]; then
  SIGN_AAB=true
fi

echo "🔨 Cleaning and building release (APK + AAB)..."
./gradlew clean assembleRelease bundleRelease

# -----------------------
# APK signing (for local testing / sideload)
# -----------------------
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

echo "📲 Installing APK on connected device..."
adb uninstall io.github.childscreentime || true
adb install "$APK_SIGNED"

# -----------------------
# AAB handling (for Play Console upload)
# -----------------------
if [ "$SIGN_AAB" = true ]; then
  echo "🔏 Signing AAB with jarsigner..."
  jarsigner -verbose \
    -sigalg SHA256withRSA -digestalg SHA-256 \
    -keystore "$KEYSTORE" \
    -storepass jessejesse \
    -keypass jessejesse \
    "$AAB_UNSIGNED" "$ALIAS"

  echo "🔍 Verifying signed AAB..."
  jarsigner -verify -verbose -certs "$AAB_UNSIGNED"
  mv "$AAB_UNSIGNED" "$AAB_SIGNED"

  echo "🎉 Build complete!"
  echo "👉 Local APK installed: $APK_SIGNED"
  echo "👉 Upload this SIGNED AAB: $AAB_SIGNED"
else
  echo "⚠️ Leaving AAB UNSIGNED for Play App Signing"
  echo "👉 Upload this UNSIGNED AAB to Play Console: $AAB_UNSIGNED"
fi

