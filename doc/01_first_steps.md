# First Steps

The _First Steps_ chapter is intended to guide you through all main parts of _devenv-4-iom_ based on simple examples. You will learn how to:

* Set up an IOM for development,
* Browse through the GUI of IOM,
* Take a look on log messages,
* Solve a very simple development task,
* Eventually destroy the IOM installation again.

Once you are able to set up IOM with _devenv-4-iom_ and have an insight into its main ideas, it should become easy for you to find out more by yourself and to solve the development tasks you have to solve.

## Define Configuration

_devenv-4-iom_ uses property files to manage different developer instances of IOM. The whole concept of configuration is explained in [General Concept of Configuration](02_configuration.md#concept_config). For the moment a simplified approach is fully sufficient.

One configuration file can hold all the information required to run one instance of IOM. As first step, a new configuration file has to be created now. To do so, the script `devenv-cli.sh` has to be called with options `get config`. In order to get the following examples to work, you have to extend the `PATH` variable by the directory, containing `devenv-cli.sh` as described in [Setup _devenv-4-iom_](00_installation.md#setup_devenv).

    # make sure, there is no existing property file
    mv -nv devenv.project.properties devenv.project.properties.bak
    mv -nv devenv.user.properties devenv.user.properties.bak
    
    # create configuration file, filled with default values
    devenv-cli.sh get config --skip-config > devenv.project.properties
    
There are some values in `devenv.project.properties` that have to be set afterwards. 

* `ID`. Every developer instance of IOM, hence every configuration file, needs to have a unique value for ID. Once you have set the `ID` and started the according IOM, you must not change it anymore. Otherwise you will loose the ability to access/control the resources associated with the IOM installation.
* `IMAGE_PULL_POLICY`. The value of this property has to be set to `IfNotPresent`. This makes it easier to get through the _first steps_ example. The [_operations_ part of the documentation](03_operations.md) shows a more sustainable approach to [access a private Docker registry](03_operations.md#private_docker_registry).
* `IOM_IMAGE`. You need to define the IOM image, that has to be used for the _first steps_ example. If you use IOM version 4.0.0, then the according image name is `docker.intershop.de/intershophub/iom:4.0.0`. The `IOM_IMAGE` property is one of the most important settings, since it defines what will be executed by _devenv-4-iom_. By defining the image, you can control that a specific project, a standard IOM product without any customizations or an image of the IOM project, you have created locally, will run in your development environment.

Now set the new values for `ID`, `IMAGE_PULL_POLICY` and `IOM_IMAGE`. Please take care, to NOT add any whitespaces around the '='!

    # set ID, IMAGE_PULL_POLICY and IOM_IMAGE in devenv.project.properties
    vi devenv.project.properties
    
The other values of the new configuration file are filled with default settings defined by _devenv-4-iom_. It is not necessary to change any of them for the _first steps_ example. 

The Docker registry, we selected for our example, requires authentication. Hence you have to log in to the registry. Additionally you need to download the images, in order to make them accessible for _devenv-4-iom_.

Open the newly created config-file `devenv.project.properties` and use the values of the `*_IMAGE` properties to pull the Docker images manually, just as shown in the box below.

    # login into Docker registry
    # you need to have valid credentials for docker.intershop.de
    docker login docker.intershop.de
    
    # pull images from registry
    docker pull postgres:12
    docker pull mailhog/mailhog
    docker pull docker.intershop.de/intershophub/iom-dbaccount:1.4.0
    docker pull docker.intershop.de/intershophub/iom:4.0.0
    
Before using `devenv-cli.sh` to manage your IOM developer instance, you need to know, how the configuration file will be passed to the script. There are some different ways, which are explained in detail in [General Concept of Configuration](02_configuration.md#concept_config). For our _first steps_ example you will use the mechanism, that `devenv.project.properties` will be automatically used, if it is located at the current directory. Hence, you only have to take care, to run `devenv-cli.sh` always from the directory, which contains the properties file.

## <a name="check_config"/>Check Configuration

Due to the quite complex [Concept of Configuration](02_configuration.md#concept_config) of _devenv-4-iom_, you should make sure, that you are using the right configuration values. To do so, execute the `info config` command.

    devenv-cli.sh info config
    --------------------------------------------------------------------------------
    first steps
    --------------------------------------------------------------------------------
    Property Files:
    ================
    user-specific config-file:
    project-specific config-file: devenv.project.properties
    --------------------------------------------------------------------------------
    Predifined variables:
    =====================
    PROJECT_DIR:                  /Users/name/iom-project
    --------------------------------------------------------------------------------
    Properties:
    ===========
    ID="first steps"
    IMAGE_PULL_POLICY=IfNotPresent
    IMAGE_PULL_SECRET=
    DOCKER_DB_IMAGE=postgres:12
    MAILHOG_IMAGE=mailhog/mailhog
    IOM_DBACCOUNT_IMAGE=docker.intershop.de/intershophub/iom-dbaccount:1.4.0
    IOM_CONFIG_IMAGE=
    IOM_APP_IMAGE=
    IOM_IMAGE=docker.intershop.de/intershophub/iom:4.0.0
    ...
    --------------------------------------------------------------------------------
 
Please check that _project-specific config-file_ points to the file, you had created before. _user-specific config-file_ has to be empty. And finally check the values of all properties, you had modified before.

## Create IOM Cluster

For IOM to run in _devenv-4-iom_, several (sub-)systems are required:

* A kubernetes namespace, to isolate different IOM developer installations from each other
* A persistent file storage to be used by the database
* A PostgreSQL database, which provides persistent storage
* A mail-server to receive mails sent by IOM. The mail-server used by _devenv-4-iom_ allows you to access the received mails by a GUI and by a REST interface.
* The IOM server itself

_devenv-4-iom_ provides an easy way to setup all these systems and make them work together. Just create the _cluster_ by executing the following command:

    devenv-cli.sh create cluster

_Cluster_ in context of _devenv-4-iom_ does not mean a scalable and high available set of IOM servers. Instead of it, it means all the services and infrastructure that is required to run a single IOM server for development purposes.

The process of cluster creation will take some minutes (between 2 and 10, depending on your hardware). During this time we should take a look at the statuses of the (sub-)systems.

    # get status of storage
    devenv-cli.sh info storage
    
    # get info about mail server
    devenv-cli.sh info mailserver
    
    # get info about Postgres server
    devenv-cli.sh info postgres
    
    # get info about IOM server
    devenv-cli.sh info iom

Mail server and PostgreSQL server start very fast. The output of the according `info` commands contains a section _Kubernetes_, which shows the current state. For these two systems, the state should be running even shortly after creating the cluster. The box below shows an example output:

    devenv-cli.sh info postgres
    ...
    --------------------------------------------------------------------------------
    Kubernetes:
    ===========
    namespace:                  firststeps
    KEEP_DATABASE_DATA:         true
    NAME       READY   STATUS    RESTARTS   AGE
    postgres   1/1     Running   0          0m22s
    Kubernetes:
    --------------------------------------------------------------------------------
    ...
    
The start of IOM takes much longer. You can use the `info iom` command to check the state periodically. After some minutes IOM should be in running state too. The according output should look like this:

    devenv-cli.sh info iom
    ...
    --------------------------------------------------------------------------------
    Kubernetes:
    ===========
    namespace:                  firststeps
    NAME                   READY   STATUS    RESTARTS   AGE
    iom-567c64d69c-59jzd   1/1     Running   0          2m51s
    --------------------------------------------------------------------------------
    ...
    
## Access IOM GUI

Once IOM is running, we can access its GUI. The `info iom` command provides the according information about the URL you have to use. The following box shows an example:

    devenv-cli.sh info iom
    ...
    --------------------------------------------------------------------------------
    Links:
    ======
    OMT:                        http://computername.local:8080/omt/
    Online help:                http://computername.local:8080/omt-help/
    DBDoc:                      http://computername.local:8080/dbdoc/
    Wildfly (admin:admin):      http://computername.local:9990/console/
    --------------------------------------------------------------------------------
    ...

Just copy the _OMT_ link into your browser and open the page. You should now see the login screen. The combination of `admin:!InterShop00!` should give you access to OMT.

## View Access Logs

IOM is now running and we are able to use it in the browser. It is time to learn how to access some log messages. Since we can browse OMT, the access-log messages will serve as a good example. The following command prints access-log entries and also waits for new entries.

    # press ^C to stop printing logs
    devenv-cli.sh log access all -f
    ...
    {
      "eventSource": "web-access",
      "hostName": "default-host",
      "tenant": "Intershop",
      "environment": "first steps",
      "logHost": "iom-567c64d69c-59jzd",
      "logVersion": "1.0",
      "appVersion": "4.0.0",
      "appName": "iom",
      "logType": "access",
      "configName": "",
      "bytesSent": 0,
      "dateTime": "2021-12-20T10:40:11.301Z",
      "localIp": "10.1.2.64",
      "localPort": 8080,
      "remoteHost": "192.168.65.3",
      "remoteUser": null,
      "requestHeaderReferer": "http://computername.local:8080/omt/app/home",
      "requestHeaderUser-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15",
      "requestHeaderHost": "computername.local:8080",
      "requestHeaderCookie": "JSESSIONID=k4OrQjjM0bERoFj8D6WOxvSLKdPoxFvHVChGNDJN.iom-567c64d69c-59jzd; org.springframework.web.servlet.i18n.CookieLocaleResolver.LOCALE=en",
      "requestHeaderX-Forwarded-For": null,
      "requestHeaderX-Real-IP": null,
      "requestHeaderX-Forwarded-Host": null,
      "requestHeaderX-Forwarded-Proto": null,
      "requestLine": "GET /omt/static/css/application-styles.css?version=4.0.0 HTTP/1.1",
      "requestProtocol": "HTTP/1.1",
      "requestScheme": "http",
      "responseCode": 304,
      "responseHeaderContent-Type": null,
      "responseHeaderSet-Cookie": null,
      "responseTime": 5
    }
    {
      "eventSource": "web-access",
      "hostName": "default-host",
      "tenant": "Intershop",
      "environment": "first steps",
      "logHost": "iom-567c64d69c-59jzd",
      "logVersion": "1.0",
      "appVersion": "4.0.0",
      "appName": "iom",
      "logType": "access",
      "configName": "",
      "bytesSent": 0,
      "dateTime": "2021-12-20T10:40:11.329Z",
      "localIp": "10.1.2.64",
      "localPort": 8080,
      "remoteHost": "192.168.65.3",
      "remoteUser": null,
      "requestHeaderReferer": "http://computername.local:8080/omt/app/home",
      "requestHeaderUser-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15",
      "requestHeaderHost": "computername.local:8080",
      "requestHeaderCookie": "JSESSIONID=k4OrQjjM0bERoFj8D6WOxvSLKdPoxFvHVChGNDJN.iom-567c64d69c-59jzd; org.springframework.web.servlet.i18n.CookieLocaleResolver.LOCALE=en",
      "requestHeaderX-Forwarded-For": null,
      "requestHeaderX-Real-IP": null,
      "requestHeaderX-Forwarded-Host": null,
      "requestHeaderX-Forwarded-Proto": null,
      "requestLine": "GET /omt/static/fonts/fontawesome-webfont.woff2?v=4.7.0 HTTP/1.1",
      "requestProtocol": "HTTP/1.1",
      "requestScheme": "http",
      "responseCode": 304,
      "responseHeaderContent-Type": null,
      "responseHeaderSet-Cookie": null,
      "responseTime": 1
    }
    ...
    
## Execute SQL File

The execution of an SQL file is a very simple example of a development task. To execute this task, we have to create a SQL file first. Therefore just create a file with the extension _.sql_ and copy the following content into it:

    select * from "CountryDefDO";
    
You have to make sure, that the file can be shared with Docker Desktop. Just check the settings of Docker Desktop. Go to _Docker Desktop | Preferences | Resources | File Sharing_ and check if the file is located in a shared directory. If not, move it to a shared directory or change the preferences (this requires a restart of Docker Desktop). For more information about sharing with Docker Desktop on Windows, refer to [Configuring Docker for Windows Shared Drives / Volume Mounting with AD](https://docs.microsoft.com/en-us/archive/blogs/stevelasker/configuring-docker-for-windows-volumes) in the Microsoft documentation.

The following box shows an example where the file is named `test.sql`. If you have `jq` installed, you can pipe the output through `jq` to get pretty-printed messages.

    devenv-cli.sh apply sql-script test.sql
    2021-12-20T10:49:57Z INFO
      apply-sql-scripts: job successfully started
      job.batch/apply-sql-job created
    {"tenant":"Intershop","environment":"first steps","logHost":"apply-sql-job-sp8tr","logVersion":"1.0","appName":"iom","appVersion":"4.0.0","logType":"script","timestamp":"2021-12-20T10:49:57+00:00","level":"INFO","processName":"apply_sql.sh","message":"Properties","configName":null,"additionalInfo":"--src=/tmp/sql-dir-volume/test.sql\nOMS_DB_HOST=postgres-service\nOMS_DB_PORT=5432\nOMS_DB_NAME=oms_db\nOMS_DB_USER=oms_user\nOMS_DB_USER_CONNECTION_SUFFIX=\nOMS_DB_CONNECT_TIMEOUT=10\nOMS_LOGLEVEL_SCRIPTS=INFO\nTENANT=Intershop\nENVIRONMENT=first steps"}
    {"tenant":"Intershop","environment":"first steps","logHost":"apply-sql-job-sp8tr","logVersion":"1.0","appName":"iom","appVersion":"4.0.0","logType":"script","timestamp":"2021-12-20T10:49:58+00:00","level":"INFO","processName":"apply_sql.sh","message":"processing file '/tmp/sql-dir-volume/test.sql'","configName":null}
    {"tenant":"Intershop","environment":"first steps","logHost":"apply-sql-job-sp8tr","logVersion":"1.0","appName":"iom","appVersion":"4.0.0","logType":"script","timestamp":"2021-12-20T10:49:58+00:00","level":"INFO","processName":"apply_sql.sh","message":"success","configName":null}
    2021-12-20T10:50:02Z INFO
      apply-sql-scripts: successfully deleted job
      job.batch "apply-sql-job" deleted

As you can see, the method shown above is not intended to show the results of your _select_ statement. For such purposes the interactive usage of psql to communicate with the PostgreSQL server is the better solution. Just use the command `info postgres` to get the according command line.

    devenv-cli.sh info postgres
    ...
    Usefull commands:
    =================
    Login into Pod:             kubectl exec --namespace firststeps postgres -it -- bash
    psql into root-db:          kubectl exec --namespace firststeps postgres -it -- bash -c "PGUSER=postgres PGDATABASE=postgres psql"
    psql into IOM-db:           kubectl exec --namespace firststeps postgres -it -- bash -c "PGUSER=oms_user PGDATABASE=oms_db psql"
    ...

    # now use the command, listed for "psql into IOM-db" and
    # enter the select statement interactively
    kubectl exec --namespace firststeps postgres -it -- bash -c "PGUSER=oms_user PGDATABASE=oms_db psql"
    psql (12.9 (Debian 12.9-1.pgdg110+1))
    Type "help" for help.

    oms_db=> select * from "CountryDefDO";
     id  | currency |              currencyName               | currencySymbol | isoCode2 | isoCode3 | isoNumeric |            name                 
    -----+----------+-----------------------------------------+----------------+----------+----------+------------+----------------------------
       1 | JMD      | Jamaica Dollar                          | J$             | JM       | JAM      | 388        | Jamaica
       2 | EUR      | Euro                                    | €              | DE       | DEU      | 276        | Germany
       3 | EUR      | Euro                                    | €              | AT       | AUT      | 040        | Austria
       4 | EUR      | Euro                                    | €              | NL       | NLD      | 528        | Netherlands
       5 | CHF      | Schweizer Franken                       | SFr            | CH       | CHE      | 756        | Switzerland
    ...
    
## Delete IOM Cluster

Now it is time to clean up the environment. To do so, you have to execute the following two steps:

* Delete IOM cluster
* Delete persistent storage

Unlike the cluster creation step, which included the creation of the persistent storage as well, the cluster deletion step does not affect the persistent storage. This way you could simply create a new cluster which uses the old database data. To delete the persistent storage, you have to do it explicitly by executing the according command.

    devenv-cli.sh delete cluster
    devenv-cli.sh delete storage
    
After deleting all resources belonging to the IOM developer instance, it is also save to delete the configuration file.

    rm devenv.user.properties

`devenv-cli.sh` was used lot in this example. If you want to explore all features of this program, just call it with argument _-h_.

---
[< Installation](00_installation.md) | [^ Index](../README.md) | [Configuration >](02_configuration.md)