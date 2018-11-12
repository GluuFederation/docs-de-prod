[TOC]

# Installation

The Gluu Docker Edition only supports Ubuntu for now. We need three containers to install Gluu Docker Edition management system.

1. gluuengine
2. gluuwebui
3. mongodb (as database)

## Prerequisites

### Minimum Linux Kernel

Cluster requires at least kernel 3.10 at minimum. We can check whether we're using supported kernel.

    uname -r

Please note, due to [issue with kernel 3.13.0-77](../known-issues#unsupported-kernel), this version should be avoided.

## Docker Engine

### Installing Docker Engine

Run this:

```
$ sudo curl -fsSL https://raw.githubusercontent.com/GluuFederation/cluster-tools/master/get_docker.sh | sh
```

## Installing and running Gluu Docker Edition management system

### Installing gluuengine and gluuwebui images

From docker hub (not yet released):

```sh
docker pull gluu/gluuengine
docker pull gluu/gluuwebui
```

Alternatively you can build it:

```sh
git clone https://github.com/GluuFederation/gluu-docker.git
docker build --rm=true --force-rm=true --tag=gluuengine gluu-docker/ubuntu/14.04/gluuengine
docker build --rm=true --force-rm=true --tag=gluuwebui gluu-docker/ubuntu/14.04/gluuwebui
```

### Preparing Database

Pull the mongodb image and run its container:

```sh
docker run -d --name mongo -v /var/lib/gluuengine/db/mongo:/data/db mongo
```

### Running gluuengine

gluuengine command:

```sh
docker run -d -p 127.0.0.1:8080:8080 --name gluuengine \
    -v /var/log/gluuengine:/var/log/gluuengine \
    -v /var/lib/gluuengine:/var/lib/gluuengine \
    -v /var/lib/gluuengine/machine:/root/.docker/machine \
    --link mongo:mongo gluuengine
```

### Running gluuwebui

gluuwebui command:

```sh
docker run -d -p 127.0.0.1:8800:8800 --name gluuwebui \
    --link gluuengine:gluuengine gluuwebui
```

As gluuwebui is running in remote server, we need to do SSH tunneling:

```sh
ssh -L 8800:localhost:8800 <user>@<host_or_ip_address>
```

There are few things we need to know about Gluu Docker Edition Web UI:

1. The application is bind to 127.0.0.1 (localhost) as currently there's no protection mechanism yet.
2. The application is listening on port 8800 to avoid conflict with port exposed to nodes.
