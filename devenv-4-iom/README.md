# Introduction
The purpose of this document is to describe how to set up _devenv-4-iom_. It provides you with all the tools and documentation that is required to run _IOM_ in a _Kubernetes_ environment with special support for typical developer tasks.

# Prerequisites
In order to work with _devenv-4-iom_ on your host machine, the installation of some additional tools is required.

## Bash
### Windows
1. Install Git Bash (comes with [Git for Windows](https://gitforwindows.org/)).
2. Use Git Bash in VS Code, see [Integrated Terminal](https://code.visualstudio.com/docs/editor/integrated-terminal#_configuration) in the Visual Studio Code documentation.
3. Open settings in C:\Users\myuser\AppData\Roaming\Code\User\seetings.json and add the following line:
   
   ```json
   // enable Git Bash in Visual Studio Code
   "terminal.integrated.shell.windows": "C:\\Program Files\\Git\\bin\\bash.exe"
   ```
If you are not able to locate _settings.json_, see [User and Workspace Settings](https://code.visualstudio.com/docs/getstarted/settings) in the Visual Studio Code documentation.
### Mac OS X
Bash is part of Mac OS X, there is nothing to do.

## Docker-Desktop
### Windows
To install [Docker Desktop](https://www.docker.com/products/docker-desktop), perform the following steps:  
 **Optional** -Define an alternate installation location to spare place on C. e.g. (cmd as Admin) mklink /J "C:\Program Files\Docker" "D:\myssdalternateprogramlocation\Docker"  
    - (see https://forums.docker.com/t/docker-installation-directory/32773/7)  
    - troubelshooting, deinstallation: https://github.com/docker/for-win/issues/1544  
> **Caution:** While installing you will be signed-out without further acknowledgements and your PC will probably be restarted. So save everything before installing.

1. Start _Docker Desktop_ by clicking the _Docker Desktop_ shortcut.
2. In the context bar (bottom right on Windows Desktop), right-click on the Docker icon.
3. Select _Settings_. 

   The modal for settings of _Docker Desktop_ is displayed.   


4. Adjust the following settings:
    - _Settings > Resources > Advanced_
       - CPUs: 3
       - Memory: 8192
       - _**Apply**_
    - _Settings > Kubernetes_
       - _Enable Kubernetes_
       - _**Apply**_
    - _Settings > Resources > File Sharing_
       - Share drives that should be available for Kubernetes. You should share the drive, that is holding the IOM sources, as well as the drive with the configurations of _devenv-4-iom_.
       - _**Apply**_
5. **Optional** - Move your _Docker Desktop VM_ to the desired device:
     1. Stop _Docker Desktop_.
     2. Start _Hyper-V Manager_.
     3. Select your PC in the left hand pane.
     4. Right-click on the correct virtual machine (e.g.DockerDesktopVM).
     5. Select _Turn off_ if it is running.
     6. Right-click on it again and select _Move_.
     7. Follow the prompts and move (e.g. _D:\virtualization\Hyper-V_).
     8. In Docker, go to _Settings > Advanced_.
     9. Change _Disk image location_ (e.g. to D:\virtualization\Hyper-V\Virtual Hard Disks).
     10. Click _**Apply**_.

> **Note:** After resetting your password you might experience problems with your shared drives. In those cases use _Settings > Shared Drives > Reset credentials_.

### Mac OS X
1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop).
2. Enable _Docker Desktop version of Kubernetes_.
    - To do so click _Docker Icon > Kubernetes > docker-desktop_.
3. Check file-sharing. Your home directory should be shared (if you are using it to hold configurations of _deven-4-iom_, IOM sources, etc).
    - To do so click _Docker Icon > Preferences > File Sharing_.
4. Set CPU and memory usage. When running a single IOM instance in Docker-Desktop you need to assign 2 CPUs and 10 GB memory.
    - To do so click _Docker Icon > Preferences > Advanced_.

## jq - Command-Line JSON Processor
_jq_ is a command-line tool that allows to work with JSON messages. Since all messages created by _devenv-4-iom_ and _IOM_ are JSON messages, it is a very useful tool.

jq is not included in _devenv-4-iom_ and _devenv-4-iom_ does not depend on it (except the _'log *'_ command), but it is strongly recommended that you install _jq_ as well.

### Windows
Install jq, see [Download jq](https://stedolan.github.io/jq/download).
1. Download to _C:\Program Files\jq_
2. Open the Git Bash console.
    1. Set an alias. The alias is required when using _jq_ interactively in the console window, e.g. to comprehend the examples which can be found in the documentation of _devenv-4-iom_.
        ```sh
         echo "alias jq=\"/c/Program\ Files/jq/jq-win64.exe\"" >> ~/.profile
         ```
    2. Add _jq_ to the PATH variable. This is required for the _'log *'_ commands of _devenv-cli.sh_ to work. These commands execute _jq_ internally and have to find it in _PATH_.
        ```sh
         echo "export PATH=\"\$PATH:/c/Program\ Files/jq\"" >> ~/.profile
        ```
    Depending on your shell it migth be necessary to edit the PATH before calling any other shell in ~/.profile. You can add this path element in your shell profile (might be ~/.bash_profile). Alternatively refer to the following step.
3. A better way would be to add a path element to the global windows environment as it is supposed to be. This also removes variances with the mount points of your windows drive paths.


4. Support alias in VS Code.

   Therefore open _settings.json_ which can be found in _C:\Users\myuser\AppData\Roaming\Code\User\settings.json_.
    ```json
    // Support alias in Visual Studio Code
    "terminal.integrated.shellArgs.windows": ["-l"],
    ```


### Mac OS X
_jq_ is not part of a standard distribution of Mac OS X. In order to install additional tools like _jq_, it is recommended to use one of the open source package management systems. Intershop recommends using [Mac Ports](https://www.macports.org/). Please follow the [installation instruction](https://www.macports.org/install.php) to set up _Mac Ports_. Once _Mac Ports_ is installed, the installation of _jq_ can be done by using the following command:
```sh
sudo port install jq
```

# Setup of _devenv-4-iom_
## Checkout the devenv-4-iom Project
_devenv-4-iom_ provides all the tools that are required to configure and run an _IOM_ instance in your local _Kubernetes_ cluster. The project must be available locally on your computer:
```sh
# checkout the devenv-4-iom project
cd /d/git/oms/
git clone https://bitbucket.intershop.de/scm/iom/devenv-4-iom.git
```

### Windows
Add _devenv-cli.sh_ to the PATH variable if you want to be able to call it from everywhere. There are two ways to do this:
   - In your shell call: 
    ```sh
    echo "export PATH=\"\$PATH:/d/git/oms/devenv-4-iom\"" >> ~/.profile
    ```
    (your profile file might vary if you are using bash).
   - Edit your whole windows system to search also in the directory your _devenv-cli.sh_ is checked out to. This way also removes variances with the mount points of your windows drive paths.

### Mac OS X
In order to become able to use _devenv-cli.sh_ without the need to call it with its absolute path, you have to extend your PATH variable. Please edit _.profile_ in your home-directory and add the according entry.

# Next Steps
Open https://confluence.intershop.de/display/ENFDEVDOC/Guide+-+IOM+Development+Environment in your browser and proceed with the _First steps_ section to get familiar with _devenv-4-iom_.
