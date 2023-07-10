#!/usr/bin/env bash

set -e
set -o pipefail
set -x

SOURCE_DIR=$pwd/ios
cd $SOURCE_DIR

# configuring bazel
cat <<EOF>> .bazelrc
try-import %workspace%/.bitrise.bazelrc
EOF

cat <<EOF> .bitrise.bazelrc.tpl
build --remote_cache=\$BITRISE_CACHE_ENDPOINT
build --remote_header=authorization="Bearer \$BITRISEIO_BITRISE_SERVICES_ACCESS_TOKEN"
build --experimental_remote_cache_compression
#build --experimental_remote_downloader=\$BITRISE_CACHE_ENDPOINT
#build --remote_downloader_header=authorization="Bearer \$BITRISEIO_BITRISE_SERVICES_ACCESS_TOKEN"

build --bes_backend=grpcs://flare-bes.services.bitrise.io:443 
build --bes_header=Authorization="Bearer \$BITRISEIO_BITRISE_SERVICES_ACCESS_TOKEN"
build --bes_header=x-step-id=\$BITRISE_STEP_EXECUTION_ID
build --invocation_id=\$BITRISE_BUILD_SLUG
build --remote_header=x-flare-ac-validation-ttl-sec=360
EOF

case "\${BITRISE_DEN_VM_DATACENTER}" in
LAS1)
export BITRISE_CACHE_ENDPOINT=grpc://10.92.230.152:6666
;;
ATL1)
export BITRISE_CACHE_ENDPOINT=grpc://10.87.100.50:6666
;;
*)
# expl: force ATL endpoint since I plan to run this on a stack pinned to ATL
# export BITRISE_CACHE_ENDPOINT=grpcs://pluggable.services.bitrise.io
export BITRISE_CACHE_ENDPOINT=grpc://10.87.100.50:6666
;;
esac
envsubst < .bitrise.bazelrc.tpl > .bitrise.bazelrc
echo "configured .bitrise.bazelrc; selected cache endpoint: \${BITRISE_CACHE_ENDPOINT}"

# telegram build stuff
mkdir -p $HOME/telegram-configuration
mkdir -p $HOME/telegram-provisioning
cp build-system/appstore-configuration.json $HOME/telegram-configuration/configuration.json
cp -R build-system/fake-codesigning $HOME/telegram-provisioning/ 

python3 build-system/Make/ImportCertificates.py --path $HOME/telegram-provisioning/fake-codesigning/certs


python3 build-system/Make/Make.py \
    build \
    --configurationPath=$HOME/telegram-configuration/configuration.json \
    --codesigningInformationPath=$HOME/telegram-provisioning/fake-codesigning \
    --configuration=release_arm64 \
    --buildNumber=2837282

# consider copying artifacts somewhere useful like so?
# cp bazel-out/applebin_ios-ios_arm64-opt-ST-*/bin/Telegram/Telegram.ipa $SOME_DEPLOY_DIR
#
