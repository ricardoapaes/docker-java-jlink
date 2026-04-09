# docker-java-jlink

Docker image for generating a Windows JRE using `jlink`, intended for use in CI pipelines.

The image bundles:
- **Linux JDK** – provides the `jlink` tool
- **Windows JDK** – provides Windows executables (`java.exe`, `keytool.exe`, `jvm.dll`)
- **Windows JMODs** – module archive required by `jlink` to produce a Windows JRE (separated since JEP 493 / Java 24+)
- **`jlink-windows` script** – a helper in `PATH` that pre-configures the standard flags, reducing verbosity

## Usage as a GitHub Action

The simplest way to use this in your CI — just reference it in a workflow step:

```yaml
- name: Generate Windows JRE
  uses: likesistemas/docker-java-jlink@main  # pin to a specific tag or SHA in production
  with:
    java-version: '21'
    modules: 'java.base,java.desktop,java.xml,java.naming,java.security.jgss,java.security.sasl,jdk.crypto.cryptoki,jdk.crypto.ec,jdk.naming.dns,jdk.security.auth,jdk.security.jgss'
    output: 'jre-windows'
```

### Action inputs

| Input | Description | Required | Default |
|---|---|---|---|
| `java-version` | Java major version (e.g. `21`) | yes | `21` |
| `modules` | Comma-separated list of modules to include | yes | `java.base` |
| `output` | Output directory (relative to workspace) | yes | `jre-windows` |

### Action outputs

| Output | Description |
|---|---|
| `jre-path` | Absolute path to the generated JRE directory |

### Full workflow example

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate Windows JRE
        id: jre
        uses: likesistemas/docker-java-jlink@main  # pin to a specific tag or SHA in production
        with:
          java-version: '21'
          modules: 'java.base,java.desktop,java.xml'
          output: 'jre-windows'

      - name: Upload JRE artifact
        uses: actions/upload-artifact@v4
        with:
          name: jre-windows
          path: ${{ steps.jre.outputs.jre-path }}
```

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
| `latest` | Most recent build from `main` (Java 25) |
| `25` | Java 25 (LTS) |
| `25.0.2_10` | Specific Java 25 version and build |
| `21` | Java 21 (LTS) |
| `21.0.7_6` | Specific Java 21 version and build |
| `11` | Java 11 (LTS) |
| `11.0.30_7` | Specific Java 11 version and build |
