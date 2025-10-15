# kotlin_native-starter

## Requirements (host)
- JDK 24, Plus native toolchain for your OS:
  - macOS: Xcode Command Line Tools
  - Linux: clang, build-essential, zlib dev
  - Windows: MSVC (VS Build Tools) + Windows SDK

## Build on your current machine
- Debug: ./gradlew linkDebugExecutableApp
- Release: ./gradlew linkReleaseExecutableApp
- Artifacts: build/bin/app/(debugExecutable|releaseExecutable)/app.kexe (Unix) or app.exe (Windows)

## Docker Build (kurz)

# ARM64
docker buildx build --platform linux/arm64 -t kotlin_native-starter:arm64-test --load .
docker run --rm -p 8080:8080 kotlin_native-starter:arm64-test

# AMD64
docker buildx build --platform linux/amd64 -t kotlin_native-starter:amd64-test --load .
docker run --rm -p 8080:8080 kotlin_native-starter:amd64-test


# Buildx-Builder erstellen (falls noch nicht vorhanden)
docker buildx create --name multiarch --use --bootstrap

# Beide Architekturen bauen (ohne Push)
docker buildx build \
--platform linux/amd64,linux/arm64 \
-t larmic/kotlin_native-starter:test \
--load \
.