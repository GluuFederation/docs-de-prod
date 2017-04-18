[TOC]

# Cluster Management

## Overview

A [Cluster](../../reference/api/cluster/) is a set of containers deployed in one or more [Node](../../reference/api/node/).
The cluster contains information shared across node, like hostname.

To manage cluster, we can use Cluster Web UI or using API directly.
Note, this page only covers how to manage cluster by using the API directly via `curl` command.
To use Web UI, refer to [Web Interface](../webui) page for details.

## Creating Cluster

The following command creates a cluster using `curl`.

```
curl http://localhost:8080/clusters \
    -d name=cluster1 \
    -d org_name=my-org \
    -d org_short_name=my-org \
    -d city=Austin \
    -d state=TX \
    -d country_code=US \
    -d admin_email='info@example.com' \
    -d ox_cluster_hostname=gluu.example.com \
    -d admin_pw=secret \
    -X POST -i
```

The parameters of the command are explained below:

* `name` represents the cluster name or label with which the cluster is identified.
* `org_name`, `org_short_name`, `city`, `state`, `country_code`, and `admin_email` are used for X509 certificate.
* `ox_cluster_hostname` is a URL for the appliance; this name must be a resolvable domain name.
* `admin_pw` is used for LDAP password, LDAP replication password, and oxTrust admin password.

A successful request returns a HTTP 201 status code:

```
HTTP/1.0 201 CREATED
Content-Type: application/json
Location: http://localhost:8080/clusters/1279de28-b6d0-4052-bd0c-cc46a6fd5f9f

{
    "inum_org": "@!FDF8.652A.6EFF.F5A3!0001!DA7B.9EB2",
    "oxauth_containers": [],
    "inum_appliance": "@!FDF8.652A.6EFF.F5A3!0002!FA83.4368",
    "admin_email": "info@example.com",
    "inum_appliance_fn": "FDF8652A6EFFF5A30002FA834368",
    "description": null,
    "city": "Austin",
    "base_inum": "@!FDF8.652A.6EFF.F5A3",
    "inum_org_fn": "FDF8652A6EFFF5A30001DA7B9EB2",
    "ldaps_port": "1636",
    "ox_cluster_hostname": "gluu.example.com",
    "state": "TX",
    "country_code": "US",
    "ldap_containers": [],
    "nginx_containers": [],
    "org_short_name": "my-org",
    "org_name": "my-org",
    "id": "0085d134-c60a-483f-8e14-ebf7afd362f0",
    "oxtrust_containers": [],
    "name": "cluster1",
    "oxidp_containers": []
}
```

A full reference to Cluster API is available at [Cluster API page](../../reference/api/cluster).

## Creating Provider

Provider represents a service that host the nodes. There are various provider type (driver) supported by Gluu Cluster Docker Edition at the moment:

1. `digitalocean`
2. `aws`
3. `generic`

Note, we will use `digitalocean` as provider throughout this page.

The following command creates a provider using `curl`.

```
curl http://localhost:8080/providers/digitalocean \
    -d name=my_do_provider \
    -d digitalocean_access_token=random-do-token \
    -d digitalocean_region=nyc3 \
    -X POST -i
```

A successful request returns a HTTP 201 status code:

```http
HTTP/1.0 201 CREATED
Content-Type: application/json
Location: http://localhost:8080/providers/4362b1a2-ce6a-4b06-9a97-6ba9a0b952ea

{
    "digitalocean_access_token": "random-do-token",
    "digitalocean_backups": false,
    "digitalocean_image": "ubuntu-14-04-x64",
    "digitalocean_ipv6": false,
    "digitalocean_private_networking": false,
    "digitalocean_region": "nyc3",
    "digitalocean_size": "4gb",
    "driver": "digitalocean",
    "id": "4362b1a2-ce6a-4b06-9a97-6ba9a0b952ea",
    "name": "my_do_provider"
}
```

We will need the `provider_id` when creating nodes, so let's keep the reference to `provider_id` as environment variable.

```
export PROVIDER_ID=4362b1a2-ce6a-4b06-9a97-6ba9a0b952ea
```

A full reference to Provider API is available at [Provider API page](../../reference/api/provider).

## Creating Nodes and Containers

Once we have one or more providers, we can create node. Node represents the actual server to host containers.
There are 3 node types supported by Gluu Cluster Docker Edition at the moment:

1. Discovery
2. Master
3. Worker (optional)

A full reference to Node API is available at [Node API page](../../reference/api/node).


### Creating Discovery Node

Discovery node provides service discovery for all containers in the cluster. This node only hosts a single `consul` container, which is automatically created by the API.

#### Creating The Node

The following command creates a discovery node using `curl`.

```
curl http://localhost:8080/nodes/discovery \
    -d name=gluu.discovery \
    -d provider_id=$PROVIDER_ID \
    -X POST -i
```

Note, for `name` parameter, we enforce `gluu.discovery` as its value. Changing the name will ended up in rejected request.

A successful request returns a HTTP 201 status code:

```http
HTTP/1.0 201 CREATED
Content-Type: application/json
Location: http://localhost:8080/nodes/gluu.discovery

{
    "id": "1cd58004-4c87-449a-a918-195ff5af2e15",
    "name": "gluu.discovery",
    "provider_id": "4362b1a2-ce6a-4b06-9a97-6ba9a0b952ea",
    "type": "discovery"
}
```

Creating a node will take a while, hence the process is running as background job. To check the status, we can make request to the URL as shown in `Location` header above.

### Creating Master Node and Containers

Master node provides [Docker Swarm](https://docs.docker.com/swarm/overview/) manager to manage all containers in the cluster.

#### Creating The Node

The following command creates a master node using `curl`.

```
curl http://localhost:8080/nodes/master \
    -d name=gluu-master \
    -d provider_id=$PROVIDER_ID \
    -X POST -i
```

A successful request returns a HTTP 201 status code:

```http
HTTP/1.0 201 CREATED
Content-Type: application/json
Location: http://localhost:8080/nodes/gluu-master

{
    "id": "0c715335-a1fe-4cd8-93f3-73fda8539f88",
    "name": "gluu-master",
    "provider_id": "4362b1a2-ce6a-4b06-9a97-6ba9a0b952ea",
    "type": "master"
}
```

Creating a node will take a while, hence the process is running as background job. To check the status, we can make request to the URL as shown in `Location` header above.

We will need the `node_id` when creating nodes, so let's keep the reference to `node_id` as environment variable.

```
export MASTER_NODE_ID=0c715335-a1fe-4cd8-93f3-73fda8539f88
```

#### SSL Certificate and Key

By default, `gluuengine` will generate a self-signed SSL certificate and key called `nginx.crt` and `nginx.key` under `/var/lib/gluuengine/ssl_certs` directory.
One can use their own SSL certificate and key.
Simply put their SSL certificate as `/var/lib/gluuengine/ssl_certs/nginx.crt` and SSL key as `/var/lib/gluuengine/ssl_certs/nginx.key`.
When those files are exist, `gluuengine` will not generate self-signed certificate and key.

#### Custom LDAP Schema

Any `ldap` container has support for custom schema. To deploy custom schema, put the desired schema in `.ldif` file
on the same machine running `gluu-engine` under `/var/lib/gluuengine/custom/opendj/schema/`.
For example, we can create `/var/lib/gluuengine/custom/opendj/schema/102-customSchema.ldif` for our custom schema.
This file will be added to ldap container located at `/opt/opendj/config/schema/102-customSchema.ldif`.
The schema is copied on ldap server creation.

Please note, custom schema file must be created first before creating any LDAP container.

#### Custom oxAuth Files

Any `oxauth` container has support for custom `xhtml`, `xml`, or even `jar` files.
There are predefined directories (create them if not exist yet) to put this file into:

1. `/var/lib/gluuengine/override/oxauth/pages` for any HTML or XML file.
2. `/var/lib/gluuengine/override/oxauth/libs` for any JAR file.
3. `/var/lib/gluuengine/override/oxauth/resources` for any resource file (e.g. CSS).

Custom oxAuth file can be created before or after `oxauth` container creation.

#### Custom oxTrust Files

Any `oxtrust` container has support for custom `xhtml`, `xml`, or even `jar` files.
There are predefined directories (create them if not exist yet) to put this file into:

1. `/var/lib/gluuengine/override/oxtrust/pages` for any HTML or XML file.
2. `/var/lib/gluuengine/override/oxtrust/libs` for any JAR file.
3. `/var/lib/gluuengine/override/oxtrust/resources` for any resource file (e.g. CSS).

Custom oxTrust file can be created before or after `oxtrust` container creation.

#### Creating Containers

Once we have a running `master` node, we can start creating containers. To ensure the cluster running as expected, the order of container creation is shown below:

1. `ldap`
2. `oxauth`
3. `oxtrust`
4. `nginx`

In this example, we are going to create `ldap` container using `curl`:

```
curl http://localhost:8080/containers/ldap \
    -d node_id=$MASTER_NODE_ID \
    -X POST -i
```

A successful request returns a HTTP 202 status code:

```http
HTTP/1.0 202 ACCEPTED
Content-Type: application/json
Location: http://localhost:8080/containers/gluuopendj_dbaadb89-4703-47e2-9d07-5fa7aa76e616
X-Container-Setup-Log: http://localhost:8080/container_logs/gluuopendj_dbaadb89-4703-47e2-9d07-5fa7aa76e616/setup

{
    "cid": "",
    "cluster_id": "0085d134-c60a-483f-8e14-ebf7afd362f0",
    "hostname": "",
    "id": "c14bd694-3895-4a77-8f51-200a232d5379",
    "ldap_admin_port": "4444",
    "ldap_binddn": "cn=directory manager",
    "ldap_jmx_port": "1689",
    "ldap_port": "1389",
    "ldaps_port": "1636",
    "name": "gluuopendj_dbaadb89-4703-47e2-9d07-5fa7aa76e616",
    "node_id": "0c715335-a1fe-4cd8-93f3-73fda8539f88",
    "state": "IN_PROGRESS",
    "type": "ldap"
}
```

Creating a container will take a while, hence the process is running as background job.
To check the status, we can make request to the URL as shown in `Location` or `X-Container-Setup-Log` header above.

The rest of the containers can be created by using similar `curl` command above. Make sure to change the URL.
For example, instead of sending request to `http://localhost:8080/containers/ldap`,
we need to use `http://localhost:8080/containers/oxauth` and so on.

A full reference to Container API is available at [Container API page](../../reference/api/container).

#### Accessing oxTrust Web Interface

The Gluu Server web interface can be accessed after the deployment of the containers are complete.
The oxTrust UI is run at `https://localhost:8443` in the master node.
To access the UI, `ssh` tunneling must be established through `docker-machine` script that have been installed.

```
docker-machine ssh gluu-master -L 8443:localhost:8443
```

After the tunnel is established, visit `https://localhost:8443` in the web browser.
The oxTrust login page will load asking for a username and a password.

* username: `admin`
* password: `admin_pw` value from the cluster object

If the credentials are supplied correctly, the page will be redirected to the oxTrust dashboard.

### Creating Worker Node and Containers

One of the purposes of creating worker node is to achieve HA setup in the cluster.
It means when master node (and its containers) is unavailable, we still have another node (and its containers) to serve requests.
Although creating worker node is an optional step, it's recommended to do so if we want to achieve full-featured Gluu Cluster.

#### Registering License Key

Registering license key is required before registering any worker node.
Refer to [License](../overview/#license) section to see available license types.

To register license key, we need to obtain code, public password, public key, and license password from Gluu.
Afterwards, we can store them as Gluu Cluster's license key.

The following command will create a new license key.

```sh
curl http://localhost:8080/license_keys \
    -d public_key=unique-public-key \
    -d public_password=unique-public-password \
    -d license_password=unique-license-password \
    -d name=testing \
    -d code=unique-code \
    -X POST -i
```

Here's an example of the response from request above:

```json
{
        "code": "unique-code",
        "id": "cebc74fe-d4f2-4f02-9e99-4187f6b55b93",
        "license_password": "unique-license-password",
        "metadata": {
            "expiration_date": null,
            "license_count_limit": 100,
            "license_features": [
                "gluu_server"
            ],
            "license_name": "testing",
            "license_type": null,
            "multi_server": false,
            "thread_count": 3
        },
        "name": "testing",
        "public_key": "unique-public-key"
        "public_password": "unique-public-password",
        "valid": true
    }

```

Note, `public_key`, `public_password`, and `license_password` must use one-liner values.

#### Creating The Node

The following command creates a worker node using `curl`.

```
curl http://localhost:8080/nodes/worker \
    -d name=gluu-worker \
    -d provider_id=$PROVIDER_ID \
    -X POST -i
```

A successful request returns a HTTP 201 status code:

```http
HTTP/1.0 201 CREATED
Content-Type: application/json
Location: http://localhost:8080/nodes/gluu-master

{
    "id": "0c715335-a1fe-4cd8-93f3-73fda8539f99",
    "name": "gluu-worker",
    "provider_id": "4362b1a2-ce6a-4b06-9a97-6ba9a0b952ea",
    "type": "worker"
}
```

Creating a node will take a while, hence the process is running as background job. To check the status, we can make request to the URL as shown in `Location` header above.

We will need the `node_id` when creating nodes, so let's keep the reference to `node_id` as environment variable.

```
export WORKER_NODE_ID=0c715335-a1fe-4cd8-93f3-73fda8539f99
```

#### Creating Containers

Once we have a running `worker` node, we can start creating containers. To ensure the cluster running as expected, the order of container creation is shown below:

1. `ldap`
2. `oxauth`
3. `nginx`

In this example, we are going to create `ldap` container using `curl`:

```
curl http://localhost:8080/containers/ldap \
    -d node_id=$WORKER_NODE_ID \
    -X POST -i
```

A successful request returns a HTTP 202 status code:

```http
HTTP/1.0 202 ACCEPTED
Content-Type: application/json
Location: http://localhost:8080/containers/gluuopendj_dbaadb89-4703-47e2-9d07-5fa7aa76e617
X-Container-Setup-Log: http://localhost:8080/container_logs/gluuopendj_dbaadb89-4703-47e2-9d07-5fa7aa76e617/setup

{
    "cid": "",
    "cluster_id": "0085d134-c60a-483f-8e14-ebf7afd362f0",
    "hostname": "",
    "id": "c14bd694-3895-4a77-8f51-200a232d5380",
    "ldap_admin_port": "4444",
    "ldap_binddn": "cn=directory manager",
    "ldap_jmx_port": "1689",
    "ldap_port": "1389",
    "ldaps_port": "1636",
    "name": "gluuopendj_dbaadb89-4703-47e2-9d07-5fa7aa76e617",
    "node_id": "0c715335-a1fe-4cd8-93f3-73fda8539f99",
    "state": "IN_PROGRESS",
    "type": "ldap"
}
```

Creating a container will take a while, hence the process is running as background job.
To check the status, we can make request to the URL as shown in `Location` or `X-Container-Setup-Log` header above.

The rest of the containers can be created by using similar `curl` command above. Make sure to change the URL.
For example, instead of sending request to `http://localhost:8080/containers/ldap`,
we need to use `http://localhost:8080/containers/oxauth` and so on.

#### LDAP Replication

As we have two LDAP containers in the cluster (one each in master and worker node), all these LDAP containers will replicate themselves.
However we need to check whether replication are created successfully by login to one of the LDAP containers.

We can list all containers in the cluster by running the following command:

```
docker `docker-machine config --swarm gluu-master` ps
```

Here's an example of the output:

```
CONTAINER ID        IMAGE                               NAMES
f7f150462622        registry.gluu.org:5000/gluuopendj   gluu-worker/gluuopendj_e7c3ce2c-3d0f-40a1-bdd2-c4bfbabb6b16
41ccbfdbd124        registry.gluu.org:5000/gluuopendj   gluu-master/gluuopendj_094ca34d-bd4b-4112-96f0-140b9652f20f
```

From the example above, we know that one of the LDAP containers is having `41ccbfdbd124` as its ID. We can login to this container by running this command:

    docker `docker-machine config --swarm gluu-master` exec -ti 41ccbfdbd124 bash

Once we are logged into the container, we can check the replication status by running the following command:

    /opt/opendj/bin/dsreplication status
