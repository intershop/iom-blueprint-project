# Docker Desktop

Docker Desktop supports two Kubernetes cluster engines, selectable under _Settings > Kubernetes > Kubernetes engine_:

- **kubeadm** — the classic engine, used prior to Docker Desktop 4.40.
- **kind** — the new default engine since Docker Desktop 4.40.

**Only the kubeadm engine is supported by _devenv-4-iom_.** The kind engine cannot be used — see below for the reason.

## Installation

> **Caution:** While installing Docker Desktop on **Windows** you will be signed-out and your PC will probably be restarted. Save everything before installing.

1. Install [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install) (Windows only).
1. Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop).
1. Enable Kubernetes: _Settings > Kubernetes > Enable Kubernetes_.
1. Select the kubeadm engine: _Settings > Kubernetes > Kubernetes engine > kubeadm_.

### Windows

On Windows, a path prefix is required so that _devenv-4-iom_ passes the correct directory paths to the Kubernetes node. See the [Configuration](#configuration) section below.

## Why the kind Engine is Not Supported

_devenv-4-iom_ uses `hostPath` volumes to mount local directories into the Kubernetes cluster. This is how all `CUSTOM_*_DIR` settings work (custom apps, templates, XSL files, shared filesystem, SQL config, etc.) and how `POSTGRES_DATA_DIR` persists database data across restarts.

With the kind engine, the Kubernetes node runs as a Docker container. That container receives a snapshot of the host filesystem when it starts, but subsequent changes on the host are **not** propagated into the node. `hostPath` volumes therefore see a stale, read-only copy — not the live host directory. The consequence is:

- All `CUSTOM_*_DIR` mounts are empty or frozen — development workflows do not work.
- `POSTGRES_DATA_DIR` directory appears empty inside the node — data is not persisted.

There is no workaround for this within the standard Docker Desktop kind setup.

## What to Do

**Option 1 — Switch Docker Desktop back to kubeadm**

In Docker Desktop, go to _Settings > Kubernetes > Kubernetes engine_ and select **kubeadm**. Restart Docker Desktop. The kubeadm engine exposes host directories correctly and all _devenv-4-iom_ features work.

> After switching engines, delete and recreate your cluster:
>
>     devenv-cli.sh delete cluster
>     devenv-cli.sh create cluster

**Option 2 — Migrate to Rancher Desktop (recommended)**

[Rancher Desktop](https://rancherdesktop.io/) is the recommended platform going forward. It uses k3s in a proper virtual machine where `hostPath` volumes work correctly on all platforms. See [setup instructions](10_rancher_desktop.md) for details.

## Checking Your Current Engine

To verify which engine your Docker Desktop cluster is using:

    kubectl get storageclass

Output for the **kind engine** — not supported. Recognisable by two StorageClasses (`hostpath` and `standard`) both using the `rancher.io/local-path` provisioner. Note: despite the name, this provisioner is an independent open-source project (`github.com/rancher/local-path-provisioner`) bundled by kind — it is unrelated to Rancher Desktop:

    NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
    hostpath             rancher.io/local-path   Delete          WaitForFirstConsumer   false                  18s
    standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  28s

Output for the **kubeadm engine** — supported. Recognisable by a single `hostpath (default)` StorageClass with `docker.io/hostpath` provisioner:

    NAME                 PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
    hostpath (default)   docker.io/hostpath   Delete          Immediate           false                  25d

## Configuration

Set the following in your `devenv.user.properties`:

```
KUBERNETES_CONTEXT=docker-desktop
```

Docker Desktop registers its cluster under the context name `docker-desktop`, so this value must match exactly.

For **Windows (Git Bash) only**, also add:

```
MOUNT_PREFIX=/run/desktop/mnt/host
```

Git Bash represents Windows paths as `/c/Users/...`, but the Docker Desktop Kubernetes node expects them under `/run/desktop/mnt/host/c/Users/...`. `MOUNT_PREFIX` bridges this gap.

> **Note:** When running _devenv-4-iom_ from a WSL2 shell with project files located in the Windows home directory (`/mnt/c/Users/...` inside WSL2), Docker Desktop cannot be used — `MOUNT_PREFIX` only prepends a prefix and cannot remap `/mnt/c/...` to `/run/desktop/mnt/host/c/...`. Use [Rancher Desktop](10_rancher_desktop.md) for this scenario.

See [Configuration](02_configuration.md) for details on where to set these properties.

---
[< Troubleshooting](08_troubleshooting.md) | [Rancher Desktop >](10_rancher_desktop.md) | [^ Index](../README.md)
