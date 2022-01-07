
# <a name="jq"/>_jq_ - Command Line JSON Processor

_[jq](https://stedolan.github.io/jq/)_ is a command line tool that allows to work with JSON messages. Since all messages created by _devenv-4-iom_ and IOM are JSON messages, it is a very useful tool. _jq_ is not included in _devenv-4-iom_. _devenv-4-iom_ does not depend on it (except the _log \*_ commands), but it is strongly recommended that you install _jq_ as well.

The most important features used in context of _devenv-4-iom_ are formatting and filtering. The following box shows some examples of these use cases. These examples are not intended to be used as they are. They are only meant to give you an impression about _jq_ and encourage you to look into the subject by yourself.

    # Print raw JSON messages 
    cmd_producing_json 
    ...
    {"tenant":"Intershop","environment":"2.17.0.0-SNAPSHOT","logHost":"iom-6c587ddd87-42k4f","logVersion":"1.0","appName":"iom-config","appVersion":"2.17.0.0-SNAPSHOT@1234","logType":"script","timestamp":"2019-12-13T13:35:45+00:00","level":"INFO","processName":"apply_json_config.sh","message":"processing file '/opt/caas-config/json-config/config/P_shopTX/G_Invoicing_and_Documents/060_InvoicingNoConfigDO/InvoicingNoConfigDO_test_shop_TX.iombc'","configName":"ci"} {"tenant":"Intershop","environment":"2.17.0.0-SNAPSHOT","logHost":"iom-6c587ddd87-42k4f","logVersion":"1.0","appName":"iom-config","appVersion":"2.17.0.0-SNAPSHOT@1234","logType":"script","timestamp":"2019-12-13T13:35:45+00:00","level":"INFO","processName":"apply_json_config.sh","message":"processing file '/opt/caas-config/json-config/config/P_shopTX/G_Invoicing_and_Documents/120_DocumentTransformerConfigDO/DocumentTransformerConfigDO_Shop_test_shop_TX.iombc'","configName":"ci"} {"tenant":"Intershop","environment":"2.17.0.0-SNAPSHOT","logHost":"iom-6c587ddd87-42k4f","logVersion":"1.0","appName":"iom-config","appVersion":"2.17.0.0-SNAPSHOT@1234","logType":"script","timestamp":"2019-12-13T13:35:45+00:00","level":"INFO","processName":"apply_json_config.sh","message":"processing file '/opt/caas-config/json-config/config/P_shopTX/H_Shop2PaymentProvider2Payment/010_Shop2PaymentProvider2PaymentDefDO/Shop2PaymentProvider2PaymentDefDO_test_shop_TX.iombc'","configName":"ci"} ... 
    
    # Print formatted JSON messages 
    cmd_producing_json | jq 
    ... 
    { 
      "tenant": "Intershop",
      "environment": "2.17.0.0-SNAPSHOT",
      "logHost": "iom-6c587ddd87-42k4f",
      "logVersion": "1.0",
      "appName": "iom-config",
      "appVersion": "2.17.0.0-SNAPSHOT@1234",
      "logType": "script",
      "timestamp": "2019-12-13T13:35:45+00:00",
      "level": "INFO",
      "processName": "apply_json_config.sh",
      "message": "processing file '/opt/caas-config/json-config/config/P_shopTX/G_Invoicing_and_Documents/120_DocumentTransformerConfigDO/DocumentTransformerConfigDO_Shop_test_shop_TX.iombc'",
       "configName": "ci"
    } 
    {
      "tenant": "Intershop",
      "environment": "2.17.0.0-SNAPSHOT",
      "logHost": "iom-6c587ddd87-42k4f",
      "logVersion": "1.0",
      "appName": "iom-config",
      "appVersion": "2.17.0.0-SNAPSHOT@1234",
      "logType": "script",
      "timestamp": "2019-12-13T13:35:45+00:00",
      "level": "INFO",
      "processName": "apply_json_config.sh",
      "message": "processing file '/opt/caas-config/json-config/config/P_shopTX/H_Shop2PaymentProvider2Payment/010_Shop2PaymentProvider2PaymentDefDO/Shop2PaymentProvider2PaymentDefDO_test_shop_TX.iombc'",
      "configName": "ci" 
    } 
    ... 
    
    # Get entries, where key "level" has value "ERROR" 
    cmd_producing_json | jq 'select(.level == "ERROR")' 
    ... 
    { 
      "timestamp": "2019-12-13T11:55:23.608Z",
      "sequence": 1349200,
      "loggerClassName": "org.jboss.logging.DelegatingBasicLogger",
      "loggerName": "org.hibernate.engine.jdbc.spi.SqlExceptionHelper",
      "level": "ERROR",
      "message": "javax.resource.ResourceException: IJ000453: Unable to get managed connection for java:/OmsDB",
      "threadName": "EJB default - 61",
      "threadId": 1113,
      "mdc": {},
      "ndc": "",
      "hostName": "iom-6c587ddd87-zlznn",
      "processName": "jboss-modules.jar",
      "processId": 288,
      "sourceClassName": "org.hibernate.engine.jdbc.spi.SqlExceptionHelper",
      "sourceFileName": "SqlExceptionHelper.java",
      "sourceMethodName": "logExceptions",
      "sourceLineNumber": 142,
      "sourceModuleName": "org.hibernate",
      "sourceModuleVersion": "5.3.10.Final",
      "tenant": "Intershop",
      "environment": "2.17.0.0-SNAPSHOT",
      "logHost": "iom-6c587ddd87-zlznn",
      "logVersion": "1.0",
      "appVersion": "2.17.0.0-SNAPSHOT@1234",
      "appName": "iom-app",
      "logType": "message",
      "configName": "ci" 
    } 
    ... 
    
    # Get entries, where key "level" has value "ERROR" and "sourceModuleName" has value "deployment.oms.monitoring-app-2.17.0.0-SNAPSHOT.war" 
    cmd_producing_json | jq 'select((.level == "ERROR") and (.sourceModuleName == "deployment.oms.monitoring-app-2.17.0.0-SNAPSHOT.war"))' 
    ... 
    { 
      "timestamp": "2019-12-13T11:50:59.698Z",
      "sequence": 1338700,
      "loggerClassName": "org.slf4j.impl.Slf4jLogger",
      "loggerName": "com.intershop.oms.monitoring.internal.rest.HealthServiceTimer",
      "level": "ERROR",
      "message": "Server not available because of missing database connection.",
      "threadName": "EJB default - 92",
      "threadId": 1222,
      "mdc": {},
      "ndc": "",
      "hostName": "iom-6c587ddd87-zlznn",
      "processName": "jboss-modules.jar",
      "processId": 288,
      "sourceClassName": "com.intershop.oms.monitoring.internal.rest.HealthServiceTimer",
      "sourceFileName": "HealthServiceTimer.java",
      "sourceMethodName": "doHealthCheck",
      "sourceLineNumber": 305,
      "sourceModuleName": "deployment.oms.monitoring-app-2.17.0.0-SNAPSHOT.war",
      "sourceModuleVersion": null,
      "tenant": "Intershop",
      "environment": "2.17.0.0-SNAPSHOT",
      "logHost": "iom-6c587ddd87-zlznn",
      "logVersion": "1.0",
      "appVersion": "2.17.0.0-SNAPSHOT@1234",
      "appName": "iom-app",
      "logType": "message",
      "configName": "ci" 
    } 
    ... 
    
    # Get only values "timestamp" and "message" of entries, where key "level" has value "ERROR" 
    cmd_producing_json | jq 'select(.level == "ERROR") | .timestamp .message' 
    ... 
    "2019-12-13T11:49:27.58Z" 
    "WFLYEJB0034: EJB Invocation failed on component MonitoringPersistenceBean for method public abstract bakery.persistence.dataobject.monitoring.HealthCheckStatusDO bakery.persistence.service.monitoring.MonitoringPersistenceService.getServerStatus(java.lang.String)" 
    "2019-12-13T11:49:27.624Z" 
    "WFLYEJB0034: EJB Invocation failed on component MonitoringLogicBean for method public abstract void com.intershop.oms.monitoring.capi.logic.MonitoringLogicService.setServerStatus(com.intershop.oms.monitoring.capi.rest.HealthCheckStatus)" 
    "2019-12-13T11:49:27.625Z" 
    " (systemPU) exception found for object 'class bakery.persistence.dataobject.monitoring.HealthCheckStatusDO'" 
    "2019-12-13T11:49:27.625Z" 
    "Server not available because of missing database connection." 
    "2019-12-13T11:49:27.631Z" 
    "WFLYEJB0022: Error during retrying timeout for timer: [id=9cd75873-66b1-4fdd-8155-fb859d7dc73e timedObjectId=oms.monitoring-app-2.17.0.0-SNAPSHOT.oms.monitoring-app-2.17.0.0-SNAPSHOT.HealthServiceTimer auto-timer?:false persistent?:false timerService=org.jboss.as.ejb3.timerservice.TimerServiceImpl@d537ad6 initialExpiration=Fri Dec 13 11:12:17 UTC 2019 intervalDuration(in milli sec)=5000 nextExpiration=Fri Dec 13 11:49:32 UTC 2019 timerState=RETRY_TIMEOUT info= startAT=Fri Dec 13 11:12:17 UTC 2019, runInterval=5000, cacheTime=11000]" 
    "2019-12-13T11:49:30.006Z" 
    "Error" 
    ... 
    
    # Get only values "timestamp", "message" and "sourceFileName" of entries, where key "level" has value "ERROR" in a new JSON structure 
    cmd_producing_json | jq 'select(.level == "ERROR") | {timestamp: .timestamp, message: .message, sourceFileName: .sourceFileName}' 
    ... 
    {
      "timestamp": "2019-12-13T11:50:11.467Z",
      "message": "WFLYEJB0034: EJB Invocation failed on component CancelOrderControllerBean for method public abstract void bakery.control.controller.ControllerJob.execute()",
      "sourceFileName": "LoggingInterceptor.java" 
    } 
    {
      "timestamp": "2019-12-13T11:50:11.472Z",
      "message": "javax.resource.ResourceException: IJ000453: Unable to get managed connection for java:/OmsDB",
      "sourceFileName": "SqlExceptionHelper.java" 
    } 
    {
      "timestamp": "2019-12-13T11:50:11.478Z",
      "message": "WFLYEJB0034: EJB Invocation failed on component CheckBonusPointsControllerBean for method public abstract void bakery.control.controller.ControllerJob.execute()",
      "sourceFileName": "LoggingInterceptor.java" 
    } 
    {
      "timestamp": "2019-12-13T11:50:11.486Z",
      "message": "WFLYEJB0034: EJB Invocation failed on component ProcessControlConfigBean for method public abstract java.util.Collection bakery.persistence.service.configuration.process.ProcessControlConfigService.loadModifiedConfigs()",
      "sourceFileName": "LoggingInterceptor.java"
    } 
    ...

# Log Messages of devenv-cli.sh

Logging of `devenv-cli.sh` is controlled by the configuration variable `OMS_LOGLEVEL_DEVENV`. Since every execution of `devenv-cli.sh` reads the configuration file, changes of this variable become effective immediately.

As mentioned [above](#jq), all log messages of `devenv-cli.sh` are written in JSON format. Hence, it is a good idea to pipe the output of `devenv-cli.sh` through _jq_ for better readability of messages.

Unfortunately, it is not as simple as it seems at first glance. There are three reasons that make things more complicated:

* Not every output of `devenv-cli.sh` is a log message, but only log messages are provided in JSON format. _info *_ and _get *_ commands and all help-messages are written as plain-text. The intended output of these commands is written to _stdout_. Any additional log messages are written to _stderr_. In fact, all log messages of `devenv-cli.sh` are written to _stderr_.
* Some commands provide a mixture of log messages of devenv-cli.sh and IOM. Developer commands (_apply *_) behave like that. E.g., when applying a SQL configuration using _apply sql-config_, there are log messages of `devenv-cli.sh` that report the progress of the process (create kubernetes-job, delete kubernetes-job, etc.). In addition, there are other log messages coming directly from IOM, which provide information about applying the SQL configuration. In this case, only the log messages of `devenv-cli.sh` are controlled by the variable `OMS_LOGLEVEL_DEVENV`. The messages of IOM are controlled by other `OMS_LOGLEVEL_*` variables, see [section below](#log_iom). Beyond that, you should know that log messages of IOM are written to _stdout_, unlike the log messages of `devenv-cli.sh`, which are written to _stderr_.
* Finally, there are the _log *_ commands, which help to facilitate access to messages created by IOM containers. For more information, see [section below](#log_cmd).

Hence, the following hints should be taken into account, when using `devenv-cli.sh` along with _jq_:

* When executing commands writing their intended output to _stdout_ (e.g. _info_, _get_), only _stderr_ must be redirected to _jq_.
* When executing commands without any intended output (e.g. _apply_, _dump_), _stdout_ and _stderr_ must be piped into _jq_.

TODO it's impossible to have a list and code in direct contact.

    # example of jq-usage along with devenv-cli.sh command, having intended output printed to stdout 
    # intended output is written to file config.properties 
    # log messages are piped to jq 
    # creates a pretty-printed version of log messages 
    devenv-cli.sh get config 2>&1 >config.properties | jq 
    
    # example of jq-usage with mixed log messages from devenv-cli.sh and IOM 
    # log messages of devenv-cli.sh are written to stderr 
    # log messages of IOM are written to stdout 
    # both are piped to jq 
    devenv-cli.sh apply sql-script test.sql 2>&1 | jq

# <a name="log_iom"/>Log Messages of IOM Containers

In addition to the IOM application container, two init containers also belong to the IOM. All these containers write messages in JSON format to _stdout_. The log-levels of these messages are controlled by the following variables:

* `OMS_LOGLEVEL_CONSOLE`
* `OMS_LOGLEVEL_IOM`
* `OMS_LOGLEVEL_HIBERNATE`
* `OMS_LOGLEVEL_QUARTZ`
* `OMS_LOGLEVEL_ACTIVEMQ`
* `OMS_LOGLEVEL_CUSTOMIZATION`
* `OMS_LOGLEVEL_SCRIPTS`

The values of these log-levels cannot be changed at runtime. For a change to take effect, IOM must be deleted and created again.

Beside these application level messages, access logs are written to _stdout_ in JSON format too. Hence, the output of the IOM containers is a mixture of different logs.

You can use `kubectl` to access these messages. In general these message can be provided in two different ways:

* Get all messages since container start and finish after that, or
* Get only new messages and wait for upcoming messages (follow new messages).

The according `kubectl` command lines are provided by the _info iom_ command.

Hence, if you use `kubectl` to get log messages of IOM, you will get everything mixed in one stream (messages and access-log), exactly as defined by the current logging configuration. E.g., if a log-level is currently set to `INFO`, but you are interessed in `FATAL`, `ERROR` and `WARN` messages only, you have to write an according _jq_ command line by your own to receive only the requested messages (see [section _jq_](#jq)).

The following box shows some examples on how to access log messages of IOM containers and how to filter and format them with the help of _jq_.

    # Get all FATAL, ERROR and WARN messages produced by IOM application container (do not follow new messages) 
    # kubectl command line was taken from output of 'info iom' command 
    # output is filtered by jq 
    # - ignore any lines, that are not valid json structures 
    # - print only json messages, with 'level' element having the value 'FATAL', 'ERROR' or 'WARN' 
    kubectl logs iom-6c587ddd87-42k4f --namespace 21700snapshot -c iom | 
      jq -R 'fromjson? | select(type == "object")' | 
      jq 'select((.level == "FATAL") or (.level == "ERROR") or (.level == "WARN"))' 
    
    # Follow new access log entries, having a status code indicating an error 
    # kubectl command line was taken from output of 'info iom' command 
    # output is filtered by jq 
    # - ignore any lines, that are not valid json structures 
    # - show only json messages with 'logType' element having the value 'access' 
    # - show only json messages with 'responceCode' element having a value greater or equal 400 
    kubectl logs --tail=1 -f iom-6c587ddd87-42k4f --namespace 21700snapshot -c iom | 
      jq -R 'fromjson? | select(type == "object")' | 
      jq 'select((.logType == "access" ) and (.responseCode >= 400))'

# <a name="log_cmd"/>devenv-cli's _log *_ Commands

The [section before](#log_iom) showed how to get messages out of the IOM containers and how to further process them with the help of _jq_. This is a valid procedure if special requirements have to be met. However, there are some standard situations that should be easier to handle. For this reason `devenv-cli.sh` provides the _log *_ commands.

The _log *_ commands facilitate accessing the logs of different IOM containers and different types of logs of IOM's application container. It is the only command that uses _jq_ internally to provide a basic filtering and formatting of messages. By using the _log *_ commands you can do the following:

* View log messages of _dbaccount_, _config_ or _application_ container:
  * Filter them for the passed level and all higher levels. E.g. when level `WARN` is passed as argument to the log command, only messages of levels `FATAL`, `ERROR` and `WARN` will be printed.
  * Show all messages or follow only new messages.
  * Format the messages or leave them unformatted for further processing with _jq_.
* View access logs of application container:
  * Filter them for HTTP status code: show all or only those requests, that had an HTTP status code >= 400.
  * Show all access log entries or follow only new ones.
  * Format the access-log entries or leave them unformatted for further processing with _jq_.

The following box shows some examples on how to use the _log *_ commands.

    # Show FATAL, ERROR and WARN messages of IOM's config container and format them 
    devenv-cli.sh log config 
    
    # Show INFO messages of IOM's config container and format them 
    devenv-cli.sh log config info 
    
    # Follow FATAL, ERROR and WARN messages of IOM's application container and format the messages 
    devenv-cli.sh log app -f 
    
    # Follow all access log entries 
    # Do not format messages to be able to process output by a second jq stage that filters for response time > 100 ms 
    devenv-cli.sh log access all -f | jq 'select(.responseTime > 100)'
