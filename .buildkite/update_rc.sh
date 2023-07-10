#!/usr/bin/env bash
set -e
set -o pipefail
set -x

cd $pwd/ios

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

cat .bitrise.bazelrc.tpl

cat <<EOF> setup_bitrise.sh
#!/usr/bin/env bash
case "\${BITRISE_DEN_VM_DATACENTER}" in
LAS1)
export BITRISE_CACHE_ENDPOINT=grpc://10.92.230.152:6666
;;
ATL1)
export BITRISE_CACHE_ENDPOINT=grpc://10.87.100.50:6666
;;
*)
export BITRISE_CACHE_ENDPOINT=grpcs://pluggable.services.bitrise.io
;;
esac
envsubst < .bitrise.bazelrc.tpl > .bitrise.bazelrc
echo "selected cache endpoint: \${BITRISE_CACHE_ENDPOINT}"
EOF

chmod +x ./setup_bitrise.sh
./setup_bitrise.sh
