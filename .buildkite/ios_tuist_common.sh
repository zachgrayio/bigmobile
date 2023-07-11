#!/usr/bin/env bash

RELEASE_URL=https://bitrise-tuist.bitrise.io/tuist-3.18-bitrise-a4baa03.zip
DOWNLOAD_PATH=$TMPDIR/tuist.zip
TUIST_BIN_PATH=.tuist-bin

curl -s --fail --show-error $RELEASE_URL --output "$DOWNLOAD_PATH"
echo "b31d9c982809a2dea0c0d7b091674bb4b9b3035d7efcb035fd1880d7284fbb88 *$DOWNLOAD_PATH" | shasum -a 256 --check

rm -rf "$TUIST_BIN_PATH"
mkdir "$TUIST_BIN_PATH"
tar -xf "$DOWNLOAD_PATH" --directory="$TUIST_BIN_PATH"
