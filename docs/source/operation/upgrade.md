# Upgrading to version 3.1.6

## Overview

The Gluu Server Docker Edition cannot be upgraded with a simple apt-get upgrade. This guide outlines the steps required to complete the upgrade from previous versions.

## LDAP

### Backup Existing Data

Before running the upgrade process, make sure to backup existing LDAP data.

### Updating Schema

1.  Download the latest [101-ox.ldif](https://github.com/GluuFederation/docker-opendj/raw/3.1.6/schemas/101-ox.ldif) schema.

1.  Depends on the setup, there are various ways to mount the file into container.

    1.  For a single host setup, mount `101-ox.ldif` to OpenDJ container directly. This is an example using `docker-compose.yml`:

            services:
              opendj:
                image: gluufederation/opendj:3.1.6_02
                volumes:
                  - /path/to/101-ox.ldif:/opt/opendj/config/schema/101-ox.ldif

    1.  For a multi-hosts setup using Docker Swarm Mode, we recommend to put the contents of `101-ox.ldif` into Docker Config:

            docker config create 101-ox /path/to/101-ox.ldif

        and then mount the file into container:

            services:
              opendj:
                image: gluufederation/opendj:3.1.6_02
                configs:
                  - source: 101-ox
                    target: /opt/opendj/config/schema/101-ox.ldif

            configs:
              101-ox:
                external: true

    1.  For a multi-hosts setup using Kubernetes, put the contents of `101-ox.ldif` into ConfigMaps:

            kubectl create cm opendj-schema --from-file=/path/to/101-ox.ldif

        and then mount the file into container:

            apiVersion: v1
            kind: StatefulSet
            metadata:
            name: opendj
            spec:
              containers:
                image: gluufederation/opendj:3.1.6_02
                volumeMounts:
                  - name: opendj-schema-volume
                    mountPath: /opt/opendj/config/schema/101-ox.ldif
                    subPath: 101-ox.ldif
              volumes:
                - name: opendj-schema-volume
                  configMap:
                    name: opendj-schema

1.  Restart the container/service to allow changes in schema.

## Upgrading from Docker Edition 3.1.4

The following steps are only required if upgrading to v. 3.1.6 from 3.1.4. If upgrading from 3.1.5, skip down to [Upgrade Container](#upgrade-container)

### Reconfiguring Backends

1.  Resize the `site` backend:

        docker exec -ti opendj /opt/opendj/bin/dsconfig \
            --trustAll \
            --bindDN "cn=directory manager" \
            --port 4444 \
            --hostname 0.0.0.0 \
            set-backend-prop --backend-name site --set db-cache-percent:20

1.  Restart the OpenDJ container/service to free JVM heap memory.

1.  Resize the `userRoot` backend:

        docker exec -ti opendj /opt/opendj/bin/dsconfig \
            --trustAll \
            --bindDN "cn=directory manager" \
            --port 4444 \
            --hostname 0.0.0.0 \
            set-backend-prop --backend-name userRoot --set db-cache-percent:70

1.  Create the `metric` backend:

         docker exec -ti opendj /opt/opendj/bin/dsconfig \
            --trustAll \
            --bindDN "cn=directory manager" \
            --port 4444 \
            --hostname 0.0.0.0 \
            create-backend \
                --backend-name metric \
                --set base-dn:o=metric \
                --type je \
                --set enabled:true \
                --set db-cache-percent:10

### Kubernetes Secrets

For Kubernetes-based deployment, the `Role` object must be modified to add access to `secrets` API.

Example:

```
# config-roles.yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: gluu-role
  namespace: default
rules:
- apiGroups: [""] # "" refers to the core API group
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

Afterwards, run the following command `kubectl apply -f config-roles.yaml`

## Upgrade Container

By running the `gluufederation/upgrade:3.1.6_03` container, the LDAP data will be adjusted to match conventions in 3.1.6.

### Upgrade container from 3.1.5

    ```
    docker run \
        --rm \
        --net container:consul \
        -e GLUU_CONFIG_CONSUL_HOST=consul \
        -e GLUU_SECRET_VAULT_HOST=vault \
        -e GLUU_LDAP_URL=ldap:1636 \
        -v /path/to/vault_role_id.txt:/etc/certs/vault_role_id \
        -v /path/to/vault_secret_id.txt:/etc/certs/vault_secret_id \
        gluufederation/upgrade:3.1.6_03 --source 3.1.5 --target 3.1.6
    ```

### Upgrade container from 3.1.4

    ```
    docker run \
        --rm \
        --net container:consul \
        -e GLUU_CONFIG_CONSUL_HOST=consul \
        -e GLUU_SECRET_VAULT_HOST=vault \
        -e GLUU_LDAP_URL=ldap:1636 \
        -v /path/to/vault_role_id.txt:/etc/certs/vault_role_id \
        -v /path/to/vault_secret_id.txt:/etc/certs/vault_secret_id \
        gluufederation/upgrade:3.1.6_03 --source 3.1.4 --target 3.1.6
    ```

!!! Note
    The upgrade process doesn't update custom scripts for oxAuth/oxTrust to avoid overwriting a script that was modified by users. They must be updated them manually.
