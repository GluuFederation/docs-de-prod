## Overview

[config-init](https://github.com/GluuFederation/docker-config-init/tree/3.1.5) is a special container that is neither daemonized nor executing a long-running process. The purpose of this container is to generate, dump (backup), or even load (restore) the config and secrets.

## Version

Latest stable version for Gluu Server Docker Edition v3.1.5 is `gluufederation/config-init:3.1.5_02`.

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
- `GLUU_SECRET_VAULT_SECRET_ID_FILE`: path to file contains Vault Approle secret ID (default to `/etc/certs/vault_secret_id`).
- `GLUU_SECRET_VAULT_CERT_FILE`: path to Vault cert file (default to `/etc/certs/vault_client.crt`).
- `GLUU_SECRET_VAULT_KEY_FILE`: path to Vault key file (default to `/etc/certs/vault_client.key`).
- `GLUU_SECRET_VAULT_CACERT_FILE`: path to Vault CA cert file (default to `/etc/certs/vault_ca.crt`). This file will be used if it exists and `GLUU_SECRET_VAULT_VERIFY` set to `true`.
- `GLUU_SECRET_KUBERNETES_NAMESPACE`: Kubernetes namespace (default to `default`).
- `GLUU_SECRET_KUBERNETES_CONFIGMAP`: Kubernetes secrets name (default to `gluu`).
- `GLUU_SECRET_KUBERNETES_USE_KUBE_CONFIG`: Load credentials from `$HOME/.kube/config`, only useful for non-container environment (default to `false`).
- `GLUU_WAIT_MAX_TIME`: How long the startup "health checks" should run (default to `300` seconds).
- `GLUU_WAIT_SLEEP_DURATION`: Delay between startup "health checks" (default to `5` seconds).
- `GLUU_OVERWRITE_ALL`: Overwrite all config (default to `false`).

Deprecated environment variables (see `GLUU_CONFIG_CONSUL_*` or `GLUU_CONFIG_KUBERNETES_*` for reference):

- `GLUU_CONSUL_HOST`
- `GLUU_CONSUL_PORT`
- `GLUU_CONSUL_CONSISTENCY`
- `GLUU_CONSUL_SCHEME`
- `GLUU_CONSUL_VERIFY`
- `GLUU_CONSUL_CACERT_FILE`
- `GLUU_CONSUL_CERT_FILE`
- `GLUU_CONSUL_KEY_FILE`
- `GLUU_CONSUL_TOKEN_FILE`
- `GLUU_KUBERNETES_NAMESPACE`
- `GLUU_KUBERNETES_CONFIGMAP`

## Commands

The following commands are supported by the container:

- `generate`
- `dump`
- `load`

### generate

The generate command will generate all the initial configuration files for the Gluu Server components. All existing config will be ignored unless forced by passing environment variable `GLUU_OVERWRITE_ALL`.

The following parameters and/or environment variables are required to launch unless otherwise marked.

Parameters:

- `--email`: The email address of the administrator usually. Used for certificate creation.
- `--domain`: The domain name where the Gluu Server resides. Used for certificate creation.
- `--country-code`: The country where the organization is located. User for certificate creation.
- `--state`: The state where the organization is located. Used for certificate creation.
- `--city`: The city where the organization is located. Used for certificate creation.
- `--org-name`: The organization using the Gluu Server. Used for certificate creation.
- `--admin-pw`: The administrator password for oxTrust and LDAP
- `--ldap-type`: Currently only OpenDJ is supported.
- `--base-inum`: (optional) Base inum with the following format `@!xxxx.xxxx.xxxx.xxxx` where `x` represents a number or uppercased alphabet, for example `@!1BDD.80B7.128C.099A`. If omitted, the value will be auto-generated.
- `--inum-org`: (optional) Organization inum with the following format `<BASE_INUM>!0001!xxxx.xxxx` where `x` represents a number or uppercased alphabet, for example `@!1BDD.80B7.128C.099A!0001!4FB1.6F8C`. If omitted, the value will be auto-generated.
- `--inum-appliance`: (optional) Appliance inum with the following format `<BASE_INUM>!0002!xxxx.xxxx` where `x` represents a number or uppercased alphabet, for example `@!1BDD.80B7.128C.099A!0002!8E48.6E9D`. If omitted, the value will be auto-generated.

### dump

The dump command will dump all configuration from inside KV store into the `/opt/config-init/db/config.json` file inside the container. The following parameters and/or environment variables are required to launch, unless otherwise marked.

Please note that to dump this file into the host, you'll need to map a mounted volume to the `/opt/config-init/db` directory. See this example on how to dump the config into the `/path/to/host/volume/config.json` file:

    docker run \
        --rm \
        --network container:consul \
        -e GLUU_CONFIG_ADAPTER=consul \
        -e GLUU_CONFIG_CONSUL_HOST=consul \
        -e GLUU_SECRET_ADAPTER=vault \
        -e GLUU_SECRET_VAULT_HOST=vault \
        -v /path/to/host/volume:/opt/config-init/db \
        gluufederation/config-init:3.1.5_01 dump

### load

The load command will load a `config.json` into the KV store. All existing config will be ignored unless forced by passing environment variable `GLUU_OVERWRITE_ALL`.

Please note that to load this file from the host, you'll need to map a mounted volume to the `/opt/config-init/db` directory. For an  example on how to load the config from `/path/to/host/volume/config.json` file, see the following:

    docker run \
        --rm \
        --network container:consul \
        -e GLUU_CONFIG_ADAPTER=consul \
        -e GLUU_CONFIG_CONSUL_HOST=consul \
        -e GLUU_SECRET_ADAPTER=vault \
        -e GLUU_SECRET_VAULT_HOST=vault \
        -v /path/to/host/volume:/opt/config-init/db \
        gluufederation/config-init:3.1.5_01 load
