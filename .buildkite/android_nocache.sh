#!/usr/bin/env bash
set -eo pipefail

cd android/mobile_app1
rm -rf .gradle

./gradlew clean rootModule:assembleDebug