#!/bin/bash
# get absolute directory of setenv.sh
BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export PATH="$BASE_DIR/devenv-4-iom/bin:$PATH"
# 'target' is configured as CUSTOM_APPS_DIR and has to exist to avoid error messages
# 'target/sql-config' is configured as CUSTOM_SQLCONF_DIR and has to exist to avoid error messages
mkdir -p "$BASE_DIR/target/sql-config"
# using eval instead of source is required due to problems with Mac OS X
eval "$(devenv-cli.sh get bash-completion)"
alias mvn="$BASE_DIR/mvnw"
kubectl config use-context docker-desktop

