#!/usr/bin/env bash
set -eo pipefail

source .buildkite/common.sh

cd android/mobile_app1
du -h ./.gradle/ || true
rm -rf .gradle

cat << EOF > init.gradle
initscript {
    repositories {
        mavenLocal()
        mavenCentral()
        maven {
            url 'https://jitpack.io'
        }
        maven {
            url "https://s01.oss.sonatype.org/content/repositories/snapshots/"
        }
    }

    dependencies {
        classpath 'io.bitrise.gradle:remote-cache:1.2.0'
    }
}

import io.bitrise.gradle.cache.BitriseBuildCache
import io.bitrise.gradle.cache.BitriseBuildCacheServiceFactory

gradle.settingsEvaluated { settings ->
    settings.buildCache {
        local {
            enabled = false
        }

        registerBuildCacheService(BitriseBuildCache.class, BitriseBuildCacheServiceFactory.class)
        remote(BitriseBuildCache.class) {
            endpoint = System.getenv('BITRISE_CACHE_ENDPOINT')
            authToken = '54743115ea75d779:' + System.getenv('BITRISE_CACHE_TOKEN')
            enabled = true
            push = true
            // debug = true
            blobValidationLevel = "none"
            numChannels = 4
            maxConcurrencyPerChannel = 50
        }
    }
}
EOF

./gradlew clean assembleDebug --init-script=./init.gradle
