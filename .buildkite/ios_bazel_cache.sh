#!/usr/bin/env bash

set -e
set -o pipefail
set -x

source .buildkite/common.sh

# for telegram iirc
SOURCE_DIR=$(pwd)/ios
cd $SOURCE_DIR

# configuring bazel
cat <<EOF>> .bazelrc
try-import %workspace%/.bitrise.bazelrc
EOF

cat <<EOF> .bitrise.bazelrc.tpl
build --remote_cache=\$BITRISE_CACHE_ENDPOINT
# needs a token set when spawning the run, or set in pool mgr
build --remote_header=authorization="Bearer \$BITRISE_CACHE_TOKEN"
build --remote_header=x-org-id=54743115ea75d779
build --experimental_remote_cache_compression
build --remote_header=x-flare-ac-validation-ttl-sec=360
#build --experimental_remote_downloader=\$BITRISE_CACHE_ENDPOINT
#build --remote_downloader_header=authorization="Bearer \$BITRISE_CACHE_TOKEN"
#build --remote_downloader_header=x-org-id=54743115ea75d779

build --bes_backend=grpcs://flare-bes.services.bitrise.io:443 
build --bes_header=Authorization="Bearer \$BITRISE_CACHE_TOKEN"
#build --bes_header=x-step-id=\$BITRISE_STEP_EXECUTION_ID
build --invocation_id=\$INV_ID
build --bes_header=x-app-id=d7188129eb51d1b0
#build --bes_header=x-org-id=54743115ea75d779
EOF

envsubst < .bitrise.bazelrc.tpl > .bitrise.bazelrc
echo "configured .bitrise.bazelrc; selected cache endpoint: ${BITRISE_CACHE_ENDPOINT}"

# telegram build stuff

bazel clean --expunge

rm -rf $HOME/telegram-configuration
rm -rf $HOME/telegram-provisioning

mkdir -p $HOME/telegram-configuration
mkdir -p $HOME/telegram-provisioning
cp build-system/appstore-configuration.json $HOME/telegram-configuration/configuration.json
cp -R build-system/fake-codesigning $HOME/telegram-provisioning/ 

python3 build-system/Make/ImportCertificates.py --path $HOME/telegram-provisioning/fake-codesigning/certs || true

python3 build-system/Make/Make.py \
    build \
    --configurationPath=$HOME/telegram-configuration/configuration.json \
    --codesigningInformationPath=$HOME/telegram-provisioning/fake-codesigning \
    --configuration=release_arm64 \
    --buildNumber=2837282

# consider copying artifacts somewhere useful like so?
# cp bazel-out/applebin_ios-ios_arm64-opt-ST-*/bin/Telegram/Telegram.ipa $SOME_DEPLOY_DIR
#
