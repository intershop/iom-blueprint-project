# Development Process
## Connect the IOM Developer Installation with the Local File System

Developers edit and compile files outside the IOM developer installation on their local file system. To grant _devenv-4-iom_ access to these files, the according `CUSTOM_*_DIR` properties have to be set.

It's possible to set the according absolute path for each `CUSTOM_*_DIR`.

However, it's even better to define the `CUSTOM_*_DIR` properties in _devenv.project.properties_ which is maintained centrally along with the project code. In this case, absolute paths cannot be used, since every developer has an individual local environment. `CUSTOM_*_DIR` properties have to hold relative paths instead, which are expanded at runtime to absolute paths. The base directory for the relative paths is the directory where _devenv.propject.properties_ is located.

Any directory, that is referenced by a `CUSTOM_*_DIR` property has to be [shared with _Docker_ Desktop](https://blogs.msdn.microsoft.com/stevelasker/2016/06/14/configuring-docker-for-windows-volumes/).

Depending on the version of Windows Subsystem for Linux (WSL), the property `MOUNT_PREFIX` might come into play. When using WSL2 (and only in this particular case), `MOUNT_PREFIX` has to be set to `/run/desktop/mnt/host`. In any other case, it must remain empty.

## Add a New Custom Built Artifact

If your project is based on the [IOM Project Archetype](https://github.com/intershop/iom-project-archetype), the custom built artifact of the project is already integrated into _devenv-4-iom_.

This is done by listing the custom built artifact in _src/deployment/customization/deployment.cluster.properties_ and by providing this file and the according artifact inside the projects _Docker_ image.

## <a name="deployment_wildfly">Deployment of Custom Built Artifacts Using the Wildfly Admin Console</a>

Using the _Wildfly Admin Console_ is the easiest way to add or update deployments. The deployment process is simply triggered by drag & drop.

Unlike described in [Deployment of custom built artifacts using CLI](#deployment_cli), deployments added/updated this way, will not survive a restart of the IOM pod.

The _Wildfly Admin Console_ has to be opened in a web browser. The according URL can be found in the output of the `info iom` command.

    # Get information about IOM
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

    # Copy the 'Wildfly' link to your web browser.

## <a name="deployment_cli">Deployment of Custom Built Artifacts Using CLI</a>

To deploy custom built artifacts using _devenv-cli.sh_, you have to:

* Set the variable `CUSTOM_APPS_DIR` in your configuration file and make sure that the [directory is shared in _Docker_ Desktop](https://blogs.msdn.microsoft.com/stevelasker/2016/06/14/configuring-docker-for-windows-volumes/).
* After changing `CUSTOM_APPS_DIR`, the IOM application server needs to be restarted:
  1. [Delete IOM](03_operations.md#delete_iom)
  2. [Create IOM](03_operations.md#create_iom)

Once you have configured _devenv-4-iom_ this way, your custom built artifacts are deployed right at the start of IOM. To update/add deployments in a running developer installation of IOM, you have the following options:

    # Redeploy an artifact selectively by adding one more parameter: A regular-expression
    # to select the artifact to be redeployed.
    # The example shows how to redeploy the OMT application selectively.
    devenv-cli.sh apply deployment omt

    # Or redeploy all
    devenv-cli.sh apply deployment

Of course you can combine both methods of deploying custom built artifacts to get the best out of both methods. If you set `CUSTOM_APPS_DIR` and make sure that the according directory contains your custom built artifacts, your IOM developer installation will always use these artifacts, even right after IOM starts. Additionally, you can use the _Wildfly Admin Console_ to update/add deployments during runtime.

## Roll Out Custom Mail Templates

To roll out custom mail templates in a running _devenv-4-iom_ installation, you have to:

* Set variable `CUSTOM_TEMPLATES_DIR` in your configuration file and make sure that the [directory is shared in _Docker_ Desktop](https://blogs.msdn.microsoft.com/stevelasker/2016/06/14/configuring-docker-for-windows-volumes/).
* After changing `CUSTOM_TEMPLATES_DIR`, the IOM application server has to be restarted:
  1. [Delete IOM](03_operations.md#delete_iom)
  1. [Create IOM](03_operations.md#create_iom)

Once you have configured your IOM developer installation this way, you can apply custom mail templates by using the following command:

    devenv-cli.sh apply mail-templates

If `CUSTOM_TEMPLATES_DIR` is configured, the templates are also copied when starting IOM.

## Roll Out Custom XSL Templates

To roll out custom XSL templates in a running _devenv-4-iom_ installation, you have to:

* Set the variable `CUSTOM_XSLT_DIR` in your configuration file and make sure that the [directory is shared in _Docker_ Desktop](https://blogs.msdn.microsoft.com/stevelasker/2016/06/14/configuring-docker-for-windows-volumes/).
* After changing `CUSTOM_XSLT_DIR`, the IOM application server has to be restarted:
  1. [Delete IOM](03_operations.md#delete_iom)
  1. [Create IOM](03_operations.md#create_iom)

Once you have configured your developer VM this way, you can apply custom XSL templates by using the following command:

    devenv-cli.sh apply xsl-templates

If `CUSTOM_XSLT_DIR` is configured, the templates are also copied when starting IOM.

## <a name="apply_sql_scripts">Apply SQL Scripts</a>

The IOM _Docker_ image (defined by `IOM_IMAGE`) contains all the necessary tools to apply SQL scripts to the IOM database. _Devenv-4-iom_ enables you to use these tools as easily as possible. Therefore it provides a _Kubernetes_ job (apply-sql-job) that applies SQL file(s) to the IOM database. Creation and deletion of job and access to logs is provided by the command `apply sql-scripts` via the command line interface.

There are two different modes that can be used:

* If a directory is given, all SQL files found in this directory are processed in numerical order, starting with the lowest one. Sub-directories are not scanned for SQL files.
* If a file is given, only this file will be executed.

The information about the SQL file or directory is passed as third parameter to the command line client. The box below shows an example that executes all SQL scripts found in _oms.tests/tc_stored_procedures_ (of course, the directory has to exist in your current working directory).

The logs created by the IOM pod are provided in JSON format. Verbosity can be controlled by the configuration variable `OMS_LOGLEVEL_SCRIPTS`.

    # Adapt third parameter according your needs
    devenv-cli.sh apply sql-scripts oms.tests/tc_stored_procedures

## <a name="apply_dbmigrate">Apply DBMigrate Scripts</a>

To develop and test a single or a couple of SQL scripts (which can be migration scripts too), the developer task [Apply SQL Scripts](#apply_sql_scripts) is the first choice. However, at some point of development, the DBMigrate process as a whole has to be tested as well. The DBMigrate process is somewhat more complex than simply applying SQL scripts from a directory. It first loads stored procedures from the _stored_procedures_ directory and then applies the migrations scripts found in the _migrations_ directory. The order of execution is controlled by the names of sub-directories within _migrations_ and the naming of the migration scripts itself (numerically sorted, smallest first).

The `IOM_IMAGE` contains a shell script that applies the migration scripts supplied with the _Docker_ image. The developer task [Apply DBMigrate scripts](#apply_dbmigrate) enables you to use this DBMigrate script together with the migration scripts located at _CUSTOM_DBMIGRATE_DIR_. Hence, if you want to roll out custom DBMigrate scripts, you have to:

* Set the variable `CUSTOM_DBMIGRATE_DIR` in your configuration file and make sure that the [directory is shared in _Docker_ Desktop](https://blogs.msdn.microsoft.com/stevelasker/2016/06/14/configuring-docker-for-windows-volumes/).

You can and should have an eye on the logs created by the migration process. These logs are provided in JSON format. Verbosity can be controlled by the configuration variable `OMS_LOGLEVEL_SCRIPTS`.

    devenv-cli.sh apply dbmigrate

If `CUSTOM_DBMIGRATE_DIR` is configured, the custom DBMigrate scripts are also applied when starting IOM.

## <a name="apply_sql_config">Apply SQL Configuration Scripts</a>

Scripts for SQL configuration are simple SQL scripts that can be easily developed and tested with the help of the developer task [Apply sql scripts](#apply_sql_scripts). However, SQL configuration in a project context is more complex. E.g. the scripts are executed depending on the currently activated environment. To be able to test SQL configuration scripts exactly in the same context as in a real IOM installation, the developer task [Apply SQL Configuration Scripts](#apply_sql_config) is provided.

To be able to roll out complete SQL configurations, you have to:

* Set the variable `CUSTOM_SQLCONF_DIR` in your configuration file and make sure that the directory is shared in _Docker_ Desktop.
* Set the variable `PROJECT_ENV_NAME` in your configuration file to the environment you want to test.

You should have an eye on the logs created by the configuration process. These logs are provided in JSON format. Verbosity can be controlled by the configuration variable `OMS_LOGLEVEL_SCRIPTS`.

    devenv-cli.sh apply sql-config

If `CUSTOM_SQLCONFIG_DIR` is configured, the custom SQL configuration is also applied when starting IOM.

## Execute Custom _Wildfly-CLI_ Scripts

Project-specific properties and _Wildfly-CLI_ scripts are applied when building the project image. If you use this image within _devenv-4-iom_, the changed settings are already applied when starting IOM.

Before creating a new project image, the properties and _Wildfly-CLI_ scripts have to be tested within a running IOM. The following box shows how to execute a _Wildfly-CLI_ script in _devenv-4-iom_:

    # determine command, how to access jboss-cli.sh in running IOM pod
    devenv-cli.sh info iom
    ...
    jboss-cli: kubectl exec --namespace customerprojectiom400 --context="docker-desktop" iom-7b99d8c9df-trctc -c iom -it -- /opt/jboss/wildfly/bin/jboss-cli.sh -c
    ...

    # execute jboss-cli.sh in running IOM pod
    kubectl exec --namespace customerprojectiom400 --context="docker-desktop" iom-7b99d8c9df-trctc -c iom -it -- /opt/jboss/wildfly/bin/jboss-cli.sh -c

    # test your CLI commands
    [standalone@localhost:9990 /] ls -l /deployment
    bakery.base-app-4.0.0.ear
    bakery.communication-app-4.0.0.ear
    bakery.control-app-4.0.0.war
    bakery.impex-app-4.0.0.war
    bakery.omt-app-4.0.0.war
    gdpr-app-4.0.0.war
    oms.monitoring-app-4.0.0.war
    oms.rest.communication-app-4.0.0.war
    order-state-app-4.0.0.war
    postgresql-jdbc4
    process-app-4.0.0.ear
    rma-app-4.0.0.war
    schedule-app-4.0.0.war
    transmission-app-4.0.0.war

## <a name="load_dump">Load Custom Dump</a>

When starting IOM and the connected database is empty, the IOM pod loads the initial dump. _Devenv-4-iom_ allows you to load a custom dump during this process. This custom dump will be treated exactly as any other dump which is part of the _Docker_ image. If you want to load a custom dump, you have to:

* Set the variable `CUSTOM_DUMPS_DIR` in your configuration file and make sure that the [directory is shared in _Docker_ Desktop](https://blogs.msdn.microsoft.com/stevelasker/2016/06/14/configuring-docker-for-windows-volumes/). The dump you want to load has to be located within this directory. To be recognized as a dump, it has to have the extension _.sql.gz_. If the directory contains more than one dump file, the script to load the dump selects the one with the numerically largest name. You can check this with the following command: `ls *.sql.gz | sort -nr | head -n 1`
* The custom dump can only be loaded if the database is empty. The `dump load` command of the command line client executes all the necessary steps to restart IOM with an empty database.
  1. [Delete IOM](03_operations.md#delete_iom)
  1. [Delete Postgres database](03_operations.md#delete_postgres)
  1. [Delete Local _Docker_ Volume](03_operations.md#delete_storage), required only if `KEEP_DATABASE_DATA` is set to `true`
  1. [Create Local _Docker_ Volume](03_operations.md#create_storage), required only if `KEEP_DATABASE_DATA` is set to `true`
  1. [Create Postgres Database](03_operations.md#create_postgres)
  1. [Create IOM](03_operations.md#create_iom)
* The custom dump can only be loaded if the database is empty. When you are using an external database (`PGHOST` is set), the steps listed above will not have any effect. You must take care of purging the external database and recreating the IOM installation yourself.

You should inspect the logs to know if the dump was actually loaded. The logs of the initialization process are provided in JSON format. Verbosity can be controlled by the configuration variable `OMS_LOGLEVEL_SCRIPTS`.

    devenv-cli.sh dump load

## Create Dump

_Devenv-4-iom_ provides a job to create a dump of the IOM database. This job uses the variable `CUSTOM_DUMPS_DIR` too. It writes the dump to this directory. The created dump uses the following naming pattern: `OmsDump.<year-month-day>.<hour.minute.second>-<hostname>.sql.gz`. To create a dump, you have to:

* Set the variable `CUSTOM_DUMPS_DIR` in your configuration file and make sure that the [directory is shared in _Docker_ Desktop](https://blogs.msdn.microsoft.com/stevelasker/2016/06/14/configuring-docker-for-windows-volumes/).

You should check the output of the dump job. The logs of the job are provided in JSON format. Verbosity can be controlled by the configuration variable `OMS_LOGLEVEL_SCRIPTS`.

    devenv-cli.sh dump create

If `CUSTOM_DUMP_DIR` is configured, the latest custom dump is loaded when IOM is started with an empty database (according to the [load-rules](#load_dump)).

- - -
**Note**

_You must not set `CUSTOM_DUMPS_DIR` to a directory that does not contain a dump when starting IOM with an uninitialized database. In this case, the initialization of the database would fail since no dump to be loaded can be found. Just set `CUSTOM_DUMPS_DIR` right before creating the dump and not before starting IOM._
- - -

## Access E-Mails

To develop e-mail templates, to test whether e-mails are successfully sent by business processes and in other use cases, it is necessary to access the e-mails. The information about links to mail server UI and REST interface is given by the command `info mailserver`, provided by the command line interface.

    devenv-cli.sh info mailserver

## Access PDF Documents

PDF documents are stored within the shared file system of IOM. To get easy access to the content of the shared file system, you have to:

* Set the variable `CUSTOM_SHARE_DIR` in your configuration file and make sure that the [directory is shared in _Docker_ Desktop](https://blogs.msdn.microsoft.com/stevelasker/2016/06/14/configuring-docker-for-windows-volumes/).
* After changing `CUSTOM_SHARE_DIR`, the IOM application server has to be restarted:
  1. [Delete IOM](03_operations.md#delete_iom)
  1. [Create IOM](03_operations.md#create_iom)

After that, you will have direct access to IOMs shared file system through the directory you have set for `CUSTOM_SHARE_DIR`.

## Testing in Context of IOM Product Development

The processes described in this section are specific for IOM product development. Nevertheless, the concept can be adapted in context of projects as well. The tasks of _devenv-4-iom_ in context of testing are very simple:

* Execute SQL scripts to prepare test data or the test environment.
* Provide property files, containing information on how to access the database and the web GUI of IOM.

The tests and the test framework (in case of IOM this is _[Geb](https://gebish.org/) / [Spock](http://spockframework.org/)_) are part of the IOM product sources. In context of projects, this has to be handled the same way. Tests and according framework have to be defined by the project. The tests can then use the property-files provided by _devenv-4-iom_ to access the IOM developer installation.

### Apply Test-specific Stored Procedures

To apply stored procedures, simply use the command [`apply sql-scripts`](#apply_sql_scripts) and set the parameter to the directory containing the stored procedures required for testing.

    # oms.tests has to exist in the current working directory
    devenv-cli.sh apply sql-scripts oms.tests/tc_stored_procedures

### Run Single Geb Test or a Group of Geb Tests

To run a single test, use the feature name or a substring of it. E.g:

    # Make sure that geb.properties reflects the latest version of configuration
    devenv-cli.sh get geb-props > geb.properties

    # Go to the oms.tests directory in your oms source directory
    # PATH_TO_IOM_SOURCES and PATH_TO_GEB_PROPERTIES have to be replaced by real values.
    cd ${PATH_TO_IOM_SOURCES}/oms.tests

    # Run a single Geb test
    ./gradlew gebTest -Pgeb.propFile=${PATH_TO_GEB_PROPERTIES}/geb.properties --tests="IOM: Role Assignment Management: admin_Oms_1 lists users for role-assignment"

    # Run a group of Geb tests
    ./gradlew gebTest -Pgeb.propFile=${PATH_TO_GEB_PROPERTIES}/geb.properties --tests="*admin_Oms_1 lists users for role-assignment*"

### Run Single ws Tests or a Group of ws Tests

To run a single test, use the the feature name or a substring of it. E.g:

    # Make sure that ws.properties reflects the latest version of configuration
    devenv-cli.sh get ws-props > ws.properties

    # Go to the oms.tests directory in your oms source directory
    # PATH_TO_IOM_SOURCES and PATH_TO_WS_PROPERTIES have to be replaced by real values.
    cd ${PATH_TO_IOM_SOURCES}/oms.tests

    # Run a single ws test
    ./gradlew wsTest -Pws.propFile=${PATH_TO_WS_PROPERTIES}/ws.properties --tests="IOM-7421-1: OrderService v1.2: Create an order with one position and billing address == shipping address"

    # Run a group of ws tests
    ./gradlew wsTest -Pws.propFile=${PATH_TO_WS_PROPERTIES}/ws.properties --tests="*OrderService v1.2: Create an order with one position and billing address*"

### Run all All Tests of a Specification

To run all tests of a specification, use the name of the specification. E.g:

    # Go to the oms.tests directory in your oms source directory
    # PATH_TO_IOM_SOURCES, PATH_TO_GEB_PROPERTIES and PATH_TO_WS_PROPERTIES have to be replaced by real values.
    cd ${PATH_TO_IOM_SOURCES}/oms.tests

    # Run all tests of a Geb test specification
    ./gradlew gebTest -Pgeb.propFile=${PATH_TO_GEB_PROPERTIES}/geb.properties --tests="*RoleAssignmentManagementListUsersSpec*"

    # Run all tests of a ws test specification
    ./gradlew wsTest -Pws.propFile=${PATH_TO_WS_PROPERTIES}/ws.properties --tests="*ReverseServiceSpec*"

### Run All Tests of a Group of Specifications (e.g. User Management, Role Management)

To run all tests of a group of specifications, just use the name of the used package. E.g:

    # Go to the oms.tests directory in your oms source directory
    # PATH_TO_IOM_SOURCES and PATH_TO_GEB_PROPERTIES have to be replaced by real values.
    cd ${PATH_TO_IOM_SOURCES}/oms.tests

    # Run all tests of a specification group
    ./gradlew gebTest -Pgeb.propFile=${PATH_TO_GEB_PROPERTIES}/geb.properties --tests="*com.intershop.oms.tests.roleassignment*"

### Run SOAP tests

To run all SOAP tests, use the following method:

    # Make sure that soap.properties reflects the latest version of configuration
    devenv-cli.sh get soap-props > soap.properties

    # Go to the oms.soap.tests directory in your oms source directory
    # PATH_TO_IOM_SOURCES an PATH_TO_SOAP_PROPERTIES have to be replaced by the real values.
    cd ${PATH_TO_IOM_SOURCES}/oms.soap.tests

    # Run all SOAP tests
    mvn -Dhost=$(cat "${PATH_TO_SOAP_PROPERTIES}/soap.properties") clean test

---
[< Operations](03_operations.md) | [^ Index](../README.md) | [Log Messages >](05_log_messages.md)
