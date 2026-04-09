# docker-java-jlink

Docker image for generating a Windows JRE using `jlink`, intended for use in CI pipelines.

The image bundles:
- **Linux JDK** – provides the `jlink` tool
- **Windows JDK** – provides Windows executables (`java.exe`, `keytool.exe`, `jvm.dll`)
- **Windows JMODs** – module archive required by `jlink` to produce a Windows JRE (separated since JEP 493 / Java 24+)
- **`jlink-windows` script** – a helper in `PATH` that pre-configures the standard flags, reducing verbosity

## Usage in a Dockerfile

```dockerfile
FROM ghcr.io/likesistemas/docker-java-jlink:21 AS jre

RUN jlink-windows \
    --add-modules java.base,java.desktop,java.xml,java.naming,java.security.jgss,java.security.sasl,jdk.crypto.cryptoki,jdk.crypto.ec,jdk.naming.dns,jdk.security.auth,jdk.security.jgss \
    --output /output/jre-windows
```

The `jlink-windows` script automatically adds the following flags:

| Flag | Value |
|---|---|
| `--module-path` | `/opt/jmods-windows` |
| `--strip-debug` | ✓ |
| `--no-man-pages` | ✓ |
| `--no-header-files` | ✓ |
| `--compress` | `zip-6` |

Any extra arguments are forwarded directly to `jlink`.

The Windows JDK (for copying executables into your image) is available at `/opt/jdk-windows`.

## Building the image locally

```bash
docker build \
  --build-arg JAVA_VERSION=21.0.7 \
  --build-arg JAVA_BUILD=6 \
  -t docker-java-jlink:21 .
```

## Available image tags

| Tag | Description |
|---|---|
| `latest` | Most recent build from `main` |
| `21` | Java 21 (LTS) |
| `21.0.7_6` | Specific Java version and build |
