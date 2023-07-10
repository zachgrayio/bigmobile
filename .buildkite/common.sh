#!/usr/bin/env bash
set -eo pipefail

export INV_ID=$(uuidgen)
echo "invocation ID $INV_ID"

if ping -c 1 -W 1 '10.92.230.152' &> /dev/null
then
  # LAS
  export BITRISE_CACHE_ENDPOINT=grpc://10.92.230.152:6666
elif ping -c 1 -W 1 '10.87.100.50' &> /dev/null
then
  # ATL
  export BITRISE_CACHE_ENDPOINT=grpc://10.87.100.50:6666
else
  # ??
  export BITRISE_CACHE_ENDPOINT=grpcs://pluggable.services.bitrise.io
fi

echo "cache endpoint selected: $BITRISE_CACHE_ENDPOINT"
