
# Troubleshooting
## _devenv-cli.sh_ Help

_devenv-cli.sh_ has a simple system for its command line arguments. In general, each call to _devenv-cli.sh_ requires two arguments. These could best be understood as topic and sub-topic. If you append `-h` or `--help` to the command line, you will get detailed help. This works even if no topic or sub-topic is passed. In this case, the provided help provides information about available topics or sub-topics.

    devenv-cli.sh -h

    devenv-cli.sh
        command line interface for configuration with ID first steps.

    SYNOPSIS
        devenv-cli.sh [CONFIG-FILE] COMMAND

    CONFIG-FILE
        Name of the configuration file to be used. If not set, the file
        devenv.user.properties in current directory will be used instead.
        The directory holding CONFIG-FILE or devenv.user.properties is searched
        for another config file devenv.project.properties. If it exists, properties
        defined in this file are loaded with lower precedence.
        If no configuration file can be found at all, devenv-cli.sh ends with an error,
        with one exception: 'get config'.

    COMMANDS
        get|g*             get devenv4iom specific resource
        info|i*            get information about Kubernetes resources
        create|c*          create Kubernetes/Docker resources
        delete|de*         delete Kubernetes/Docker resources
        apply|a*           apply customization
        dump|du*           create or load dump
        log|l*             simple access to log messages

    Run 'devenv-cli.sh [CONFIG-FILE] COMMAND --help|-h' for more information on a command.

## IOM is Not Working

"IOM is not working" is a very unspecific description, but it is the most common. For a systematic search for the root cause, you have to know the different stages of starting IOM and how to get detailed information about each stage.

The IOM development environment consists of three main components: database, mail server and IOM. If the mail server is not working properly, it will not affect the startup of IOM. Hence, in a situation where IOM is not working all, it's only necessary to take a look at the database and IOM itself.

### Search for Problems of Postgres Database

Before searching for a problem, the status of the Postgres database should be checked. The easiest way to do this, is to use the `info postgres` command. The output of this command contains a section named _Kubernetes_, which shows the status of the Postgres pod. If the Postgres pod is working, the entry _READY_ is _1/1_ and _STATUS_ is _Running_, see example below:

    # get information about postgres component
    devenv-cli.sh info postgres
    ...
    --------------------------------------------------------------------------------
    Kubernetes:
    ===========
    namespace:                  test
    KEEP_DATABASE_DATA:         true
    NAME       READY   STATUS    RESTARTS   AGE
    postgres   1/1     Running   0          74m
    --------------------------------------------------------------------------------
    ...

If there is no _Kubernetes_ section at all, the problem occurred in a very early stage, just before the Kubernetes resources were created. E.g. you might have tried to start the system with an invalid configuration. Please check the output of the command you have used to create the Postgres database (`create cluster` or `create postgres`) for error messages.

If there is a _Kubernetes_ section but Postgres is not running or not ready, the Postgres database startup has to be investigated. There are two possible causes of the problem:

1. The Kubernetes resource cannot be created for a certain reason (e.g. problem accessing the _Docker_ image).
1. The Postgres process itself has problems getting into the _READY_ state (e.g. Postgres version is not compatible with persistently stored data).

To get information about these two different stages, two different strategies are necessary:

1. Problems of the first category can be seen in the output of the `kubectl describe` command.
1. Problems of the second category can be seen when looking at log messages of Postgres.

The `info postgres` command of `devenv-cli.sh` provides you with the necessary command lines for further investigation. You will find them in the section _Useful commands_ as _Describe pod_ and _Get logs_.

    # get information about Postgres component
    devenv-cli.sh info postgres
    ...
    --------------------------------------------------------------------------------
    Useful commands:
    =================
    ...
    Describe pod:              kubectl describe --namespace test --context="docker-desktop" pod postgres
    Get logs:                  kubectl logs postgres --namespace test --context="docker-desktop"
    ...
    --------------------------------------------------------------------------------

    # Execute these commands for further investigation
    kubectl describe --namespace test --context="docker-desktop" pod postgres
    ...
    Events:
      Type    Reason     Age        From                     Message
      ----    ------     ----       ----                     -------
      Normal  Scheduled    default-scheduler        Successfully assigned test/postgres to docker-desktop
      Normal  Pulling    9m11s      kubelet, docker-desktop  Pulling image "postgres:11"
      Normal  Pulled     9m7s       kubelet, docker-desktop  Successfully pulled image "postgres:11"
      Normal  Created    9m7s       kubelet, docker-desktop  Created container postgres
      Normal  Started    9m7s       kubelet, docker-desktop  Started container postgres

    kubectl logs postgres --namespace test --context="docker-desktop"
    ...
    ' 2020-05-22 11:36:15.750 UTC   [1] 'LOG:  listening on IPv4 address "0.0.0.0", port 5432
    ' 2020-05-22 11:36:15.750 UTC   [1] 'LOG:  listening on IPv6 address "::", port 5432
    ' 2020-05-22 11:36:15.754 UTC   [1] 'LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
    ' 2020-05-22 11:36:15.780 UTC   [26] 'LOG:  database system was interrupted; last known up at 2020-05-22 11:13:26 UTC
    ' 2020-05-22 11:36:17.036 UTC   [26] 'LOG:  database system was not properly shut down; automatic recovery in progress
    ' 2020-05-22 11:36:17.042 UTC   [26] 'LOG:  redo starts at 0/31FE868
    ' 2020-05-22 11:36:17.043 UTC   [26] 'LOG:  invalid record length at 0/3204028: wanted 24, got 0
    ' 2020-05-22 11:36:17.043 UTC   [26] 'LOG:  redo done at 0/3203FE8
    ' 2020-05-22 11:36:17.043 UTC   [26] 'LOG:  last completed transaction was at log time 2020-05-22 11:15:51.823575+00
    ' 2020-05-22 11:36:17.071 UTC   [1] 'LOG:  database system is ready to accept connections ...

### Search for Problems of IOM

The process of searching problems of IOM is in general identical to the one used for the Postgres database, with one slight addition: IOM has an init-container, which may cause problems too. Hence, the process of searching for errors consists of these steps:

1. Check IOM's status in _Kubernetes_.
1. If the _Kubernetes_ section is missing:
    1. Check _devenv-cli.sh_ commands used to create IOM for error messages.
1. If the _Kubernetes_ section is present but IOM is not running or not ready:
    1. Check output of `kubectl describe` command for errors.
    1. Check log messages of account initialization for errors (dbaccount init-container).
    1. Check log messages of IOM for errors.

According to the checklist above, the first step gets the status of IOM. This can be easily done by using the `info iom` command. The _Kubernetes_ section in the output shows the current status. If everything is fine, _READY_ is _1/1_ and _STATUS_ is _Running_.

    devenv-cli.sh info iom
    ...
    --------------------------------------------------------------------------------
    Kubernetes:
    ===========
    namespace:                  test
    NAME                   READY   STATUS    RESTARTS   AGE
    iom-849dcb5d88-6dnss   1/1     Running   0          60m
    --------------------------------------------------------------------------------
    ...

If there is no _Kubernetes_ section at all, the problem occurred in a very early stage, just before the _Kubernetes_ resources were created. E.g. you might have tried to start the system with an invalid configuration. Please check the output of the command you have used to create IOM (`create cluster` or `create iom`) for error messages.

If there is a _Kubernetes_ section but IOM is not running or not ready, the start process of IOM has to be investigated. There are the following possible causes of the problem:

1. The _Kubernetes_ resource cannot be created for a certain reason (e.g. problem accessing the _Docker_ image).
1. The dbaccount init-container has problems to be executed successfully (e.g. wrong credentials).
1. The IOM server itself has problems to get in ready state (e.g. erroneous deployment artifact, missing database dump, erroneous configuration script, etc.).

To get information about these different stages, according strategies have to be used:

1. Problems of the first category can be found in the output of the `kubectl describe` command.
1. Problems with the dbaccount init-container can be found by checking the output of the container for error messages.
1. Problems with the IOM server can be found by checking the output of the IOM container for error messages.

The `info iom` command provides you the necessary command lines to investigate the actions made by _Kubernetes_ when starting IOM. The `log *` commands of `devenv-cli.sh` provide access to the log messages created by containers belonging to IOM.

    # Get information about IOM
    devenv-cli.sh info iom
    ...
    --------------------------------------------------------------------------------
    Useful commands:
    =================
    ...
    Describe iom pod:           kubectl describe --namespace test --context="docker-desktop" pod iom-849dcb5d88-6dnss
    Describe iom deployment     kubectl describe --namespace test --context="docker-desktop" deployment iom
    ...
    --------------------------------------------------------------------------------

    # Execute these commands for further investigation
    kubectl describe --namespace test --context="docker-desktop" pod iom-849dcb5d88-6dnss
    ...
    QoS Class:       BestEffort
    Node-Selectors:  <none>
    Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                     node.kubernetes.io/unreachable:NoExecute for 300s
    Events:          <none>

    kubectl describe --namespace test --context="docker-desktop" deployment iom
    ...
    Conditions:
      Type           Status  Reason
      ----           ------  ------
      Available      True    MinimumReplicasAvailable
      Progressing    True    NewReplicaSetAvailable
    OldReplicaSets:  <none>
    NewReplicaSet:   iom-849dcb5d88 (1/1 replicas created)
    Events:          <none>

The easiest method to get log messages out of containers is using the `log *` commands, provided by _devenv-cli.sh_. If called without further parameters, only messages of levels `WARN`, `ERROR` and `FATAL` are displayed, which makes it easy to find errors. You can use these commands only if _jq_ is properly installed.

    # Show error messages of the dbaccount init-container
    devenv-cli.sh log dbaccount
    ...

    # Show error messages of the iom application server
    devenv-cli.sh log iom
    ...

Unexpected errors may occur that are not handled properly. These errors cannot be found by using the `log *` commands. To find such errors, the raw output of containers has to be investigated. If you do not have _jq_ properly installed, you have to use this basic access to log messages as well. The according command lines are provided by `info iom` within the section _Useful commands_.

    devenv-cli.sh info iom
    ...
    --------------------------------------------------------------------------------
    Useful commands:
    =================
    ...
    Get dbaccount logs:         kubectl logs iom-849dcb5d88-6dnss --namespace test --context="docker-desktop" -c dbaccount
    Get iom logs:               kubectl logs iom-849dcb5d88-6dnss --namespace test --context="docker-desktop" -c iom
    ...
    --------------------------------------------------------------------------------

## <a name="manual_cleanup">Manual Cleanup</a>

According to section [Delete a Configuration](02_configuration.md#delete_config), a configuration must not be deleted as long as corresponding _Kubernetes_ and _Docker_ resources still exist. In a situation where the configuration file is deleted and resources belonging to this configuration were not cleaned up, you have to delete these resources manually. To do so, perform the following steps:

1. Search and delete orphaned _Kubernetes_ namespaces.
2. Delete orphaned _Docker_ volumes.

### Search and Delete Orphaned _Kubernetes_ Namespaces

All _Kubernetes_ resources, belonging to a configuration, are assigned to one _Kubernetes_ namespace. The name of this namespace is derived from the `ID` defined in the configuration file. To create a valid name for the namespace, all non-alphanumerical characters are stripped from the `ID` and the remaining characters are transformed to lowercase. E.g., if you had used _CustomerProject IOM 4.1.0_ as `ID`, the derived namespace is _customerprojectiom410_.

_Kubernetes_ uses namespaces for its own purposes. To avoid any conflict with these namespaces, _devenv-4-iom_ will not allow you to use an `ID` that starts with: _default_, _docker_ or _kube_. Hence, the orphaned _Kubernetes_ namespace will never start with any of these three phrases.

The following box shows how to list all existing namespaces. According to the naming rules of namespaces created by _devenv-4-iom_, only two entries in the list of results are of interest: _customerprojectiom410_ and _oldprojectiom3000_. If you know the `ID`s of your currently existing configurations, you can find out the name of the orphaned namespace. In our example, _oldprojectiom3000_ is the one we have searched for.

    # list all existing Kubernetes namespaces
    kubectl get namespace --context="docker-desktop"
    NAME                     STATUS   AGE
    customerprojectiom410    Active   40m
    default                  Active   28d
    docker                   Active   28d
    kube-node-lease          Active   28d
    kube-public              Active   28d
    kube-system              Active   28d
    oldprojectiom3000        Active   10d

    # delete orphaned Kubernetes namespace
    kubectl delete namespace oldprojectiom3000 --context="docker-desktop"
    namespace "oldprojectiom3000" deleted

### Delete Orphaned _Docker_ Volumes

_Docker_ volumes are used to provide persistent storage for the PostgreSQL database server. Since the usage of persistent storage is optional, an orphaned _Docker_ volume might not exist at all. Once you have found the name of an orphaned _Kubernetes_ namespace, it is very simple to find out whether an according _Docker_ volume exists or not. The name of the _Docker_ volume is derived from `ID` too. The same rules are applied to the `ID` as described above, additionally the prefix _-pgdata_ is appended.

Hence, if the orphaned _Kubernetes_ namespaces is _oldprojectiom3000_, the according _Docker_ volume is named _oldprojectiom3000-pgdata_. The following command lists all _Docker_ volumes and shows you how to delete the one _Docker_ volume you have identified before.

    # list all existing Docker volumes
    docker volume ls -q
    008e5dc60890b954a68de526da1ba73113143b8dcb9edbf382db585cb7cf2736
    customerprojectiom410-pgdata
    oldprojectiom3000-pgdata

    # delete orphaned Docker volume
    docker volume rm oldprojectiom3000-pgdata
    oldprojectiom3000-pgdata

## Wrong _Kubernetes_ Context

`kubectl` can interact with more than one _Kubernetes_ cluster by setting the context. If _devenv-cli.sh_ does not work as expected, a wrong context might be the cause.

    # List the existing contexts
    # Look out for the context you want to use. Normally it is "docker-desktop".
    kubectl config view

    # Set variable KUBERNETES_CONTEXT to the right context
    vi devenv.user.properties

## Non TTY device

When trying a `docker login` from a Linux-like terminal on Windows such as _Git bash_ or _Docker quickstart terminal_, you will get the following error.

    docker login docker.tools.intershop.com
    > Error: Cannot perform an interactive login from a non TTY device

    # The trick here is to use:
    winpty docker login docker.tools.intershop.com

---
[< Log Messages](06_log_messages.md) | [^ Index](../README.md)
