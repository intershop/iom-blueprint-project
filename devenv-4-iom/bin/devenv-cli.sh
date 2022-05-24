#!/bin/bash

TMP_ERR="$(mktemp)"
TMP_OUT="$(mktemp)"
trap "rm -f $TMP_ERR $TMP_OUT" EXIT SIGTERM

################################################################################
# display help messages
################################################################################

#-------------------------------------------------------------------------------
# helper method to indent text
# $1 - required. Number of spaces to indent content
indent() {
    while read LINE; do
        I=$1
        while [ "$I" -gt 0 ]; do
            echo -n ' '
            I=$(expr $I - 1)
        done
            echo $LINE
    done
}

#-------------------------------------------------------------------------------
# helper method to provide message about CONFIG-FILE
# $1 - optional. Number of spaces to indent content
msg_config_file() {
    INDENT="${1:-0}"
    indent $INDENT <<EOF
Name of configuration file to be used. If not set, the file 
devenv.user.properties in current directory will be used instead.
The directory holding CONFIG-FILE or devenv.user.properties is searched
for another config file devenv.project.properties. If it exists, properties 
defined in this file are loaded with lower precedence.
If no configuration file can be found at all, $ME ends with an error, 
with one exception: 'get config'.
EOF
}

#-------------------------------------------------------------------------------
# helper method, giving information about handling of CUSTOM_*_DIR properties
# $1 - required. Fills the * in CUSTOM_*_DIR with the real value.
# $2 - optional. Number of spaces to indent content
msg_custom_dir() {
    FACET="${1:-*}"
    INDENT="${2:-0}"
    indent $INDENT <<EOF
CUSTOM_${FACET}_DIR can be defined as an absolute or relative path. If a
relative path is configured, the according absolute path is determined at
runtime. If a project specific configuration file exists 
(devenv.project.properties), the directory holding this configuration file
will be used as base directory for the relative path.
If no project specific configuration file exists at all, a relative path
defined in CUSTOM_${FACET}_DIR will be expanded relative to the current
working directory.
EOF
}

#-------------------------------------------------------------------------------
help() {
    ME=$(basename "$0")
    cat <<EOF
$ME
    command line interface for configuration with ID $ID.

SYNOPSIS
    $ME [CONFIG-FILE] COMMAND

CONFIG-FILE
$(msg_config_file 4)

COMMANDS
    get|g*             get devenv4iom specific resource
    info|i*            get information about Kubernetes resources
    create|c*          create Kubernetes/Docker resources
    delete|de*         delete Kubernetes/Docker resources
    apply|a*           apply customization
    dump|du*           create or load dump
    log|l*             simple access to log messages

Run '$ME [CONFIG-FILE] COMMAND --help|-h' for more information on a command.
EOF
}

#-------------------------------------------------------------------------------
help-info() {
    ME=$(basename "$0")
    cat <<EOF
display information about Kubernetes/Docker resources

SYNOPSIS
    $ME [CONFIG-FILE] info RESOURCE

CONFIG-FILE
$(msg_config_file 4)

RESOURCE
    iom|i*             view information about IOM
    postgres|p*        view information about Postgres
    mailserver|m*      view information about mail server
    storage|s*         view information about storage
    cluster|cl*        view information about cluster
    config|co*         view information about configuration

Run '$ME [CONFIG-FILE] info RESOURCE  --help|-h' for more information on a command.
EOF
}

#-------------------------------------------------------------------------------
help-info-iom() {
    ME=$(basename "$0")
    cat <<EOF
view information about IOM

SYNOPSIS
    $ME [CONFIG-FILE] info iom

CONFIG-FILE
$(msg_config_file 4)
EOF
}

#-------------------------------------------------------------------------------
help-info-postgres() {
    ME=$(basename "$0")
    cat <<EOF
view information about postgres

SYNOPSIS
    $ME [CONFIG-FILE] info postgres

CONFIG-FILE
$(msg_config_file 4)
EOF
}

#-------------------------------------------------------------------------------
help-info-mailserver() {
    ME=$(basename "$0")
    cat <<EOF
view information about mailserver

SYNOPSIS
    $ME [CONFIG-FILE] info mailserver

CONFIG-FILE
$(msg_config_file 4)
EOF
}

#-------------------------------------------------------------------------------
help-info-storage() {
    ME=$(basename "$0")
    cat <<EOF
view information about storage

SYNOPSIS
    $ME [CONFIG-FILE] info storage

CONFIG-FILE
$(msg_config_file 4)
EOF
}

#-------------------------------------------------------------------------------
help-info-cluster() {
    ME=$(basename "$0")
    cat <<EOF
view information about cluster

SYNOPSIS
    $ME [CONFIG-FILE] info cluster

CONFIG-FILE
$(msg_config_file 4)
EOF
}

#-------------------------------------------------------------------------------
help-info-config() {
    ME=$(basename "$0")
    cat <<EOF
view information about configuration

SYNOPSIS
    $ME [CONFIG-FILE] info config

CONFIG-FILE
$(msg_config_file 4)
EOF
}

#-------------------------------------------------------------------------------
help-create() {
    ME=$(basename "$0")
    cat <<EOF
create Kubernetes/Docker resource

SYNOPSIS
    $ME [CONFIG-FILE] create RESOURCE

CONFIG-FILE
$(msg_config_file 4)

RESOURCE
    storage|s*         create persistant local Docker storage
    namespace|n*       create kubernetes namespace
    mailserver|m*      create mail server
    postgres|p*        create postgres server
    iom|i*             create iom server
    cluster|c*         create all resources

Run '$ME [CONFIG-FILE] create RESOURCE --help|-h' for more information
EOF
}

#-------------------------------------------------------------------------------
help-create-storage() {
    ME=$(basename "$0")
    cat <<EOF
create a local Docker volume for persistent storage of DB data

SYNOPSIS
    $ME [CONFIG-FILE] create storage

OVERVIEW
    Creates a Docker volume, depending on the configuration variable
    KEEP_DATABASE_DATA. If you want to use persistent storage, the Docker
    volume has to be created before starting postgres.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    KEEP_DATABASE_DATA - only when set to true, the Docker volume will be
      created.
    ID - name of Docker volume will be derived from ID

SEE
    $ME [CONFIG-FILE] delete storage
    $ME [CONFIG-FILE] info   storage
    $ME [CONFIG-FILE] create postgres

BACKGROUND
    # executed only, if KEEP_DATABASE_DATA is true
    $KeepDatabaseSh docker volume create --name=$EnvId-pgdata -d local
EOF
}

#-------------------------------------------------------------------------------
help-create-namespace() {
    ME=$(basename "$0")
    cat <<EOF
creates a Kubernetes namespace which will be used for all other resources

SYNOPSIS
    $ME [CONFIG-FILE] create namespace

OVERVIEW
    Kubernetes namespaces isolate different devenv4iom instances from
    each other.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    ID - the name of namespace is derived from the ID of the current configuration.

SEE
    $ME [CONFIG-FILE] delete namespace

BACKGROUND
    kubectl create namespace $EnvId --context="$KUBERNETES_CONTEXT"
EOF
}

#-------------------------------------------------------------------------------
help-create-mailserver() {
    ME=$(basename "$0")
    cat <<EOF
creates a mail server that is used by IOM to send mails

SYNOPSIS
    $ME [CONFIG-FILE] create mailserver

OVERVIEW
    Creates a mail server and according service.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    MAILHOG_IMAGE - defines the image of the mailserver to be used
    IMAGE_PULL_POLICY - defines when to pull the image from origin
    ID - the namespace to be used is derived from ID

SEE
    $ME [CONFIG-FILE] delete mailserver
    $ME [CONFIG-FILE] info pods

BACKGROUND
    "$DEVENV_DIR/bin/template_engine.sh" \\
      --template="$DEVENV_DIR/templates/mailhog.yml.template" \\
      --config="$CONFIG_FILES" \\
      --project-dir="$PROJECT_DIR" |
      kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT"  -f -
EOF
}

#-------------------------------------------------------------------------------
help-create-postgres() {
    ME=$(basename "$0")
    cat <<EOF
creates postgres server for use by IOM

SYNOPSIS
    $ME [CONFIG-FILE] create postgres

OVERVIEW
    Creates Postgres server and according service. If KEEP_DATABASE_DATA is
    set to true, the Docker volume has to be created in advance.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    DOCKER_DB_IMAGE - docker image to be used
    PGHOST - if set, it indicates the usage of an external Postgres server.
      The command will not create a Postgres server in this case.
    KEEP_DATABASE_DATA - if set to true, the command links the local Docker volume
      to the Postgres store.
    IMAGE_PULL_POLICY - defines when to pull the image from origin
    ID - the namespace where Postgres server and service are created. It is
      derived from the ID of the current configuration.

SEE
    $ME [CONFIG-FILE] delete postgres
    $ME [CONFIG-FILE] create storage
    $ME [CONFIG-FILE] info pods

BACKGROUND
    # Link Docker volume to database storage (only if KEEP_DATABASE_DATA == true)
    $KeepDatabaseSh MOUNTPOINT="\"\$(docker volume inspect --format='{{.Mountpoint}}' $EnvId-pgdata)\"" \\
    $KeepDatabaseSh   "$DEVENV_DIR/bin/template_engine.sh" \\
    $KeepDatabaseSh     --template="$DEVENV_DIR/templates/postgres-storage.yml.template" \\
    $KeepDatabaseSh     --config="$CONFIG_FILES" \\
    $KeepDatabaseSh     --project-dir="$PROJECT_DIR" |
    $KeepDatabaseSh   kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -

    # create Postgres
    "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/postgres.yml.template" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR" |
      kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -
EOF
}

#-------------------------------------------------------------------------------
help-create-iom() {
    ME=$(basename "$0")
    cat <<EOF
creates IOM server

SYNOPSIS
    $ME [CONFIG-FILE] create iom

OVERVIEW
    Creates IOM server and according service.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    IOM_DBACCOUNT_IMAGE - defines the dbaccount image to be used
    IOM_CONFIG_IMAGE - defines the config image to be used (IOM < v.4)
    IOM_APP_IMAGE - defines the IOM application image to be used (IOM < v.4)
    IOM_IMAGE - defined the IOM image to be used (IOM >= v.4)
    IMAGE_PULL_POLICY - defines when to pull images from origin
    IMAGE_PULL_SECRET - name of the secret to be used when pulling images from 
      origin.

SEE
    $ME [CONFIG-FILE] delete iom
    $ME [CONFIG-FILE] info pods

BACKGROUND
    "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/$IomTemplate" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR" |
      kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -
EOF
}

#-------------------------------------------------------------------------------
help-create-cluster() {
    ME=$(basename "$0")
    cat <<EOF
creates all resources required by IOM

SYNOPSIS
    $ME [CONFIG-FILE] create cluster

OVERVIEW
    Creates all resources to run IOM in devenv4iom (storage, namespace,
    Postgres, mail server, IOM). Finally, this is a shorcut for a couple of
    different commands only.

CONFIG-FILE
$(msg_config_file 4)

SEE
    $ME [CONFIG-FILE] create storage
    $ME [CONFIG-FILE] create namespace
    $ME [CONFIG-FILE] create postgres
    $ME [CONFIG-FILE] create mailserver
    $ME [CONFIG-FILE] create iom
EOF
}

#-------------------------------------------------------------------------------
help-delete() {
    ME=$(basename "$0")
    cat <<EOF
delete Kubernetes/Docker resource

SYNOPSIS
    $ME [CONFIG-FILE] delete RESOURCE

CONFIG-FILE
$(msg_config_file 4)

RESOURCE
    storage|s*         delete persistant local Docker storage
    namespace|n*       delete Kubernetes namespace including all resources
                       belonging to this namespace
    mailserver|m*      delete mail server
    postgres|p*        delete Postgres server
    iom|i*             delete IOM server
    cluster|c*         delete all resources, except storage

Run '$ME [CONFIG-FILE] delete RESOURCE --help|-h' for more information
EOF
}

#-------------------------------------------------------------------------------
help-delete-storage() {
    ME=$(basename "$0")
    cat <<EOF
deletes local Docker volume that is used for persistent storage of DB data

SYNOPSIS
    $ME [CONFIG-FILE] delete storage

OVERVIEW
    Deletes the Docker volume used for persistent storage of database data.
    Before deleting storage, you have to delete Postgres.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    ID - the name of the Docker volume will be derived from the ID.

SEE
    $ME [CONFIG-FILE] create storage
    $ME [CONFIG-FILE] info   storage
    $ME [CONFIG-FILE] delete postgres

BACKGROUND
    docker volume rm $EnvId-pgdata
EOF
}

#-------------------------------------------------------------------------------
help-delete-namespace() {
    ME=$(basename "$0")
    cat <<EOF
deletes the Kubernetes namespace used by the current IOM installation

SYNOPSIS
    $ME [CONFIG-FILE] delete namespace

OVERVIEW
    When deleting the namespace, all resources of this namespace are deleted
    too. These are IOM, Posgres and mail server, but not the Docker volume
    used for persistent storage of database data.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    ID - the name of the namespace is derived from the ID of the current configuration.

SEE
    $ME [CONFIG-FILE] create namespace

BACKGROUND
    kubectl delete namespace ${EnvId} --context="$KUBERNETES_CONTEXT"
EOF
}

#-------------------------------------------------------------------------------
help-delete-mailserver() {
    ME=$(basename "$0")
    cat <<EOF
deletes mail server that is used by IOM to send mails

SYNOPSIS
    $ME [CONFIG-FILE] delete mailserver

OVERVIEW
    Deletes the mail server and the according service.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    ID - the namespace where the mail server is deleted is derived from ID

SEE
    $ME [CONFIG-FILE] create mailserver
    $ME [CONFIG-FILE] info   mailserver

BACKGROUND
    "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/mailhog.yml.template" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR" |
      kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -
EOF
}

#-------------------------------------------------------------------------------
help-delete-postgres() {
    ME=$(basename "$0")
    cat <<EOF
deletes Postgres server used by IOM

SYNOPSIS
    $ME [CONFIG-FILE] delete postgres

OVERVIEW
    Deletes Postgres server and according service.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    ID - the namespace where Postgres is deleted from is derived from ID

SEE
    $ME [CONFIG-FILE] create postgres
    $ME [CONFIG-FILE] info   postgres
    $ME [CONFIG-FILE] info   pods

BACKGROUND
    # Stop/Remove postgres database
    "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/postgres.yml.template" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR" |
      kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -

    # Unlink Docker volume from database storage
    MOUNTPOINT="\"\$(docker volume inspect --format='{{.Mountpoint}}' $EnvId-pgdata)\"" \\
      "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/postgres-storage.yml.template" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR" |
      kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -
EOF
}

#-------------------------------------------------------------------------------
help-delete-iom() {
    ME=$(basename "$0")
    cat <<EOF
deletes IOM

SYNOPSIS
    $ME [CONFIG-FILE] delete iom

OVERVIEW
    Deletes IOM and the according service.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    ID - the namespace where IOM is deleted from is derived from ID

SEE
    $ME [CONFIG-FILE] create iom
    $ME [CONFIG-FILE] info   iom
    $ME [CONFIG-FILE] info   pods

BACKGROUND
    "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/$IomTemplate" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR" |
      kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -
EOF
}

#-------------------------------------------------------------------------------
help-delete-cluster() {
    ME=$(basename "$0")
    cat <<EOF
deletes all resources used by IOM, except storage

SYNOPSIS
    $ME [CONFIG-FILE] delete cluster

OVERVIEW
    Deletes all resources used by IOM, except storage. These are IOM, Postgres,
    mail server, namespace. Finally, this is a shortcut for a couple of
    different commands only.
    Storage will not be deleted, as it is the basic idea of persistent storage,
    to survive the deletion of postgres.

CONFIG-FILE
$(msg_config_file 4)

SEE
    $ME [CONFIG-FILE] delete iom
    $ME [CONFIG-FILE] delete postgres
    $ME [CONFIG-FILE] delete mailserver
    $ME [CONFIG-FILE] delete postgres
    $ME [CONFIG-FILE] delete namespace
    $ME [CONFIG-FILE] delete storage
EOF
}

#-------------------------------------------------------------------------------
help-apply() {
    ME=$(basename "$0")
    cat <<EOF
apply customization

SYNOPSIS
    $ME [CONFIG-FILE] apply RESOURCE

CONFIG-FILE
$(msg_config_file 4)

RESOURCE
    deployment|de*     apply custom deployment artifacts
    mail-templates|m*  apply custom mail templates
    xsl-templates|x*   apply custom XSL template
    sql-scripts|sql-s* apply custom SQL scripts
    sql-config|sql-c*  apply custom SQL config
    json-config|j*     apply custom JSON config
    dbmigrate|db*      apply custom DB migration

Run '$ME [CONFIG-FILE] apply RESOURCE --help|-h' for more information on a command.
EOF
}

#-------------------------------------------------------------------------------
help-apply-deployment() {
    ME=$(basename "$0")
    cat <<EOF
deploys custom built artifacts

SYNOPSIS
    $ME [CONFIG-FILE] apply deployment [PATTERN]

ARGUMENTS
    PATTERN - optional. Pattern is simply a regex, which will be matched
      against deployment artifacts. If pattern is set, only artifacts matching
      the pattern will be redeployed in forced mode.
      If pattern is not set, all artifacts will be undeployed and deployed
      again.

OVERVIEW
    The Developer VM has an extended search path for deployments. The scripts
    doing the deployment look first at directory /opt/oms/application-dev,
    instead of the standard directory /opt/oms/application, which contains all
    the standard deployment artifacts delivered by the Docker image. Hence, if
    an artifact was found in /opt/oms/application-dev, the according standard
    artifact will be ignored.
    All you have to do is to mount a directory containing your custom built
    artifacts at /opt/oms/application-dev. To do so, you have to:
    - Set variable CUSTOM_APPS_DIR in your configuration file and make sure,
      that the directory is shared in Docker Desktop.
    - After changing CUSTOM_APPS_DIR, IOM needs to be restarted.
    Once you have configured your developer VM this way, your custom built
    artifacts are deployed right at the start of IOM.
    Alternatively you can use Wildfly Console for deployments too.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    CUSTOM_APPS_DIR - directory, where your custom built artifacts are located.
      Make sure, the directory is shared with Docker Desktop.
$(msg_custom_dir APPS 6)
    ID - the namespace used is derived from ID

SEE
    $ME [CONFIG-FILE] info iom

BACKGROUND
    # redeploy omt selectively
    POD_NAME=\$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l app=iom -o jsonpath="{.items[0].metadata.name}")
    kubectl exec \$POD_NAME --namespace $EnvId --context="$KUBERNETES_CONTEXT" -- bash -ic redeploy omt

    # redeploy all
    POD_NAME=\$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l app=iom -o jsonpath="{.items[0].metadata.name}")
    kubectl exec \$POD_NAME --namespace $EnvId --context="$KUBERNETES_CONTEXT" -- bash -ic redeploy
EOF
}

#-------------------------------------------------------------------------------
help-apply-mail-templates() {
    ME=$(basename "$0")
    cat <<EOF
rolls out custom mail templates

SYNOPSIS
  $ME [CONFIG-FILE] apply mail-templates

OVERVIEW
    The developer VM contains an additional directory /opt/oms/templates-dev,
    which will be used as mount point for custom mail templates. Part of the
    developer VM is also the script apply-templates, which copies the templates
    from /opt/oms/templates-dev to the standard directory /opt/oms/var/templates.
    If you want to roll out custom mail templates in a running developer VM, you
    have to:
    - Set variable CUSTOM_TEMPLATES_DIR in your configuration file and make sure
      that the directory is shared in Docker Desktop.
    - After changing CUSTOM_TEMPLATES_DIR, IOM needs to be restarted.
    If CUSTOM_TEMPLATES_DIR is configured, the templates are also copied when
    starting IOM.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    CUSTOM_TEMPLATES_DIR - directory, where your custom mail templates are
      located. Make sure, the directory is shared with Docker Desktop.
$(msg_custom_dir TEMPLATES 6)
    ID - the namespace used is derived from ID

SEE
    $ME [CONFIG-FILE] delete iom
    $ME [CONFIG-FILE] create iom
    $ME [CONFIG-FILE] info   iom

BACKGROUND
    POD_NAME=\$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l app=iom -o jsonpath="{.items[0].metadata.name}")
    kubectl exec \$POD_NAME --namespace $EnvId --context="$KUBERNETES_CONTEXT" -- bash -ic apply-templates
EOF
}

#-------------------------------------------------------------------------------
help-apply-xsl-templates() {
    ME=$(basename "$0")
    cat <<EOF
rolls out custom XSL templates

SYNOPSIS
  $ME [CONFIG-FILE] apply xsl-templates

OVERVIEW
    The developer VM contains a directory /opt/oms/xslt-dev, which will be used
    as mount point for custom XSL templates. Part of the developer VM is also
    the script apply-xslt, which copies the templates from /opt/oms/xslt-dev to
    the standard directory /opt/oms/var/xslt. If you want to roll out custom xsl
    templates in a running developer VM, you have to:
    - Set variable CUSTOM_XSLT_DIR in your configuration file and make sure, that
      the directory is shared in Docker Desktop.
    - After changing CUSTOM_XSLT_DIR, IOM has to be restarted.
    If CUSTOM_XSLT_DIR is configured, the templates are also copied when
    starting IOM.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    CUSTOM_XSLT_DIR - directory, where your custom XSL templates are located.
      Make sure, the directory is shared with Docker Desktop.
$(msg_custom_dir XSLT 6)
    ID - the namespace used is derived from ID.

SEE
    $ME [CONFIG-FILE] delete iom
    $ME [CONFIG-FILE] create iom
    $ME [CONFIG-FILE] info   iom

BACKGROUND
    POD_NAME=\$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l app=iom -o jsonpath="{.items[0].metadata.name}")
    kubectl exec \$POD_NAME --namespace $EnvId --context="$KUBERNETES_CONTEXT" -- bash -ic apply-xslt
EOF
}

#-------------------------------------------------------------------------------
help-apply-sql-scripts() {
    ME=$(basename "$0")
    cat <<EOF
applies SQL files from passed directory or single SQL file

SYNOPSIS
    $ME [CONFIG-FILE] apply sql-scripts DIRECTORY|FILE [TIMEOUT]

ARGUMENTS
    DIRECTORY|FILE has to be shared in Docker Desktop.
    TIMEOUT in seconds. Defaults to 60.

OVERVIEW
    The docker-image defined by IOM_CONFIG_IMAGE/IOM_IMAGE contains all the 
    necessary tools to apply SQL scripts to the IOM database. Devenv4iom enables 
    you to use these tools as easily as possible. Therefore it provides a 
    Kubernetes job (apply-sql-job), that applies SQL file(s) to the IOM database.

    There are two different modes that can be used.

    If a directory is passed to the job, all SQL files found in this directory
    are processed in numerical order, starting with the smallest one.
    Sub-directories are not scanned for SQL files.

    If a file is passed to the job, only this file will be executed.

    The logs are printed in JSON format. Verbosity can be controlled by
    configuration variable OMS_LOGLEVEL_SCRIPTS.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    ID - the namespace used is derived from ID
    OMS_LOGLEVEL_SCRIPTS - controls verbosity of script applying the SQL files.

SEE
    $ME [CONFIG-FILE] info iom

BACKGROUND
    # define directory with SQL file (has to be an absolute path)
    export SQL_SRC=<DIRECTORY>

    # start apply-sql-job
    "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/apply-sql.yml.template" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR" | 
      kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -

    # get logs of job
    POD_NAME=\$(kubectl get pods --namespace $EnvId \\
      --context="$KUBERNETES_CONTEXT" \\
      -l job-name=apply-sql-job \\
      -o jsonpath="{.items[0].metadata.name}")
    kubectl logs \$POD_NAME --namespace $EnvId --context="$KUBERNETES_CONTEXT"

    # delete apply-sql-job
    "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/apply-sql.yml.template" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR" | 
      kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -
EOF
}

#-------------------------------------------------------------------------------
help-apply-sql-config() {
    ME=$(basename "$0")
    cat <<EOF
applies custom sql configuration

SYNOPSIS
    $ME [CONFIG-FILE] apply sql-config

OVERVIEW
    Scripts for SQL configuration are simple SQL scripts, which can be easily
    developed and tested using the developer task "apply sql-scripts".
    However, SQL configuration in a project context is more complex. E.g.
    the scripts are executed depending on the currently activated environment.
    In order to enable you to test SQL configuration scripts exactly in the same
    context as in real IOM installations, the developer task "apply sql-config"
    is provided.
    To be able to roll out complete SQL configurations, you have to:
    - Set variable CUSTOM_SQLCONF_DIR in your configuration file and make sure,
      that the directory is shared in Docker Desktop.
    - Set variable PROJECT_ENV_NAME in your configuratoin file to the environment
      you want to test.
    You should have an eye on the logs created by the configuration process.
    These logs are printed in JSON format. Verbosity can be controlled by the
    configuration variable OMS_LOGLEVEL_SCRIPTS.
    If CUSTOM_SQLCONFIG_DIR is configured, the custom SQL configuration is also
    applied when starting IOM.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    CUSTOM_SQLCONF_DIR - directory where your custom SQL configuration is
      located.
$(msg_custom_dir SQLCONF 6)
    PROJECT_ENV_NAME - environment name; controls which parts of the SQL
    configuration will be applied and which not.
    OMS_LOGLEVEL_SCRIPTS - controls verbosity of script applying SQL
      configuration.

SEE
    $ME [CONFIG-FILE] info iom

BACKGROUND
    # start sqlconfig-job
    "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/sqlconfig.yml.template" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR" |
      kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -

    # get logs of job
    POD_NAME=\$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l job-name=sqlconfig-job -o jsonpath="{.items[0].metadata.name}")
    kubectl logs \$POD_NAME --namespace $EnvId --context="$KUBERNETES_CONTEXT"

    # delete sqlconfig-job
    "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/sqlconfig.yml.template" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR" |
      kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -
EOF
}

#-------------------------------------------------------------------------------
help-apply-json-config() {
    ME=$(basename "$0")
    cat <<EOF
applies custom JSON configuration

SYNOPSIS
    $ME [CONFIG-FILE] apply json-config

OVERVIEW
    JSON configuration of IOM is not publicly available. There is no task to
    support development of single JSON configuration scripts. Additionally the
    current implementation of JSON configuration does not use the concept of
    environments (configuration variable PROJECT_ENV_NAME). The current developer
    task "apply json-config" allows to apply complete JSON configurations
    exactly in the same context as in a real IOM installation.
    To be able to roll out JSON configurations, you have to:
    - Set variable CUSTOM_JSONCONF_DIR in your configuration file and make sure,
      that the directory is shared in Docker Desktop.
    You should have an eye on the logs created by the configuration process.
    These logs are printed in JSON format. Verbosity can be controlled by
    configuration variable OMS_LOGLEVEL_SCRIPTS.
    If CUSTOM_JSONCONFIG_DIR is configured, the custom JSON configuration is
    also applied when starting IOM.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    CUSTOM_JSONCONF_DIR - directory where your custom JSON confguration is
      located.
$(msg_custom_dir JSONCONF 6)
    IOM_CONFIG_IMAGE - defines the image to be used when executing the job (IOM < v.4).
    IOM_IMAGE - defines the image to be used when executing the job (IOM >= v.4).
    IMAGE_PULL_POLICY - defines when to pull the image from origin.
    OMS_LOGLEVEL_SCRIPTS - controls verbosity of script applying JSON
      configuration.
    ID - the namespace used is derived from ID.

SEE
    $ME [CONFIG-FILE] info iom

BACKGROUND
    # start jsonconfig-job
    "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/jsonconfig.yml.template" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR" |
      kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -

    # get logs of job
    POD_NAME=\$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l job-name=jsonconfig-job -o jsonpath="{.items[0].metadata.name}")
    kubectl logs \$POD_NAME --namespace $EnvId --context="$KUBERNETES_CONTEXT"

    # delete jsonconfig-job
    "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/jsonconfig.yml.template" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR" |
      kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -
EOF
}

#-------------------------------------------------------------------------------
help-apply-dbmigrate() {
    ME=$(basename "$0")
    cat <<EOF
applies custom dbmigrate scripts

SYNOPSIS
    $ME [CONFIG-FILE] apply dbmigrate

OVERVIEW
    To develop and test a single or a couple of SQL scripts (which can be
    migration scripts too), the developer task "apply sql-scripts" is the first
    choice. However, at some point of development, the dbmigrate process as a
    whole has to be tested too. The dbmigrate process is somewhat more complex
    than simply applying SQL scripts from a directory. It first loads stored
    procedures from the stored_procedures directory and then it applies the
    migrations scripts found in the migrations directory. The order of execution
    is controlled by the names of sub-directories within migrations and the
    naming of the migration scripts itself (numerically sorted, smallest first).

    The IOM_CONFIG_IMAGE/IOM_IMAGE contains a shell script, that applies the 
    migration scripts which are delivered along with the Docker image. The 
    developer task "apply dbmigrate" enables you to use this dbmigrate script 
    along with the migration scripts located at CUSTOM_DBMIGRATE_DIR. Hence, if 
    you want to roll out custom dbmigrate scripts, you have to:
    - Set the variable CUSTOM_DBMIGRATE_DIR in your configuration file and make
      sure, that the directory is shared in Docker Desktop.
    You can and should have an eye on the logs created by the migration process.
    These logs are printed in JSON format. Verbosity can be controlled by the
    configuration variable OMS_LOGLEVEL_SCRIPTS.
    If CUSTOM_DBMIGRATE_DIR is configured, the custom dbmigrate scripts are also
    applied when starting IOM.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    CUSTOM_DBMIGRATE_DIR - directory where your custom dbmigrate scripts are
      located. This directory needs two sub-directories: stored_procedures,
      migrations.
$(msg_custom_dir DBMIGRATE 6)
    IOM_CONFIG_IMAGE - defines the image to be used when executing the job (IOM < v.4).
    IOM_IMAGE - defines the image to be used when executing the job (IOM >= v.4).
    IMAGE_PULL_POLICY - defines when to pull the image from origin.
    OMS_LOGLEVEL_SCRIPTS - controls the verbosity of the script doing
      the db-migration.
    ID - the namespace used is derived from ID.

SEE
    $ME [CONFIG-FILE] info iom

BACKGROUND
    # start dbmigrate-job
    "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/dbmigrate.yml.template" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR" |
      kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -

    # get logs of job
    POD_NAME=\$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l job-name=dbmigrate-job -o jsonpath="{.items[0].metadata.name}")
    kubectl logs \$POD_NAME --namespace $EnvId --context="$KUBERNETES_CONTEXT"

    # delete dbmigrate-job
    "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/dbmigrate.yml.template" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR" |
      kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -
EOF
}

#-------------------------------------------------------------------------------
help-dump() {
    ME=$(basename "$0")
    cat <<EOF
handle dump

SYNOPSIS
    $ME [CONFIG-FILE] dump OPERATION

CONFIG-FILE
$(msg_config_file 4)

OPERATION
    create|c*          create dump
    load|l*            load dump

Run '$ME [CONFIG-FILE] dump OPERATION --help|-h' for more information on a command.
EOF
}

#-------------------------------------------------------------------------------
help-dump-create() {
    ME=$(basename "$0")
    cat <<EOF
creates a dump of current database

SYNOPSIS
    $ME [CONFIG-FILE] dump create

OVERVIEW
    Devenv4iom provides a job to create a dump of the IOM database. This job
    uses the variable CUSTOM_DUMPS_DIR. It writes the dumps to this directory.
    The created dumps uses the following naming pattern:
    OmsDump.year-month-day.hour.minute.second-hostname.sql.gz. To create dumps,
    you have to:
    - Set variable CUSTOM_DUMPS_DIR in your configuration file and make sure
      that the directory is shared in Docker Desktop.
    You should check the output of the dump-job. The logs of the job are printed
    in JSON format. Verbosity can be controlled by the configuration variable
    OMS_LOGLEVEL_SCRIPTS.

    If CUSTOM_DUMPS_DIR is configured, the newest custom dump will be loaded
    when starting IOM with an empty database (according to the load-rules that
    can be found in overview of '$ME dump load'.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    CUSTOM_DUMPS_DIR - directory where custom dumps will be stored. If this
      variable is empty, no dumps will be created.
$(msg_custom_dir DUMPS 6)
    IOM_CONFIG_IMAGE - defines the image to be used when executing the job (IOM < v.4).
    IOM_IMAGE - defined the image to be used when executing the job (IOM >= v.4).
    IMAGE_PULL_POLICY - defines when to pull the image from origin.
    OMS_LOGLEVEL_SCRIPTS - controls verbosity of the script creating the dump.
    ID - the namespace used is derived from ID.

SEE
    $ME [CONFIG-FILE] dump load

BACKGROUND
    # start dump-job
    "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/dump.yml.template" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR" |
      kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -

    # get logs of job
    POD_NAME=\$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l job-name=dump-job -o jsonpath="{.items[0].metadata.name}")
    kubectl logs \$POD_NAME --namespace $EnvId --context="$KUBERNETES_CONTEXT"

    # delete dump-job
    "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/dump.yml.template" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR" |
      kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f -
EOF
}

#-------------------------------------------------------------------------------
help-dump-load() {
    ME=$(basename "$0")
    cat <<EOF
loads a custom dump into database

SYNOPSIS
    $ME [CONFIG-FILE] dump load

OVERVIEW
    When starting IOM and the conneted database is empty, the config container
    loads the initial dump. Devenv4iom allows to load a custom dump during this
    process. This custom dump will be treated exactly as any other dump which
    is part of the docker image.
    If you want to load a custom dump, you have to:
    - Set variable CUSTOM_DUMPS_DIR in your configuration file and make sure
      that the directory is shared in Docker Desktop. The dump you want to load
      has to be located within this directory. To be recognized as a dump, it
      has to have the extension .sql.gz. If the directory contains more than one
      dump file, the script of the config container selects the one with the
      largest numerical name. You can check this with following command:
      ls *.sql.gz | sort -nr | head -n 1

    The custom dump can only be loaded if the database is empty. The current
    command executes all the necessary steps to restart IOM with an empty
    database:
    - delete iom
    - delete postgres
    - delete storage
    - create storage
    - create postgres
    - create iom
    You should inspect the logs created when running the config container to
    know if the dump was actually loaded. The logs of the config process are
    printed in JSON format. Verbosity can be controlled by configuration
    variable OMS_LOGLEVEL_SCRIPTS.

    This command works only if an internal PostgreSQL server is used.
    Devenv4iom is not able to control an external PostgreSQL server.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    CUSTOM_DUMPS_DIR - the directory in which custom dumps must be located.
$(msg_custom_dir DUMPS 6)

    As 'dump load' is only a shortcut for a couple of others commands, you
    can learn more about CONFIG by requesting help of these commands.

SEE
    $ME [CONFIG-FILE] delete iom
    $ME [CONFIG-FILE] delete postgres
    $ME [CONFIG-FILE] delete storage
    $ME [CONFIG-FILE] create storage
    $ME [CONFIG-FILE] create postgres
    $ME [CONFIG-FILE] create iom
EOF
}

#-------------------------------------------------------------------------------
help-get() {
    ME=$(basename "$0")
    cat <<EOF
writes devenv4iom specific resource to stdout

SYNOPSIS
    $ME [CONFIG-FILE] get RESOURCE

CONFIG-FILE
$(msg_config_file 4)

RESOURCE
    config|co*         get configuration file
    ws-props|w*        get ws properties
    geb-props|g*       get geb properties
    soap-props|s*      get soap properties

Run '$ME [CONFIG-FILE] get RESOURCE --help|-h' for more information on a command.
EOF
}

#-------------------------------------------------------------------------------
help-get-config() {
    ME=$(basename "$0")
    cat <<EOF
writes configuration to stdout

SYNOPSIS
    $ME [CONFIG-FILE] get config [--skip-config|--skip-user-config]

ARGUMENTS
    --skip-config|--skip-user-config - optional. If --skip-config is set, 
      $ME ignores any existing configuration. In case of 
      --skip-user-config, only the user specific configuration will be ignored. 
      Using this options, it is possible to create clean configurations for 
      different use cases. --skip-config is intended to be used, when creating 
      new configurations or to reset configurations to factory defaults. 
      --skip-user-config helps to maintain project specific configurations.

OVERVIEW
    Devenv4iom provides a template for configuration files. With every new
    version new configuration variables might be introduced or the description
    of existing configuration variables might be improved.
    The 'get config' writes a new configuration to stdout based on the template
    but containing the original configuration values.
    Hence, you should run 'get config' after every update of devenv4iom to keep
    your configuration files up to date.
    When called without passing a configuration file, a configuration containg
    default values is written to stdout.

CONFIG-FILE
$(msg_config_file 4)

BACKGROUND
    "$DEVENV_DIR/bin/template_engine.sh" \\
        --template="$DEVENV_DIR/templates/config.properties.template" \\
        --config="$CONFIG_FILES" \\
        --project-dir="$PROJECT_DIR"
EOF
}

#-------------------------------------------------------------------------------
help-get-ws-props() {
    ME=$(basename "$0")
    cat <<EOF
writes ws properties to stdout

SYNOPSIS
    $ME [CONFIG-FILE] get ws-props

OVERVIEW
    Writes ws properties to stdout. This file is required to run ws-tests on the
    managed IOM installation.

CONFIG-FILE
$(msg_config_file 4)

BACKGROUND
    "$DEVENV_DIR/bin/template_engine.sh" \\
      --template="$DEVENV_DIR/templates/ws.properties.template" \\
      --config="$CONFIG_FILES" \\
      --project-dir="$PROJECT_DIR"
EOF
}

#-------------------------------------------------------------------------------
help-get-geb-props() {
    ME=$(basename "$0")
    cat <<EOF
writes geb properties to stdout

SYNOPSIS
    $ME [CONFIG-FILE] get geb-props

OVERVIEW
    Writes geb properties to stdout. This file is required to run geb-tests on
    the managed IOM installation.

CONFIG-FILE
$(msg_config_file 4)

BACKGROUND
    "$DEVENV_DIR/bin/template_engine.sh" \\
      --template="$DEVENV_DIR/templates/geb.properties.template" \\
      --config="$CONFIG_FILES" \\
      --project-dir="$PROJECT_DIR"
EOF
}

#-------------------------------------------------------------------------------
help-get-soap-props() {
    ME=$(basename "$0")
    cat <<EOF
writes soap properties to stdout

SYNOPSIS
    $ME [CONFIG-FILE] get soap-props

OVERVIEW
    Writes soap properties to stdout. This file is required to run soap-tests on
    the managed IOM installation.

CONFIG-FILE
$(msg_config_file 4)

BACKGROUND
    "$DEVENV_DIR/bin/template_engine.sh" \\
      --template="$DEVENV_DIR/templates/soap.properties.template" \\
      --config="$CONFIG_FILES" \\
      --project-dir="$PROJECT_DIR"
EOF
}

#-------------------------------------------------------------------------------
help-log() {
    ME=$(basename "$0")
    cat <<EOF
very basic access to log-messages

SYNOPSIS
    $ME [CONFIG-FILE] log WHAT

CONFIG-FILE
$(msg_config_file 4)

WHAT
    dbaccount|d*       get logs of dbaccount init-container
EOF
    if [ "$IsIomSingleDist" = 'true' ]; then
        cat <<EOF
    iom|i*             get message logs of iom container
    access|ac*         get access logs of iom container 
EOF
    else
        cat <<EOF
    config|c*          get logs of iom-config init-container
    app|ap*            get message logs of iom-app container
    access|ac*         get access logs of iom-app container
EOF
    fi
    cat <<EOF

Run '$ME [CONFIG-FILE] log WHAT --help|-h' for more information on command
EOF
}

#-------------------------------------------------------------------------------
help-log-dbaccount() {
    ME=$(basename "$0")
    cat <<EOF
get logs of dbaccount init-container

SYNOPSIS
    $ME [CONFIG-FILE] log dbaccount [LEVEL] [-f]

ARGUMENTS
    LEVEL - optional. If set, it has to be one of
      FATAL|ERROR|WARN|INFO|DEBUG|TRACE. If not set, WARN will be used.
      The specified level defines which messages are printed. Only messages of
      the specified level and higher levels will be shown.
    -f - optional. If set, $ME follows new messages only. If not set, ALL
      messages created until now are printed and the process ends after it.

OVERVIEW
    Requires 'jq' to be installed.
    Writes messages of dbaccount init-container and filters them according to
    the specified log-level.
    Behaves differntly when used inside and outside a pipe.
    If output is written to a terminal, $ME formats the messages.
    If output is written to a pipe, no formatting is applied. This makes it
    easier to use the output for further processing.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    OMS_LOGLEVEL_SCRIPTS - controls what type of messages are written. Messages
      that are not written in container can never be seen.

SEE
    $ME [CONFIG-FILE] info iom
EOF
}

#-------------------------------------------------------------------------------
help-log-config() {
    ME=$(basename "$0")
    cat <<EOF
get messages of config init-container

SYNOPSYS
    $ME [CONFIG-FILE] log config [LEVEL] [-f]

ARGUMENTS
    LEVEL - optional. If set, it has to be one of
      FATAL|ERROR|WARN|INFO|DEBUG|TRACE. If not set, WARN will be used.
      The specified level defines which messages are printed. Only messages of
      specified level and higher levels will be shown.
    -f - optional. If set, $ME follows new messages only. If not set, ALL
      messages created until now are printed and the process ends after it.

OVERVIEW
    Requires 'jq' to be installed.
    Writes messages of config init-container and filters them according the
    specified log level.
    Behaves differently when used inside and outside of a pipe.
    If output is written to a terminal, $ME formats the messages.
    If output is written to a pipe, no formatting is applied. This makes it
    easier to use the output for further processing.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    OMS_LOGLEVEL_SCRIPTS - controls what type of messages are written. Messages
      that are not written in container can never be seen.

SEE
    $ME [CONFIG-FILE] info iom
EOF
}

#-------------------------------------------------------------------------------
help-log-app() {
    help-log-iom backwardCompatible
}
help-log-iom() {
    SCOPE=iom
    if [ "$1" = 'backwardCompatible' ]; then
        SCOPE=app
    fi
    
    ME=$(basename "$0")
    cat <<EOF
get messages of iom container

SYNOPSIS
    $ME [CONFIG-FILE] log $SCOPE [LEVEL] [-f]

ARGUMENTS
    LEVEL - optional. If set, it has to be one of
      FATAL|ERROR|WARN|INFO|DEBUG|TRACE. If not set, WARN will be used.
      The specified level defines which messages are printed. Only messages of
      specified level and higher levels will be shown.
    -f - optional. If set, $ME follows new messages only. If not set, ALL
      messages created until now are printed and the process ends after it.

OVERVIEW
    Requires 'jq' to be installed!
    Writes messages of the IOM container and filters them according the 
    specified log level.
    The Wildfly application server still writes some messages that are not in
    JSON format. Those messages can only be seen when accessing the output of
    the container directly.
    Behaves differently when used inside and outside of a pipe.
    If output is written to a terminal, $ME formats the messages.
    If output is written to a pipe, no formatting is applied. This makes it
    easier to use the output for further processing.

CONFIG-FILE
$(msg_config_file 4)

CONFIG
    OMS_LOGLEVEL_SCRIPTS - controls what type of messages are written by
      scripts.
    OMS_LOGLEVEL_CONSOLE
    OMS_LOGLEVEL_IOM
    OMS_LOGLEVEL_HIBERNATE
    OMS_LOGLEVEL_QUARTZ
    OMS_LOGLEVEL_ACTIVEMQ
    OMS_LOGLEVEL_CUSTOMIZATION - all these variables control what type of
      messages are written by Wildfly application server and the IOM
      applications.

SEE
    $ME [CONFIG-FILE] info iom
EOF
}

#-------------------------------------------------------------------------------
help-log-access() {
    ME=$(basename "$0")
    cat <<EOF
get access logs of iom application-container

SYNOPSIS
    $ME [CONFIG-FILE] log access [LEVEL] [-f]

ARGUMENTS
    LEVEL - optional. If set, it has to be one of ERROR|ALL. If not set, ERROR
      will be used. The specified level defines which messages are printed. If
      set to ERROR, only access-log entries where HTTP status code is equal or
      greater than 400 are printed.
    -f - optional. If set, $ME follows new log entries only. If not set, ALL
      log entries created until now are printed and the process ends after it.

OVERVIEW
    Requires 'jq' to be installed.
    Writes access logs of iom application-container and filters them
    according the specified log-level.
    Behaves differently when used inside and outside of a pipe.
    If output is written to a terminal, $ME formats the messages.
    If output is written to a pipe, no formatting is applied. This makes it
    easier to use the output for further processing.

CONFIG-FILE
$(msg_config_file 4)

SEE
    $ME [CONFIG-FILE] info iom
EOF
}

################################################################################
# helper functions
################################################################################

#-------------------------------------------------------------------------------
# print error message
# $1: level 0
# $2: level 1
#-------------------------------------------------------------------------------
syntax_error() (
    ME="$(basename "$0")"
    log_msg ERROR "Syntax error. Please call '$ME $1 $2 --help' to get more information." < /dev/null
)

#-------------------------------------------------------------------------------
# logs messages
# $1:    log-level (ERROR|WARN|INFO|DEBUG)
# $2:    log-message
# stdin: additional info (error output of programs, etc.)
#-------------------------------------------------------------------------------
log_msg() (
    LEVEL="$1"
    MSG="$2"
    ADD_INFO="$(mktemp)"
    trap "rm -f $ADD_INFO" EXIT SIGTERM

    # store additional info
    cat > "$ADD_INFO"
    
    # get REQUESTED_LEVEL
    case $LEVEL in
        ERROR)
            REQUESTED_LEVEL=0
            ;;
        WARN)
            REQUESTED_LEVEL=1
            ;;
        INFO)
            REQUESTED_LEVEL=2
            ;;
        DEBUG)
            REQUESTED_LEVEL=3
            ;;
        *)
            echo "log_msg: unknown LEVEL '$LEVEL'" 1>&2
            exit 1
            ;;
    esac
    # get ALLOWED_LEVEL (from configuration)
    case $OMS_LOGLEVEL_DEVENV in
        ERROR)
            ALLOWED_LEVEL=0
            ;;
        WARN)
            ALLOWED_LEVEL=1
            ;;
        INFO)
            ALLOWED_LEVEL=2
            ;;
        DEBUG)
            ALLOWED_LEVEL=3
            ;;
        *)
            echo "log_msg: config variable OMS_LOGLEVEL_DEVENV contains invalid value '$OMS_LOGLEVEL_DEVENV'" 1>&2
            exit 1
            ;;
    esac

    # write message if REQUESTED_LEVEL <= ALLOWED_LEVEL
    if [ $REQUESTED_LEVEL -le $ALLOWED_LEVEL ]; then
        cat 1>&2 <<EOF
$(date -u +"%Y-%m-%dT%H:%M:%SZ") $LEVEL
  $MSG
EOF
        if [ -s "$ADD_INFO" ]; then
            indent 2 1>&2 < "$ADD_INFO"
        fi
    fi
    rm -f "$ADD_INFO"
)

#-------------------------------------------------------------------------------
# get name of operating system
#-------------------------------------------------------------------------------
OS() {
    if ! uname -o > /dev/null 2>&1; then
        uname -s
    else
        uname -o
    fi
}

#-------------------------------------------------------------------------------
# wait for job to complete
# $1: job name
# $2: timeout [s]
# ->: 0 if job was successfully completed before timeout
#     1 timed out
#     2 Job not Succeeded
#-------------------------------------------------------------------------------
kube_job_wait() (
    JOB_NAME=$1
    TIMEOUT=$2
    PHASE=$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l job-name=$JOB_NAME -o jsonpath='{.items[0].status.phase}' 2> /dev/null)
    START_TIME=$(date '+%s')
    while [ \( "$PHASE" != 'Succeeded' \) -a \( $PHASE"" != 'Failed' \) -a \( $(date '+%s') -lt $(expr "$START_TIME" + "$TIMEOUT") \) ]; do
        sleep 5
        PHASE=$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l job-name=$JOB_NAME -o jsonpath='{.items[0].status.phase}' 2> /dev/null)
    done
    if [ "$PHASE" = 'Succeeded' ]; then
        exit 0
    elif [ $(date '+%s') -ge $(expr "$START_TIME" + "$TIMEOUT") ]; then
        exit 1
    else
        exit 2
    fi
)

#-------------------------------------------------------------------------------
# wait for pod to be in phase running
# $1: app name (iom|postgres|mailhog)
# $2: timeout [s]
# ->: true - if pod is running before timeout
#     false - if timeout is reached before pod is running
#-------------------------------------------------------------------------------
# TODO: don't test first pod only
kube_pod_wait() (
    APP_NAME=$1
    TIMEOUT=$2
    PHASE=$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l app=$APP_NAME -o jsonpath='{.items[0].status.phase}' 2> /dev/null)
    START_TIME=$(date '+%s')
    while [ \( "$PHASE" != 'Succeeded' \) -a \
               \( "$PHASE" != 'Failed' \) -a \
               \( "$PHASE" != 'Running' \) -a \
               \( $(date '+%s') -lt $(expr "$START_TIME" + "$TIMEOUT") \) ]; do
        sleep 5
        PHASE=$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l app=$APP_NAME -o jsonpath='{.items[0].status.phase}' 2> /dev/null)
    done
    [ "$PHASE" = 'Running' ]
)

#-------------------------------------------------------------------------------
# kubernetes namespace exists
# ->: true|false
#-------------------------------------------------------------------------------
kube_namespace_exists() (
    NAME=$1
    # list all namespaces and check if the requested namespace exists
    NAMESPACE_EXISTS=false
    for NAMESPACE in $(kubectl get namespaces --context="$KUBERNETES_CONTEXT" -o jsonpath='{.items[*].metadata.name}' 2> /dev/null); do
        if [ "$NAMESPACE" = "$EnvId" ]; then
            NAMESPACE_EXISTS=true
            break
        fi
    done
    [ "$NAMESPACE_EXISTS" = 'true' ]
)

#-------------------------------------------------------------------------------
# Docker volume exists
# $1: name
# ->: true|false
#-------------------------------------------------------------------------------
docker_volume_exists() (
    NAME=$1
    # list all volumes and check if requested volume already exists
    VOLUME_EXISTS=false
    for VOLUME in $(docker volume ls -q 2> /dev/null); do
        if [ "$VOLUME" = "$EnvId-$NAME" ]; then
            VOLUME_EXISTS=true
            break
        fi
    done
    [ "$VOLUME_EXISTS" = 'true' ]
)

#-------------------------------------------------------------------------------
# kubernetes resource exists?
# $1: type (pod|service)
# $2: name
# ->: true|false
#-------------------------------------------------------------------------------
kube_resource_exists() (
    TYPE=$1
    NAME=$2
    # list all resources and check if NAME exists
    RESOURCE_EXISTS=false
    for RESOURCE in $(kubectl get $TYPE --context="$KUBERNETES_CONTEXT" -o jsonpath='{.items[*].metadata.name}' --namespace=$EnvId 2> /dev/null); do
        if [ "$RESOURCE" = "$NAME" ]; then
            RESOURCE_EXISTS=true
            break
        fi
    done
    [ "$RESOURCE_EXISTS" = 'true' ]
)

#-------------------------------------------------------------------------------
# $1: timestamp
# ->  seconds
#-------------------------------------------------------------------------------
time2seconds() {
    if [ "$(OS)" = 'Darwin' ]; then
        date -j -f '%Y-%m-%dT%H:%M:%SZ' "$1" '+%s'
    else
        date -d "$1" '+%s'
    fi
}

#-------------------------------------------------------------------------------
# get id of pod matching requested app-name
# if there is more than one pod matching (e.g. one is terminating, one is
# starting), the "running" pod is returned. If no such exists, the newer one
# will be selected.
# $1: app-name
# -> pod-name or empty, if no matching pod exists
#-------------------------------------------------------------------------------
kube_get_pod() (
    # get name, status, creation timestamp of pods and store them in an array
    # the array is flat and contains all names, statuses and creation timestamps in this order
    POD_INFO=( $(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l app=$1 -o jsonpath='{.items[*].metadata.name} {.items[*].status.phase} {.items[*].metadata.creationTimestamp}' 2> /dev/null) )
    POD_COUNT=$(expr ${#POD_INFO[@]} / 3)
    POD_NAME=''

    # search for a pod in state running and store its name
    # terminating pods still have the state running. Terminating pods can be
    # identified by checking deletionTimestamp. If this field exists, it is
    # terminating.
    I=0
    while [ \( -z "$POD_NAME" \) -a \( "$I" -lt "$POD_COUNT" \) ]; do
        NAME_INDEX=$(expr 0 \* $POD_COUNT + $I)
        STATUS_INDEX=$(expr 1 \* $POD_COUNT + $I)
        if [ "${POD_INFO[$STATUS_INDEX]}" = 'Running' ]; then
            # check deletionTimestamp
            if [ -z "$(kubectl get pod "${POD_INFO[$NAME_INDEX]}" --namespace $EnvId --context="$KUBERNETES_CONTEXT" -o jsonpath='{.metadata.deletionTimestamp}' 2> /dev/null)" ]; then
                POD_NAME="${POD_INFO[$NAME_INDEX]}"
            fi
        fi
        I=$(expr $I + 1)
    done

    # search for the newest pod and store its name
    # if no running pod was found before
    if [ -z "$POD_NAME" ]; then
        I=0
        POD_SECONDS=
        while [  "$I" -lt "$POD_COUNT" ]; do
            NAME_INDEX=$(expr 0 \* $POD_COUNT + $I)
            TIMESTAMP_INDEX=$(expr 2 \* $POD_COUNT + $I)
            if [ -z "$POD_SECONDS" ]; then
                POD_SECONDS="$(time2seconds "${POD_INFO[$TIMESTAMP_INDEX]}")"
                POD_NAME="${POD_INFO[$NAME_INDEX]}"
            elif [ "$(time2seconds "${POD_INFO[$TIMESTAMP_INDEX]}")" -gt "$POD_SECONDS" ]; then
                POD_SECONDS="$(time2seconds "${POD_INFO[$TIMESTAMP_INDEX]}")"
                POD_NAME="${POD_INFO[$NAME_INDEX]}"
            fi
            I=$(expr $I + 1)
        done
    fi

    echo "$POD_NAME"
)

################################################################################
# functions, implementing the info handlers
################################################################################

#-------------------------------------------------------------------------------
# info iom
#-------------------------------------------------------------------------------
info-iom() {
    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "info-iom: no config-file given!" < /dev/null
        false
    else
        cat <<EOF
--------------------------------------------------------------------------------
$ID
--------------------------------------------------------------------------------
Links:
======
OMT:                        http://$HostIom:$PORT_IOM_SERVICE/omt/
Online help:                http://$HostIom:$PORT_IOM_SERVICE/omt-help/
DBDoc:                      http://$HostIom:$PORT_IOM_SERVICE/dbdoc/
Wildfly (admin:admin):      http://$HostIom:$PORT_WILDFLY_SERVICE/console/
--------------------------------------------------------------------------------
Development:
============
Debug-Port:                 $PORT_DEBUG_SERVICE
PROJECT_ENV_NAME:           $PROJECT_ENV_NAME
PROJECT_DIR:                $PROJECT_DIR
CUSTOM_APPS_DIR:            $CUSTOM_APPS_DIR
CUSTOM_TEMPLATES_DIR:       $CUSTOM_TEMPLATES_DIR
CUSTOM_XSLT_DIR:            $CUSTOM_XSLT_DIR
CUSTOM_DBMIGRATE_DIR:       $CUSTOM_DBMIGRATE_DIR
CUSTOM_DUMPS_DIR:           $CUSTOM_DUMPS_DIR
CUSTOM_SQLCONF_DIR:         $CUSTOM_SQLCONF_DIR
CUSTOM_JSONCONF_DIR:        $CUSTOM_JSONCONF_DIR
--------------------------------------------------------------------------------
Direct access:
==============
CUSTOM_SHARE_DIR:           $CUSTOM_SHARE_DIR
--------------------------------------------------------------------------------
Runtime:
========
PROJECT_ENV_NAME:           $PROJECT_ENV_NAME
PROJECT_IMPORT_TEST_DATA:   $PROJECT_IMPORT_TEST_DATA
PERFORM_HEALTH_CHECKS:      $PERFORM_HEALTH_CHECKS
JBOSS_JAVA_OPTS:            $JBOSS_JAVA_OPTS
JBOSS_XA_POOLSIZE_MIN:      $JBOSS_XA_POOLSIZE_MIN
JBOSS_XA_POOLSIZE_MAX:      $JBOSS_XA_POOLSIZE_MAX
--------------------------------------------------------------------------------
Logging:
========
OMS_LOGLEVEL_CONSOLE:       $OMS_LOGLEVEL_CONSOLE
OMS_LOGLEVEL_IOM:           $OMS_LOGLEVEL_IOM
OMS_LOGLEVEL_HIBERNATE:     $OMS_LOGLEVEL_HIBERNATE
OMS_LOGLEVEL_QUARTZ:        $OMS_LOGLEVEL_QUARTZ
OMS_LOGLEVEL_ACTIVEMQ:      $OMS_LOGLEVEL_ACTIVEMQ
OMS_LOGLEVEL_CUSTOMIZATION: $OMS_LOGLEVEL_CUSTOMIZATION
OMS_LOGLEVEL_SCRIPTS:       $OMS_LOGLEVEL_SCRIPTS
--------------------------------------------------------------------------------
Docker:
=======
IOM_DBACCOUNT_IMAGE:        $IOM_DBACCOUNT_IMAGE
IOM_CONFIG_IMAGE:           $IOM_CONFIG_IMAGE
IOM_APP_IMAGE:              $IOM_APP_IMAGE
IOM_IMAGE:                  $IOM_IMAGE
IMAGE_PULL_POLICY:          $IMAGE_PULL_POLICY
--------------------------------------------------------------------------------
EOF
        POD="$(kube_get_pod iom)"
        if [ ! -z "$POD" ]; then
            cat <<EOF
Kubernetes:
===========
namespace:                  $EnvId

$(kubectl get pods --namespace=$EnvId --context="$KUBERNETES_CONTEXT" -l app=iom)

$(kubectl get service --namespace=$EnvId --context="$KUBERNETES_CONTEXT" iom-service 2> /dev/null)
--------------------------------------------------------------------------------
Usefull commands:
=================

Login into Pod:             kubectl exec --namespace $EnvId $POD --context="$KUBERNETES_CONTEXT" -c iom -it -- bash
jboss-cli:                  kubectl exec --namespace $EnvId $POD --context="$KUBERNETES_CONTEXT" -c iom -it -- /opt/jboss/wildfly/bin/jboss-cli.sh -c

Currently used yaml:        kubectl get pod -l app=iom -o yaml --namespace=$EnvId --context="$KUBERNETES_CONTEXT"
Describe iom pod:           kubectl describe --namespace $EnvId --context="$KUBERNETES_CONTEXT" pod $POD
Describe iom deployment     kubectl describe --namespace $EnvId --context="$KUBERNETES_CONTEXT" deployment iom
Describe iom service        kubectl describe --namespace $EnvId --context="$KUBERNETES_CONTEXT" service iom-service

Get dbaccount logs:         kubectl logs $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" -c dbaccount
Follow dbaccount logs:      kubectl logs --tail=1 -f $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" -c dbaccount
EOF
            if [ "$IsIomSingleDist" = 'false' ]; then
                cat <<EOF
Get config logs:            kubectl logs $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" -c config
Follow config logs:         kubectl logs --tail=1 -f $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" -c config
EOF
            fi
            cat <<EOF
Get iom logs:               kubectl logs $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" -c iom
Follow iom logs:            kubectl logs --tail=1 -f $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" -c iom
--------------------------------------------------------------------------------
EOF
        fi
    fi
}

#-------------------------------------------------------------------------------
# info postgres
#-------------------------------------------------------------------------------
info-postgres() {
    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "info-postgres: no config-file given!" < /dev/null
        false
    else
        cat <<EOF
--------------------------------------------------------------------------------
$ID
--------------------------------------------------------------------------------
Access to database:
===================
Host:                       $PgHostExtern
Port:                       $PgPortExtern
OMS_DB_USER:                $OMS_DB_USER
OMS_DB_PASS:                $OMS_DB_PASS
OMS_DB_NAME:                $OMS_DB_NAME
--------------------------------------------------------------------------------
Account Settings:
=================
OMS_DB_OPTIONS:             $OMS_DB_OPTIONS
OMS_DB_SEARCHPATH:          $OMS_DB_SEARCHPATH
--------------------------------------------------------------------------------
EOF
        if [ -z "$PGHOST" ]; then
            cat <<EOF
Server Settings:
================
POSTGRES_ARGS:              ${POSTGRES_ARGS[*]}
--------------------------------------------------------------------------------
Docker:
=======
DOCKER_DB_IMAGE:            $DOCKER_DB_IMAGE
IMAGE_PULL_POLICY:          $IMAGE_PULL_POLICY
--------------------------------------------------------------------------------
EOF
        fi
        POD="$(kube_get_pod postgres)"
        if [ ! -z "$POD" ]; then
            cat <<EOF
Kubernetes:
===========
namespace:                  $EnvId
KEEP_DATABASE_DATA:         $KEEP_DATABASE_DATA

$(kubectl get pods --namespace=$EnvId --context="$KUBERNETES_CONTEXT" -l app=postgres)

$(kubectl get service --namespace=$EnvId --context="$KUBERNETES_CONTEXT" postgres-service 2> /dev/null)
--------------------------------------------------------------------------------
Usefull commands:
=================
Login into Pod:             kubectl exec --namespace $EnvId --context="$KUBERNETES_CONTEXT" $POD -it -- bash
psql into root-db:          kubectl exec --namespace $EnvId --context="$KUBERNETES_CONTEXT" $POD -it -- bash -c "PGUSER=$PGUSER PGDATABASE=$PGDATABASE psql"
psql into IOM-db:           kubectl exec --namespace $EnvId --context="$KUBERNETES_CONTEXT" $POD -it -- bash -c "PGUSER=$OMS_DB_USER PGDATABASE=$OMS_DB_NAME psql"

Currently used yaml:        kubectl get pod -l app=postgres -o yaml --namespace=$EnvId --context="$KUBERNETES_CONTEXT"
Describe pod:               kubectl describe --namespace $EnvId --context="$KUBERNETES_CONTEXT" pod $POD

Get logs:                   kubectl logs $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT"
Follow logs:                kubectl logs --tail=1 -f $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT"
--------------------------------------------------------------------------------
EOF
        fi
    fi
}

#-------------------------------------------------------------------------------
# info mailserver
#-------------------------------------------------------------------------------
info-mailserver() {
    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "info-mailserver: no config-file given!" < /dev/null
        false
    else
        cat <<EOF
--------------------------------------------------------------------------------
$ID
--------------------------------------------------------------------------------
Links:
======
Web-UI:                     http://$HostIom:$PORT_MAILHOG_UI_SERVICE
REST:                       http://$HostIom:$PORT_MAILHOG_UI_SERVICE/api/v2/messages
--------------------------------------------------------------------------------
Docker:
=======
MAILHOG_IMAGE:              $MAILHOG_IMAGE
IMAGE_PULL_POLICY           $IMAGE_PULL_POLICY
--------------------------------------------------------------------------------
EOF
        POD="$(kube_get_pod mailhog)"
        if [ ! -z "$POD" ]; then
            cat <<EOF
Kubernetes:
===========
namespace:                  $EnvId

$(kubectl get pods --namespace=$EnvId --context="$KUBERNETES_CONTEXT" -l app=mailhog)

$(kubectl get service --namespace=$EnvId --context="$KUBERNETES_CONTEXT" mailhog-service 2> /dev/null)
--------------------------------------------------------------------------------
Usefull commands:
=================
Login into Pod:             kubectl exec --namespace $EnvId --context="$KUBERNETES_CONTEXT" $POD -it -- sh
Currently used yaml:        kubectl get pod -l app=mailhog -o yaml --namespace=$EnvId --context="$KUBERNETES_CONTEXT"
--------------------------------------------------------------------------------
EOF
        fi
    fi
}

#-------------------------------------------------------------------------------
# info storage
#-------------------------------------------------------------------------------
info-storage() {
    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "info-storage: no config-file given!" < /dev/null
        false
    else
        cat <<EOF
--------------------------------------------------------------------------------
$ID
--------------------------------------------------------------------------------
Config:
=======
KEEP_DATABASE_DATA:         $KEEP_DATABASE_DATA
--------------------------------------------------------------------------------
EOF
        if docker_volume_exists pgdata; then
            cat <<EOF
Docker:
=======
$(docker volume inspect $EnvId-pgdata)
--------------------------------------------------------------------------------
EOF
        else
            cat <<EOF
Docker:
=======
no docker volume with name $EnvId-pgdata exists.
--------------------------------------------------------------------------------
EOF
        fi
        if kube_resource_exists persistentvolumes $EnvId-postgres-pv; then
            cat <<EOF
Kubernetes:
===========
$(kubectl get persistentvolumes --namespace=$EnvId --context="$KUBERNETES_CONTEXT")
--------------------------------------------------------------------------------
Usefull commands:
=================
Currently used yaml:        kubectl get persistentvolumes -o yaml --namespace=$EnvId --context="$KUBERNETES_CONTEXT"
--------------------------------------------------------------------------------
EOF
        else
            cat <<EOF
Kubernetes:
===========
no persistent volume with name $EnvId-postgres-pv exists.
--------------------------------------------------------------------------------
EOF
        fi
    fi
}

#-------------------------------------------------------------------------------
# info cluster
#-------------------------------------------------------------------------------
info-cluster() {
    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "info-cluster: no config-file given!" < /dev/null
        false
    else
        cat <<EOF
--------------------------------------------------------------------------------
$ID
--------------------------------------------------------------------------------
Kubernetes Pods:
================
$(kubectl get pods --namespace=$EnvId --context="$KUBERNETES_CONTEXT")
--------------------------------------------------------------------------------
Kubernetes Services:
====================
$(kubectl get services --namespace=$EnvId --context="$KUBERNETES_CONTEXT")
--------------------------------------------------------------------------------
EOF
    fi
}

#-------------------------------------------------------------------------------
# info config
#-------------------------------------------------------------------------------
info-config() {
    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "info-cluster: no config-file given!" < /dev/null
        false
    else
        cat <<EOF
--------------------------------------------------------------------------------
$ID
--------------------------------------------------------------------------------
Property Files:
================
user-specific config-file:    $CONFIG_FILE_USER
project-specific config-file: $CONFIG_FILE_PROJECT
--------------------------------------------------------------------------------
Predifined variables:
=====================
PROJECT_DIR:                  $PROJECT_DIR
--------------------------------------------------------------------------------
Properties:
===========
$($DEVENV_DIR/bin/template_engine.sh \
    --template="$DEVENV_DIR/templates/config.properties.template" \
    --config="$CONFIG_FILES" \
    --project-dir="$PROJECT_DIR" | grep -v '^[ \t]*#' | grep -v '^[ \t]*$')
--------------------------------------------------------------------------------
EOF
    fi
}

################################################################################
# functions, implementing the create handlers
################################################################################

#-------------------------------------------------------------------------------
# create storage
# -> true|false indicating success
#-------------------------------------------------------------------------------
create-storage() {
    SUCCESS=true
    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "create-storage: no config-file given!" < /dev/null
        SUCCESS=false
    elif [ "$KEEP_DATABASE_DATA" = 'true' ] && ! docker_volume_exists pgdata; then
        docker volume create --name=$EnvId-pgdata -d local 2> "$TMP_ERR" > "$TMP_OUT"
        if [ $? -ne 0 ]; then
            log_msg ERROR "create-storage: error creating docker volume $EnvId-pgdata" < "$TMP_ERR"
            SUCCESS=false
        else
            log_msg INFO "create-storage: docker volume $EnvId-pgdata was successfully created" < "$TMP_OUT"
        fi
    else
        log_msg INFO "create-storage: nothing to do" < /dev/null
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# create namespace
# -> true|false indicating success
#-------------------------------------------------------------------------------
create-namespace() {
    SUCCESS=true
    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "create-namespace: no config-file given!" < /dev/null
        SUCCESS=false
    elif ! kube_namespace_exists; then
        kubectl create namespace $EnvId --context="$KUBERNETES_CONTEXT" 2> "$TMP_ERR" > "$TMP_OUT"
        if [ $? -ne 0 ]; then
            log_msg ERROR "create-namespace: error creating namespace '$EnvId'" < "$TMP_ERR"
            SUCCESS=true
        else
            log_msg INFO "create-namespace: namespace '$EnvId' was successfully created" < "$TMP_OUT"
        fi
    else
        log_msg INFO "create-namespace: nothing to do" < /dev/null
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# create mailserver
# -> true|false indicating success
#-------------------------------------------------------------------------------
create-mailserver() {
    SUCCESS=true
    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "create-mailserver: no config-file given!" < /dev/null
        SUCCESS=false
    else
        "$DEVENV_DIR/bin/template_engine.sh" \
            --template="$DEVENV_DIR/templates/mailhog.yml.template" \
            --config="$CONFIG_FILES" \
            --project-dir="$PROJECT_DIR" | kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
        if [ $? -ne 0 ]; then
            log_msg ERROR "create-mailserver: error creating mailserver" < "$TMP_ERR"
            SUCCESS=false
        else
            log_msg INFO "create-mailserver: mailserver successfully created" < "$TMP_OUT"
        fi
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# create postgres
# -> true|false indicating success
#-------------------------------------------------------------------------------
create-postgres() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "create-postgres: no config-file given!" < /dev/null
        SUCCESS=false
    elif [ -z "$PGHOST" ]; then
        # link Docker volume to database storage
        if [ "$KEEP_DATABASE_DATA" = 'true' ]; then
            MOUNTPOINT="\"$(docker volume inspect --format='{{.Mountpoint}}' $EnvId-pgdata)\"" \
                      "$DEVENV_DIR/bin/template_engine.sh" \
                        --template="$DEVENV_DIR/templates/postgres-storage.yml.template" \
                        --config="$CONFIG_FILES" \
                        --project-dir="$PROJECT_DIR" | kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
            if [ $? -ne 0 ]; then
                log_msg ERROR "create-postgres: error linking docker volume to database storage" < "$TMP_ERR"
                SUCCESS=false
            else
                log_msg INFO "create-postgres: successfully linked docker volume to database storage" < "$TMP_OUT"
            fi
        else
            log_msg INFO "create-postges: no need to link docker volume to dabase storage" < /dev/null
        fi
        if [ "$SUCCESS" = 'true' ]; then
            if ! kube_resource_exists pods postgres || ! kube_resource_exists services postgres-service; then
                # start postgres pod/service
                "$DEVENV_DIR/bin/template_engine.sh" \
                    --template="$DEVENV_DIR/templates/postgres.yml.template" \
                    --config="$CONFIG_FILES" \
                    --project-dir="$PROJECT_DIR" | kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
                if [ $? -ne 0 ]; then
                    log_msg ERROR "create-postgres: error creating postgres" < "$TMP_ERR"
                    SUCCESS=false
                else
                    log_msg INFO "create-postgres: successfully created postgres" < "$TMP_OUT"
                fi
            else
                log_msg INFO "create-postgres: pod and service already exist" < /dev/null
            fi
        fi
    else
        log_msg INFO "create-postgres: nothing to do, external database configured (config variable PGHOST is set)" < /dev/null
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# create iom
# -> true|false indicating success
#-------------------------------------------------------------------------------
create-iom() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "create-iom: no config-file given!" < /dev/null
        SUCCESS=false
    else
        # copy secret from default namespace to namespace of IOM
        if [ ! -z "$IMAGE_PULL_SECRET" ]; then
            kubectl get secret "$IMAGE_PULL_SECRET" --namespace default --context="$KUBERNETES_CONTEXT" -oyaml 2> "$TMP_ERR" |
                grep -v 'namespace:\|resourceVersion:\|selfLink:\|uid:' |
                kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2>> "$TMP_ERR" > "$TMP_OUT"
            if [ $? -ne 0 ]; then
                log_msg ERROR "create-iom: error copying secret $IMAGE_PULL_SECRET from default namespace" < "$TMP_ERR"
                SUCCESS=false
            else
                log_msg INFO "create-iom: successfully copied secret $IMAGE_PULL_SECRET from default namespace" < "$TMP_OUT"
            fi
        fi
        if [ "$SUCCESS" = 'true' ]; then
            "$DEVENV_DIR/bin/template_engine.sh" \
                --template="$DEVENV_DIR/templates/$IomTemplate" \
                --config="$CONFIG_FILES" \
                --project-dir="$PROJECT_DIR" | kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
            if [ $? -ne 0 ]; then
                log_msg ERROR "create-iom: error creating iom" < "$TMP_ERR"
                SUCCESS=false
            else
                log_msg INFO "create-iom: successfully created iom" < "$TMP_OUT"
            fi
        fi
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# create cluster
# -> true|false indicating success
#-------------------------------------------------------------------------------
create-cluster() {
    create-storage &&
        create-namespace &&
        create-postgres &&
        create-mailserver &&
        create-iom
}

################################################################################
# functions, implementing the delete handlers
################################################################################

#---------------------------------------------------------------------------
# delete storage
# -> true|false indicating success
#---------------------------------------------------------------------------
delete-storage() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "delete-storage: no config-file given!" < /dev/null
        SUCCESS=false
    elif docker_volume_exists pgdata; then
        docker volume rm $EnvId-pgdata 2> "$TMP_ERR" > "$TMP_OUT"
        if [ $? -ne 0 ]; then
            log_msg ERROR "delete-storage: error deleting volume $EnvId-pgdata" < "$TMP_ERR"
            SUCCESS=false
        else
            log_msg INFO "delete-storage: successfully deleted volume $EnvId-pgdata" < "$TMP_OUT"
        fi
    else
        log_msg INFO "delete-storage: nothing to do" < /dev/null
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# delete namespace
# -> true|false indicating success
#-------------------------------------------------------------------------------
delete-namespace() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "delete-namespace: no config-file given!" < /dev/null
        SUCCESS=false
    elif kube_namespace_exists; then
        kubectl delete namespace $EnvId --context="$KUBERNETES_CONTEXT" 2> "$TMP_ERR" > "$TMP_OUT"
        if [ $? -ne 0 ]; then
            log_msg ERROR "delete-namespace: error deleting namespace '$EnvId'" < "$TMP_ERR"
            SUCCESS=false
        else
            log_msg INFO "delete-namespace: successfully deleted namespace '$EnvId'" < "$TMP_OUT"
        fi
    else
        log_msg INFO "delete-namespace: nothing to do" < /dev/null
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# delete mailserver
# -> true|false indicating success
#-------------------------------------------------------------------------------
delete-mailserver() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "delete-mailserver: no config-file given!" < /dev/null
        SUCCESS=false
    elif kube_resource_exists pods mailhog || kube_resource_exists services mailhog-service; then
        "$DEVENV_DIR/bin/template_engine.sh" \
            --template="$DEVENV_DIR/templates/mailhog.yml.template" \
            --config="$CONFIG_FILES" \
            --project-dir="$PROJECT_DIR" | kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
        if [ $? -ne 0 ]; then
            log_msg ERROR "delete-mailserver: error deleting mail-server" < "$TMP_ERR"
            SUCCESS=false
        else
            log_msg INFO "delete-mailserver: successfully deleted mail-server" < "$TMP_OUT"
        fi
    else
        log_msg INFO "delete-mailserver: nothing to do" < /dev/null
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# delete postgres
#-------------------------------------------------------------------------------
delete-postgres() {
    SUCCESS_PG=true
    SUCCESS_VL=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "delete-postgres: no config-file given!" < /dev/null
        SUCCESS_PG=false
        SUCCESS_VL=false
    else
        if kube_resource_exists pods postgres || kube_resource_exists services postgres-service; then
            "$DEVENV_DIR/bin/template_engine.sh" \
                --template="$DEVENV_DIR/templates/postgres.yml.template" \
                --config="$CONFIG_FILES" \
                --project-dir="$PROJECT_DIR" | kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
            if [ $? -ne 0 ]; then
                log_msg ERROR "delete-postgres: error deleting postgres" < "$TMP_ERR"
                SUCCESS_PG=false
            else
                log_msg INFO "delete-postgres: successfully deleted postgres" < "$TMP_OUT"
            fi
        else
            log_msg INFO "delete-postgres: nothing to do, to delete postgres" < /dev/null
        fi
        # unlink Docker volume from database storage
        if kube_resource_exists persistentvolumes $EnvId-postgres-pv; then
            MOUNTPOINT="\"$(docker volume inspect --format='{{.Mountpoint}}' $EnvId-pgdata)\"" \
                      "$DEVENV_DIR/bin/template_engine.sh" \
                        --template="$DEVENV_DIR/templates/postgres-storage.yml.template" \
                        --config="$CONFIG_FILES" \
                        --project-dir="$PROJECT_DIR" | kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
            if [ $? -ne 0 ]; then
                log_msg ERROR "delete-postgres: error unlinking Docker volume from database storage" < "$TMP_ERR"
                SUCCESS_VL=false
            else
                log_msg INFO "delete-postgres: successfully unlinked Docker volume from database storage" < "$TMP_OUT"
            fi
        else
            log_msg INFO "delete-postgres: nothing to do, to unlink Docker volume from database storage" < /dev/null
        fi
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ \( "$SUCCESS_PG" = 'true' \) -a \( "$SUCCESS_VL" = 'true' \) ]
}

#-------------------------------------------------------------------------------
# delete iom
#-------------------------------------------------------------------------------
delete-iom() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "delete-iom: no config-file given!" < /dev/null
        SUCCESS=false
    elif kube_resource_exists pods iom || kube_resource_exists services iom-service; then
        "$DEVENV_DIR/bin/template_engine.sh" \
            --template="$DEVENV_DIR/templates/$IomTemplate" \
            --config="$CONFIG_FILES" \
            --project-dir="$PROJECT_DIR" | kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
        if [ $? -ne 0 ]; then
            log_msg ERROR "delete-iom: error deleting iom" < "$TMP_ERR"
            SUCCESS=false
        else
            log_msg INFO "delete-iom: successfully deleted iom" < "$TMP_OUT"
        fi
    else
        log_msg INFO "delete-iom: nothing to do" < /dev/null
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# delete cluster
#-------------------------------------------------------------------------------
delete-cluster() {
    delete-iom &&
    delete-postgres &&
    delete-mailserver &&
    delete-namespace
}

################################################################################
# functions, implementing the apply handler
################################################################################

#-------------------------------------------------------------------------------
# apply deployment
# $1: pattern
# ->: true|false indicating success
#-------------------------------------------------------------------------------
apply-deployment() {
    PATTERN=$1
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "apply-deployment: no config-file given!" < /dev/null
        SUCCESS=false
    elif [ ! -z "$CUSTOM_APPS_DIR" ]; then
        POD=$(kube_get_pod iom 2> "$TMP_ERR")
        if [ -z "$POD" ]; then
            log_msg ERROR "apply-deployment: error getting pod name" < "$TMP_ERR"
            SUCCESS=false
        else
            if [ -z "$PATTERN" ]; then
                kubectl exec $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" -- bash -ic redeploy 2> "$TMP_ERR" > "$TMP_OUT"
            else
                # TODO no messages visible, if script ended with error!
                kubectl exec $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" -- bash -ic "/opt/oms/bin/forced-redeploy.sh --pattern=$PATTERN || true" 2> "$TMP_ERR" > "$TMP_OUT"
            fi
            if [ $? -ne 0 ]; then
                log_msg ERROR "apply-deployment: error applying deployments" < "$TMP_ERR"
                SUCCESS=false
            else
                # output is already in json format
                cat "$TMP_OUT"
                log_msg INFO "apply-deployment: successfully applied deployments" < /dev/null
            fi
        fi
    else
        log_msg INFO "apply-deployment: config variable CUSTOM_APPS_DIR not set, deployment skipped" < /dev/null
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# apply mail templates
# -> true|false indicating success
#-------------------------------------------------------------------------------
apply-mail-templates() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "apply-mail-templates: no config-file given!" < /dev/null
        SUCCESS=false
    elif [ ! -z "$CUSTOM_TEMPLATES_DIR" ]; then
        POD=$(kube_get_pod iom 2> "$TMP_ERR")
        if [ -z "$POD" ]; then
            log_msg ERROR "apply-mail-templates: error getting pod name" < "$TMP_ERR"
            SUCCESS=false
        else
            kubectl exec $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" -- bash -ic apply-templates 2> "$TMP_ERR" > "$TMP_OUT"
            if [ $? -ne 0 ]; then
                log_msg ERROR "apply-mail-templates: error applying mail templates" < "$TMP_ERR"
                SUCCESS=false
            else
                log_msg INFO "apply-mail-templates: successfully applied mail templates" < "$TMP_OUT"
            fi
        fi
    else
        log_msg INFO "apply-mail-templates: config variable CUSTOM_TEMPLATES_DIR not set, skipped applying mail templates" < /dev/null
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# apply xsl templates
# -> true|false indicating success
#-------------------------------------------------------------------------------
apply-xsl-templates() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "apply-xsl-templates: no config-file given!" < /dev/null
        SUCCESS=false
    elif [ ! -z "$CUSTOM_XSLT_DIR" ]; then
        POD=$(kube_get_pod iom 2> "$TMP_ERR")
        if [ -z "$POD" ]; then
            log_msg ERROR "apply-xsl-templates: error getting pod name" < "$TMP_ERR"
            SUCCESS=false
        else
            kubectl exec $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" -- bash -ic apply-xslt 2> "$TMP_ERR" > "$TMP_OUT"
            if [ $? -ne 0 ]; then
                log_msg ERROR "apply-xsl-templates: error applying xsl templates" < "$TMP_ERR"
                SUCCESS=false
            else
                log_msg INFO "apply-xsl-templates: successfully applied xsl templates" < "$TMP_OUT"
            fi
        fi
    else
        log_msg INFO "apply-xsl-templates: config variable CUSTOM_XSLT_DIR not set, skipped applying xsl templates" < /dev/null
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# apply sql scripts
# $1: sql-directory
# $2: timeout
# -> true|false indicating success
#-------------------------------------------------------------------------------
apply-sql-scripts() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "apply-sql-scripts: no config-file given!" < /dev/null
        SUCCESS=false
    else
        # check and convert to absolute path
        if [ ! -d "$1" -a ! -f "$1" ]; then
            log_msg ERROR "apply-sql-scripts: '$1' is nor a file or directory" < /dev/null
            SUCCESS=false
        else
            case "$1" in
                /*)
                    SQL_SRC="$1"
                    ;;
                *)
                    SQL_SRC="$(pwd)/$1"
            esac
        fi

        # check and set timeout
        TIMEOUT=60
        if [ ! -z "$2" ] && ! ( echo "$2" | grep -q '^[0-9]*$'); then
            log_msg WARN "apply-sql-scripts: invalid value passed for timeout ($2). Default value will be used" < /dev/null
        elif [ ! -z "$2" ]; then
            TIMEOUT=$2
        fi

        if [ "$SUCCESS" = 'true' ]; then
            # start apply-sql job
            SQL_SRC="$SQL_SRC" \
                   "$DEVENV_DIR/bin/template_engine.sh" \
                     --template="$DEVENV_DIR/templates/apply-sql.yml.template" \
                     --config="$CONFIG_FILES" \
                     --project-dir="$PROJECT_DIR" | kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
            if [ $? -ne 0 ]; then
                log_msg ERROR "apply-sql-scripts: error starting job" < "$TMP_ERR"
                SUCCESS=false
            else
                log_msg INFO "apply-sql-scripts: job successfully started" < "$TMP_OUT"

                # wait for job to finish
                kube_job_wait apply-sql-job $TIMEOUT
                KUBE_JOB_STATUS=$?
                if [ "$KUBE_JOB_STATUS" = '1' ]; then
                    log_msg ERROR "apply-sql-scripts: timeout of $TIMEOUT seconds reached" < /dev/null
                    SUCCESS=false
                elif [ "$KUBE_JOB_STATUS" = '2' ]; then
                    log_msg ERROR "apply-sql-scripts: job execution failed" < /dev/null
                    SUCCESS=false
                fi
                # get logs of job
                POD=$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l job-name=apply-sql-job -o jsonpath='{.items[0].metadata.name}' 2> "$TMP_ERR" )
                if [ -z "$POD" ]; then
                    log_msg ERROR "apply-sql-scripts: error getting pod name" < "$TMP_ERR"
                    SUCCESS=false
                else
                    kubectl logs $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" 2> "$TMP_ERR" > "$TMP_OUT"
                    if [ $? -ne 0 ]; then
                        log_msg ERROR "apply-sql-scripts: error getting logs of job" < "$TMP_ERR"
                        SUCCESS=false
                    else
                        # logs of job are already in json format
                        cat "$TMP_OUT"
                    fi
                fi
                # delete apply-sql-job
                "$DEVENV_DIR/bin/template_engine.sh" \
                    --template="$DEVENV_DIR/templates/apply-sql.yml.template" \
                    --config="$CONFIG_FILES" \
                    --project-dir="$PROJECT_DIR" | kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
                if [ $? -ne 0 ]; then
                    log_msg ERROR "apply-sql-scripts: error deleting job" < "$TMP_ERR"
                    SUCCESS=false
                else
                    log_msg INFO "apply-sql-scripts: successfully deleted job" < "$TMP_OUT"
                fi

                # it's easier for the user to detect an error, if the last message
                # is giving this information
                if [ "$SUCCESS" != 'true' ]; then
                    log_msg ERROR "apply-sql-scripts: job ended with ERROR" < /dev/null
                fi
            fi
        fi
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# apply sql config
# $1: timeout [s]
# -> true|false indicating success
#-------------------------------------------------------------------------------
apply-sql-config() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "apply-sql-config: no config-file given!" < /dev/null
        SUCCESS=false
    else
        # check and set timeout
        TIMEOUT=60
        if [ ! -z "$1" ] && ! ( echo "$1" | grep -q '^[0-9]*$'); then
            log_msg WARN "apply-sql-config: invalid value passed for timeout ($1). Default value will be used" < /dev/null
        elif [ ! -z "$1" ]; then
            TIMEOUT=$1
        fi

        if [ ! -z "$CUSTOM_SQLCONF_DIR" ]; then
            # start sqlconfig-job
            "$DEVENV_DIR/bin/template_engine.sh" \
                --template="$DEVENV_DIR/templates/sqlconfig.yml.template" \
                --config="$CONFIG_FILES" \
                --project-dir="$PROJECT_DIR" | kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
            if [ $? -ne 0 ]; then
                log_msg ERROR "apply-sql-config: error starting job" < "$TMP_ERR"
                SUCCESS=false
            else
                log_msg INFO "apply-sql-config: job successfully started" < "$TMP_OUT"

                # wait for job to finish
                kube_job_wait sqlconfig-job $TIMEOUT
                KUBE_JOB_STATUS=$?
                if [ "$KUBE_JOB_STATUS" = '1' ]; then
                    log_msg ERROR "apply-sql-config: timeout of $TIMEOUT seconds reached" < /dev/null
                    SUCCESS=false
                elif [ "$KUBE_JOB_STATUS" = '2' ]; then
                    log_msg ERROR "apply-sql-config: job execution failed" < /dev/null
                    SUCCESS=false
                fi
                # get logs of job
                POD=$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l job-name=sqlconfig-job -o jsonpath='{.items[0].metadata.name}' 2> "$TMP_ERR" )
                if [ -z "$POD" ]; then
                    log_msg ERROR "apply-sql-config: error getting pod name" < "$TMP_ERR"
                    SUCCESS=false
                else
                    kubectl logs $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" 2> "$TMP_ERR" > "$TMP_OUT"
                    if [ $? -ne 0 ]; then
                        log_msg ERROR "apply-sql-config: error getting logs of job" < "$TMP_ERR"
                        SUCCESS=false
                    else
                        # logs of job are already in json format
                        cat "$TMP_OUT"
                    fi
                fi
                # delete sqlconfig-job
                "$DEVENV_DIR/bin/template_engine.sh" \
                    --template="$DEVENV_DIR/templates/sqlconfig.yml.template" \
                    --config="$CONFIG_FILES" \
                    --project-dir="$PROJECT_DIR" | kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
                if [ $? -ne 0 ]; then
                    log_msg ERROR "apply-sql-config: error deleting job" < "$TMP_ERR"
                    SUCCESS=false
                else
                    log_msg INFO "apply-sql-config: successfully deleted job" < "$TMP_OUT"
                fi

                # it's easier for the user to detect an error, if the last message
                # is giving this information
                if [ "$SUCCESS" != 'true' ]; then
                    log_msg ERROR "apply-sql-config: job ended with ERROR" < /dev/null
                fi
            fi
        else
            log_msg INFO "apply-sql-config: config variable CUSTOM_SQLCONF_DIR not set, no sql-config applied" < /dev/null
        fi
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# apply json config
# $1: timeout [s]
# -> true|false indicating success
#-------------------------------------------------------------------------------
apply-json-config() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "apply-json-config: no config-file given!" < /dev/null
        SUCCESS=false
    else
        # check and set timeout
        TIMEOUT=60
        if [ ! -z "$1" ] && ! ( echo "$1" | grep -q '^[0-9]*$'); then
            log_msg WARN "apply-json-config: invalid value passed for timeout ($1). Default value will be used" < /dev/null
        elif [ ! -z "$1" ]; then
            TIMEOUT=$1
        fi

        if [ ! -z "$CUSTOM_JSONCONF_DIR" ]; then
            # start jsonconfig-job
            "$DEVENV_DIR/bin/template_engine.sh" \
                --template="$DEVENV_DIR/templates/jsonconfig.yml.template" \
                --config="$CONFIG_FILES" \
                --project-dir="$PROJECT_DIR" | kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
            if [ $? -ne 0 ]; then
                log_msg ERROR "apply-json-config: error starting job" < "$TMP_ERR"
                SUCCESS=false
            else
                log_msg INFO "apply-json-config: job successfully started" < "$TMP_OUT"

                # wait for job to finish
                kube_job_wait jsonconfig-job $TIMEOUT
                KUBE_JOB_STATUS=$?
                if [ "$KUBE_JOB_STATUS" = '1' ]; then
                    log_msg ERROR "apply-json-config: timeout of $TIMEOUT seconds reached" < /dev/null
                    SUCCESS=false
                elif [ "$KUBE_JOB_STATUS" = '2' ]; then
                    log_msg ERROR "apply-json-config: job execution failed" < /dev/null
                    SUCCESS=false
                fi
                # get logs of job
                POD=$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l job-name=jsonconfig-job -o jsonpath='{.items[0].metadata.name}' 2> "$TMP_ERR" )
                if [ -z "$POD" ]; then
                    log_msg ERROR "apply-json-config: error getting pod name" < "$TMP_ERR"
                    SUCCESS=false
                else
                    kubectl logs $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" 2> "$TMP_ERR" > "$TMP_OUT"
                    if [ $? -ne 0 ]; then
                        log_msg ERROR "apply-json-config: error getting logs of job" < "$TMP_ERR"
                        SUCCESS=false
                    else
                        # logs of job are already in json format
                        cat "$TMP_OUT"
                    fi
                fi

                # delete jsonconfig-job
                "$DEVENV_DIR/bin/template_engine.sh" \
                    --template="$DEVENV_DIR/templates/jsonconfig.yml.template" \
                    --config="$CONFIG_FILES" \
                    --project-dir="$PROJECT_DIR" | kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
                if [ $? -ne 0 ]; then
                    log_msg ERROR "apply-json-config: error deleting job" < "$TMP_ERR"
                    SUCCESS=false
                else
                    log_msg INFO "apply-json-config: successfully deleted job" < "$TMP_OUT"
                fi

                # it's easier for the user to detect an error, if the last message
                # is giving this information
                if [ "$SUCCESS" != 'true' ]; then
                    log_msg ERROR "apply-json-config: job ended with ERROR" < /dev/null
                fi
            fi
        else
            log_msg INFO "apply-json-config: config variable CUSTOM_JSONCONF_DIR not set, no json-config applied" < /dev/null
        fi
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# apply db-migrate scripts
# $1: timeout [s]
# -> true|false indicating success
#-------------------------------------------------------------------------------
apply-dbmigrate() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "apply-dbmigrate: no config-file given!" < /dev/null
        SUCCESS=false
    else
        # check and set timeout
        TIMEOUT=60
        if [ ! -z "$1" ] && ! ( echo "$1" | grep -q '^[0-9]*$'); then
            log_msg WARN "apply-dbmigrate: invalid value passed for timeout ($1). Default value will be used" < /dev/null
        elif [ ! -z "$1" ]; then
            TIMEOUT=$1
        fi

        if [ ! -z "$CUSTOM_DBMIGRATE_DIR" ]; then
            # start dbmigrate-job
            "$DEVENV_DIR/bin/template_engine.sh" \
                --template="$DEVENV_DIR/templates/dbmigrate.yml.template" \
                --config="$CONFIG_FILES" \
                --project-dir="$PROJECT_DIR" | kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
            if [ $? -ne 0 ]; then
                log_msg ERROR "apply-dbmigrate: error starting job" < "$TMP_ERR"
                SUCCESS=false
            else
                log_msg INFO "apply-dbmigrate: job successfully started" < "$TMP_OUT"

                # wait for job to finish
                kube_job_wait dbmigrate-job $TIMEOUT
                KUBE_JOB_STATUS=$?
                if [ "$KUBE_JOB_STATUS" = '1' ]; then
                    log_msg ERROR "apply-dbmigrate: timeout of $TIMEOUT seconds reached" < /dev/null
                    SUCCESS=false
                elif [ "$KUBE_JOB_STATUS" = '2' ]; then
                    log_msg ERROR "apply-dbmigrate: job execution failed" < /dev/null
                    SUCCESS=false
                fi
                # get logs of job
                POD=$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l job-name=dbmigrate-job -o jsonpath='{.items[0].metadata.name}' 2> "$TMP_ERR" )
                if [ -z "$POD" ]; then
                    log_msg ERROR "apply-dbmigrate: error getting pod name" < "$TMP_ERR"
                    SUCCESS=false
                else
                    kubectl logs $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" 2> "$TMP_ERR" > "$TMP_OUT"
                    if [ $? -ne 0 ]; then
                        log_msg ERROR "apply-dbmigrate: error getting logs of job" < "$TMP_ERR"
                        SUCCESS=false
                    else
                        # logs are already in json format
                        cat "$TMP_OUT"
                    fi
                fi
                # delete dbmigrate-job
                "$DEVENV_DIR/bin/template_engine.sh" \
                    --template="$DEVENV_DIR/templates/dbmigrate.yml.template" \
                    --config="$CONFIG_FILES" \
                    --project-dir="$PROJECT_DIR" | kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
                if [ $? -ne 0 ]; then
                    log_msg ERROR "apply-dbmigrate: error deleting job" < "$TMP_ERR"
                    SUCCESS=false
                else
                    log_msg INFO "apply-dbmigrate: successfully deleted job" < "$TMP_OUT"
                fi

                # it's easier for the user to detect an error, if the last message
                # is giving this information
                if [ "$SUCCESS" != 'true' ]; then
                    log_msg ERROR "apply-dbmigrate: job ended with ERROR" < /dev/null
                fi
            fi
        else
            log_msg INFO "apply-dbmigrate: config variable CUSTOM_DBMIGRATE_DIR not set, db-migrate not applied" < /dev/null
        fi
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

################################################################################
# functions, implementing the dump handler
################################################################################

#-------------------------------------------------------------------------------
# load dump
# -> true|false indicating success
#-------------------------------------------------------------------------------
dump-load() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "dump-load: no config-file given!" < /dev/null
        SUCCESS=false
    elif [ ! -z "$CUSTOM_DUMPS_DIR" ]; then
        if [ -z "$PGHOST" ]; then
            # delete iom & postgres
            if ! delete-iom; then
                SUCCESS=false
            fi
            if [ "$SUCCESS" = 'true' ] && ! delete-postgres; then
                SUCCESS=false
            fi
            # renew Docker local store
            if [ "$SUCCESS" = 'true' ] && ! delete-storage; then
                SUCCESS=false
            fi
            if [ "$KEEP_DATABASE_DATA" = 'true' ]; then
                if [ "$SUCCESS" = 'true' ] && ! create-storage; then
                    SUCCESS=false
                fi
            fi
            # create postgres and iom
            if [ "$SUCCESS" = 'true' ] && ! create-postgres; then
                SUCCESS=false
            fi
            if [ "$SUCCESS" = 'true' ] && ! kube_pod_wait postgres 300; then
                log_msg ERROR "dump-load: error waiting for postgres to get running" < /dev/null
                SUCCESS=false
            fi
            if [ "$SUCCESS" = 'true' ]; then
                if ! create-iom; then
                    SUCCESS=false
                fi
            fi
        else
            log_msg INFO "dump-load: external database configured, cannot load dump" < /dev/null
        fi
    else
        log_msg INFO "dump-load: config variable CUSTOM_DUMPS_DIR not set, skipped loading dump" < /dev/null
    fi
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# create dump
# $1: timeout [s]
# -> true|false indicating success
#-------------------------------------------------------------------------------
dump-create() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "dump-create: no config-file given!" < /dev/null
        SUCCESS=false
    else
        # check and set timeout
        TIMEOUT=60
        if [ ! -z "$1" ] && ! ( echo "$1" | grep -q '^[0-9]*$'); then
            log_msg WARN "dump-create: invalid value passed for timeout ($1). Default value will be used" < /dev/null
        elif [ ! -z "$1" ]; then
            TIMEOUT=$1
        fi

        if [ ! -z "$CUSTOM_DUMPS_DIR" ]; then
            # start dump-job
            "$DEVENV_DIR/bin/template_engine.sh" \
                --template="$DEVENV_DIR/templates/dump.yml.template" \
                --config="$CONFIG_FILES" \
                --project-dir="$PROJECT_DIR" | kubectl apply --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
            if [ $? -ne 0 ]; then
                log_msg ERROR "dump-create: error starting job" < "$TMP_ERR"
                SUCCESS=false
            else
                log_msg INFO "dump-create: job successfully started" < "$TMP_OUT"

                # wait for job to finish
                kube_job_wait dump-job $TIMEOUT
                KUBE_JOB_STATUS=$?
                if [ "$KUBE_JOB_STATUS" = '1' ]; then
                    log_msg ERROR "dump-create: job failed or timeout of $TIMEOUT seconds reached" < /dev/null
                    SUCCESS=false
                elif [ "$KUBE_JOB_STATUS" = '2' ]; then
                    log_msg ERROR "dump-create: job execution failed" < /dev/null
                    SUCCESS=false
                fi

                # get logs of job
                POD=$(kubectl get pods --namespace $EnvId --context="$KUBERNETES_CONTEXT" -l job-name=dump-job -o jsonpath='{.items[0].metadata.name}' 2> "$TMP_ERR" )
                if [ -z "$POD" ]; then
                    log_msg ERROR "dump-create: error getting pod name" < "$TMP_ERR"
                    SUCCESS=false
                else
                    kubectl logs $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" 2> "$TMP_ERR" > "$TMP_OUT"
                    if [ $? -ne 0 ]; then
                        log_msg ERROR "dump-create: error getting logs of job" < "$TMP_ERR"
                        SUCCESS=false
                    else
                        # logs are already in json format
                        cat "$TMP_OUT"
                    fi
                fi
                # delete dump-job
                "$DEVENV_DIR/bin/template_engine.sh" \
                    --template="$DEVENV_DIR/templates/dump.yml.template" \
                    --config="$CONFIG_FILES" \
                    --project-dir="$PROJECT_DIR" | kubectl delete --namespace $EnvId --context="$KUBERNETES_CONTEXT" -f - 2> "$TMP_ERR" > "$TMP_OUT"
                if [ $? -ne 0 ]; then
                    log_msg ERROR "dump-create: error deleting job" < "$TMP_ERR"
                    SUCCESS=false
                else
                    log_msg INFO "dump-create: successfully deleted job" < "$TMP_OUT"
                fi

                # it's easier for the user to detect an error, if the last message
                # is giving this information
                if [ "$SUCCESS" != 'true' ]; then
                    log_msg ERROR "dump-create: job ended with ERROR" < /dev/null
                fi
            fi
        else
            log_msg INFO "dump-create: config variable CUSTOM_DUMPS_DIR not set, skipped creation of dump" < /dev/null
        fi
    fi
    rm -f "$TMP_ERR" "$TMP_OUT"
    [ "$SUCCESS" = 'true' ]
}

################################################################################
# functions, implementing the config handler
################################################################################

#-------------------------------------------------------------------------------
# get configuration
# $1: [--skip-config|--skip-user-config] if set, whole configuration or user
#     specific configuration will be ignored
# ->  true|false indicating success
#-------------------------------------------------------------------------------
get-config() {
    SUCCESS=true

    # handle optional parameter
    if [ ! -z "$1" -a "$1" = '--skip-config' ]; then
        CONFIG_FILES=
    elif [ ! -z "$1" -a "$1" = '--skip-user-config' ]; then
        CONFIG_FILES="$CONFIG_FILE_PROJECT"
    elif [ ! -z "$1" ]; then
        log_msg ERROR "get-config: unknown parameter '$1'." < /dev/null
        SUCCESS=false
    fi

    if [ "$SUCCESS" = 'true' ]; then
        if [ -z "$CONFIG_FILES" ]; then
            log_msg WARN "get-config: no configuration given, using default values instead." < /dev/null
            "$DEVENV_DIR/bin/template_engine.sh" \
                --project-dir="$PROJECT_DIR" \
                --template="$DEVENV_DIR/templates/config.properties.template" 2> "$TMP_ERR"
        else
            "$DEVENV_DIR/bin/template_engine.sh" \
                --template="$DEVENV_DIR/templates/config.properties.template" \
                --config="$CONFIG_FILES" \
                --project-dir="$PROJECT_DIR" 2> "$TMP_ERR"
        fi
        if [ $? -ne 0 ]; then
            log_msg ERROR "get-config: error writing configuration." < "$TMP_ERR"
            SUCCESS=false
        else
            log_msg INFO "get-config: configuration successfully written." < /dev/null
        fi
    fi

    rm -f "$TMP_ERR"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# get ws.properties
#-------------------------------------------------------------------------------
get-ws-props() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "get-ws-props: no config-file given!" < /dev/null
        SUCCESS=false
    else
        "$DEVENV_DIR/bin/template_engine.sh" \
            --template="$DEVENV_DIR/templates/ws.properties.template" \
            --config="$CONFIG_FILES" \
            --project-dir="$PROJECT_DIR" 2> "$TMP_ERR"
        if [ $? -ne 0 ]; then
            log_msg ERROR "get-ws-props: error writing ws.properties." < "$TMP_ERR"
            SUCCESS=false
        else
            log_msg INFO "get-ws-props: ws.properties successfully written." < /dev/null
        fi
    fi
    rm -f "$TMP_ERR"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# get geb.properties
#-------------------------------------------------------------------------------
get-geb-props() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "get-geb-props: no config-file given!" < /dev/null
        SUCCESS=false
    else
        "$DEVENV_DIR/bin/template_engine.sh" \
            --template="$DEVENV_DIR/templates/geb.properties.template" \
            --config="$CONFIG_FILES" \
            --project-dir="$PROJECT_DIR" 2> "$TMP_ERR"
        if [ $? -ne 0 ]; then
            log_msg ERROR "get-geb-props: error writing geb.properties." < "$TMP_ERR"
            SUCCESS=false
        else
            log_msg INFO "get-geb-props: geb.properties successfully written" < /dev/null
        fi
    fi
    rm -f "$TMP_ERR"
    [ "$SUCCESS" = 'true' ]
}

#-------------------------------------------------------------------------------
# get soap.properties
#-------------------------------------------------------------------------------
get-soap-props() {
    SUCCESS=true

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "get-soap-props: no config-file given!" < /dev/null
        SUCCESS=false
    else
        "$DEVENV_DIR/bin/template_engine.sh" \
            --template="$DEVENV_DIR/templates/soap.properties.template" \
            --config="$CONFIG_FILES" \
            --project-dir="$PROJECT_DIR" 2> "$TMP_ERR"
        if [ $? -ne 0 ]; then
            log_msg ERROR "get-soap-props: error writing soap.properties." < "$TMP_ERR"
            SUCCESS=false
        else
            log_msg INFO "get-soap-props: soap.properties successfully written" < /dev/null
        fi
    fi
    rm -f "$TMP_ERR"
    [ "$SUCCESS" = 'true' ]
}

################################################################################
# functions, implementing the log handler
################################################################################

#-------------------------------------------------------------------------------
# helper to find value in array
# $1: value
# $2: array
# -> true if found, else false
#-------------------------------------------------------------------------------
is_in_array() {
    VALUE="$1"
    shift
    ARRAY=( $@ )
    IS_IN_ARRAY=false
    for ENTRY in "${ARRAY[@]}"; do
        if [ "$ENTRY" = "$VALUE" ]; then
            IS_IN_ARRAY=true
            break
        fi
    done
    [ "$IS_IN_ARRAY" = 'true' ]
}

#-------------------------------------------------------------------------------
# helper to build jq filter for levels. The filter has to match all higher
# levels in array and the requested level itself.
# $1: Level
# $2: Array of levels
#-------------------------------------------------------------------------------
level_filter() {
    LEVEL="$1"
    shift
    LEVELS=( $@ )
    COUNT=0
    for ENTRY in "${LEVELS[@]}"; do
        if [ "$COUNT" -gt 0 ]; then
            echo -n ' or '
        fi
        echo -n "( .level == \"$ENTRY\")"
        if [ "$ENTRY" = "$LEVEL" ]; then
            break
        fi
        COUNT=$(expr $COUNT + 1)
    done
}

#-------------------------------------------------------------------------------
# get name of jq (since it differs on different platforms)
# -> name of jq
#-------------------------------------------------------------------------------
jq_get() {
    if [ ! -z "$(which jq 2> /dev/null)" ]; then
        echo 'jq'
    elif [ ! -z "$(which jq-win64) 2> /dev/null" ]; then
        echo 'jq-win64'
    fi
}

#-------------------------------------------------------------------------------
# get logs of dbaccount init container
# $1|2: [FATAL|ERROR|WARN|INFO|DEBUG|TRACE], defaults to WARN
# $1|2: [-f] if set, messages are printed in follow mode
# ->  true|false indicating success
#-------------------------------------------------------------------------------
log-dbaccount() (
    SUCCESS=false
    FOLLOW=false
    LEVEL=WARN
    LEVELS=(FATAL ERROR WARN INFO DEBUG TRACE)

    # decide how to interpret arguments
    if [ "$1" = '-f' -a ! -z "$2" ]; then
        FOLLOW=true
        LEVEL="$2"
    elif [ "$1" = '-f' ]; then
        FOLLOW=true
    elif [ "$2" = '-f' ]; then
        FOLLOW=true
        LEVEL="$1"
    elif [ ! -z "$1" ]; then
        LEVEL="$1"
    fi

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "log-dbaccount: no config-file given!" < /dev/null
        SUCCESS=false
    # check value of LEVEL
    elif is_in_array "$(echo "$LEVEL" | tr '[a-z]' '[A-Z]')" ${LEVELS[@]}; then
        LEVEL=$(echo "$LEVEL" | tr '[a-z]' '[A-Z]')
        JQ="$(jq_get)"
        if [ -z "$JQ" ]; then
            log_msg ERROR "log-dbaccount: jq not found" < /dev/null
        else
            if [ "$FOLLOW" = 'true' ]; then
                FOLLOW_FLAG="--tail=1 -f"
            else
                FOLLOW_FLAG=''
            fi

            # avoid formatting if output is written to pipe. This makes it much easier,
            # to process the results
            if [ -t 1 ]; then
                COMPACT_FLAG=''
            else
                COMPACT_FLAG='--compact-output'
            fi

            POD="$(kube_get_pod iom)"
            if [ ! -z "$POD" ]; then
                # make sure to get info about failed kubectl call
                set -o pipefail
                kubectl logs $FOLLOW_FLAG $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" -c dbaccount 2> "$TMP_ERR" |
                    $JQ -R 'fromjson? | select(type == "object")' |
                    $JQ $COMPACT_FLAG "select((.logType != \"access\") and ( $(level_filter $LEVEL ${LEVELS[@]}) ))"
                RESULT=$?
                set +o pipefail
                if [ $RESULT -ne 0 ]; then
                    log_msg ERROR "log_dbaccount: error getting logs" < "$TMP_ERR"
                else
                    SUCCESS=true
                fi
            else
                log_msg ERROR "log_dbaccount: no pod available" < /dev/null
            fi
        fi
    else
        log_msg ERROR "log-dbaccount: '$LEVEL' is not a valid log-level" < /dev/null
    fi
    rm -f "$TMP_ERR"
    [ "$SUCCESS" = 'true' ]
)

#-------------------------------------------------------------------------------
# get logs of config init container
# $1|2: [FATAL|ERROR|WARN|INFO|DEBUG|TRACE], defaults to WARN
# $1|2: [-f] if set, messages are printed in follow mode
# -> true|false indicating success
#-------------------------------------------------------------------------------
log-config() (
    SUCCESS=false
    FOLLOW=false
    LEVEL=WARN
    LEVELS=(FATAL ERROR WARN INFO DEBUG TRACE)

    if [ "$IsIomSingleDist" = 'false' ]; then
    
        # decide how to interpret arguments
        if [ "$1" = '-f' -a ! -z "$2" ]; then
            FOLLOW=true
            LEVEL="$2"
        elif [ "$1" = '-f' ]; then
            FOLLOW=true
        elif [ "$2" = '-f' ]; then
            FOLLOW=true
            LEVEL="$1"
        elif [ ! -z "$1" ]; then
            LEVEL="$1"
        fi
        
        if [ -z "$CONFIG_FILES" ]; then
            log_msg ERROR "log-config: no config-file given!" < /dev/null
            SUCCESS=false
            # check value of LEVEL
        elif is_in_array "$(echo "$LEVEL" | tr '[a-z]' '[A-Z]')" ${LEVELS[@]}; then
            LEVEL=$(echo "$LEVEL" | tr '[a-z]' '[A-Z]')
            JQ="$(jq_get)"
            if [ -z "$JQ" ]; then
                log_msg ERROR "log-config: jq not found" < /dev/null
            else
                if [ "$FOLLOW" = 'true' ]; then
                    FOLLOW_FLAG='--tail=1 -f'
                else
                    FOLLOW_FLAG=''
                fi
                
                # avoid formatting if output is written to pipe. This makes it much easier,
                # to process the results
                if [ -t 1 ]; then
                    COMPACT_FLAG=''
                else
                    COMPACT_FLAG='--compact-output'
                fi
                
                POD="$(kube_get_pod iom)"
                if [ ! -z "$POD" ]; then
                    # make sure to get info about failed kubectl call
                    set -o pipefail
                    kubectl logs $FOLLOW_FLAG $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" -c config 2> "$TMP_ERR" |
                        $JQ -R 'fromjson? | select(type == "object")' |
                        $JQ $COMPACT_FLAG "select((.logType != \"access\") and ( $(level_filter $LEVEL ${LEVELS[@]}) ))"
                    RESULT=$?
                    set +o pipefail
                    if [ $RESULT -ne 0 ]; then
                        log_msg ERROR "log-config: error getting logs" < "$TMP_ERR"
                    else
                        SUCCESS=true
                    fi
                else
                    log_msg ERROR "log-config: no pod available" < /dev/null
                fi
            fi
        else
            log_msg ERROR "log-config: '$LEVEL' is not a valid log-level." < /dev/null
        fi
        rm -f "$TMP_ERR"
    fi
    [ "$SUCCESS" = 'true' ]
)

#-------------------------------------------------------------------------------
# get logs of IOM application container
# $1|2: [FATAL|ERROR|WARN|INFO|DEBUG|TRACE], defaults to WARN
# $1|2: [-f] if set, messages are printed in follow mode
# -> true|false indicating success
#-------------------------------------------------------------------------------
log-app() {
    log-iom "$1" "$2"
}
log-iom() (
    SUCCESS=false
    FOLLOW=false
    LEVEL=WARN
    LEVELS=(FATAL ERROR WARN INFO DEBUG TRACE)

    # decide how to interpret arguments
    if [ "$1" = '-f' -a ! -z "$2" ]; then
        FOLLOW=true
        LEVEL="$2"
    elif [ "$1" = '-f' ]; then
        FOLLOW=true
    elif [ "$2" = '-f' ]; then
        FOLLOW=true
        LEVEL="$1"
    elif [ ! -z "$1" ]; then
        LEVEL="$1"
    fi

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "log-iom: no config-file given!" < /dev/null
        SUCCESS=false
    # check value of LEVEL
    elif is_in_array "$(echo "$LEVEL" | tr '[a-z]' '[A-Z]')" ${LEVELS[@]}; then
        LEVEL=$(echo "$LEVEL" | tr '[a-z]' '[A-Z]')
        JQ="$(jq_get)"
        if [ -z "$JQ" ]; then
            log_msg ERROR "log-iom: jq not found" < /dev/null
        else
            if [ "$FOLLOW" = 'true' ]; then
                FOLLOW_FLAG='--tail=1 -f'
            else
                FOLLOW_FLAG=''
            fi

            # avoid formatting if output is written to pipe. This makes it much easier,
            # to process the results
            if [ -t 1 ]; then
                COMPACT_FLAG=''
            else
                COMPACT_FLAG='--compact-output'
            fi

            POD="$(kube_get_pod iom)"
            if [ ! -z "$POD" ]; then
                # make sure to get info about failed kubectl call
                set -o pipefail
                kubectl logs $FOLLOW_FLAG $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" -c iom 2> "$TMP_ERR" |
                    $JQ -R 'fromjson? | select(type == "object")' |
                    $JQ $COMPACT_FLAG "select((.logType != \"access\") and ( $(level_filter $LEVEL ${LEVELS[@]}) ))"
                RESULT=$?
                set +o pipefail
                if [ $RESULT -ne 0 ]; then
                    log_msg ERROR "log-iom: error getting logs" < "$TMP_ERR"
                else
                    SUCCESS=true
                fi
            else
                log_msg ERROR "log-iom: no pod available" < /dev/null
            fi
        fi
    else
        log_msg ERROR "log-iom: '$LEVEL' is not a valid log-level." < /dev/null
    fi
    rm -r "$TMP_ERR"
    [ "$SUCCESS" = 'true' ]
)

#-------------------------------------------------------------------------------
# get access logs of IOM application container
# $1|2: [ERROR|ALL], defaults to ERROR
# $1|2: [-f] if set, messages are printed in follow mode
# -> true|false indicating success
#-------------------------------------------------------------------------------
log-access() (
    SUCCESS=false
    FOLLOW=false
    LEVEL=ERROR
    LEVELS=(ERROR ALL)

    # decide how to interpret arguments
    if [ "$1" = '-f' -a ! -z "$2" ]; then
        FOLLOW=true
        LEVEL="$2"
    elif [ "$1" = '-f' ]; then
        FOLLOW=true
    elif [ "$2" = '-f' ]; then
        FOLLOW=true
        LEVEL="$1"
    elif [ ! -z "$1" ]; then
        LEVEL="$1"
    fi

    if [ -z "$CONFIG_FILES" ]; then
        log_msg ERROR "log-access: no config-file given!" < /dev/null
        SUCCESS=false
    # check value of level
    elif is_in_array "$(echo "$LEVEL" | tr '[a-z]' '[A-Z]')" ${LEVELS[@]}; then
        LEVEL=$(echo "$LEVEL" | tr '[a-z]' '[A-Z]')
        JQ="$(jq_get)"
        if [ -z "$JQ" ]; then
            log_msg ERROR "log-access: jq not found" < /dev/null
        else
            if [ "$FOLLOW" = 'true' ]; then
                FOLLOW_FLAG='--tail=1 -f'
            else
                FOLLOW_FLAG=''
            fi

            if [ "$LEVEL" = 'ERROR' ]; then
                FILTER='and (.responseCode >= 400)'
            else
                FILTER=''
            fi

            # avoid formatting if output is written to pipe. This makes it much easier,
            # to process the results
            if [ -t 1 ]; then
                COMPACT_FLAG=''
            else
                COMPACT_FLAG='--compact-output'
            fi

            POD="$(kube_get_pod iom)"
            if [ ! -z "$POD" ]; then
                # make sure to get info about failed kubectl call
                set -o pipefail
                kubectl logs $FOLLOW_FLAG $POD --namespace $EnvId --context="$KUBERNETES_CONTEXT" -c iom 2> "$TMP_ERR" |
                    $JQ -R 'fromjson? | select(type == "object")' |
                    $JQ $COMPACT_FLAG "select((.logType == \"access\") $FILTER)"
                RESULT=$?
                set +o pipefail
                if [ $RESULT -ne 0 ]; then
                    log_msg ERROR "log_access: error getting logs" < "$TMP_ERR"
                else
                    SUCCESS=true
                fi
            else
                log_msg ERROR "log-access: no pod available" < /dev/null
            fi
        fi
    else
        log_msg ERROR "log-access: '$LEVEL' is not a valid log-level." < /dev/null
    fi
    rm -f "$TMP_ERR"
    [ "$SUCCESS" = 'true' ]
)

################################################################################
# read configuration
################################################################################


# will be overwritten by CONFIG_FILES later
OMS_LOGLEVEL_DEVENV=WARN

# TODO can be removed sometimes later
if [ ! -z "$DEVENV4IOM_CONFIG" ]; then
    log_msg ERROR "Usage of environment variable DEVENV4IOM_CONFIG is not supported any longer. Please remove this variable and inform you about current configuration options by running '$(basename $0) --help'" < /dev/null
    exit 1
fi

#-------------------------------------------------------------------------------
# loopup, check, read property files

# definition of constants
CONFIG_FILE_USER_PREDEFINED=devenv.user.properties
CONFIG_FILE_PROJECT_PREDEFINED=devenv.project.properties
# global variables, used by info-config functions too
CONFIG_FILE_USER=
CONFIG_FILE_PROJECT=
# global variable, to be passed to various functions
# contains the list of config files, suitable to be passed as argument to
# template_engine.sh
CONFIG_FILES=

# if $1 is a file, it's assumed to be the config-file
if [ ! -z "$1" -a -f "$1" ]; then
    # try to read config
    if ! ( set -e; . "$1" ) 2> /dev/null; then
        log_msg ERROR "error reading config file '$1'" < /dev/null
        exit 1
    else
        CONFIG_FILE_USER="$1"
        shift
    fi
fi

# lookup default user config
if [ -z "$CONFIG_FILE_USER" -a -s "$CONFIG_FILE_USER_PREDEFINED" ]; then
    # try to read config
    if ! ( set -e; . "$CONFIG_FILE_USER_PREDEFINED" ) 2> "$TMP_ERR"; then
        log_msg ERROR "error reading config file '$CONFIG_FILE_USER_PREDEFINED'" < "$TMP_ERR"
        rm -f "$TMP_ERR"
        exit 1
    else
        CONFIG_FILE_USER="$CONFIG_FILE_USER_PREDEFINED"
    fi
fi

# lookup project config
# search within the directory where user-specific properties were located
# search within current directory otherwise
# files with size 0 are ignored. They are created by redirecting output just before
# this code is executed!
if [ ! -z "$CONFIG_FILE_USER" -a -s "$(dirname "$CONFIG_FILE_USER")/$CONFIG_FILE_PROJECT_PREDEFINED" ]; then
    # try to read config
    if ! ( set -e; . "$(dirname "$CONFIG_FILE_USER")/$CONFIG_FILE_PROJECT_PREDEFINED" ) 2> "$TMP_ERR"; then
        log_msg ERROR "error reading config file '$(dirname "$CONFIG_FILE_USER")/$CONFIG_FILE_PROJECT_PREDEFINED'" < "$TMP_ERR"
        rm -f "$TMP_ERR"
        exit 1
    else
        CONFIG_FILE_PROJECT="$(realpath "$(dirname "$CONFIG_FILE_USER")")/$CONFIG_FILE_PROJECT_PREDEFINED"
    fi
elif [ -s "$CONFIG_FILE_PROJECT_PREDEFINED" ]; then
    # try to read config
    if ! ( set -e; . "$CONFIG_FILE_PROJECT_PREDEFINED" ) 2> /dev/null; then
        log_msg ERROR "error reading config file '$CONFIG_FILE_PROJECT_PREDEFINED'" < /dev/null
        exit 1
    else
        CONFIG_FILE_PROJECT="$CONFIG_FILE_PROJECT_PREDEFINED"
    fi
fi

# read config files
# user has higher precedence than project settings
if [ ! -z "$CONFIG_FILE_PROJECT" ]; then
    . "$CONFIG_FILE_PROJECT"
fi
if [ ! -z "$CONFIG_FILE_USER" ]; then
    . "$CONFIG_FILE_USER"
fi

# provide list of config files for template-engine
# user has higher precedence than project settings
if [ ! -z "$CONFIG_FILE_PROJECT" -a ! -z "$CONFIG_FILE_USER" ]; then
    CONFIG_FILES="$CONFIG_FILE_PROJECT","$CONFIG_FILE_USER"
elif [ ! -z "$CONFIG_FILE_PROJECT" ]; then
    CONFIG_FILES="$CONFIG_FILE_PROJECT"
elif [ ! -z "$CONFIG_FILE_USER" ]; then
    CONFIG_FILES="$CONFIG_FILE_USER"
fi

#-------------------------------------------------------------------------------
# determine project directory
# it's the directory where project-specific configuration is located or the
# current directory, if no such configuration exists

# global variable to be passed at variable places to template_engine.sh
PROJECT_DIR="$(pwd)"

if [ ! -z "$CONFIG_FILE_PROJECT" ]; then
    PROJECT_DIR="$(realpath "$(dirname "$CONFIG_FILE_PROJECT")")"
fi

#-------------------------------------------------------------------------------
# check configuration
if [ ! -z "$CONFIG_FILES" ]; then
    if [ -z "$ID" ]; then
        # reject config file with empty ID
        # this is the initial state after creation of file
        log_msg ERROR "property ID must not be empty!" < /dev/null
        exit 1
    elif echo "$ID" | grep -qi '^default' || echo "$ID" | grep -qi '^docker' || echo "$ID" | grep -qi '^kube'; then
        # reject config file with ID starting with one of the reserved words,
        # which are used by namespaces of Docker-Destop
        log_msg ERROR "property ID must not start with one of the reserverd words 'default', 'docker', 'kube'" < /dev/null
        exit 1
    fi
fi

# determine DEVENV_DIR
DEVENV_DIR="$(realpath "$(dirname "$BASH_SOURCE")/..")"

# get template variables
. $DEVENV_DIR/bin/template-variables || exit 1

################################################################################
# read command line arguments
################################################################################

# handle 1. level of command line arguments
LEVEL0=
case $1 in
    i*)
        LEVEL0=info
        ;;
    c*)
        LEVEL0=create
        ;;
    de*)
        LEVEL0=delete
        ;;
    a*)
        LEVEL0=apply
        ;;
    du*)
        LEVEL0=dump
        ;;
    g*)
        LEVEL0=get
        ;;
    l*)
        LEVEL0=log
        ;;
    --help)
        help
        exit 0
        ;;
    -h)
        help
        exit 0
        ;;
    *)
        syntax_error
        exit 1
        ;;
esac

# handle next command line argument
shift

# handle 2. level of command line arguments
LEVEL1=
if [ "$LEVEL0" = "info" ]; then
    case $1 in
        i*)
            LEVEL1=iom
            ;;
        p*)
            LEVEL1=postgres
            ;;
        m*)
            LEVEL1=mailserver
            ;;
        s*)
            LEVEL1=storage
            ;;
        cl*)
            LEVEL1=cluster
            ;;
        co*)
            LEVEL1=config
            ;;
        --help)
            help-info
            exit 1
            ;;
        -h)
            help-info
            exit 1
            ;;
        *)
            syntax_error info
            exit 1
            ;;
    esac
elif [ "$LEVEL0" = "create" ]; then
    case $1 in
        s*)
            LEVEL1=storage
            ;;
        n*)
            LEVEL1=namespace
            ;;
        m*)
            LEVEL1=mailserver
            ;;
        p*)
            LEVEL1=postgres
            ;;
        i*)
            LEVEL1=iom
            ;;
        c*)
            LEVEL1=cluster
            ;;
        --help)
            help-create
            exit 0
            ;;
        -h)
            help-create
            exit 0
            ;;
        *)
            syntax_error create
            exit 1
            ;;
    esac
elif [ "$LEVEL0" = "delete" ]; then
    case $1 in
        s*)
            LEVEL1=storage
            ;;
        n*)
            LEVEL1=namespace
            ;;
        m*)
            LEVEL1=mailserver
            ;;
        p*)
            LEVEL1=postgres
            ;;
        i*)
            LEVEL1=iom
            ;;
        c*)
            LEVEL1=cluster
            ;;
        --help)
            help-delete
            exit 1
            ;;
        -h)
            help-delete
            exit 1
            ;;
        *)
            syntax_error delete
            exit 1
            ;;
    esac
elif [ "$LEVEL0" = "apply" ]; then
    case $1 in
        de*)
            LEVEL1=deployment
            ;;
        m*)
            LEVEL1=mail-templates
            ;;
        x*)
            LEVEL1=xsl-templates
            ;;
        sql-s*)
            LEVEL1=sql-scripts
            ;;
        sql-c*)
            LEVEL1=sql-config
            ;;
        j*)
            LEVEL1=json-config
            ;;
        db*)
            LEVEL1=dbmigrate
            ;;
        --help)
            help-apply
            exit 0
            ;;
        -h)
            help-apply
            exit 0
            ;;
        *)
            syntax_error apply
            exit 1
            ;;
    esac
elif [ "$LEVEL0" = "dump" ]; then
    case $1 in
        c*)
            LEVEL1=create
            ;;
        l*)
            LEVEL1=load
            ;;
        --help)
            help-dump
            exit 0
            ;;
        -h)
            help-dump
            exit 0
            ;;
        *)
            syntax_error dump
            exit 1
            ;;
    esac
elif [ "$LEVEL0" = 'get' ]; then
    case $1 in
        co*)
            LEVEL1=config
            ;;
        g*)
            LEVEL1=geb-props
            ;;
        w*)
            LEVEL1=ws-props
            ;;
        s*)
            LEVEL1=soap-props
            ;;
        --help)
            help-get
            exit 0
            ;;
        -h)
            help-get
            exit 0
            ;;
        *)
            syntax_error get
            exit 1
            ;;
    esac
elif [ "$LEVEL0" = 'log' ]; then
    case $1 in
        d*)
            LEVEL1=dbaccount
            ;;
        c*)
            LEVEL1=config
            ;;
        i*)
            LEVEL1=iom
            ;;
        ap*)
            LEVEL1=app
            ;;
        ac*)
            LEVEL1=access
            ;;
        --help)
            help-log
            exit 0
            ;;
        -h)
            help-log
            exit 0
            ;;
        *)
            syntax_error log
            exit 1
            ;;
    esac
fi

# handle next command line argument
shift

# handle --help|-h on detail level
# it's fully sufficient to find a -h or --help within remaining arguments
for ARG in "$@"; do
    case $ARG in
        --help*)
            eval help-$LEVEL0-$LEVEL1
            exit 0
            ;;
        -h*)
            eval help-$LEVEL0-$LEVEL1
            exit 0
            ;;
    esac
done

# get remaining arguments
ARG1=$1
ARG2=$2

################################################################################
# execute commands
################################################################################

# there is no command, accepting more than two arguments
if [ ! -z "$3" ]; then
    syntax_error $LEVEL0 $LEVEL1
    exit 1
fi

# handle command, requiring one argument
if [ "$LEVEL0" = 'apply' -a "$LEVEL1" = 'sql-scripts' ]; then
    if [ -z "$ARG1" ]; then
        syntax_error $LEVEL0 $LEVEL1
        exit 1
    fi
    eval $LEVEL0-$LEVEL1 "$ARG1" "$ARG2" || exit 1

# handle commands, accepting one argument
elif [    \( "$LEVEL0" = 'apply' -a "$LEVEL1" = 'sql-config'  \) -o \
          \( "$LEVEL0" = 'apply' -a "$LEVEL1" = 'json-config' \) -o \
          \( "$LEVEL0" = 'apply' -a "$LEVEL1" = 'dbmigrate'   \) -o \
          \( "$LEVEL0" = 'apply' -a "$LEVEL1" = 'deployment'  \) -o \
          \( "$LEVEL0" = 'get'   -a "$LEVEL1" = 'config'      \) -o \
          \( "$LEVEL0" = 'dump'  -a "$LEVEL1" = 'create'      \) ]; then
    if [ ! -z "$ARG2" ]; then
        syntax_error $LEVEL0 $LEVEL1
        exit 1
    fi
    eval $LEVEL0-$LEVEL1 "$ARG1" || exit 1


# handle commands, accepting two arguments
elif [ "$LEVEL0" = 'log' ]; then
    eval $LEVEL0-$LEVEL1 "$ARG1" "$ARG2" || exit 1

# handle commands, not accepting any argument
else
    if [ ! -z "$ARG1" ]; then
        syntax_error $LEVEL0 $LEVEL1
        exit 1
    fi
    eval $LEVEL0-$LEVEL1 || exit 1
fi
