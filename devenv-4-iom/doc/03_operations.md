# Operations
## <a name="private_docker_registry">Accessing a Private Docker Registry</a>

Private _Docker_ registries require authentication and sufficient rights to pull images from them. The according authentication data can be passed in a _Kubernetes_ secret object. The configuration of _devenv-4-iom_ provides the variable `IMAGE_PULL_SECRET`, which has to hold the name of the _Kubernetes_ secret object, if authentication is required.

_devenv-4-iom_ does not manage the _Kubernetes_ secret in any way. The user is fully responsible to create, update and delete the _Kubernetes_ secret object. _Kubernetes_ secret objects, which should be used by _devenv-4-iom_, always have to be created within the default namespace. During [creation of IOM](#create_iom) the secret will be copied from the default namespace to the namespace used by IOM.

The document [Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) from the _Kubernetes_ documentation explains how to create _Kubernetes_ secret objects in general, suitable to authenticate at a private _Docker_ registry. [Pull images from an Azure container registry to a _Kubernetes_ cluster](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-kubernetes) from the Microsoft Azure documentation explains how to apply this concept to private Azure Container Registries.

The following example shows how to create a _Kubernetes_ secret to be used to access the private _Docker_ Registry _docker.tools.intershop.com_ within the default namespace. The name of the newly created secret is `intershop-pull-secret`, which has to be set as value of the variable `IMAGE_PULL_SECRET`.

    kubectl create secret docker-registry intershop-pull-secret \
        --context="docker-desktop" \
        --docker-server=docker.tools.intershop.com \
        --docker-username='<user name>' \
        --docker-password='<password>'

If the secret is created and the variable `IMAGE_PULL_SECRET` is set in a user-specific configuration file (see [General Concept of Configuration](02_configuration.md#concept_config)), _devenv-4-iom_ can now authenticate at the _Docker_ Registry _docker.tools.intershop.com_.

When accessing a private Azure Container Registry (ACR), the same mechanism can be used. In this case the value of _service principal ID_ has to be set at `docker-username` and the value of _service principal password_ for `docker-password`.

## <a name="create_cluster">Create an Entire IOM Cluster</a>

_Cluster_ in context of _devenv-4-iom_ does not mean a scalable and high available set of IOM servers. Instead, it refers to all the services and infrastructure that are required to run a single IOM server for development purposes.

The creation of an entire IOM cluster consists of these steps:

1. [Create local _Docker_ volume](#create_storage) (not required if `KEEP_DATABASE_DATA` is set to false)
1. [Create namespace](#create_namespace)
1. [Create mailserver](#create_mailserver)
1. [Create postgres database](#create_postgres) (not required if an external database is used, which is the case if `PGHOST` is set)
1. [Create IOM](#create_iom)

_devenv-cli.sh_ provides all these commands separately, but it also provides the shortcut `create cluster`, which does all these steps at once.

Depending on the _Docker_ registry you are using, it might be required to set `IMAGE_PULL_SECRET` first.

    devenv-cli.sh create cluster

## <a name="delete_cluster">Delete an Entire IOM Cluster</a>

Deleting an entire IOM development environment consists of several steps. These are:

1. [Delete IOM](#delete_iom)
1. [Delete postgres database](#delete_postgres) (not required if an external database is used, which is the case if `PGHOST` is set)
1. [Delete mailserver](#delete_mailserver)
1. [Delete namespace](#delete_namespace)

All these steps are provided as single commands by _devenv-cli.sh_. The command line client also provides the shortcut `delete cluster`, which performs all these operations at once.

Please note that persistent storage will never be deleted by the `delete cluster` command. The storage has to be [deleted separately](#delete_storage).

    devenv-cli.sh delete cluster

## <a name="create_namespace">Create Namespace</a>

A namespace is required to isolate the IOM development instances from each other and from other _Kubernetes_ resources. The following command creates a namespace based on the `ID` you have specified in your properties:

    devenv-cli.sh create namespace

## <a name="delete_namespace">Delete Namespace</a>

The following command deletes the namespace and all resources assigned to this namespace:

    devenv-cli.sh delete namespace

## <a name="create_mailserver">Create Mail Server</a>

The following command creates a mail server which is used to receive mails from IOM:

    devenv-cli.sh create mailserver

## <a name="delete_mailserver">Delete Mail Server</a>

The following command deletes the mail server:

    devenv-cli.sh delete mailserver

## <a name="create_storage">Create Local _Docker_ Volume</a>

The following command creates a local _Docker_ volume to be used to keep database data. This command is only effective if `KEEP_DATABASE_DATA` is set to `true`.

    devenv-cli.sh create storage

## <a name="delete_storage">Delete Local _Docker_ Volume</a>

To remove the database data, you just have to remove the persistent database data volume using the following command. This command is only effective if a local _Docker_ volume was created before (`KEEP_DATABASE_DATA` is set to `true`).

    devenv-cli.sh delete storage

## <a name="create_postgres">Create Postgres Database</a>

The following command creates the Postgres database server. This command is only effective if an internal database server is used (when `PGHOST` is not set).

    devenv-cli.sh create postgres

## <a name="delete_postgres">Delete Postgres Database</a>

The following command deletes the Postgres database server. This command is only effective if an internal database server was created before (when `PGHOST` is not set).

    devenv-cli.sh delete postgres

## <a name="create_iom">Create IOM</a>

The following command creates the IOM application server.

Depending on the _Docker_ registry you are using, it might be required to set `IMAGE_PULL_SECRET` first.

    devenv-cli.sh create iom

## <a name="delete_iom">Delete IOM</a>

The following command deletes the IOM application server.

    devenv-cli.sh delete iom

## Get Information About Components

Each component (IOM, Postgres, mail server, storage, configuration) has a lot of information to provide, e.g.:

* Links to access services
* Public ports
* Configuration settings
* Useful commands, etc.

The _devenv-cli.sh_ provides a very simple interface to get these information:

    # Get information about IOM
    devenv-cli.sh info iom

    # Get information about mail server
    devenv-cli.sh info mailserver

    # Get information about PostgreSQL
    devenv-cli.sh info postgres

    # Get information about storage
    devenv-cli.sh info storage

    # Get information about configuration
    devenv-cli.sh info config

---
[< Configuration](02_configuration.md) | [^ Index](../README.md) | [Development Process >](04_development_process.md)
