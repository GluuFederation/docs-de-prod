## Upgrading from v3.1.4 to v3.1.5

Gluu Server DE 3.1.5 introduces a secrets layer which depends on the selected secrets adapter (`vault` or `kubernetes`), the migration may need to configure the secret backend first. Otherwise startup for all Gluu Server containers will wait (and eventually crash) for secrets backend to be available.

### Prerequisites

Gluu Server DE 3.1.5 introduces new variables and deprecates some. See [Reference](../reference/index.md) documentation on these changes. Also it it best to compare the latest deployment examples with your existing setup to see what changes need to be applied.

### Vault

If Vault is selected as secrets adapter, we may see a similar logs message upon container startup as shown below:

    $ docker logs -f --tail=10 opendj
    WARNING - 2019-01-28 17:36:03,099 - Secret backend is not ready; reason=Vault is sealed; retrying in 5 seconds.

The logs message indicates Vault hasn't initialized and/or unsealed.
If Vault has been configured properly, eventually the container will show a similar logs message:

    INFO - 2019-01-28 17:43:37,088 - Secret backend is ready.

Refer to [Vault operation guide](./vault.md) to setup Vault.

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

### LDAP

#### Backup Existing Data

Before running the upgrade process, make sure to backup existing LDAP data.

#### Updating Schema

1.  Download the latest [101-ox.ldif](https://github.com/GluuFederation/docker-opendj/raw/3.1.5/schemas/101-ox.ldif) schema.

1.  Depends on the setup, there are various ways to mount the file into container.

    1.  For a single host setup, mount `101-ox.ldif` to OpenDJ container directly. This is an example using `docker-compose.yml`:

            services:
              opendj:
                image: gluufederation/opendj:3.1.5_02
                volumes:
                  - /path/to/101-ox.ldif:/opt/opendj/config/schema/101-ox.ldif

    1.  For a multi-hosts setup using Docker Swarm Mode, we recommend to put the contents of `101-ox.ldif` into Docker Config:

            docker config create 101-ox /path/to/101-ox.ldif

        and then mount the file into container:

            services:
              opendj:
                image: gluufederation/opendj:3.1.5_02
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
                image: gluufederation/opendj:3.1.5_02
                volumeMounts:
                  - name: opendj-schema-volume
                    mountPath: /opt/opendj/config/schema/101-ox.ldif
                    subPath: 101-ox.ldif
              volumes:
                - name: opendj-schema-volume
                  configMap:
                    name: opendj-schema

1.  Restart the container/service to allow changes in schema.

#### Reconfiguring Backends

1.  Resize the `site` backend:

        docker exec -ti opendj /opt/opendj/bin/dsconfig \
            --trustAll \
            --bindDN "cn=directory manager" \
            --port 4444 \
            --hostname 0.0.0.0 \
            set-backend-prop --backend-name site --set db-cache-percent:20

    Enter the password when prompted and choose `f` on last prompt (see example below).

    ```
    >>>> Configure the properties of the site

    Enter choice [f]:         Property           Value(s)
        ---------------------------
    1)  backend-id         site
    2)  base-dn            o=site
    3)  compact-encoding   true
    4)  db-cache-percent   20
    5)  db-cache-size      0 b
    6)  db-directory       db
    7)  enabled            true
    8)  index-entry-limit  4000
    9)  writability-mode   enabled
    ?)  help
    f)  finish - apply any changes to the site
    q)  quit
    ```

1.  Restart the OpenDJ container/service to free JVM heap memory.

1.  Resize the `userRoot` backend:

        docker exec -ti opendj /opt/opendj/bin/dsconfig \
            --trustAll \
            --bindDN "cn=directory manager" \
            --port 4444 \
            --hostname 0.0.0.0 \
            set-backend-prop --backend-name userRoot --set db-cache-percent:70

    A similar prompt will be shown as found in step 1.

1.  Create `metric` backend:

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

    A similar prompt will be shown as found in step 1.

### Upgrade Container

By running the `gluufederation/upgrade:3.1.5_02` container, the LDAP data will be adjusted to match conventions in 3.1.5.

    docker run \
        --rm \
        --net container:consul \
        -e GLUU_CONFIG_CONSUL_HOST=consul \
        -e GLUU_SECRET_VAULT_HOST=vault \
        -e GLUU_LDAP_URL=ldap:1636 \
        -v /path/to/vault_role_id.txt:/etc/certs/vault_role_id \
        -v /path/to/vault_secret_id.txt:/etc/certs/vault_secret_id \
        gluufederation/upgrade:3.1.5_02

Note, the upgrade process doesn't update custom scripts for oxAuth/oxTrust to avoid overwriting a script that was modified by users. They must be updated them manually.
