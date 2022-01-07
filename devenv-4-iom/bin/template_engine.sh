#!/bin/bash

usage() {
    ME=$(basename $0)
    cat <<EOF
$ME
    expands template file

SYNOPSIS
    $(basename $0) --template=<template-file> --project-dir=<project-dir> [ --config=<config-file>,... ]" [-h]

DESCRIPTION
    This is a very simple templating system to render environment varibales
    or variables of given <config-file>(s) in a given <template-file> by using
    the given pre-defined template-variables file.

    Options:

    --template=<template-file>
      Name of the template file to be used.

    --project-dir=<project-dir>
      Value of project-dir is required by some variables (CUSTOM_*_DIR) to be expanded
      to absolute paths.

    --config=<config-file>,...
      Optional parameter. One or more config files, defining variables, to be expanded
      within the template. The first config-file within the list has the lowest precedence.
      This way, it's possible to provide an overwrite mechanism for variables.

    -h
      Display this help and exit.

EXAMPLES

    VAR1=Something VAR2=1.2.3 ${ME} ../templates/index.template
    ${ME} --template=../templates/index.template --config=variables.sample
    VAR1=Something VAR2=1.2.3 ${ME} --template=../templates/index.template --config=variables.sample
    ${ME} --template=../templates/index.template --config=variables.sample

EOF
}

# renders the template and replace the variables
render(){
    FILE="$1"
    # read the lines of the template
    # IFS='' (or IFS=) prevents leading/trailing whitespace from being trimmed.
    # -r prevents backslash escapes from being interpreted.
    # || [[ -n $LINE ]] prevents the last line from being ignored if it doesn't end with a \n (since read returns a non-zero exit code when it encounters EOF).
    while IFS='' read -r LINE || [[ -n "$LINE" ]]; do
        # find the variables by regex
        while [[ "$LINE" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]] ; do
            MATCH=${BASH_REMATCH[1]}
            REPLACED_MATCH="$(eval echo "\"$MATCH\"")"
            # replace all
            LINE=${LINE//$MATCH/$REPLACED_MATCH}
        done
        # output
        echo "$LINE"
    done < $FILE
}

# name of template-variables file
TEMPLATE_VAR_FILE="$(dirname $0)/template-variables"

TEMPLATE_FILE=
CONFIG_FILES=
PROJECT_DIR=

for OPT in "$@"; do
    case $OPT in
        --template=*)
            TEMPLATE_FILE="${OPT#*=}"
            shift
            ;;
        --project-dir=*)
            PROJECT_DIR="${OPT#*=}"
            shift
            ;;
        --config=*)
            CONFIG_FILES="${OPT#*=}"
            shift
            ;;
        -h)
            usage
            exit
            ;;
        *)  echo "invalid option $OPT" 1>&2
            echo 1>&2
            usage 1>&2
            exit 1
            ;;
    esac
done

# check template-file
if [ -z "$TEMPLATE_FILE" -o ! -f "$TEMPLATE_FILE" ]; then
    echo "template-file missing!" 1>&2
    echo 1>&2
    usage 1>&2
    exit 1
fi

# check project-dir
if [ -z "$PROJECT_DIR" -o ! -d "$PROJECT_DIR" ]; then
    echo "project-dir is missing!" 1>&2
    echo 1>&2
    usage 1>&2
    exit 1
fi

if [ ! -z "$CONFIG_FILES" ]; then
    # check status and syntax of config files
    echo "$CONFIG_FILES" | tr ',' '\n' | while read CONFIG_FILE; do
        if [ ! -f "$CONFIG_FILE" ]; then
            echo "passed config-file '$CONFIG_FILE' does not exist!" 1>&2
            echo 1>&2
            usage 1>&2
            exit 1
        elif ! ( set -e; . $CONFIG_FILE ); then
            echo "error reading '$CONFIG_FILE'" 1>&2
            exit 1
        fi
    done || exit 1

    # read content of config files
    # . notation cannot be used, since variables would be defined inside a
    # subshell only.
    CONFIG=$(echo "$CONFIG_FILES" | tr ',' '\n' | while read CONFIG_FILE; do
                 cat "$CONFIG_FILE"
                 echo # just for the case, a newline is missing at the end of file
             done)
fi

# check template-variables file
if [ -z "$TEMPLATE_VAR_FILE" -o ! -f "$TEMPLATE_VAR_FILE" ]; then
    echo "template-variables file missing!" 1>&2
    echo 1>&2
    usage 1>&2
    exit 1
fi

# check syntax of $TEMPLATE_VAR_FILE
if ! ( set -e; . "$TEMPLATE_VAR_FILE" ); then
    echo "error reading '$TEMPLATE_VAR_FILE'" 1>&2
    exit 1
fi

# render template with variables from CONFIG
ORIGINAL_PROJECT_DIR="$PROJECT_DIR"
if [ ! -z "$CONFIG_FILES" ]; then
    eval "$CONFIG"
fi
# read $TEMPLATE_VAR_FILE
. $TEMPLATE_VAR_FILE

if [ "$ORIGINAL_PROJECT_DIR" != "$PROJECT_DIR" ]; then
    echo "overwriting PROJECT_DIR is not supported!" 1>&2
    exit 1
fi
render "$TEMPLATE_FILE"
