
# Log Messages
## <a name="jq">_jq_ - Command Line JSON Processor</a>

_[jq](https://stedolan.github.io/jq/)_ is a command line tool that allows to work with JSON messages. Since all messages created by IOM are JSON messages, it is a very useful tool. _jq_ is not included in _devenv-4-iom_ and _devenv-4-iom_ does not depend on it (except for the `log *` commands). However, it is strongly recommended to install _jq_ as well.

The most important features used in context of _devenv-4-iom_ are formatting and filtering. The following box shows some examples of these use cases. These examples are not intended to be used as they are. They are only meant to give you an impression of _jq_ and encourage you to look into the subject by yourself.

    # Print raw JSON messages
    cmd_producing_json
    ...
    {"tenant":"Intershop","environment":"first steps","logHost":"iom-5948d556fd-h8wq8","logVersion":"1.0","appName":"iom","appVersion":"4.0.0","logType":"script","timestamp":"2021-12-21T11:48:19+00:00","level":"INFO","processName":"dbmigrate-kubernetes.sh","message":"processing directory '/opt/oms/stored_procedures'","configName":null}
    {"tenant":"Intershop","environment":"first steps","logHost":"iom-5948d556fd-h8wq8","logVersion":"1.0","appName":"iom","appVersion":"4.0.0","logType":"script","timestamp":"2021-12-21T11:48:19+00:00","level":"INFO","processName":"dbmigrate-kubernetes.sh","message":"processing file '/opt/oms/stored_procedures/./admin/add_communication_partner.sql'","configName":null}
    ...

    # Print formatted JSON messages
    cmd_producing_json | jq
    {
      "tenant": "Intershop",
      "environment": "first steps",
      "logHost": "iom-5948d556fd-h8wq8",
      "logVersion": "1.0",
      "appName": "iom",
      "appVersion": "4.0.0",
      "logType": "script",
      "timestamp": "2021-12-21T11:48:19+00:00",
      "level": "INFO",
      "processName": "dbmigrate-kubernetes.sh",
      "message": "processing directory '/opt/oms/stored_procedures'",
      "configName": null
    }
    {
      "tenant": "Intershop",
      "environment": "first steps",
      "logHost": "iom-5948d556fd-h8wq8",
      "logVersion": "1.0",
      "appName": "iom",
      "appVersion": "4.0.0",
      "logType": "script",
      "timestamp": "2021-12-21T11:48:19+00:00",
      "level": "INFO",
      "processName": "dbmigrate-kubernetes.sh",
      "message": "processing file '/opt/oms/stored_procedures/./admin/add_communication_partner.sql'",
      "configName": null
    }
    ...

    # Get entries, where key "level" has value "ERROR"
    cmd_producing_json | jq 'select(.level == "ERROR")'
    ...
    {
      "timestamp": "2021-12-21T14:13:03.49Z",
      "sequence": 1388,
      "loggerClassName": "org.slf4j.impl.Slf4jLogger",
      "loggerName": "com.intershop.oms.rolemgmt.internal.connector.BackendAdminConnector",
      "level": "ERROR",
      "message": "noObjectFound: Object not found for given ID '100' while 'get user for management'.",
      "threadName": "default task-45",
      "threadId": 1236,
      "mdc": {},
      "ndc": "",
      "hostName": "iom-5948d556fd-h8wq8",
      "processName": "jboss-modules.jar",
      "processId": 12621,
      "stackTrace": ": com.intershop.oms.rolemgmt.capi.OMSLogicalException: Object not found for given ID '100' while 'get user for management'.\n\tat deployment.bakery.base-app-4.0.0.ear.oms.rolemgmt-internal-4.0.0.jar//com.intershop.oms.rolemgmt.internal.security.user.UserSecurityBean.checkForNull(UserSecurityBean.java:87)\n\t...",
      "sourceClassName": "com.intershop.oms.rolemgmt.internal.connector.BackendAdminConnector",
      "sourceFileName": "BackendAdminConnector.java",
      "sourceMethodName": "handleException",
      "sourceLineNumber": 140,
      "sourceModuleName": "deployment.bakery.base-app-4.0.0.ear.oms.rolemgmt-internal-4.0.0.jar",
      "sourceModuleVersion": null,
      "tenant": "Intershop",
      "environment": "first steps",
      "logHost": "iom-5948d556fd-h8wq8",
      "logVersion": "1.0",
      "appVersion": "4.0.0",
      "appName": "iom",
      "logType": "message",
      "configName": null
    }
    ...

    # Get entries where key "level" has value "ERROR" and "threadId" has value 1236
    cmd_producing_json | jq 'select((.level == "ERROR") and (.threadId == 1236))'
    ...
    {
      "timestamp": "2021-12-21T14:13:03.49Z",
      "sequence": 1388,
      "loggerClassName": "org.slf4j.impl.Slf4jLogger",
      "loggerName": "com.intershop.oms.rolemgmt.internal.connector.BackendAdminConnector",
      "level": "ERROR",
      "message": "noObjectFound: Object not found for given ID '100' while 'get user for management'.",
      "threadName": "default task-45",
      "threadId": 1236,
      "mdc": {},
      "ndc": "",
      "hostName": "iom-5948d556fd-h8wq8",
      "processName": "jboss-modules.jar",
      "processId": 12621,
      "stackTrace": ": com.intershop.oms.rolemgmt.capi.OMSLogicalException: Object not found for given ID '100' while 'get user for management'.\n\tat deployment.bakery.base-app-4.0.0.ear.oms.rolemgmt-internal-4.0.0.jar//com.intershop.oms.rolemgmt.internal.security.user.UserSecurityBean.checkForNull(UserSecurityBean.java:87)\n\t...",
      "sourceClassName": "com.intershop.oms.rolemgmt.internal.connector.BackendAdminConnector",
      "sourceFileName": "BackendAdminConnector.java",
      "sourceMethodName": "handleException",
      "sourceLineNumber": 140,
      "sourceModuleName": "deployment.bakery.base-app-4.0.0.ear.oms.rolemgmt-internal-4.0.0.jar",
      "sourceModuleVersion": null,
      "tenant": "Intershop",
      "environment": "first steps",
      "logHost": "iom-5948d556fd-h8wq8",
      "logVersion": "1.0",
      "appVersion": "4.0.0",
      "appName": "iom",
      "logType": "message",
      "configName": null
    }
    ...

    # Only get the "timestamp" and "message" values of entries where key "level" has value "ERROR"
    cmd_producing_json | jq 'select(.level == "ERROR") | .timestamp,.message'
    ...
    "2021-12-21T14:13:03.49Z"
    "noObjectFound: Object not found for given ID '100' while 'get user for management'."
    ...

    # Only get the "timestamp" and "message" values in a new JSON structure where key "level" has value "ERROR"
    cmd_producing_json  | jq 'select(.level == "ERROR") | {timestamp: .timestamp, message: .message}'
    ...
    {
      "timestamp": "2021-12-21T14:13:03.49Z",
      "message": "noObjectFound: Object not found for given ID '100' while 'get user for management'."
    }
    ...


## Log Messages of _devenv-cli.sh_

Logging of _devenv-cli.sh_ is controlled by the configuration variable `OMS_LOGLEVEL_DEVENV`. Since every execution of _devenv-cli.sh_ reads the configuration file, changes of this variable become effective immediately. In difference to log messages created by IOM, _devenv-cli.sh_ uses a very simple line-based log format. Log messages, directly created by _devenv-cli.sh_ are always written to _stderr_, whereas log messages of IOM are printed to _stdout_.

## <a name="log_iom">Log Messages of IOM Containers</a>

In addition to the IOM application container, one init container also belongs to IOM. These containers write messages in the JSON format to _stdout_. The log-levels of the messages are controlled by the following variables:

* `OMS_LOGLEVEL_CONSOLE`
* `OMS_LOGLEVEL_IOM`
* `OMS_LOGLEVEL_HIBERNATE`
* `OMS_LOGLEVEL_QUARTZ`
* `OMS_LOGLEVEL_ACTIVEMQ`
* `OMS_LOGLEVEL_CUSTOMIZATION`
* `OMS_LOGLEVEL_SCRIPTS`

The values of these log-levels cannot be changed at runtime. For a change to take effect, IOM must be deleted and created again.

Beside these application level messages, access logs are also written to _stdout_ in the JSON format. Hence, the output of the IOM container is a mixture of different logs.

`kubectl` can be used to access these messages. In general the message can be provided in two different ways:

* Get all messages since container start and finish after that, or
* Only get new messages and wait for upcoming messages (follow new messages).

The according `kubectl` command lines are provided by the `info iom` command.

Hence, using `kubectl` to get log messages of IOM will deliver everything mixed in one stream (script-, message- and access-log), exactly as defined by the current logging configuration. E.g., if a log-level is currently set to `INFO`, but you are interested in `FATAL`, `ERROR` and `WARN` messages only, you have to write an according _jq_ command line yourself to receive only the requested messages (see [section _jq_](#jq)).

## <a name="log_cmd">devenv-cli's `log *` Commands</a>

The [section before](#log_iom) showed how to get messages out of the IOM containers and how to further process them with the help of _jq_. This is a valid procedure if special requirements have to be met. However, there are some standard situations that should be easier to handle. For this reason `devenv-cli.sh` provides the `log *` commands.

The `log *` commands facilitate accessing the logs of different IOM containers and different types of logs of IOM's application container. It is the only command that uses _jq_ internally to provide a basic filtering and formatting of messages. By using the `log *` commands you can do the following:

* View log messages of _dbaccount_ or _iom_ containers:
  * Filter them for the passed level and all higher levels. E.g. when level `WARN` is passed as argument to the `log` command, only messages of levels `FATAL`, `ERROR` and `WARN` will be printed.
  * Show all messages or follow only new messages.
  * Format the messages or leave them unformatted for further processing with _jq_.
* View access logs of the IOM container:
  * Filter them for HTTP status code: show all or only those requests, that had an HTTP status code >= 400.
  * Show all access log entries or only follow new ones.
  * Format the access-log entries or leave them unformatted for further processing with _jq_.

The following box shows some examples on how to use the `log *` commands.

    # Show FATAL, ERROR and WARN messages of IOM's dbaccount init container and format them
    devenv-cli.sh log dbaccount

    # Show INFO and higher level messages of IOM's dbaccount init container and format them
    devenv-cli.sh log dbaccount info

    # Follow WARN and higher level messages of IOM pod and format the messages
    devenv-cli.sh log iom -f

    # Follow all access log entries
    # Do not format messages to be able to process output by a second jq stage that filters for response time > 100 ms
    devenv-cli.sh log access all -f | jq 'select(.responseTime > 100)'

---
[< Development Process](04_development_process.md) | [^ Index](../README.md) | [Troubleshooting >](06_troubleshooting.md)
