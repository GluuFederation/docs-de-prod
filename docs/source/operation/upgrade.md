## v3.1.4 to v3.1.5

Gluu Server DE v3.1.5 introduces secrets layer which depends on selected secrets adapter (`vault` or `kubernetes`), the migration may need to configure the secret backend first. Otherwise all of Gluu Server containers startup will wait (and eventually crashed) for secrets backend to be available.

### Prerequisites

Gluu Server DE 3.1.5 introduces new variables and deprecates some. See [Reference](reference/index) documentation on these changes. Also it it best to compare the latest [deployment examples](example/index) with your existing setup to see what changes need to be applied.

### Vault

If Vault is selected as secrets adapter, we may see a similar logs message upon container startup as shown below:

    $ docker logs -f --tail=10 opendj
    WARNING - 2019-01-28 17:36:03,099 - Secret backend is not ready; reason=Vault is sealed; retrying in 5 seconds.

The logs message indicates Vault hasn't initialized and/or unsealed.
If Vault has been configured properly, eventually the container will show a similar logs message:

    INFO - 2019-01-28 17:43:37,088 - Secret backend is ready.

Refer to [Vault operation guide](/operation/vault) to setup Vault.

### LDAP

#### Backup Existing Data

Before running the upgrade process, make sure to backup existing LDAP data.

#### Updating Schema

1.  Download the latest [101-ox.ldif](https://github.com/GluuFederation/docker-opendj/raw/3.1.5/schemas/101-ox.ldif) schema.

2.  Depends on the setup, there are various ways to mount the file into container.

    1.  For single host setup, mount `101-ox.ldif` to OpenDJ container directly. This is an example using `docker-compose.yml`:

            services:
              opendj:
                image: gluufederation/opendj:3.1.5_01
                volumes:
                  - /path/to/101-ox.ldif:/opt/opendj/config/schema/101-ox.ldif

    2.  For multi hosts setup using Docker Swarm Mode, we recommend to put the contents of `101-ox.ldif` into Docker Config:

            docker config create 101-ox /path/to/101-ox.ldif

        and then mount the file into container:

            services:
              opendj:
                image: gluufederation/opendj:3.1.5_01
                configs:
                  - source: 101-ox
                    target: /opt/opendj/config/schema/101-ox.ldif

            configs:
              101-ox:
                external: true

    3.  For multi hosts setup using Kubernetes, put the contents of `101-ox.ldif` into ConfigMaps:

            kubectl create cm opendj-schema --from-file=/path/to/101-ox.ldif

        and then mount the file into container:

            apiVersion: v1
            kind: StatefulSet
            metadata:
            name: opendj
            spec:
              containers:
                image: gluufederation/opendj:3.1.5_01
                volumeMounts:
                  - name: opendj-schema-volume
                    mountPath: /opt/opendj/config/schema/
              volumes:
                - name: opendj-schema-volume
                  configMap:
                    name: opendj-schema

3.  Restart the container/service to allow changes in schema.

#### Reconfiguring Backends

1.  Resize the `site` backend:

        docker exec -ti opendj /opt/opendj/bin/dsconfig \
            --trustAll \
            --bindDN "cn=directory manager" \
            --port 4444 \
            --hostname 0.0.0.0 \
            set-backend-prop --backend-name site --set db-cache-percent:20

2.  Restart the OpenDJ container/service to free JVM heap memory.

3.  Resize the `userRoot` backend:

        docker exec -ti opendj /opt/opendj/bin/dsconfig \
            --trustAll \
            --bindDN "cn=directory manager" \
            --port 4444 \
            --hostname 0.0.0.0 \
            set-backend-prop --backend-name userRoot --set db-cache-percent:70

4.  Create `metric` backend:

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

### Upgrade Container

By running the `gluufederation/upgrade:3.1.5_01` container, the LDAP data will be adjusted to match convention in v3.1.5.

    docker run \
        --rm \
        --net container:consul \
        -e GLUU_CONFIG_CONSUL_HOST=consul \
        -e GLUU_SECRET_VAULT_HOST=vault \
        -e GLUU_LDAP_URL=ldap:1636 \
        -v /path/to/vault_role_id.txt:/etc/certs/vault_role_id \
        -v /path/to/vault_secret_id.txt:/etc/certs/vault_secret_id \
        gluufederation/upgrade:3.1.5_01

Note, the upgrade process doesn't update custom scripts for oxAuth/oxTrust to avoid overwritting custom script that modified by users. Please update them manually.
