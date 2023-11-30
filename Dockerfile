FROM ubuntu:22.04

# Prerequisites
RUN apt update && \
    apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-11-jdk wget && \
    rm -rf /var/lib/apt/lists/*

# Set up new user
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer

# Prepare Android directories and system variables
RUN mkdir -p Android/sdk && \
    touch .android/repositories.cfg
ENV ANDROID_SDK_ROOT /home/developer/Android/sdk

# Set up Android SDK
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
    unzip sdk-tools.zip && \
    rm sdk-tools.zip && \
    mv tools Android/sdk/tools && \
    cd Android/sdk/tools/bin && yes | ./sdkmanager --licenses && \
    ./sdkmanager "build-tools;29.0.2" "patcher;v4" "platform-tools" "platforms;android-29" "sources;android-29"
ENV PATH "$PATH:/home/developer/Android/sdk/platform-tools"

# Download Flutter SDK
ARG FLUTTER_VERSION=stable
RUN git clone --branch $FLUTTER_VERSION https://github.com/flutter/flutter.git
ENV PATH "$PATH:/home/developer/flutter/bin"

# Run basic check to download Dark SDK
RUN flutter doctor && \
    flutter --version

# Clean up unnecessary files
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Optional: Expose ports for Android Emulator (if needed)
# EXPOSE 5555 5554
