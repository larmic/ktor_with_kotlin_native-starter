# syntax=docker/dockerfile:1.19

# ⚠️ IMPORTANT: We intentionally use linux/amd64 as build platform
# because Kotlin/Native does not support linux/arm64 as build host (only as target).
# BuildKit warning "FromPlatformFlagConstDisallowed" is expected and can be ignored.
# See: https://kotlinlang.org/docs/native-target-support.html#tier-2
# See: https://youtrack.jetbrains.com/issue/KT-36871
FROM --platform=linux/amd64 eclipse-temurin:25-jdk AS build
ARG TARGETARCH

# Install native toolchain for Kotlin/Native Linux builds
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       ca-certificates curl unzip zip \
       build-essential clang pkg-config zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Cache-friendly copy
COPY gradle/wrapper/ gradle/wrapper/
COPY gradlew gradlew
COPY settings.gradle.kts settings.gradle.kts
COPY build.gradle.kts build.gradle.kts
RUN chmod +x gradlew

# Pre-download Gradle wrapper and dependencies
RUN ./gradlew --no-daemon --version

# Copy the rest of the sources
COPY src/ src/

# Build release executable for current platform
RUN set -eux; \
    case "$TARGETARCH" in \
        amd64) ./gradlew --no-daemon linkReleaseExecutableApp -PtargetOs="Linux" -PtargetArch="x86_64" ;; \
        arm64) ./gradlew --no-daemon linkReleaseExecutableApp -PtargetOs="Linux" -PtargetArch="aarch64" ;; \
        *) echo "Unsupported TARGETARCH: $TARGETARCH" && exit 1 ;; \
    esac

# Find produced binary (app.kexe) and rename to app
RUN set -eux; \
    bin_dir=$(find build/bin -type d -name "releaseExecutable" | head -n1); \
    echo "Found binary in: $bin_dir"; \
    ls -la "$bin_dir"; \
    cp "$bin_dir"/app.kexe /out-app; \
    chmod +x /out-app

# Runtime image
FROM alpine:3.22 AS runtime

# Add minimal runtime deps
RUN apk add --no-cache gcompat libgcc libstdc++

# OCI labels for metadata
LABEL org.opencontainers.image.title="ktor_with_kotlin_native-starter" \
      org.opencontainers.image.description="Ktor with Kotlin/Native server with Docker and GitHub Actions" \
      org.opencontainers.image.source="https://github.com/larmic/ktor_with_kotlin_native-starter" \
      org.opencontainers.image.licenses="Apache-2.0"

# Copy binary
COPY --from=build /out-app /app

# Run as non-root user (minimal approach for static binaries)
USER 10001:10001

EXPOSE 8080

# Health check using native health endpoint with wget
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

ENTRYPOINT ["/app"]
