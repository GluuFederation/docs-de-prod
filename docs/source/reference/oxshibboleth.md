## Overview

Docker image packaging for oxShibboleth.

## Version

The latest stable version for Gluu Server Docker Edition v3.1.6 is `gluufederation/oxshibboleth:3.1.6_02`.

## Environment Variables

The following environment variables are supported by the container:

- `GLUU_CONFIG_ADAPTER`: The config backend adapter, can be `consul` (default) or `kubernetes`.
- `GLUU_CONFIG_CONSUL_HOST`: hostname or IP of Consul (default to `localhost`).
- `GLUU_CONFIG_CONSUL_PORT`: port of Consul (default to `8500`).
- `GLUU_CONFIG_CONSUL_CONSISTENCY`: Consul consistency mode (choose one of `default`, `consistent`, or `stale`). Default to `stale` mode.
- `GLUU_CONFIG_CONSUL_SCHEME`: supported Consul scheme (`http` or `https`).
- `GLUU_CONFIG_CONSUL_VERIFY`: whether to verify cert or not (default to `false`).
- `GLUU_CONFIG_CONSUL_CACERT_FILE`: path to Consul CA cert file (default to `/etc/certs/consul_ca.crt`). This file will be used if it exists and `GLUU_CONFIG_CONSUL_VERIFY` set to `true`.
- `GLUU_CONFIG_CONSUL_CERT_FILE`: path to Consul cert file (default to `/etc/certs/consul_client.crt`).
- `GLUU_CONFIG_CONSUL_KEY_FILE`: path to Consul key file (default to `/etc/certs/consul_client.key`).
- `GLUU_CONFIG_CONSUL_TOKEN_FILE`: path to file contains ACL token (default to `/etc/certs/consul_token`).
- `GLUU_CONFIG_KUBERNETES_NAMESPACE`: Kubernetes namespace (default to `default`).
- `GLUU_CONFIG_KUBERNETES_CONFIGMAP`: Kubernetes configmaps name (default to `gluu`).
- `GLUU_CONFIG_KUBERNETES_USE_KUBE_CONFIG`: Load credentials from `$HOME/.kube/config`, only useful for non-container environment (default to `false`).
- `GLUU_SECRET_ADAPTER`: The secrets adapter, can be `vault` or `kubernetes`.
- `GLUU_SECRET_VAULT_SCHEME`: supported Vault scheme (`http` or `https`).
- `GLUU_SECRET_VAULT_HOST`: hostname or IP of Vault (default to `localhost`).
- `GLUU_SECRET_VAULT_PORT`: port of Vault (default to `8200`).
- `GLUU_SECRET_VAULT_VERIFY`: whether to verify cert or not (default to `false`).
- `GLUU_SECRET_VAULT_ROLE_ID_FILE`: path to file contains Vault AppRole role ID (default to `/etc/certs/vault_role_id`).
- `GLUU_SECRET_VAULT_SECRET_ID_FILE`: path to file contains Vault AppRole secret ID (default to `/etc/certs/vault_secret_id`).
- `GLUU_SECRET_VAULT_CERT_FILE`: path to Vault cert file (default to `/etc/certs/vault_client.crt`).
- `GLUU_SECRET_VAULT_KEY_FILE`: path to Vault key file (default to `/etc/certs/vault_client.key`).
- `GLUU_SECRET_VAULT_CACERT_FILE`: path to Vault CA cert file (default to `/etc/certs/vault_ca.crt`). This file will be used if it exists and `GLUU_SECRET_VAULT_VERIFY` set to `true`.
- `GLUU_SECRET_KUBERNETES_NAMESPACE`: Kubernetes namespace (default to `default`).
- `GLUU_SECRET_KUBERNETES_CONFIGMAP`: Kubernetes secrets name (default to `gluu`).
- `GLUU_SECRET_KUBERNETES_USE_KUBE_CONFIG`: Load credentials from `$HOME/.kube/config`, only useful for non-container environment (default to `false`).
- `GLUU_WAIT_MAX_TIME`: How long the startup "health checks" should run (default to `300` seconds).
- `GLUU_WAIT_SLEEP_DURATION`: Delay between startup "health checks" (default to `5` seconds).
- `GLUU_MAX_RAM_FRACTION`: Used in conjunction with Docker memory limitations (`docker run -m <mem>`) to identify the fraction of the maximum amount of heap memory you want the JVM to use.
- `GLUU_LDAP_URL`: The LDAP database's IP address or hostname. Default is `localhost:1636`. Multiple URLs can be used using comma-separated values (i.e. `192.168.100.1:1636,192.168.100.2:1636`).
- `GLUU_SHIB_SOURCE_DIR`: absolute path to directory to copy Shibboleth config from (default is `/opt/shared-shibboleth-idp`)
- `GLUU_SHIB_TARGET_DIR`: absolute path to directory to copy Shibboleth config to (default is `/opt/shibboleth-idp`)

Unsupported environment variables from previous versions (see `GLUU_CONFIG_CONSUL_*` or `GLUU_CONFIG_KUBERNETES_*` for replacement as seen below):

| Old Environment Variable      | New Environment Variable              |
| ----------------------------- | ------------------------------------- |
| `GLUU_CONSUL_HOST`            | `GLUU_CONFIG_CONSUL_HOST`             |
| `GLUU_CONSUL_PORT`            | `GLUU_CONFIG_CONSUL_PORT`             |
| `GLUU_CONSUL_CONSISTENCY`     | `GLUU_CONFIG_CONSUL_CONSISTENCY`      |
| `GLUU_CONSUL_SCHEME`          | `GLUU_CONFIG_CONSUL_SCHEME`           |
| `GLUU_CONSUL_VERIFY`          | `GLUU_CONFIG_CONSUL_VERIFY`           |
| `GLUU_CONSUL_CACERT_FILE`     | `GLUU_CONFIG_CONSUL_CACERT_FILE`      |
| `GLUU_CONSUL_CERT_FILE`       | `GLUU_CONFIG_CONSUL_CERT_FILE`        |
| `GLUU_CONSUL_KEY_FILE`        | `GLUU_CONFIG_CONSUL_KEY_FILE`         |
| `GLUU_CONSUL_TOKEN_FILE`      | `GLUU_CONFIG_CONSUL_TOKEN_FILE`       |
| `GLUU_KUBERNETES_NAMESPACE`   | `GLUU_CONFIG_KUBERNETES_NAMESPACE`    |
| `GLUU_KUBERNETES_CONFIGMAP`   | `GLUU_CONFIG_KUBERNETES_CONFIGMAP`    |

## Shared Directories

Mounting the volume from host to container, as seen in the `-v $PWD/shared-shibboleth-idp:/opt/shared-shibboleth-idp` option, is required to ensure oxShibboleth can load the configuration correctly. This can [also be seen here](https://github.com/GluuFederation/gluu-docker/blob/master/examples/single-host/docker-compose.yml#L114) in the standalone docker-compose yaml file or [here](https://github.com/GluuFederation/gluu-docker/blob/master/examples/multi-hosts/web.yml#L88) in the multi-host docker-compose yaml file.

By design, each time a Trust Relationship entry is added/updated/deleted via the oxTrust GUI, some Shibboleth-related files will be generated/modified by oxTrust and saved to the `/opt/shibboleth-idp` directory inside the oxTrust container. A background job in oxTrust container ensures those files are copied to the `/opt/shared-shibboleth-idp` directory (and also inside the oxTrust container, which must be mounted from container to host).

After those Shibboleth-related files are copied to `/opt/shared-shibboleth`, a background job in oxShibboleth copies them to the `/opt/shibboleth-idp` directory inside oxShibboleth container. To ensure files are synchronized between oxTrust and oxShibboleth, both containers must use the same mounted volume, `/opt/shared-shibboleth-idp`.

The `/opt/shibboleth-idp` directory is not mounted directly into the container, as there are two known issues with this approach. First, the oxShibboleth container has its own default `/opt/shibboleth-idp` directory requirements to start the app itself. By mounting `/opt/shibboleth-idp` directly from the host, the directory will be replaced and the oxShibboleth app won't run correctly. Secondly, oxTrust renames the metadata file, which unfortunately didn't work as expected in the mounted volume.
