## Overview

ConfigInit is a special container used to load (generate/restore) and dump (backup) the configuration and secrets.

## Versions

- Stable: `gluufederation/config-init:4.0.1_05`
- Unstable: `gluufederation/config-init:4.0.1_dev`

Refer to the [Changelog](https://github.com/GluuFederation/docker-config-init/blob/4.0/CHANGES.md) for details on new features, bug fixes, or older releases.

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
- `GLUU_WAIT_SLEEP_DURATION`: Delay between startup "health checks" (default to `10` seconds).
- `GLUU_OVERWRITE_ALL`: Overwrite all config (default to `false`).

## Commands

The following commands are supported by the container:

- `load`
- `dump`
- `migrate`

### load

The load command can be used either to generate or restore config and secret for the cluster.

-   To generate the initial configuration and secret, create `/path/to/host/volume/generate.json` similar to example below:

    ```json
    {
        "hostname": "demoexample.gluu.org",
        "country_code": "US",
        "state": "TX",
        "city": "Austin",
        "admin_pw": "S3cr3t+pass",
        "email": "s@gluu.local",
        "org_name": "Gluu Inc."
    }
    ```

    and mount the volume into container:

    ```sh
    docker run \
        --rm \
        --network container:consul \
        -e GLUU_CONFIG_ADAPTER=consul \
        -e GLUU_CONFIG_CONSUL_HOST=consul \
        -e GLUU_SECRET_ADAPTER=vault \
        -e GLUU_SECRET_VAULT_HOST=vault \
        -v /path/to/host/volume:/opt/config-init/db \
        -v /path/to/vault_role_id.txt:/etc/certs/vault_role_id \
        -v /path/to/vault_secret_id.txt:/etc/certs/vault_secret_id \
        gluufederation/config-init:4.0.1_05 load
    ```

-   To restore configuration and secrets from a backup of `/path/to/host/volume/config.json` and `/path/to/host/volume/secret.json`, mount the directory as `/opt/config-init/db` inside the container:

    ```sh
    docker run \
        --rm \
        --network container:consul \
        -e GLUU_CONFIG_ADAPTER=consul \
        -e GLUU_CONFIG_CONSUL_HOST=consul \
        -e GLUU_SECRET_ADAPTER=vault \
        -e GLUU_SECRET_VAULT_HOST=vault \
        -v /path/to/host/volume:/opt/config-init/db \
        -v /path/to/vault_role_id.txt:/etc/certs/vault_role_id \
        -v /path/to/vault_secret_id.txt:/etc/certs/vault_secret_id \
        gluufederation/config-init:4.0.1_05 load
    ```

### dump

The dump command will dump all configuration and secrets from the backends saved into the `/opt/config-init/db/config.json` and `/opt/config-init/db/secret.json` files.

Please note that to dump this file into the host, mount a volume to the `/opt/config-init/db` directory as seen in the following example:

```sh
docker run \
    --rm \
    --network container:consul \
    -e GLUU_CONFIG_ADAPTER=consul \
    -e GLUU_CONFIG_CONSUL_HOST=consul \
    -e GLUU_SECRET_ADAPTER=vault \
    -e GLUU_SECRET_VAULT_HOST=vault \
    -v /path/to/host/volume:/opt/config-init/db \
    -v /path/to/vault_role_id.txt:/etc/certs/vault_role_id \
    -v /path/to/vault_secret_id.txt:/etc/certs/vault_secret_id \
    gluufederation/config-init:4.0.1_05 dump
```

### migrate

The migrate command exports secrets that were previously saved in the configuration backend into the secret backend.

```sh
docker run \
    --rm \
    --network container:consul \
    -e GLUU_CONFIG_ADAPTER=consul \
    -e GLUU_CONFIG_CONSUL_HOST=consul \
    -e GLUU_SECRET_ADAPTER=vault \
    -e GLUU_SECRET_VAULT_HOST=vault \
    -v /path/to/vault_role_id.txt:/etc/certs/vault_role_id \
    -v /path/to/vault_secret_id.txt:/etc/certs/vault_secret_id \
    gluufederation/config-init:4.0.1_05 migrate
```
