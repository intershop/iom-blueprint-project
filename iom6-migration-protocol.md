# IOM 6 Migration Protocol

**Date:** 2026-07-02
**Project:** iom-blueprint-project
**Archetype version used to generate this project:** Not explicitly recorded in pom.xml; inferred from git history (initial commit contains archetype output, platform.version was 5.x at generation time)
**Migrated by:** Claude (iom6-project-migration-agent.md)

## Build Result

Not run — build requires Azure DevOps Maven feed credentials for IOM 6 platform artifacts (`platform.version=6.0.0`). Changes are structurally complete; a full `mvn clean install` should be run in the CI environment to confirm.

## Changes Applied

### pom.xml
**Action:** changed
**Reason:** Multiple version updates required for IOM 6 / WildFly 40 / Java 21 compatibility.
**Details:**
- `platform.version`: `5.1.6` → `6.0.0`
- `wildfly.version`: `30.0.1.Final` → `40.0.0.Final`
- `testframework.version`: `7.1.0` → `8.0.0`
- `postgresql` version: `42.7.1` → `42.7.11`
- Maven compiler `<release>`: `17` → `21`
- `org.junit.version`: intentionally left unchanged at `5.9.2` (see Decisions and Observations)
- Removed dependency `resteasy-core-spi` (dropped in WildFly 40)
- Removed dependency `resteasy-client` (dropped in WildFly 40)
- Removed dependency `slf4j-api` provided (no longer needed as explicit dependency)
- Removed dependency `slf4j-simple` test (dropped with iom-test-framework 8.0.0)
- Removed dependency `jackson-datatype-jsr310` (dropped in IOM 6; date/time support is built-in)
- Changed `commons-lang3` scope: compile → `provided` (now provided by WildFly 40)
- Added dependency `com.intershop.oms:rest` at `${platform.version}` with `provided` scope (platform logging and REST API)
- Updated all archetype-provided plugin versions (see table in migration strategy)
- Added `versions-maven-plugin` `2.21.0` to `<pluginManagement>` (was in `<reporting>` without a version pin)
- Added `maven-clean-plugin` configuration block to `<build><plugins>` with `<excludeDefaultDirectories>true</excludeDefaultDirectories>` (critical for devenv-4-iom bind-mount compatibility)

### dependency-helper/pom.xml
**Action:** changed
**Reason:** `order-state-app` was removed from the IOM 6 platform.
**Details:** Removed the `com.intershop.oms:order-state-app` dependency block.

### src/main/java/com/intershop/oms/enums/expand/ExpandedExecutionBeanKeyDefDO.java
**Action:** changed
**Reason:** IOM 6 replaced `@PersistedEnumerationTable` with `@ExpandedEnum`.
**Details:**
- Import `bakery.persistence.annotation.PersistedEnumerationTable` → `bakery.persistence.annotation.ExpandedEnum`
- Class annotation `@PersistedEnumerationTable(ExecutionBeanKeyDefDO.class)` → `@ExpandedEnum(ExecutionBeanKeyDefDO.class)`
- Enum constant IDs, names, and JNDI strings were not changed.

### src/main/java/com/intershop/oms/enums/expand/ExpandedDocumentMapperDefDO.java
**Action:** skipped
**Reason:** Already uses `@ExpandedEnum`; no `@Entity`, `@Table`, or `@Configuration` annotations present. No changes required.

### src/main/java/com/intershop/oms/enums/expand/ExpandedPaymentDefDO.java
**Action:** changed
**Reason:** IOM 6 requires the last argument of enum constant constructors to use `EnumPayment` constants instead of raw string literals.
**Details:**
- Added import `bakery.payment.v1.EnumPayment`
- Enum constant `TEST` (id=-9999, placeholder): last argument `"AfterPay"` → `EnumPayment.NO_PAYMENT`. The name `"AfterPay"` and description `"AfterPay"` were replaced with `"whateverName"` / `"whateverDescription"` because a real-sounding payment name on a placeholder constant with `EnumPayment.NO_PAYMENT` would be contradictory and misleading.

### src/main/java/com/intershop/oms/ps/rest/DefaultOptionsExceptionHandler.java
**Action:** deleted
**Reason:** Superseded by `com.intershop.oms.rest.exceptions.DefaultOptionsMethodExceptionMapper` in IOM 6.
**Details:** File was unmodified from archetype template (same logic, same `@Provider` + `ExceptionMapper<DefaultOptionsMethodException>` pattern). No other project file referenced this class. Both deletion conditions met.

### src/main/java/com/intershop/oms/ps/rest/ExceptionHandler.java
**Action:** skipped (kept as-is)
**Reason:** Contains project-specific logic — handles `OMSAuthorizeException` and has custom error mapping beyond the archetype template. Cannot be deleted.
**Details:** No imports from removed dependencies are present in this file (SLF4J is used but still available via WildFly; the only removed dep was the explicit `slf4j-api` provided declaration). No action required.

### src/main/java/com/intershop/oms/ps/rest/JacksonObjectMapperProvider.java
**Action:** deleted
**Reason:** Superseded by `com.intershop.oms.rest.provider.JacksonContextResolver` in IOM 6. The `jackson-datatype-jsr310` dependency it used was removed.
**Details:** File was unmodified from archetype template. No other project file referenced this class. Both deletion conditions met.

### src/main/java/com/intershop/oms/ps/rest/filter/BasicAuthSecurityContext.java
**Action:** skipped (kept as-is)
**Reason:** Referenced by `IOMAuthFilter`, which has project-specific authentication logic and cannot be deleted.
**Details:** `BasicAuthSecurityContext` is an internal helper used by `IOMAuthFilter`. Since `IOMAuthFilter` is kept, this file must also be kept. The platform equivalent `BasicSecurityContext` is only relevant if `IOMAuthFilter` were replaced.

### src/main/java/com/intershop/oms/ps/rest/filter/CORSFilter.java
**Action:** deleted
**Reason:** Superseded by `com.intershop.oms.rest.provider.CORSFilter` in IOM 6.
**Details:** File was unmodified from archetype template. No other project file referenced this class. Both deletion conditions met.

### src/main/java/com/intershop/oms/ps/rest/filter/IOMAuthFilter.java
**Action:** skipped (kept as-is)
**Reason:** Contains project-specific authentication logic — calls `userLoginLogicService.authorizeUserCrypted` and sets a `BasicAuthSecurityContext`. The logic is different from the archetype template; this is a customized authentication filter.
**Details:** No imports from removed dependencies in this file. No action required.

### src/main/java/com/intershop/oms/ps/rest/RestServiceApplication.java
**Action:** skipped
**Reason:** File contains only `@ApplicationPath("api")` and extends `Application` with no registered classes. No references to deleted classes.

### src/main/java/com/intershop/oms/ps/rest/logging/DynamicLoggingFeature.java
**Action:** changed
**Reason:** References to `SLF4JContainerLoggingHandler` and `SLF4JWriterInterceptor` replaced with platform equivalents per IOM 6 migration.
**Details:**
- Removed import `com.intershop.oms.ps.rest.logging.sl4j.SLF4JContainerLoggingHandler`
- Removed import `com.intershop.oms.ps.rest.logging.sl4j.SLF4JWriterInterceptor`
- Added import `com.intershop.oms.rest.logging.LoggingHandler`
- Added import `com.intershop.oms.rest.logging.LoggingWriterInterceptor`
- `context.register(SLF4JContainerLoggingHandler.class)` → `context.register(LoggingHandler.class)`
- `context.register(SLF4JWriterInterceptor.class)` → `context.register(LoggingWriterInterceptor.class)`
- The project-specific `DATABASE_LOGGING_PACKAGE_BLACKLIST` and all custom logic was preserved unchanged.

### src/main/java/com/intershop/oms/ps/rest/logging/sl4j/SLF4JContainerLoggingHandler.java
**Action:** deleted
**Reason:** Superseded by `com.intershop.oms.rest.logging.LoggingHandler`. After updating `DynamicLoggingFeature`, no project file referenced this class.
**Details:** All callers were migrated to platform equivalent before deletion.

### src/main/java/com/intershop/oms/ps/rest/logging/sl4j/SLF4JWriterInterceptor.java
**Action:** deleted
**Reason:** Superseded by `com.intershop.oms.rest.logging.LoggingWriterInterceptor`. After updating `DynamicLoggingFeature` and `ClientBuilder`, no project file referenced this class.
**Details:** All callers were migrated to platform equivalent before deletion.

### src/main/java/com/intershop/oms/ps/util/ClientBuilder.java
**Action:** changed
**Reason:** Referenced `SLF4JWriterInterceptor` which is deleted in this migration.
**Details:**
- Removed import `com.intershop.oms.ps.rest.logging.sl4j.SLF4JWriterInterceptor`
- Added import `com.intershop.oms.rest.logging.LoggingWriterInterceptor`
- `webClient.register(SLF4JWriterInterceptor.class)` → `webClient.register(LoggingWriterInterceptor.class)`
- `SLF4JClientLoggingHandler` was kept unchanged (no platform equivalent for client-side logging).

### src/main/java/com/intershop/oms/ps/rest/logging/LoggingIOStreamHandler.java
**Action:** changed
**Reason:** Contains a method `readEntity(HttpResponse)` using `org.apache.http.*` types dropped in WildFly 40.
**Details:**
- Removed imports `org.apache.http.Header`, `org.apache.http.HttpResponse`, `org.apache.http.client.entity.EntityBuilder`, `org.apache.http.entity.ContentType`
- Removed method `readEntity(HttpResponse response)` — its only purpose was to use Apache HttpClient types; no replacement is possible without the library.

### src/main/java/com/intershop/oms/ps/rest/logging/MaskedHeaders.java
**Action:** changed
**Reason:** Contains a method `of(Header[] headers)` using `org.apache.http.Header` dropped in WildFly 40.
**Details:**
- Removed import `org.apache.http.Header`
- Removed method `of(Header[] headers)` — its only purpose was to convert Apache HttpClient `Header[]` arrays.

### azure-pipelines.yml
**Action:** skipped
**Reason:** Delegates entirely to `ci-job-template.yml` in `iom-partner-devops` with no hardcoded JDK version, Helm chart version, or `Maven@4` references. No changes required.

### Helm values files
**Action:** skipped
**Reason:** No `helm-values*.yaml` files found in the project. Standard generated projects do not contain them.

## Files Flagged for Manual Review

_(none — all files could be handled automatically or cleanly skipped)_

## Follow-up Tasks

### com.evolvedbinary.maven.jvnet:jaxb30-maven-plugin
**Current version:** `0.15.0`
**Reason:** Project-specific plugin not covered by the IOM 6 archetype — version was not reviewed as part of this migration.

### org.junit.version (JUnit 5 → 6 upgrade)
**Current version:** `5.9.2`
**Reason:** Intentionally left unchanged. JUnit is independent of the IOM platform version. Upgrading JUnit 5 → 6 requires migrating test implementations and is a separate follow-up task. See JUnit migration documentation.

## Decisions and Observations

- **`org.junit.version` not updated:** Per migration strategy, JUnit version is intentionally left at `5.9.2`. A JUnit 5 → 6 upgrade requires test code changes and should be scheduled separately.

- **SLF4J logging in kept files:** `ExceptionHandler.java` uses `org.slf4j.Logger`/`LoggerFactory`. Although the explicit `slf4j-api` provided dependency was removed from `pom.xml`, SLF4J is still available as a WildFly module and the code will continue to compile and run. No change was needed.

- **`IOMAuthFilter` and `BasicAuthSecurityContext` kept:** Both files contain project-specific authentication logic beyond the archetype template. The platform equivalent `AuthenticationFilter` would not cover the custom `authorizeUserCrypted` call. These files are intentionally kept and no callers need migration.

- **`ExceptionHandler` kept:** Contains project-specific error handling for `OMSAuthorizeException`. The platform `ExceptionHandler` replacement would not cover this custom case.

- **SLF4J transitive effects:** No `logback` or `log4j` logging backends were found in `pom.xml`. No action needed for SLF4J 2.x compatibility.

- **`jackson-annotations` pin:** No explicit `com.fasterxml.jackson.core:jackson-annotations` version override found in `<dependencyManagement>`. The WildFly 40 BOM will provide the correct version. No action needed.

- **Flyway direct API usage:** No `import org.flywaydb` found in `src/test/`. No action needed.

- **`versions-maven-plugin` added to `<pluginManagement>`:** The plugin appeared in `<reporting>` without a version pin in `<pluginManagement>`. Added with version `2.21.0` per migration target.
