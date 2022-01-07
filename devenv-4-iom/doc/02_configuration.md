# <a name="create_config"/>Create an New Configuration

_devenv-4-iom_ uses a very simple concept to manage developer instances of IOM. One configuration file holds all the information required to run one instance of IOM. Along the many configuration values required to control the behavior of IOM, there is one property which is required to mark Kubernetes and Docker resources as being associated with a certain configuration. This property is the `ID`. Each configuration has to have its own unique `ID`. Hence, the creation of a new configuration file consists of these steps:

1. Create a new configuration file based on the template provided by _devenv-4-iom_. Make sure that there is currently no other configuration file used.
1. Set `ID` in the newly created configuration file to a unique value.
1. Adapt all other entries in the configuration file according your requirements.

TODO: code cannot follow a list

    # Make sure no other configuration file is currently used.
    export DEVENV4IOM_CONFIG=
    
    # Create a new configuration file that contains default values only.
    devenv-cli.sh get config > config.properties
    
    # Set ID to a unique value and adapt other values according your needs.
    vi config.properties

# Link Configuration to `devenv-cli.sh`

`devenv-cli.sh` is used to control your IOM developer instances. Therefore the configuration has to be passed on each call of this script. There are two different ways to link `devenv-cli.sh` to a certain configuration:

1. The configuration file can be passed as first parameter of the command line.
2. The configuration file can be set in the environment variable `DEVENV4IOM_CONFIG`.

In case both methods are used at once, the configuration file passed on the command line has precedence.

    # Provide the absolute name of configuration file in DEVENV4IOM_CONFIG
    export DEVENV4IOM_CONFIG="$(pwd)/config.properties"
    
    # devenv-cli.sh will now use the config defined by the environment variable
    devenv-cli.sh info iom
    
    # Or set configuration file as first parameter at the command line
    devenv-cli.sh another-config.properties info iom
    
# <a name="change_config"/>Change Configuration Values

Changing a value in the configuration file does not automatically change the according developer instance of IOM. The only process guaranteeing that changes are applied is the complete recreation of the IOM installation.

    # Change configuration file
    vi config.properties
    
    # Delete the whole IOM cluster
    devenv-cli.sh delete cluster

    # Create the IOM cluster
    devenv-cli.sh create cluster

# <a name="reset_config_partially"/>Reset Configuration Partially

If you want to reset the whole configuration, simply create a new one and set the `ID` within the properties file to the old value (see section [Create an New Configuration](#create_config)).

To reset only parts of the configuration, just delete the according entries from your configuration file. Now create a new configuration file, but make sure the old configuration is used during this process. In this case, only the missing/empty properties of the old configuration are filled with default values in the new configuration file.

    # Remove entries from the configuration file that should be filled with default values.
    vi config.properties
    
    # Create a new configuration file based on the old one.
    devenv-cli.sh config.properties get config > new-config.properties
    
    # Check the reset entries and change them according to your requirements.

# Parallel Instances of _devenv-4-iom_ Environments

Running different IOM installations within _devenv-4-iom_ is no problem as long as they are not running simultaneously. Just run _delete cluster_ on one installation before running _create cluster_ on another.

Different IOM installations are perfectly isolated by different namespaces on Kubernetes level. Precondition is the usage of unique `ID`s in configurations (see section [Create an New Configuration](#create_config)). However, when it comes to the operating system level of your host machine, the ports required to access the IOM installation from the outside collide.

_devenv-4-iom_ provides a simple mechanism to avoid port collisions. The configuration variable `INDEX` controls the port usage when providing services at OS level. Just make sure that every IOM configuration uses a different value for `INDEX`. After each change of `INDEX` you have to delete and create the cluster (see section [Change Configuration Values](#change_config)).

# Migrate a Configuration After Update of _devenv-4-iom_

After updating _devenv-4-iom_, the content of the current configuration file has to be updated too. The new version of _devenv-4-iom_ might bring a new template for configuration files, which may contain new properties or improved comments. You have to create a new configuration file based on this template, which is filled with your current configuration. To do so, just create a new configuration file, but make sure your current configuration is used during this process (see section [Reset Configuration Partially](#reset_config_partially)).

    # Create a new configuration file based on the old one
    devenv-cli.sh config.properties get config > migrated-config.properties
    
    # Check the migrated configuration file for new properties and change them according to your requirements.
    vi migrated-config.properties

# <a name="delete_config"/>Delete a Configuration

Before deleting a configuration file, you must ensure that all associated Kubernetes and Docker resources are deleted as well. You will not be able to delete them using `devenv-cli.sh` afterwards. Executing _delete cluster_ and _delete storage_ will remove all resources assigned to a configuration. Additionally, it is recommended to delete unused Docker images as well.

    # Delete IOM cluster
    devenv-cli.sh delete cluster
    
    # Delete storage
    devenv-cli.sh delete storage
    
    # Now the configuration file can be deleted
    rm config.properties
    
    # Do not forget to unset the environment variable pointing to the configuration file
    export DEVENV4IOM_CONFIG=
    
    # Clean up unused Docker images (cleans up all unused images, not only the ones related to the current configuration)
    docker system prune -a -f

If you have accidentally removed a configuration file before deleting the according Kubernetes and Docker resources, you have to cleanup these resources manually. Section [Manual Cleanup in Troubleshooting](06_troubleshooting.md#manual_cleanup) describes this process in detail.