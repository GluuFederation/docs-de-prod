## Overview

[key-rotation](https://github.com/GluuFederation/docker-key-rotation/tree/3.1.6) is a special container to rotate oxAuth keys.

## Version

Currently there's no stable version for Gluu Server Docker Edition v3.1.6, however unstable version is available as `gluufederation/key-rotation:3.1.6_dev`.

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
- `GLUU_LDAP_URL`: The LDAP database's IP address or hostname. Default is `localhost:1636`. Multiple URLs can be used using comma-separated values (i.e. `192.168.100.1:1636,192.168.100.2:1636`).
- `GLUU_KEY_ROTATION_INTERVAL`: how long the key should be expired (default to 48 hours).
- `GLUU_KEY_ROTATION_CHECK`: delay between rotation check (default to 3600 seconds).

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