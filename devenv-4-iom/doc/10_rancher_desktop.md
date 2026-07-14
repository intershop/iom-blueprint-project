# Rancher Desktop

[Rancher Desktop](https://rancherdesktop.io/) is the recommended platform for running _devenv-4-iom_. It is open-source, free for commercial use, and provides a stable Kubernetes environment that fully supports all _devenv-4-iom_ features including `hostPath` volumes for local file sharing.

## Why Rancher Desktop?

_devenv-4-iom_ relies on `hostPath` volumes to mount local development directories (custom apps, templates, XSL files, database data) into the Kubernetes cluster. Rancher Desktop exposes host paths correctly into the Kubernetes node on all supported platforms, which means all `CUSTOM_*_DIR` and `POSTGRES_DATA_DIR` settings work as expected.

## Installation

### macOS

1. Download and install [Rancher Desktop](https://rancherdesktop.io/).
2. During first launch, select **dockerd (moby)** as the container runtime (required for `docker` CLI compatibility) or **containerd** if you prefer. Either works.
3. Kubernetes is enabled by default.
4. macOS 13 (Ventura) and later: Rancher Desktop uses [virtiofs](https://virtio-fs.gitlab.io/) for file sharing between the host and the Lima VM. This provides fast, reliable access to any directory under `/Users`. No additional configuration is needed.

### Linux

1. Download and install [Rancher Desktop](https://rancherdesktop.io/) using the package for your distribution (AppImage, .deb, .rpm, etc.).
2. Kubernetes is enabled by default.
3. All directories on the host are directly accessible inside the Kubernetes node — `hostPath` volumes work without any prefix configuration.

### Windows

1. Install [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install) first.
2. Download and install [Rancher Desktop](https://rancherdesktop.io/).
3. Kubernetes is enabled by default.

On Windows, a path prefix is required so that _devenv-4-iom_ passes the correct directory paths to the Kubernetes node. See the [Configuration](#configuration) section below.

## Resource Requirements

Running IOM together with a PostgreSQL pod requires enough memory in the Rancher Desktop VM. With the default of 4 GB, the Kubernetes API server can become unstable under load, causing commands to hang or fail with TLS timeout errors.

**Recommended minimum: 8 GB.** Set it via the command line (Rancher Desktop will restart to apply the change):

```bash
rdctl set --virtual-machine.memory-in-gb=8
```

Or adjust it in the Rancher Desktop UI under **Preferences → Virtual Machine → Hardware**.

## Configuration

Set the following in your `devenv.user.properties`:

```
KUBERNETES_CONTEXT=rancher-desktop
```

`rancher-desktop` is also the default value, so if no context is configured explicitly, _devenv-4-iom_ will use Rancher Desktop automatically.

For **Windows (Git Bash) only**, also add:

```
MOUNT_PREFIX=/mnt
```

Git Bash represents Windows paths as `/c/Users/...`, but the Rancher Desktop Kubernetes node expects them under `/mnt/c/Users/...`. `MOUNT_PREFIX` bridges this gap — always use the Git Bash path format in `CUSTOM_*_DIR` and `POSTGRES_DATA_DIR` settings and let `MOUNT_PREFIX` handle the translation.

When running _devenv-4-iom_ from a WSL2 shell, project files in the Windows home directory are accessible as `/mnt/c/Users/...` inside WSL2, which is already the correct format for the Rancher Desktop node — leave `MOUNT_PREFIX` empty.

See [Configuration](02_configuration.md) for details on where to set these properties.

---
[< Docker Desktop](09_docker_desktop.md) | [^ Index](../README.md)
