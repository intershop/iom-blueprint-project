# Configuration
## <a name="concept_config"/>General Concept

_devenv-4-iom_ uses property files for configuration. A configuration might be split into two property files or may be provided within a single file.

Splitting a configuration into two files is a measure to lower configuration efforts and to centralize the management of configurations. This approach is intended to be used in context of projects. A global, project-specific property file should be part of the project. This file has to be managed centrally. Whenever the project changes in a way, that _devenv-4-iom_ is affected too, the centrally managed property file has to reflect the according change. This way the project members (except the one, who is maintaining the project specific configuration) do not need to care about such changes.

Additionally, every project member should have the ability to adapt the configuration of _devenv-4-iom_, without the need to change the project wide settings. Therefore a second property file is required, which has higher precedence. In this file, a user can define all properties, that should overwrite project wide settings.

### Lookup of user specific configuration

There are two possibilities to set a user specific configuration file. First, the name of the property file might be passed as first parameter to `devenv-cli.sh`. In this case, the user specific configuration file might have any name.

If no property file is given at the command line, `devenv.user.properties` in current directory is used as user specific configuration of _deven-4-iom_.

### Lookup of project specific configuration

The project specific configuration file has always the fixed name `devenv.project.properties`. It is looked up on two positions in this order:
1. It is searched within the same directory, where the user specific configuration file was found.
2. It is searched in the current working directory.

If no configuration file could be found at all, `devenv-cli.sh` ends with an error.

### Check configuration

Due to different configuration files with different lookup rules and different precedences, a mechanism is required to check the effective configuration, which will be used by _devenv-4-iom_. The command `info config` is intended to do such checks. It was already intorduced by the [check of configuration within the _first steps_ example](01_first_steps.md#check_config).

## <a name="create_project_config"/>Create a New Project Configuration

The creation of a new project configuration file consists of these steps:

1. Create a new configuration file based on the template provided by _devenv-4-iom_. Make sure that there is currently no other configuration file used.
1. Set `ID` in the newly created configuration file to an unique value.
1. Adapt all other entries in the configuration file according your requirements.

`ID` has no default value. It is required to mark _Kubernetes_ and _Docker_ resources as being associated with a certain configuration. Each configuration has to have its own unique `ID`. To avoid damages of existing developer installations of IOM, caused by use of a duplicated `ID`, this property is initially empty and has to be filled manually.

    # Create a new configuration file that contains default values only.
    # --skip-config switch indicates, that any existing configuration has to be ignored.
    devenv-cli.sh get config --skip-config > devenv.project.properties
    
    # Set ID to a unique value and adapt other values according your needs.
    vi devenv.project.properties

## Create a New User Configuration

A user specific configuration of _devenv-4-iom_ should only be used to override some specific properties of the project wide configuration. For this reason, it should only contain these properties and nothing else. Otherwise the benefits of a centrally maintained project specific configuration of _devenv-4-iom_ would disappear. The user specific configuration would simply overrule any settings of the project specific configuration.

Therefore, user specific configurations of _devenv-4-iom_ should never be based on the predefined templates. They should always be curated manually.

    # define the properties, you want to override
    vi devenv.user.properties

## <a name="change_config"/>Change Configuration Values

Changing a value in the configuration file does not automatically change the according developer instance of IOM. The only process guaranteeing that changes are applied, is the complete recreation of the IOM installation.

    # Change configuration file
    vi devenv.user.properties
    
    # Delete the whole IOM cluster
    devenv-cli.sh delete cluster

    # Create the IOM cluster
    devenv-cli.sh create cluster

## <a name="reset_config_partially"/>Reset Project Configuration Partially

If you want to reset the whole configuration, simply create a new one and set the `ID` within the properties file to the old value (see section [Create a New Project Configuration](#create_project_config)).

To reset only parts of the configuration, just delete the according entries from your properties file. Now create a new one, but make sure the old project configuration is used during this process. In this case, only the missing/empty properties are filled with default values in the new configuration file.

Make sure, not to accidentally overwrite project specific values, that are redefined in your personal settings. To do so, option --skip-user-config has to be set.

It's impossible to redirect the updated configuration directly into the configuration file, since the _redirect_ operator will empty the file before `devenv-cli.sh` is able to read it. This way, you would loose your old configuration, before it can be taken over into the new one.

    # Remove entries from the configuration file that should be filled with default values.
    vi devenv.project.properties
    
    # Create a new configuration file based on the old one.
    # Ignore any settings, defined in you user specific configuration file
    devenv-cli.sh get config --skip-user-config > new.devenv.project.properties
        
    # backup the old and activate the new configuration
    mv -nv devenv.project.properties devenv.project.properties.bak
    mv -nv new.devenv.project.properties devenv.project.properties
    
    # Check the reseted entries and change them according to your requirements.
    vi devenv.project.properties

## Parallel Instances of _devenv-4-iom_ Environments

Running different IOM installations within _devenv-4-iom_ is no problem as long as they are not running simultaneously. Just run `delete cluster` on one installation before running `create cluster` on another.

Different IOM installations are perfectly isolated by different namespaces on _Kubernetes_ level. Precondition is the usage of unique `ID`s in each configuration (see section [Create a New Project Configuration](#create_project_config)). However, when it comes to the operating system level of your host machine the ports collide, which are required to access the IOM installation from the outside.

_devenv-4-iom_ provides a simple mechanism to avoid port collisions. The configuration variable `INDEX` controls the port usage when providing services at OS level. Just make sure that every IOM configuration uses a different value for `INDEX`. After change of `INDEX` value, you have to delete and create the cluster (see section [Change Configuration Values](#change_config)).

## Migrate a Configuration After Updating _devenv-4-iom_

After updating _devenv-4-iom_, the content of the current configuration file has to be updated too. The new version of _devenv-4-iom_ might bring a new template for configuration files, which may contain new properties or improved comments. You have to create a new configuration file based on this template, which is filled with your current configuration. To do so, just create a new project specific configuration file. Make sure your current project configuration is used during this process, but not your user specific configuration (see section [Reset Project Configuration Partially](#reset_config_partially)).

    # Create a new configuration file based on the old one
    devenv-cli.sh get config --skip-user-config > migrated.devenv.project.properties
    
    # backup the old and activate the migrated configuration
    mv -nv devenv.project.properties devenv.project.properties.bak
    mv -nv migrated.devenv.project.properties devenv.project.properties
    
    # Check the migrated configuration file for new properties and change them according to your requirements.
    vi devenv.project.properties

    # Finally, adapt your user specific configuration manually
    vi devenv.user.properties
    
## <a name="delete_config"/>Delete a Configuration

Before deleting a configuration file, you must ensure that all associated _Kubernetes_ and _Docker_ resources are deleted as well. You will not be able to delete them using `devenv-cli.sh` afterwards. Executing `delete cluster` and `delete storage` will remove all resources assigned to a configuration. Additionally, it is recommended to delete unused _Docker_ images as well.

    # Delete IOM cluster
    devenv-cli.sh delete cluster
    
    # Delete storage
    devenv-cli.sh delete storage
    
    # Now the configuration files can be deleted
    rm devenv.project.properties devenv.user.properties
    
    # Clean up unused Docker images (cleans up all unused images, not only the ones related to the current configuration)
    docker system prune -a -f

If you have accidentally removed a configuration file before deleting the according _Kubernetes_ and _Docker_ resources, you have to cleanup these resources manually. Section [Manual Cleanup in chapter _Troubleshooting_](06_troubleshooting.md#manual_cleanup) describes this process in detail.

---
[< First Steps](01_first_steps.md) | [^ Index](../README.md) | [Operations >](03_operations.md)