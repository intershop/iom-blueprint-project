# Installation
## Prerequisites
In order to use _devenv-4-iom_ on your host machine, the installation of some additional tools is required.

### Bash
**Windows**

1. Install Git Bash (comes with [Git for Windows](https://gitforwindows.org/)).
1. It's recommended to use Git Bash in VS Code, see [Integrated Terminal](https://code.visualstudio.com/docs/editor/integrated-terminal#_configuration). To enable Git Bash in VS Code, open settings in `C:\Users\myuser\AppData\Roaming\Code\User\seetings.json` and add the following lines:
   ```json
   // enable Git Bash in Visual Studio Code
   "terminal.integrated.shell.windows": "C:\\Program Files\\Git\\bin\\bash.exe"
   ```
If you are not able to locate `settings.json`, see [User and Workspace Settings](https://code.visualstudio.com/docs/getstarted/settings) in the Visual Studio Code documentation.

**Mac OS X**

Bash is part of Mac OS X, there is nothing to do. It's not required, that bash is your default shell.

### Docker-Desktop
Usage of _Docker-Desktop_ is recommended. It provides a _Docker_ environment and also _Kubernetes_ functionality, which is required to use _devenv-4-iom_. Other _Docker/Kubernetes_ implementations can be used along with _devenv-4-iom_ too, but all of them have restrictions, that makes their usage much more complicated.
     
> **Caution:** While installing _Docker-Desktop_ on **Windows** you will be signed-out without further acknowledgements and your PC will probably be restarted. So save everything before installing.

1. Download and install [_Docker-Desktop_](https://www.docker.com/products/docker-desktop).
2. Enable _Kubernetes in Docker Desktop_.
    - _Docker Icon > Preferences > Kubernetes > Enable Kubernetes_.
3. Make sure, the directory holding IOM-project sources is shared.
    - _Docker Icon > Preferences > Resources > File Sharing_.
4. Set CPU and memory usage. When running a single IOM instance in _Docker-Desktop_ you need to assign at least 2 CPUs and 8 GB of memory.
    - _Docker Icon > Preferences > Resources > Advanced_.

### jq - Command-Line JSON Processor
_jq_ is a command-line tool that allows to work with JSON messages. Since all messages created by IOM are JSON messages, it is a very useful tool.

_jq_ is not included in _devenv-4-iom_ and _devenv-4-iom_ does not depend on it (except for the `log *` commands), but it is strongly recommended that you install _jq_ as well.

**Windows**

1. Download the latest executable from [Download jq](https://stedolan.github.io/jq/download) and install it to `C:\Program Files\jq`
1. Define an alias. The alias is required when using _jq_ interactively in the console window, e.g. to comprehend the examples which are [part of the documentation](05_log_messages.md#jq). To do so, add the following line to `$HOME/.profile`:
    ```sh
    alias jq="/c/Program Files/jq/jq-win64.exe"
    ```
1. Add _jq_ to the `PATH` variable. This is required for the `log *` commands of `devenv-cli.sh` to work. These commands execute _jq_ internally and have to find it in `PATH`. To do so, add the following line to `$HOME/.profile`
    ```sh
    export PATH="$PATH:/c/Program Files/jq"
    ```
1. Support usage of aliases in VS Code. Therefore open `C:\Users\myuser\AppData\Roaming\Code\User\settings.json` and add the following lines:
    ```json
    // Support alias in Visual Studio Code
    "terminal.integrated.shellArgs.windows": ["-l"],
    ```

**Mac OS X**

_jq_ is not part of a standard distribution of Mac OS X. In order to install additional tools like _jq_, it is recommended to use one of the open source package management systems. Intershop recommends using [_Mac Ports_](https://www.macports.org/). Please follow the [installation instruction](https://www.macports.org/install.php) to set up _Mac Ports_. Once _Mac Ports_ is installed, the installation of _jq_ can be done by using the following command:
```sh
sudo port install jq
```

## <a name="setup_devenv"/>Setup _devenv-4-iom_
In order to use _devenv-4-iom_, you need a local copy of it on your computer. This copy can simply created, by cloning the sources. The _main_ branch always contains the latest release-version.

    # get devenv-4-iom
    git clone git@github.com:intershop/devenv-4-iom.git
    cd devenv-4-iom
    git checkout main
    
In order to become able to use `devenv-cli.sh` without the need to call it with its absolute path, you have to extend the `PATH` variable. Please edit `$HOME/.profile` and add the following line (please adapt the directory name to the location where _devenv-4-iom_ was installed before):
```sh
export PATH="$PATH:/DirnameToBeAdapted/devenv-4-iom/bin"
```

---
[^ Index](../README.md) | [First Steps >](01_first_steps.md)