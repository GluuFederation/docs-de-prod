## Overview

A common question using custom LDAP schema in Gluu Server DE containers is when to mount the file and where to put it.
This guide will explain how to use custom schema in OpenDJ containers in various scenarios.

## Adding Schema Before Deployment

It is important to know that during first deployment of OpenDJ container, we cannot mount any file to `/opt/opendj/config`,
otherwise the installation will fail. Fortunately, during installation, OpenDJ will copy schema from `/opt/opendj/template/config/schema` to `/opt/opendj/config/schema` directory.

Below is example on how to mount custom schema:

    docker run \
        -v /path/to/78-myAttributes.ldif:/opt/opendj/template/config/schema/78-myAttributes.ldif \
        gluufederation/opendj:3.1.5_01

As we can see, the `78-myAttributes.ldif` is mounted as `/opt/opendj/template/config/schema/78-myAttributes.ldif` inside the container, which eventually will be copied to `/opt/opendj/config/schema/78-myAttributes.ldif` automatically.
This custom schema will be loaded by OpenDJ server upon startup.

## Adding Schema After Deployment

In this scenario, we assume container has been running and somehow we need to add new schema named `79-otherAttributes.ldif`.
Mounting this file into `/opt/opendj/template/config/schema` won't work as it will not be copied to `/opt/opendj/config/schema` directory inside the container. Instead, we are going to mount the file to `/opt/opendj/config/schema` directly.

    docker run \
        -v /path/to/79-otherAttributes.ldif:/opt/opendj/config/schema/79-otherAttributes.ldif \
        gluufederation/opendj:3.1.5_01

__Note__: adding new schema may require restarting the container.

## Custom Schema in Multiple OpenDJ Containers

### Using Docker Config (Swarm Mode)

Create config to store the contents of custom schema `78-myAttributes.ldif`.

    docker config create custom-ldap-schema 78-myAttributes.ldif

Mount the schema (depends on deployment scenario) into container:

    # before deployment
    services:
      opendj:
        image: gluufederation/opendj:3.1.5_01
        configs:
          - source: custom-ldap-schema
            target: /opt/opendj/template/config/schema/78-myAttributes.ldif

    configs:
      custom-ldap-schema:
        external: true

Or:

    # after deployment, restart service if needed
    services:
      opendj:
        image: gluufederation/opendj:3.1.5_01
        configs:
          - source: custom-ldap-schema
            target: /opt/opendj/config/schema/78-myAttributes.ldif

    configs:
      custom-ldap-schema:
        external: true

### Using Kubernetes ConfigMaps

Create config to store the contents of custom schema `78-myAttributes.ldif`.

    kubectl create cm opendj-custom-schema --from-file=78-myAttributes.ldif

Mount the schema (depends on deployment scenario) into container:

    # before deployment
    apiVersion: v1
    kind: StatefulSet
    metadata:
      name: opendj
    spec:
      containers:
        image: gluufederation/opendj:3.1.5_01
        volumeMounts:
          - name: opendj-schema-volume
            # schema will be mounted under this directory
            mountPath: /opt/opendj/template/config/schema
      volumes:
        - name: opendj-schema-volume
          configMap:
            name: opendj-custom-schema

Or:

    # after deployment, restart service if needed
    apiVersion: v1
    kind: StatefulSet
    metadata:
      name: opendj
    spec:
      containers:
        image: gluufederation/opendj:3.1.5_01
        volumeMounts:
          - name: opendj-schema-volume
            # schema will be mounted under this directory
            mountPath: /opt/opendj/config/schema
      volumes:
        - name: opendj-schema-volume
          configMap:
            name: opendj-custom-schema
