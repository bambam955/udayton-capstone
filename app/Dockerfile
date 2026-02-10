# =============================================================================
# Base: Ubuntu + mise + Flutter (shared by all targets)
# =============================================================================
# We use a multi-stage Dockerfile so that lightweight commands (test, check,
# format) run against the small "base" image, while heavier toolchains (web
# build tools, Android SDK + JDK) are only pulled in by the stages that need
# them. This keeps the common-case fast.
#
# mise manages Flutter and just versions inside the container, matching how
# we manage tools on the host. The root justfile delegates commands into the
# container via `docker compose run --rm app-base just <recipe>`, so the
# app/justfile can be simple Flutter calls with no Docker awareness.
#
# Packages are stored in ~/.pub-cache on the host via a bind mount
# (see docker-compose.yml), so VS Code's Dart extension can resolve them
# for syntax highlighting without needing Flutter installed locally.
# =============================================================================
FROM ubuntu:24.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    xz-utils \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV MISE_DATA_DIR=/opt/mise
ENV PATH="/opt/mise/shims:${PATH}"
ENV CI=true
ENV FLUTTER_SUPPRESS_ANALYTICS=true

# Install flutter and just via mise
RUN curl https://mise.run | sh && \
    /root/.local/bin/mise use -g flutter@3.38 && \
    /root/.local/bin/mise use -g just && \
    /root/.local/bin/mise reshim

RUN flutter config --no-analytics \
    --no-enable-linux-desktop \
    --no-enable-macos-desktop \
    --no-enable-windows-desktop

WORKDIR /app

# =============================================================================
# Web: base + pre-cached web build toolchain
# =============================================================================
FROM base AS web

RUN flutter precache --web

EXPOSE 8080
CMD ["flutter", "run", "-d", "web-server", "--web-port=8080", "--web-hostname=0.0.0.0"]

# =============================================================================
# Android: base + JDK + Android SDK (heavy — only used for APK builds)
# =============================================================================
FROM base AS android

# Install additional dependencies for Java
RUN apt-get update && apt-get install -y --no-install-recommends \
    zip \
    wget \
    openjdk-17-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

# Java/Android SDK environment configuration
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}"

# Download Android's sdkmanager tooling, which can be used to install the rest of Android
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools && \
    mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

# Install the full Android SDK
RUN yes | sdkmanager --licenses > /dev/null 2>&1 && \
    sdkmanager --install \
    "platform-tools" \
    "platforms;android-36" \
    "build-tools;36.0.0" \
    && rm -rf ${ANDROID_HOME}/.temp

RUN flutter precache --android && \
    flutter config --android-sdk ${ANDROID_HOME}

CMD ["bash"]
