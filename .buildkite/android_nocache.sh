#!/usr/bin/env bash
set -eo pipefail

cd android/mobile_app1
du -h ./.gradle/ || true
rm -rf .gradle
rm -f init.gradle

./gradlew clean
./gradlew --stop
./gradlew rootModule:assembleDebug