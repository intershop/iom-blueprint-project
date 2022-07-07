#!/bin/bash
kubectl config use-context docker-desktop
mkdir -p devenv-share
export PATH="$(pwd)/devenv-4-iom/bin:$PATH"
eval "$(devenv-cli.sh get bash-completion)"

