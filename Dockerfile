FROM debian:stable-slim

ARG JAVA_VERSION
ARG JAVA_BUILD

WORKDIR /opt

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates wget unzip \
 && rm -rf /var/lib/apt/lists/*

# Download Linux JDK (provides jlink)
RUN wget -q "https://github.com/adoptium/temurin${JAVA_VERSION%%.*}-binaries/releases/download/jdk-${JAVA_VERSION}%2B${JAVA_BUILD}/OpenJDK${JAVA_VERSION%%.*}U-jdk_x64_linux_hotspot_${JAVA_VERSION}_${JAVA_BUILD}.tar.gz" \
 && tar xzf "OpenJDK${JAVA_VERSION%%.*}U-jdk_x64_linux_hotspot_${JAVA_VERSION}_${JAVA_BUILD}.tar.gz" \
 && rm "OpenJDK${JAVA_VERSION%%.*}U-jdk_x64_linux_hotspot_${JAVA_VERSION}_${JAVA_BUILD}.tar.gz" \
 && mv "jdk-${JAVA_VERSION}+${JAVA_BUILD}" jdk-linux

# Download Windows JDK (provides java.exe, keytool.exe, jvm.dll)
RUN wget -q "https://github.com/adoptium/temurin${JAVA_VERSION%%.*}-binaries/releases/download/jdk-${JAVA_VERSION}%2B${JAVA_BUILD}/OpenJDK${JAVA_VERSION%%.*}U-jdk_x64_windows_hotspot_${JAVA_VERSION}_${JAVA_BUILD}.zip" \
 && unzip -q "OpenJDK${JAVA_VERSION%%.*}U-jdk_x64_windows_hotspot_${JAVA_VERSION}_${JAVA_BUILD}.zip" \
 && rm "OpenJDK${JAVA_VERSION%%.*}U-jdk_x64_windows_hotspot_${JAVA_VERSION}_${JAVA_BUILD}.zip" \
 && mv "jdk-${JAVA_VERSION}+${JAVA_BUILD}" jdk-windows

# Download Windows JMODs (separate package for Java 24+ per JEP 493; bundled in JDK for older versions)
RUN MAJOR="${JAVA_VERSION%%.*}"; \
    if [ "$MAJOR" -ge 24 ]; then \
      wget -q "https://github.com/adoptium/temurin${MAJOR}-binaries/releases/download/jdk-${JAVA_VERSION}%2B${JAVA_BUILD}/OpenJDK${MAJOR}U-jmods_x64_windows_hotspot_${JAVA_VERSION}_${JAVA_BUILD}.zip" \
      && unzip -q "OpenJDK${MAJOR}U-jmods_x64_windows_hotspot_${JAVA_VERSION}_${JAVA_BUILD}.zip" -d jmods-windows-pkg \
      && rm "OpenJDK${MAJOR}U-jmods_x64_windows_hotspot_${JAVA_VERSION}_${JAVA_BUILD}.zip" \
      && JMODS_DIR=$(find /opt/jmods-windows-pkg -name "*.jmod" | head -1 | xargs dirname) \
      && ln -s "${JMODS_DIR}" /opt/jmods-windows; \
    else \
      ln -s /opt/jdk-windows/jmods /opt/jmods-windows; \
    fi

ENV PATH="/opt/jdk-linux/bin:${PATH}"

COPY scripts/jlink-windows /usr/local/bin/jlink-windows
RUN chmod +x /usr/local/bin/jlink-windows

WORKDIR /workspace
