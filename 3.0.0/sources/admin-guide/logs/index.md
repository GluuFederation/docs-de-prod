[TOC]
# Logs
## Introduction
The logs in the Gluu Server Docker Edition are made accessible from a central service called Message-consumer using RESTful API. The design of the central loggin system uses [activemq](http://activemq.apache.org/) messaging server and any one of [postgresql](https://www.postgresql.org/) or [mysql](https://www.mysql.com/). The logs are read in an asynchronous manner and stored in the database for custom searches. The REST API is used to read and seach thrugh the messages. It must be noted that old messages/logs are removed from time to time, configurable from the application properties.

The log messages are expected to be objects of `org.apache.log4j.spi.LoggingEvent` in JSON stings.

## Installation
### Pre-requisites
The scema for the database used to store the logs must be created before installing the message-consumer.

#### MySQL
The schema template for mysql is available in the link given below. Please use the template to create the schema.

* [MySQL Schema](https://raw.githubusercontent.com/GluuFederation/message-consumer/master/schema/mysql_schema.sql)

Please use the following command template to install the schema

```
# source ${path_to_file}/mysql_schema.sql
```

#### PostgreSQL
The following template can be used to create the schema for postgresql.

* [PostgreSQL Schema](https://raw.githubusercontent.com/GluuFederation/message-consumer/master/schema/postgresql_schema.sql)

Please edit the file to change the database owner and the postgresql user.
The example below shows how to create a user named `gluu` and create the database schema:

```
CREATE USER gluu WITH password 'root';
\i ${path_to_file}/postgresql_schema.sql
```

!!! Note
    Please update `pring.datasource.username` and `spring.datasource.password` in `application-prod-postgresql.properties` after creating new postgresql user

#### activeMQ
The message-consumer component uses the activeMQ messaging server. The followng steps will guide you through the installation porcess.

1. Download the activemq zipped tarball file to the Unix machine from [this link](http://activemq.apache.org/download.html)

2. Please use the following command to extract the archive
```
tar -xvzf apache-activemq-x.x.x-bin.tar.gz
```

3. Edit the `apache-activemq-x.x.x-bin.tar.gz/bin/env` to specify the location of JAVA_HOME

4. Run the server with the following command
```
apache-activemq-x.x.x-bin.tar.gz/bin/activemq start
```

The activeMQ console will be available at `http://localhost:8161/`.

### Building Message Consumer
There are two separate production profiles for the message-consumer component: `prod-mysql` and `prod-postgresql`. Please make sure that MySQL/PostgreSQL is running and schema is created and activeMQ is installed and running. Please make sure to check the `application-{profile}.properties` file for any error in configuration.

The example below shows how to build the message-consumer for MySQL.

```
$ git clone https://github.com/GluuFederation/message-consumer.git
$ cd message-consumer/
$ sudo mvn -Pprod-mysql clean package
$ java -jar target/message-consumer-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod-mysql
```

The message-consumer for PostgreSQL can be build with the commands below:

```
$ git clone https://github.com/GluuFederation/message-consumer.git
$ cd message-consumer/
$ sudo mvn -Pprod-postgresql clean package
$ java -jar target/message-consumer-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod-postgresql
```

## Configuration
The steps below will enable the oxAuth server to send logging messages via JMS. 

1. Please add [JMSQueueAppender](https://gist.github.com/worm333/fd60ed5535878c423c228ccb7617748e) into the classpath of [oxAuth Server](https://github.com/GluuFederation/oxAuth/tree/master/Server/src/main/java/org/xdi/oxauth/appender)

2. Please add the follwing snippet into the `log4j.xml` file under `/opt/tomcat/webapps/oxauth/WEB-INF/classes` folder.
```
    <appender name="JMS" class="org.xdi.oxauth.audit.JMSQueueAppender">
        <param name="InitialContextFactoryName"
            value="org.apache.activemq.jndi.ActiveMQInitialContextFactory" />
        <param name="ProviderURL" value="tcp://localhost:61616"/>
        <param name="QueueBindingName" value="server" />
        <param name="QueueConnectionFactoryBindingName" value="ConnectionFactory" />
        <param name="UserName" value="admin" />
        <param name="Password" value="admin" />

        <layout class="org.apache.log4j.PatternLayout">
            <!-- The default pattern: Date Priority [Category] (Thread) Message\n -->
            <param name="ConversionPattern" value="%d %-5p [%c{6}] (%t) %m%n" />
        </layout>
    </appender>
```

3. Please add `<appender-ref ref="JMS"/>` in the `root` tag in the `log4j.xml` file.

4. Create `jndi.properties` file in the resources folder and put the following in the file.

```
queue.server=oxauth.server.logging
```
### External properties
 The following porperties can be customised besides the standard spring boot porperties:
 * `message-consumer.oauth2-audit.destination` - defines activemq queue name for oauth2 audit logging
 * `message-consumer.oauth2-audit.days-after-logs-can-be-deleted` - defines how many days the oauth2 audit logging data should be kept
 * `message-consumer.oauth2-audit.cron-for-log-cleaner` - defines cron expression for oauth2 audit logging data cleaner
 * `message-consumer.oxauth-server.destination` - defines activemq queue name for oxauth server logs
 * `message-consumer.oxauth-server.days-after-logs-can-be-deleted` - defines how many days the oxauth server logging data should be kept
 * `message-consumer.oxauth-server.cron-for-log-cleaner` - defines cron expression for oxauth server logging data cleaner
## Log API
The following table shows the API calls for the log related functions with the required parameters. The required parameters are given in the table below followed by the API calls.

|Reruired Parameter|Description|Example|
|------------------|------------|------|
|ip|The IP address of the oxauth server| 10.0.2.2|
|action|The event which triggered the log | USER_AUTHORIZATION|
|clientID|The ID of the client|@!7A06.6...|
|username|The username for whom the search is performed|admin|
|scope|The scopes released to the client | openid profile email user_name|
|success|Return true if log found, else false|true|
|timestamp|The time when the log was noted| 2016-10-03T12:53:47.509+0000|


|API Fuction| Oauth2 Log | OxAuth Log|
|--|--|--|
|Get All Logs|/api/oauth2-audit-logs{?page,size,sort}|/api/oxauth-server-logs{?page,size,sort}|
|Get Single Log|/api/oauth2-audit-logs/{id}|/api/oxauth-server-logs/{id}|
|Search Log|/api/oauth2-audit-logs/search/query{?ip,clientId,action,<br/>username,scope,success,fromDate,toDate,page,size,sort}|/api/oxauth-server-logs/search/query{?level,<br/>loggerName,formattedMessage,fromDate,toDate,page,size,sort}|

!!! Note
    Please remember to add the hostname of the log server before the log api commands given above.

### Example
This section gives an example of a log search command.

```
curl http://localhost:8080/api/oauth2-audit-logs/search/query?ip=10.0.2.2&username=admin&scope=openid&size=1
```

The response received is given below:

```
{
  "_embedded" : {
    "oauth2-audit-logs" : [ {
      "ip" : "10.0.2.2",
      "action" : "USER_AUTHORIZATION",
      "clientId" : "@!7A06.6C73.B7D4.3983!0001!CFEA.2908!0008!13E4.C749",
      "username" : "admin",
      "scope" : "openid profile email user_name",
      "success" : true,
      "timestamp" : "2016-10-03T12:53:47.509+0000",
      "_links" : {
        "self" : {
          "href" : "http://localhost:8080/api/oauth2-audit-logs/3335"
        },
        "oAuth2AuditLoggingEvent" : {
          "href" : "http://localhost:8080/api/oauth2-audit-logs/3335"
        }
      }
    } ]
  },
  "_links" : {
    "first" : {
      "href" : "http://localhost:8080/api/oauth2-audit-logs/search/query?ip=10.0.2.2&username=admin&scope=openid&page=0&size=1"
    },
    "self" : {
      "href" : "http://localhost:8080/api/oauth2-audit-logs/search/query?ip=10.0.2.2&username=admin&scope=openid&size=1"
    },
    "next" : {
      "href" : "http://localhost:8080/api/oauth2-audit-logs/search/query?ip=10.0.2.2&username=admin&scope=openid&page=1&size=1"
    },
    "last" : {
      "href" : "http://localhost:8080/api/oauth2-audit-logs/search/query?ip=10.0.2.2&username=admin&scope=openid&page=1&size=1"
    }
  },
  "page" : {
    "size" : 1,
    "totalElements" : 2,
    "totalPages" : 2,
    "number" : 0
  }
}
```

#### Search
It is mandatory to perform search using the following format when the search is performed using date.

| Search Format| Example|
|--|--|
|yyyy-MM-dd HH:mm:ss.SSS|/api/oauth2-audit-logs/search/query?fromDate=2016-10-03%2015:53:47.509|

## Database Schema
### List of Relations
Schema |                 Name                  | Type  | Owner
--------|:------------------------------------:|------:|-------
 public | oauth2_audit_logging_event            | table | gluu
 public | oxauth_server_logging_event           | table | gluu
 public | oxauth_server_logging_event_exception | table | gluu

### oAuth2 Logging
#### Event
The following table shows the logged parameters of any event for oauth2.

|Parameter |            Type             | Modifiers | Storage  |
|----------|:----------------------------|-----------|----------|
|id        | bigint                      | not null  | plain    |
|action    | character varying(255)      |           | extended |
|client_id | character varying(255)      |           | extended |
|ip        | character varying(255)      |           | extended |
|mac_address| character varying(255)     |           | extended |
|scope     | character varying(255)      |           | extended |
|success   | boolean                     |           | plain    |
|timestamp | timestamp without time zone |           | plain    |
|username  | character varying(255)      |           | extended |

The following shows the log indexes for oauth2.

```
    "oauth2_audit_logging_event_pkey" PRIMARY KEY, btree (id)
    "oauth2_audit_logging_event_timestamp" btree ("timestamp")
```

#### Logging events
The following table shows the events that are saved in the logs.

|Column            |            Type             | Modifiers | Storage  |
|------------------|-----------------------------|-----------|----------|
|id                | bigint                      | not null  | plain    |
|formatted_message | text                        |           | extended |
|level             | character varying(255)      |           | extended |
|logger_name       | character varying(255)      |           | extended |
|timestamp         | timestamp without time zone |           | plain    |

The following shows the log indexes log indexes

```
    "oxauth_server_logging_event_pkey" PRIMARY KEY, btree (id)
    "oxauth_server_logging_event_timestamp" btree ("timestamp")
```

The logging events are referenced by the following:

```
    TABLE "oxauth_server_logging_event_exception" CONSTRAINT "fktp5p28uolrsx6vlj6annm7255" FOREIGN KEY (oxauth_server_logging_event_id) REFERENCES oxauth_server_logging_event(id)
```

#### Exceptions
The following table lists the exceptions to the logging events:

            Column             |          Type          | Modifiers | Storage  |
--------------------------------|:----------------------:|----------:|---------:|
 id                             | bigint                 | not null  | plain    |
 index                          | integer                |           | plain    |   
 trace_line                     | text                   |           | extended |   
 oxauth_server_logging_event_id | bigint                 |           | plain    |

The index for the exception is
```
    "oxauth_server_logging_event_exception_pkey" PRIMARY KEY, btree (id)
```

The foreign key constrains are:

```
    "fktp5p28uolrsx6vlj6annm7255" FOREIGN KEY (oxauth_server_logging_event_id) REFERENCES oxauth_server_logging_event(id)
```
