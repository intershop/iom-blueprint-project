# Overview

_devenv-4-iom_ provides all the tools that are required to configure and run an IOM development instance in your local _Kubernetes_ cluster.

The following chapters provide a detailed insight into various aspects of installing and using _devenv-4-iom_.
- [Installation](doc/00_installation.md)
- [First steps](doc/01_first_steps.md)
- [Configuration](doc/02_configuration.md)
- [Operation](doc/03_operations.md)
- [Development process](doc/04_development_process.md)
- [Log messages](doc/05_log_messages.md)
- [Troubleshooting](doc/06_troubleshooting.md)

If _devenv-4-iom_ is already installed and you are looking for a short overview about features, please use the integrated help. To do so, call `devenv-cli.sh` with parameter `-h` or `--help`:

```
    devenv-cli.sh -h
```

# Release Information 2.0.4

## Compatibility

At the time of release of _devenv-4-iom_, it is compatible with the latest version of IOM. As long as there is no new release of _devenv-4-iom_, it is ensured, that new releases of IOM are compatible with _devenv-4-iom_. If a new version of IOM requires an update of _devenev-4-iom_, the release notes of IOM will contain an according statement.

At the time of writing, _devenv-4-iom 2.0.4_ is compatible with all IOM versions between 3.0 and 4.1 (inclusive).

## New Features

### Support for Single Image Distribution of IOM <!-- 71327 -->

IOM 4.0 has changed the distribution model. Instead of providing IOM in form of two _Docker_ images (_iom-app_, _iom-config_), IOM 4.0 now consists of a single image only (plus the _iom-dbaccount_ image, which is not directly part of the IOM release).

To define the (single) IOM image to be used, the new configuration variable `IOM_IMAGE` was added. The two configuration variables `IOM_CONFIG_IMAGE` and `IOM_APP_IMAGE` still exist and must be used when using _devenv-4-iom_ with IOM prior version 4.

If `IOM_IMAGE` contains a value, the content of `IOM_CONFIG_IMAGE` and `IOM_APP_IMAGE` will be ignored.

### Configuration Concept Has Changed for Easier Integration into Projects <!-- 70641 -->

The configuration of _devenv-4-iom_ is now split into two parts, a project-specific one and one for user-related configurations. This makes it very easy to maintain the configuration of _devenv-4-iom_ centrally along with the project code. Users should only define configuration variables that they want to override.

To enable a central maintanance of the project-specific properties-file, it is now possible to define relative paths for `CUSTOM_*_DIR` configuration variables.

For more information, see [Configuration](doc/02_configuration.md).

### Kubernetes Context Is Part of Configuration Now <!-- 73923 -->

Before _devenv-4-iom 2.0.0_, the current default _Kubernetes_ context was always used.
When working with different _Kubernetes_ clusters, it could happen that operations were accidentally executed on the wrong cluster.

To avoid such cases, the new configuration variable `KUBERNETES_CONTEXT` was added, having the default value _docker-desktop_.

From now on _devenv-4-iom_ uses the configured _Kubernetes_ context in any case.

### WSL2 Is Supported Now <!-- 60376 -->

WSL2 (Windows Subsystem for Linux 2) can now be used along with _devenv-4-iom_. To do so, the new configuration variable `MOUNT_PREFIX` was added, which has to be set to `/run/desktop/mnt/host` when using WSL2.

### Usage of SQL Hashes Is Configurable Now <!-- 73739 -->

IOM uses hash-values of directories containing SQL files to determine whether a database-initialization step was already performed or not. The hash-values are determined when creating the images (IOM-product and IOM-project image). _devenv-4-iom_ is able to overrule database-initialization settings made in the images, by defining `CUSTOM_DBMIGRATE_DIR`, `CUSTOM_SQLCONF_DIR`, `CUSTOM_JSONCONF_DIR`. Since these configurations do not affect the hash-values stored within the image, the usage of SQL hashes was switched off prior version 2 of _devenv-4-iom_, without an option to enable it.

However, there are some use cases in the context of IOM product development that make it necessary to enable usage of SQL hashes in _devenv-4-iom_. For this reason, the new configuration variable `OMS_DB_SQLHASH` was added, which defaults to `false`.

### PostgreSQL Session Is Now Included in Database Server Logs <!-- 70390 -->

The configuration of PostgreSQL-server has been changed so that the PostgreSQL session is now part of the server logs. This information is important when investigating _deadlock_ messages.

### _devenv-4-iom_ Logs Are in Human Readable Format Now <!-- 70998 -->

Prior to version 2, devenv-4-iom printed all messages in JSON format. This has changed to a human readable multi-line format. Please note that this change does not affect the log messages from IOM itself. These messages will still be printed in JSON format.


## Migration Notes

### Configuration File Has to Be Split and Renamed <!-- 70641 -->

The configuration of _devenv-4-iom_ is now split into two files, a project-specific configuration file and another that allows the user to override certain values. Location and naming of the different configuration files are now have to match some certain rules. Please refer to [Configuration](doc/02_configuration.md) to find all the necessary details.

### `CAAS_*` Configuration Variables are Renamed to `PROJECT_*` <!-- 70362 -->

The following configuration variables were renamed:

* `CAAS_ENV_NAME` -> `PROJECT_ENV_NAME`
* `CAAS_IMPORT_TEST_DATA` -> `PROJECT_IMPORT_TEST_DATA`
* `CAAS_IMPORT_TEST_DATA_TIMEOUT` -> `PROJECT_IMPORT_TEST_DATA_TIMEOUT`

Only the names have changed, the meaning of the configuration variables remain unchanged.

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