# Overview

_devenv-4-iom_ provides all the tools that are required to configure and run an IOM development instance in your local _Kubernetes_ cluster.

The following chapters provide a detailed insight into various aspects of installing and using _devenv-4-iom_.
- [Installation](doc/00_installation.md)
- [First steps](doc/01_first_steps.md)
- [Configuration](doc/02_configuration.md)
- [Azure DevOps Integration](doc/03_devops_integration.md)
- [Operations](doc/04_operations.md)
- [Development process](doc/05_development_process.md)
- [Log messages](doc/06_log_messages.md)
- [Metrics](doc/07_metrics.md)
- [Troubleshooting](doc/08_troubleshooting.md)

If _devenv-4-iom_ is already installed and you are looking for a short overview about features, please use the integrated help. To do so, call `devenv-cli.sh` with parameter `-h` or `--help`:

```
    devenv-cli.sh -h
```
# Compatibility

The latest versions of _devenv-4-iom_ and IOM are always compatible with each other. As long as not noted otherwise, _devenv-4-iom_ is backward
compatible with all versions of IOM >= 3.0. For best experience, always use the latest version of _devenv-4-iom_, regardless of the IOM version
you are currently using. To do so, please update _devenv-4-iom_ as often as possible.

There exists no backward compatibility the other way around. There is no information available, which version of _devenv-4-iom_ is required by
a certain version of IOM.

# Release information 2.6.0

### Access to Documentation of SOAP- and REST-APIs <!-- #92163 -->

The `info iom` command was extended to provide the url, that gives access to the documentation of IOMs SOAP- and REST-APIs. An according section
was added to the document, describing the [Development process](doc/05_development_process.md).

# Release information 2.5.0

## New Features

### Implementation of mail-server was replaced <!-- #93089 -->

The oudated mail-server _mailhog_ was replaced by [_mailpit_](https://mailpit.axllent.org). The _devenv.project.properties_ file, belonging to your project, has to be migrated according to the
[documentation](doc/02_configuration.md#migrate-a-configuration-after-updating-devenv-4-iom).

### Support for sending Metrics to an _OpenTelemetry Collector_ compatible endpoint <!-- 93088 -->

The new property *OTEL_COLLECTOR* was added. A new [documentation chapter](doc/07_metrics.md) explains the usage.

### Support for version information <!-- 80982 -->

The new command line switch _-v_ provides now the version of _devenv-4-iom_.

### Support for Cache-Reset <!-- 81950 -->

The new command *apply cache-reset* allows to trigger a reset of IOMs configuration cache. This cache reset
is now also applied automatically after deployment or configuration changes, executed by _devenv-4-iom_.

### Improved documentation

* Added documentation how to [access the PostgreSQL database](doc/05_development_process.md#access-postgresql-database) <!-- 81066 -->
* Added documentation about how to [handle custom configurations](doc/05_development_process.md#apply-custom-configurations) that are not directly supported by _devenv-4-iom_. <!-- 81066 -->

## Fixed Bugs

* _deploy <pattern>_ succeeds if the pattern has not matched any deployment artifact. <!-- 79162 -->
* commands executed by _devenv-4-iom_ inside the IOM pod are now running interactively, in order to make sure that ~/.bashrc inside the container is read. <!-- 84293 -->

# Release information 2.4.0

## New Features

### Support for Single-Sign-On (SSO) <!-- 79686 -->

Three new properties have been added to support configuration of SSO for IOM development:
* *SSO_ENABLED*: allowed values are *true*|*false*.
* *SSO_TYPE*: allowed values are *azure-ad*|*keycloak*.
* *SSO_OIDC_CONFIG*: holds a JSON structure similar to *oidc.json*, see: [Elytron OpenID Connect Client Subsystem Configuration](https://docs.wildfly.org/26/Admin_Guide.html#Elytron_OIDC_Client)

# Release Information 2.3.0

## New Features

### Support for Multiple Image Pull Secrets <!-- 79173 -->

Property *IMAGE_PULL_SECRET* can now hold a list of image pull secrets. The different secrets have to be separated by comma.

### Documentation of Azure DevOps Integration <!-- 78770 -->

A new chapter has been added to the documentation that describes the integration of _devenv-4-iom_ into *Azure DevOps Environment*.

# Release Information 2.2.0

## New Features

### Documentation, Comments, and Default Values Have Been Adapted for New Intershop Docker Registry <!-- 77974 -->

Intershop provides Docker images of their products now on _docker.tools.intershop.com_. All documentation, comments, and default values have been changed to use this new server.

## Migration Notes

### Default Value of _DB_ACCOUNT_IMAGE_ Has Been Changed <!-- 77974 -->

The Docker repository that is used by the default value of DB_ACCOUNT_IMAGE has been changed to _docker.tools.intershop.com_. Since this repository requires authorization to access its images, a new Pull-Secret has to be created (see chapter [Accessing in Private Docker Registry](docs/04_development_process.md#accessing-a-private-docker-registry)).

# Release Information 2.1.0

## New Features

### Support for Bash Completion <!-- 77729 -->

_devenv-4-iom_ now supports bash completion. In order to use this new feature, the according completion script has to be installed, see [documentation of installation](doc/00_installation.md).

### Support for IOM Test Framework <!-- 75996 -->

When starting the IOM application server (`create iom`), a file _testframework-config.user.yaml_ is created within the project root directory, containing all necessary information to run local tests based on [IOM Test Framework](https://github.com/intershop/iom-test-framework). Along with support for this file, one new configuration property has been added: _CREATE_TEST_CONFIG_, which controls the creation of the configuration file.

# Release Information 2.0.5

## New Features

### Support for Single Image Distribution of IOM <!-- 71327 -->

IOM 4.0 has changed the distribution model. Instead of providing IOM in form of two _Docker_ images (_iom-app_, _iom-config_), IOM 4.0 now consists of a single image only (plus the _iom-dbaccount_ image, which is not directly part of the IOM release).

To define the (single) IOM image to be used, the new configuration variable `IOM_IMAGE` has been added. The two configuration variables `IOM_CONFIG_IMAGE` and `IOM_APP_IMAGE` still exist and must be used when using _devenv-4-iom_ with IOM prior version 4.

If `IOM_IMAGE` contains a value, the content of `IOM_CONFIG_IMAGE` and `IOM_APP_IMAGE` will be ignored.

### Configuration Concept Has Changed for Easier Integration Into Projects <!-- 70641 -->

The configuration of _devenv-4-iom_ is now split into two parts, a project-specific one and one for user-related configurations. This makes it very easy to maintain the configuration of _devenv-4-iom_ centrally along with the project code. Users should only define configuration variables that they want to override.

To enable central maintenance of the project-specific properties file, it is now possible to define relative paths for `CUSTOM_*_DIR` configuration variables.

For more information, see [Configuration](doc/02_configuration.md).

### Kubernetes Context Is Part of Configuration Now <!-- 73923 -->

Before _devenv-4-iom 2.0.0_ the current default _Kubernetes_ context was always used.
When working with different _Kubernetes_ clusters, it could happen that operations were accidentally executed on the wrong cluster.

To avoid such cases, the new configuration variable `KUBERNETES_CONTEXT` has been added, having the default value _docker-desktop_.

From now on _devenv-4-iom_ uses the configured _Kubernetes_ context in any case.

### WSL2 Is Supported Now <!-- 60376 -->

WSL2 (Windows Subsystem for Linux 2) can now be used along with _devenv-4-iom_. To do so, the new configuration variable `MOUNT_PREFIX` has been added, which has to be set to `/run/desktop/mnt/host` when using WSL2.

### Usage of SQL Hashes Is Configurable Now <!-- 73739 -->

IOM uses hash-values of directories containing SQL files to determine whether a database-initialization step has been already performed or not. The hash-values are determined when creating the images (IOM-product and IOM-project image). _devenv-4-iom_ is able to overrule database-initialization settings made in the images, by defining `CUSTOM_DBMIGRATE_DIR`, `CUSTOM_SQLCONF_DIR`, `CUSTOM_JSONCONF_DIR`. Since these configurations do not affect the hash-values stored within the image, the usage of SQL hashes has been switched off prior to version 2 of _devenv-4-iom_, without an option to enable it.

However, there are some use cases in the context of IOM product development that make it necessary to enable usage of SQL hashes in _devenv-4-iom_. For this reason, the new configuration variable `OMS_DB_SQLHASH` has been added, which defaults to `false`.

### PostgreSQL Session Is Now Included in Database Server Logs <!-- 70390 -->

The configuration of PostgreSQL-server has been changed so that the PostgreSQL session is now part of the server logs. This information is important when investigating _deadlock_ messages.

### _devenv-4-iom_ Logs Are in Human Readable Format Now <!-- 70998 -->

Prior to version 2, devenv-4-iom printed all messages in JSON format. This has changed to a human readable multi-line format. Please note that this change does not affect the log messages from IOM itself. These messages will still be printed in JSON format.

## Migration Notes

### Configuration File Has to Be Split and Renamed <!-- 70641 -->

The configuration of _devenv-4-iom_ is now split into two files, a project-specific configuration file and another one that allows the user to override certain values. Location and naming of different configuration files now have to match some certain rules. Please refer to [Configuration](doc/02_configuration.md) to find all the necessary details.

### `CAAS_*` Configuration Variables are Renamed to `PROJECT_*` <!-- 70362 -->

The following configuration variables have been renamed:

* `CAAS_ENV_NAME` -> `PROJECT_ENV_NAME`
* `CAAS_IMPORT_TEST_DATA` -> `PROJECT_IMPORT_TEST_DATA`
* `CAAS_IMPORT_TEST_DATA_TIMEOUT` -> `PROJECT_IMPORT_TEST_DATA_TIMEOUT`

Only the names have changed, the meaning of the configuration variables remains unchanged.

### Documentation is Part of the Source Repository Now <!-- 71048 -->

The documentation of _devenv-4-iom_ prior to version 2 was separately published from the tool itself in the [_Intershop Knowledgebase_](https://support.intershop.com/kb/29Z730). This also applied for the release communication, see [_Intershop Knowledgebase_](https://support.intershop.com/kb/283D59).

Documentation and release communication are now part of the source repository. Current documentation will not be available in the [_Intershop Knowledgebase_](https://support.intershop.com/kb/index.php) anymore.

## Fixed Bugs

* Information about services was missing in output of *info*-commands <!-- 76951 -->
* Error if `CUSTOM_*_DIR` contains .. <!-- 71396 -->
* Error if `CUSTOM_SHARE_DIR` does not exist <!-- 71396 -->
* Error executing "apply sql-config" when IOM image is provided by a private Docker-registry <!-- 74659 -->
* Error using persistent storage with current version of Docker-Desktop <!-- 77223 -->
* Replaced outdated documentation references <!-- 77268 -->
* Error applying environment specific SQL-config <!-- 77554 -->
* Abbrevations of commands were not tested strictly to match the requested command <!-- 77544 -->
