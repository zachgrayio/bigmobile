#!/usr/bin/env bash
set -eo pipefail

cd android/mobile_app1

./gradlew clean rootModule:assembleDebug