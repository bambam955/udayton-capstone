# =============================================================================
# Base: Ubuntu + mise + Flutter (shared by all targets)
# =============================================================================
FROM ubuntu:24.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

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

RUN curl https://mise.run | sh && \
    /root/.local/bin/mise use -g flutter@3.38 && \
    /root/.local/bin/mise reshim

RUN flutter config --no-analytics

WORKDIR /app

# =============================================================================
# Web: Lightweight image for web development
# =============================================================================
FROM base AS web

RUN flutter precache --web

# Note: flutter pub get runs at runtime since ./app is volume-mounted

EXPOSE 8080
CMD ["flutter", "run", "-d", "web-server", "--web-port=8080", "--web-hostname=0.0.0.0"]

# =============================================================================
# Android: Full SDK for builds and emulator connection
# =============================================================================
FROM base AS android

# Additional dependencies for Android
RUN apt-get update && apt-get install -y --no-install-recommends \
    zip \
    wget \
    openjdk-17-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}"

# Install Android SDK
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools && \
    mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

RUN yes | sdkmanager --licenses > /dev/null 2>&1 && \
    sdkmanager --install \
    "platform-tools" \
    "platforms;android-36" \
    "build-tools;36.0.0" \
    && rm -rf ${ANDROID_HOME}/.temp

RUN flutter precache --android && \
    flutter config --android-sdk ${ANDROID_HOME}

CMD ["bash"]
