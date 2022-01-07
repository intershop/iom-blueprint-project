
# Accessing a Private Docker Registry

- - -
_This functionality is available since version 1.1.0.0 of devenv-4-iom._
- - -

Private Docker registries are requiring authentication and sufficient rights to pull images from them. The according authentication data can be passed in a Kubernetes secret object. The configuration of _devenv-4-iom_ provides the variable `IMAGE_PULL_SECRET`, which has to hold the name of the Kubernetes secret object, if authentication is required.

_devenv-4-iom_ does not manage the Kubernetes secret in any way. The user is fully responsible to create, update and delete the Kubernetes secret object. Kubernetes secret objects, which should be used by _devenv-4-iom_, always need to be created within default namespace. During [creation of IOM](#create_iom) the secret will be copied from the default namespace to the namespace used by IOM.

The document [Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) from Kubernetes documentation explains how to create Kubernetes secret objects in general, suitable to authenticate at a private Docker registry. [Pull images from an Azure container registry to a Kubernetes cluster](https://docs.microsoft.com/de-de/azure/container-registry/container-registry-auth-kubernetes) from Microsoft Azure documentation explains how to apply this concept to private Azure Container Registries.

The following box shows an example for how to create a Kubernetes secret within default namespace to be used to access the private Docker Registry _docker.intershop.de_. The name of the newly created secret is `intershop-pull-secret`, which has to be set as value of variable `IMAGE_PULL_SECRET`.

    kubectl create secret docker-registry intershop-pull-secret \
        --docker-server=docker.intershop.de \
        --docker-username='<user name>' \
        --docker-password='<password>'

If the secret is created and the variable `IMAGE_PULL_SECRET` is set, _devenv-4-iom_ can now authenticate at the Docker Registry _docker.intershop.de_.

When accessing a private Azure Container Registry (ACR), the same mechanism can be used. In this case the value of _service principal ID_ has to be set at `docker-username` and the value of _service principal password_ for `docker-password`.

# <a name="create_cluster"/>Create Whole IOM Cluster

The creation of a whole IOM cluster consists of several steps. These are:

1. [Create local Docker volume](#create_storage) (not required if `KEEP_DATABASE_DATA` is set to false)
1. [Create namespace](#create_namespace)
1. [Create mailserver](#create_mailserver)
1. [Create postgres database](#create_postgres) (not required if an external database is used, which is the case if `PGHOST` is set)
1. [Create IOM](#create_iom)
The command line client provides all these commands separately, but it also provides the shortcut _create cluster_, which does all these steps at once.

Depending on the Docker registry you are using, it might be required to set `IMAGE_PULL_SECRET` first.

    # Now create the cluster
    devenv-cli.sh create cluster

# <a name="delete_cluster"/>Delete Whole IOM Cluster

Removing the whole IOM development environment consists of several steps. These are:

1. [Delete IOM](#delete_iom)
1. [Delete postgres database](#delete_postgres) (not required if an external database is used, which is the case if `PGHOST` is set)
1. [Delete mailserver](#delete_mailserver)
1. [Delete namespace](#delete_namespace)

All these steps are provided as single commands by _devenv-4-iom_'s command line client. The command line client also provides the shortcut _delete cluster_, which performs all these operations at once.

Please note that persistent storage will never be deleted by the _delete cluster_ command.

    devenv-cli.sh delete cluster

# <a name="create_namespace"/>Create Namespace

Namespace is required to isolate the _devenv-4-iom_ from other resources and from resources of other configurations. The following command creates a namespace based on the `ID` you have specified in your properties.

    devenv-cli.sh create namespace

# <a name="delete_namespace"/>Delete Namespace

The following command deletes the namespace and all resources assigned to this namespace.

    devenv-cli.sh delete namespace

# <a name="create_mailserver"/>Create Mail Server

The following command creates a mail server which is used to receive mails from IOM.

    devenv-cli.sh create mailserver

# <a name="delete_mailserver"/>Delete Mail Server

The following command deletes the mail server.

    devenv-cli.sh delete mailserver

# <a name="create_storage"/>Create Local Docker Volume

The following command creates a local Docker volume to be used to keep database data. This command is only effective if `KEEP_DATABASE_DATA` is set to true.

    devenv-cli.sh create storage
    
# <a name="delete_storage"/>Delete Local Docker Volume

- - -
**Note**

_To remove the database data, you just have to remove the persistent database data volume with the following command. This command is only effective if a local Docker volume was created before (`KEEP_DATABASE_DATA` is set to `true`)_
- - -

    devenv-cli.sh delete storage

# <a name="create_postgres"/>Create Postgres Database

The following command creates the Postgres database. This command is only effective if an internal database server is used (when `PGHOST` is not set).

    devenv-cli.sh create postgres

# <a name="delete_postgres"/>Delete Postgres Database

The following command deletes the Postgres database. This command is only effective if an internal database was created before (when `PGHOST` is not set)

    devenv-cli.sh delete postgres

# <a name="create_iom"/>Create IOM

The following command creates the IOM application server.

Depending on the Docker registry you are using, it might be required to set `IMAGE_PULL_SECRET` first.

    # now create IOM 
    devenv-cli.sh create iom

# <a name="delete_iom"/>Delete IOM

The following command deletes the IOM application server.

    devenv-cli.sh delete iom

# Get Information About Components

Each component (IOM, Postgres, mail server, storage) has a lot of information to provide, e.g.:

* Links to access services
* Public ports
* Configuration settings
* Useful commands, etc.

The command line client of _devenv-4-iom_ provides a very simple interface to get these information:

    # Get information about IOM 
    devenv-cli.sh info iom 
    
    # Get information about mail server 
    devenv-cli.sh info mailserver 
    
    # Get information about PostgreSQL 
    devenv-cli.sh info postgres 
    
    # Get information about storage 
    devenv-cli.sh info storage
    
