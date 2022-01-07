# Overview

The section First Steps is intended to guide you through all main parts of _devenv-4-iom_ based on simple examples. You will learn how to:

* Set up an IOM cluster,
* Browse through the GUI of IOM,
* Take a look on access-log messages,
* Solve a very simple development task: Executing an SQL file,
* Eventually destroy the IOM cluster again.

Once you are able to set up IOM with _devenv-4-iom_ and have an insight into its main ideas, it should become easy for you to find out more by yourself and to solve the development tasks you have to solve.

# Configuration

_devenv-4-iom_ uses a very simple concept to manage developer instances of IOM. One configuration file holds all the information required to run one instance of IOM. As first step, a new configuration file has to be created now. To do so, the script `devenv-cli.sh` has to be called with options get config. In order to get the following examples to work, you have to extend the `PATH` variable by the directory, containing `devenv-cli.sh`, or you can also call the script using its absolute path.

    # extend PATH variable
    # PATH_TO_DEVENV_CLI has to be replaced by the real value.
    export PATH="${PATH_TO_DEVENV_CLI}:$PATH"
    
    # create configuration file, filled with default values
    devenv-cli.sh get config > config.properties
    
There is one value in `config.properties`, that has to be set manually: `ID`. Every instance of IOM, hence every configuration file, needs to have a unique value for ID. Once you have set the `ID` and started the according IOM, you must not change it anymore. Otherwise you will loose the ability to access/control the resources associated with the IOM installation. Now set the `ID` to `first-steps`.

    # set ID in config.properties to "first-steps"
    vi config.properties
    
The other values of the new configuration file are filled with default settings defined by _devenv-4-iom_. The most important settings are the `*_IMAGE` properties, since they define what will be executed by _devenv-4-iom_. By defining the images, you can control, for example, that a specific project, a standard IOM product without any customizations, an IOM product which is currently in development or even containers of the IOM product or project you have created yourself will run on your local computer.

The default settings use the pure IOM product. It is not necessary to change any of these settings for the first steps. The Docker registry used by default settings requires a login. Hence you have to log in to the registry. Additionally you should check if you are able to access the Docker images specified in the configuration file. To do so, try to pull the images manually in a shell.

Open the newly created config-file `config.properties` and copy the values of the `*_IMAGE` properties and use them to pull the Docker images manually, just as shown in the box below.

    # login into Docker registry
    docker login docker.intershop.de
    
    # pull images from registry
    docker pull postgres:11
    docker pull mailhog/mailhog
    docker pull docker.intershop.de/intershop/iom-dbaccount:1.1.0.0
    docker pull docker.intershop.de/intershop/iom-config:3.0.0.0
    docker pull docker.intershop.de/intershop/iom-app:3.0.0.0
    
Before using `devenv-cli.sh` to manage our IOM developer instance, we need to have a look at how configuration files are passed to the script. There are two different ways:

1. Set the configuration file as first command line parameter of `devenv-cli.sh`.
2. Define the configuration file as value for the environment variable `DEVENV4IOM_CONFIG`.

For this guide, we will use the second variant. It is recommended to store the absolute name of the configuration file in `DEVENV4IOM_CONFIG`, otherwise `devenv-cli.sh` would find the file only if it is called in the same directory as the configuration file resides.

    export DEVENV4IOM_CONFIG="$(pwd)/config.properties"

# Create IOM Cluster

For IOM to run in Kubernetes, several (sub-)systems are required:

* A kubernetes namespace, to isolate different installations from each other
* A persistent storage to be used by the database
* A PostgreSQL database, which uses persistent storage
* A mail-server to receive mails sent by IOM. The mail-server used by _devenv-4-iom_ allows you to access the received mails by a GUI and by a REST interface.
* The IOM sever itself

_devenv-4-iom_ provides an easy way to setup all these systems and make them work together. Just create the cluster by executing the following command:

    devenv-cli.sh create cluster

The process of cluster creation will take some minutes (between 2 and 10, depending on your hardware). During this time we should take a look at the statuses of the (sub-)systems.

    # get status of storage
    devenv-cli.sh info storage
    
    # get info about mail server
    devenv-cli.sh info mailserver
    
    # get info about Postgres server
    devenv-cli.sh info postgres
    
    # get info about IOM server
    devenv-cli.sh info iom

Mail server and PostgreSQL server start very fast. The output of the according _info_ commands contains a section 'Kubernetes', which shows the state. For these two systems, the state should be running even shortly after creating the cluster. The box below shows an example output:

    devenv-cli.sh info postgres
    ...
    --------------------------------------------------------------------------------
    Kubernetes:
    ===========
    namespace:                  21700snapshot
    KEEP_DATABASE_DATA:         true
    NAME       READY   STATUS    RESTARTS   AGE
    postgres   1/1     Running   0          8s
    --------------------------------------------------------------------------------
    ...
    
The start of IOM takes much longer. You can use the _info iom_ command to check the state periodically. After some minutes IOM should be in running state too. The according output should look like this:

    devenv-cli.sh info iom
    ...
    --------------------------------------------------------------------------------
    Kubernetes:
    ===========
    namespace:                  21700snapshot
    NAME                   READY   STATUS    RESTARTS   AGE
    iom-6c587ddd87-d7qb2   1/1     Running   0          5m5s
    --------------------------------------------------------------------------------
    ...
    
# Access IOM GUI

Once IOM is running, we can access its GUI. The _info iom_ command provides the according information about the URL you have to use. The following box shows an example:

    devenv-cli.sh info iom
    ...
    --------------------------------------------------------------------------------
    Links:
    ======
    OMT:                        http://computername.local:8080/omt
    DBDoc:                      http://computername.local:8080/dbdoc/
    Wildfly (admin:admin):      http://computername.local:9990/console
    --------------------------------------------------------------------------------
    ...

Just copy the OMT link into your browser and open the page. You should now see the login screen. The combination of `admin:!InterShop00!` should give you access to IOM.

# View Access Logs

IOM is running and we are able to use it in the browser. It is time to learn how to access some log messages. Since we can browse IOM, the access-log message will serve as a good example. The following command prints access-log entries and also waits for new entries.

    # press ^C to stop printing logs
    devenv-cli.sh log access all -f
    ...
    {
      "eventSource": "web-access",
      "hostName": "default-host",
      "tenant": "Intershop",
      "environment": "2.17.0.0-SNAPSHOT",
      "logHost": "iom-6c587ddd87-d7qb2",
      "logVersion": "1.0",
      "appVersion": "2.17.0.0-SNAPSHOT@1234",
      "appName": "iom-app",
      "logType": "access",
      "configName": "ci",
      "bytesSent": 33586,
      "dateTime": "2019-12-17T14:12:36153Z",
      "localIp": "10.1.1.210",
      "localPort": 8080,
      "remoteHost": "192.168.65.3",
      "remoteUser": null,
      "requestHeaderReferer": "http://computername.local:8080/omt/app/order/landingpage",
      "requestHeaderUser-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.4 Safari/605.1.15",
      "requestHeaderHost": "computername.local:8080",
      "requestHeaderCookie": "OMS_IDENTITY=eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJPTVQiLCJleHAiOjE1NzY2NzgzNDksImlhdCI6MTU3NjU5MTk0OSwic3ViIjoiQXV0aGVudGljYXRpb24iLCJ1c2VyIjoiYWRtaW4ifQ.c5XuyKZM1FbrwRRGTg4CqaXog3WN6K-kuSTYSp6WEio; SessionKey=11a11a64-9ee9-44cc-bd4d-7ffbb1e12fac; JSESSIONID=k_AxMo_ElpYnjaTTLAkOeFoF3LF_W6VW67PpYcG1.iom-6c587ddd87-d7qb2; org.springframework.web.servlet.i18n.CookieLocaleResolver.LOCALE=en",
      "requestLine": "GET /omt/WEB-INF/views/widgets/shortOrderSearchContainer.jsp?_=1576591952608 HTTP/1.1",
      "requestProtocol": "HTTP/1.1",
      "requestScheme": "http",
      "responseCode": 200,
      "responseHeaderContent-Type": "text/html;charset=utf-8",
      "responseHeaderSet-Cookie": null,
      "responseTime": 3420
    }
    {
      "eventSource": "web-access",
      "hostName": "default-host",
      "tenant": "Intershop",
      "environment": "2.17.0.0-SNAPSHOT",
      "logHost": "iom-6c587ddd87-d7qb2",
      "logVersion": "1.0",
      "appVersion": "2.17.0.0-SNAPSHOT@1234",
      "appName": "iom-app",
      "logType": "access",
      "configName": "ci",
      "bytesSent": 472,
      "dateTime": "2019-12-17T14:12:41026Z",
      "localIp": "10.1.1.210",
      "localPort": 8080,
      "remoteHost": "10.1.0.1",
      "remoteUser": null,
      "requestHeaderReferer": null,
      "requestHeaderUser-Agent": "kube-probe/1.14",
      "requestHeaderHost": "10.1.1.210:8080",
      "requestHeaderCookie": null,
      "requestLine": "GET /monitoring/services/health/status HTTP/1.1",
      "requestProtocol": "HTTP/1.1",
      "requestScheme": "http",
      "responseCode": 200,
      "responseHeaderContent-Type": "application/json",
      "responseHeaderSet-Cookie": null,
      "responseTime": 2
    }
    ...
    
# Execute SQL File

The execution of an SQL file is a very simple example of a development task. To execute this task, we have to create an SQL file first. Therefore just create a file with the extension _.sql_ and copy the following content into it:

    select * from "CountryDefDO";
    
You have to make sure, that the file can be shared with Docker Desktop. Just check the settings of Docker Desktop. Go to _Docker Desktop | Preferences | File Sharing_ and check if the file is located in a shared directory. If not, move it to a shared directory or change the preferences (this requires a restart of Docker Desktop). For more information about sharing with Docker Desktop, refer to Configuring Docker for Windows Shared Drives / Volume Mounting with AD in the Microsoft documentation.

The following box shows an example where the file is named `/home/user/test.sql`. If you have `jq` installed, you can pipe the output through `jq` to get pretty-printed messages.

    devenv-cli.sh apply sql-script /home/user/test.sql
    { "tenant":"Intershop", "environment":"devenv4iom", "logHost":"computername.local", "logVersion":"1.0", "appName":"devenv4iom", "appVersion":"1.0.0.0-SNAPSHOT", "logType":"script", "timestamp":"2019-12-17T14:42:23Z", "level":"INFO", "message":"apply-sql-scripts: job successfully started", "processName":"devenv-cli.sh", "additionalInfo":"job.batch/apply-sql-job created", "configName":"ci" }
    {"tenant":"Intershop","environment":"2.17.0.0-SNAPSHOT","logHost":"apply-sql-job-kqcnh","logVersion":"1.0","appName":"iom-config","appVersion":"2.17.0.0-SNAPSHOT@1234","logType":"script","timestamp":"2019-12-17T14:42:24+00:00","level":"INFO","processName":"apply_sql.sh","message":"Properties","configName":"ci","additionalInfo":"--src=/tmp/sql-dir-volume/test.sql\nOMS_DB_HOST=postgres-service\nOMS_DB_PORT=5432\nOMS_DB_NAME=oms_db\nOMS_DB_USER=oms_user\nOMS_DB_PASS=oms_pw\nOMS_USER_CONNECTION_SUFFIX=\nOMS_LOGLEVEL_SCRIPTS=INFO\nTENANT=Intershop\nENVIRONMENT=2.17.0.0-SNAPSHOT"}
    {"tenant":"Intershop","environment":"2.17.0.0-SNAPSHOT","logHost":"apply-sql-job-kqcnh","logVersion":"1.0","appName":"iom-config","appVersion":"2.17.0.0-SNAPSHOT@1234","logType":"script","timestamp":"2019-12-17T14:42:24+00:00","level":"INFO","processName":"apply_sql.sh","message":"processing file '/tmp/sql-dir-volume/test.sql'","configName":"ci"}
    {"tenant":"Intershop","environment":"2.17.0.0-SNAPSHOT","logHost":"apply-sql-job-kqcnh","logVersion":"1.0","appName":"iom-config","appVersion":"2.17.0.0-SNAPSHOT@1234","logType":"script","timestamp":"2019-12-17T14:42:24+00:00","level":"INFO","processName":"apply_sql.sh","message":"success","configName":"ci"}
    { "tenant":"Intershop", "environment":"devenv4iom", "logHost":"computername.local", "logVersion":"1.0", "appName":"devenv4iom", "appVersion":"1.0.0.0-SNAPSHOT", "logType":"script", "timestamp":"2019-12-17T14:42:29Z", "level":"INFO", "message":"apply-sql-scripts: successfully deleted job", "processName":"devenv-cli.sh", "additionalInfo":"job.batch \"apply-sql-job\" deleted", "configName":"ci" }

As you can see, the method shown above is not intended to show the results of your select statement. For such purposes the interactive usage of psql to communicate with the PostgreSQL server is the better solution. Just use the command info postgres to get the according command line.

    devenv-cli.sh info postgres
    ...
    Usefull commands:
    =================
    Login into Pod:             kubectl exec --namespace firststeps postgres -it bash
    psql into root-db:          kubectl exec --namespace firststeps postgres -it -- bash -c "PGUSER=postgres PGDATABASE=postgres psql"
    psql into IOM-db:           kubectl exec --namespace firststeps postgres -it -- bash -c "PGUSER=oms_user PGDATABASE=oms_db psql"
    ...

    # now use the command for "psql into IOM-db" and
    # enter the select statement interactively
    kubectl exec --namespace firststeps postgres -it -- bash -c "PGUSER=oms_user PGDATABASE=oms_db psql"
    psql (11.8 (Debian 11.8-1.pgdg90+1))
    Type "help" for help.
    
    oms_db=> select * from "CountryDefDO";
     id | currency |       currencyName        | currencySymbol | isoCode2 | isoCode3 | isoNumeric |                 name
    ----+----------+---------------------------+----------------+----------+----------+------------+--------------------------------------
      1 | JMD      | Jamaica Dollar            | J$             | JM       | JAM      | 388        | Jamaica
      2 | EUR      | Euro                      | €              | DE       | DEU      | 276        | Germany
      3 | EUR      | Euro                      | €              | AT       | AUT      | 040        | Austria
      4 | EUR      | Euro                      | €              | NL       | NLD      | 528        | Netherlands
      5 | CHF      | Schweizer Franken         | SFr            | CH       | CHE      | 756        | Switzerland
    ...
    
# Delete IOM Cluster

Now it is time to clean up the environment. To do so, we have to execute the following two steps:

* Delete IOM cluster
* Delete persistent storage

Unlike the cluster creation step, which included the creation of the persistent storage as well, the cluster deletion step does not affect the persistent storage. This way you could simply create a new cluster which uses the old database data. To delete the persistent storage, we have to do it explicitly by executing the according command.

    devenv-cli.sh delete cluster
    devenv-cli.sh delete storage
    
After deleting all resources belonging to our IOM developer instance, it is also save to delete the configuration file. Do not forget to unset `DEVENV4IOM_CONFIG` as well.

    rm config.properties
    export DEVENV4IOM_CONFIG=

We have used `devenv-cli.sh` a lot. If you want to explore all features of this program, just call it with _-h_ as argument.
