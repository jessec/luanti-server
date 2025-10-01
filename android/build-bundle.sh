#!/bin/bash
set -e

APP_NAME="EduquestScreenTime"
KEYSTORE="/home/jesse/android-studio-keys/EduquestScreenTime.jks"
ALIAS="key0"
AAB_UNSIGNED="app/build/outputs/bundle/release/app-release.aab"
AAB_SIGNED="app/build/outputs/bundle/release/app-release-signed.aab"

export JAVA_HOME=/opt/java/openjdk-17.0.2_linux-x64_bin/jdk-17.0.2/
export PATH=$JAVA_HOME/bin:$PATH

echo "🔨 Cleaning and building App Bundle..."
./gradlew clean bundleRelease

# Optional: sign AAB (if not using Play App Signing)
echo "🔏 Signing AAB with jarsigner..."
jarsigner -verbose \
  -sigalg SHA256withRSA -digestalg SHA-256 \
  -keystore "$KEYSTORE" \
  -storepass jessejesse \
  -keypass jessejesse \
  "$AAB_UNSIGNED" "$ALIAS"

# Verify signature
echo "🔍 Verifying AAB..."
jarsigner -verify -verbose -certs "$AAB_UNSIGNED"

echo "📦 AAB ready at: $AAB_UNSIGNED"

