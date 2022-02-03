#!/bin/bash
kubectl config use-context docker-desktop
mkdir -p devenv-share
#export DEVENV4IOM_CONFIG="$(pwd)/devenv-config.properties"
export PATH="$(pwd)/devenv-4-iom/bin:$PATH"
export DEVENV_SHARE_BASE_PATH="$(pwd)"

