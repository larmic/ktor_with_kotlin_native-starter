# kotlin_native-starter

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Gradle build](https://github.com/larmic/kotlin_native_starter/actions/workflows/gradle-build.yml/badge.svg)](https://github.com/larmic/kotlin_native_starter/actions/workflows/gradle-build.yml)
[![Docker build and push](https://github.com/larmic/kotlin_native_starter/actions/workflows/docker-build-push.yml/badge.svg)](https://github.com/larmic/kotlin_native_starter/actions/workflows/docker-build-push.yml)
[![Docker hub image](https://img.shields.io/docker/image-size/larmic/kotlin_native-starter?label=dockerhub)](https://hub.docker.com/repository/docker/larmic/kotlin_native-starter)
![Docker Image Version (latest by date)](https://img.shields.io/docker/v/larmic/kotlin_native-starter)

## Overview
This serves as a straightforward example illustrating how [Kotlin/Native](https://kotlinlang.org/docs/native-overview.html), [Ktor](https://ktor.io/), [Docker](https://www.docker.com/), [Docker Hub](https://hub.docker.com/) and [GitHub Actions](https://github.com/features/actions) can work seamlessly together.
The ultimate goal is to achieve fully automated creation of a compact Docker image and its versioned
transfer to Docker Hub.

‼️Choosing the right runtime:
- [Kotlin/Native](https://kotlinlang.org/docs/native-overview.html), with static compilation and limited Java library support, shines for IoT, iOS/mobile, embedded targets, and small tools.
- For larger cloud-native apps, microservices, and serverless, prefer [GraalVM Native Image](https://www.graalvm.org/latest/reference-manual/native-image/).
- When startup time is less critical, the [JVM's JIT](https://www.ibm.com/docs/de/sdk-java-technology/8?topic=reference-jit-compiler) and runtime optimizations make it ideal for enterprise systems, monoliths, and other long-running services.

## Technologies used
* [Kotlin/Native](https://kotlinlang.org/docs/native-overview.html)
* [Ktor](https://ktor.io/) server framework
* [Gradle](https://gradle.org/) as build tool
* [Docker](https://www.docker.com/) as application container
* [Docker Hub](https://hub.docker.com/) as container registry
* [GitHub Actions](https://github.com/features/actions) to automate CI/CD workflows (build the Docker application, push to the registry,...)
* [Renovate](renovate.json) for automatic dependency updates

## Requirements
* [Local JDK 24 installation](https://openjdk.org/projects/jdk/24/) to build and run application without using docker for local debugging
* [Local Docker installation](https://docs.docker.com/engine/install/) to build docker container from local machine
* [Docker Hub account](https://hub.docker.com/signup) for automatic container upload to the registry
* [Installed Renovate GitHub App](https://github.com/apps/renovate) to support automatic dependency updates

## Restrictions
* No [Java 25](https://openjdk.org/projects/jdk/25/) support yet because [Kotlin Multiplatform](https://www.jetbrains.com/help/kotlin-multiplatform-dev/multiplatform-compatibility-guide.html) is not yet available for [Gradle 9.0](https://docs.gradle.org/current/userguide/compatibility.html), and lower Gradle versions do not support Java 25
* [Dockerfile](Dockerfile) is using --platform=linux/amd64 as build host, because build host aarch64 is not supported by [Kotlin/Native](https://youtrack.jetbrains.com/issue/KT-36871/Support-Aarch64-Linux-as-a-host-for-the-Kotlin-Native)
* Kotlin/Native does not include a JVM. Therefore, many Java libraries will not work. Only libraries that are explicitly Kotlin Multiplatform or those that can be integrated via C Interop are usable.

## Build on your current machine
- Debug: ./gradlew linkDebugExecutableApp
- Release: ./gradlew linkReleaseExecutableApp
- Artifacts: build/bin/app/(debugExecutable|releaseExecutable)/app.kexe (Unix) or app.exe (Windows)

## Docker build (quick start)

# ARM64
docker buildx build --platform linux/arm64 -t kotlin_native-starter:arm64-test --load .
docker run --rm -p 8080:8080 kotlin_native-starter:arm64-test

# AMD64
docker buildx build --platform linux/amd64 -t kotlin_native-starter:amd64-test --load .
docker run --rm -p 8080:8080 kotlin_native-starter:amd64-test


# Create Buildx builder (if not already present)
docker buildx create --name multiarch --use --bootstrap

# Build both architectures (without push)
docker buildx build \
--platform linux/amd64,linux/arm64 \
-t larmic/kotlin_native-starter:test \
--load \
.