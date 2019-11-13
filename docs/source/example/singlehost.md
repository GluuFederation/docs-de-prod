## Overview

This an example of running Gluu Server on a single VM using [Docker Compose](https://docs.docker.com/compose/).

The following is a thorough explanation of the process we used to make launching a stand-alone instance repeatable, modular and consistent. Adjust the process as needed.

## Requirements

-  Download Manifests

    ```sh
    wget https://github.com/GluuFederation/community-edition-containers/archive/4.0.zip \
        && unzip 4.0.zip
    cd community-edition-containers-4.0/examples/single-host
    chmod +x run_all.sh
    ```

-  For Linux users:

    1. Follow the [Docker installation instructions](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository) or use the [convenient installation script](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-convenience-script)
    1. Install [docker-compose](https://docs.docker.com/compose/install/#install-compose)

-   For OS X (Mac) users:

    1. Meet the [system requirements](https://docs.docker.com/docker-for-mac/install/)
    1. Install [Docker Desktop for Mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac)

## Pre-Installation Notes

Before deploying Gluu Server, choose whether to use default or custom installation. If default installation is selected, skip over the [Customizing Installation](#customizing-installation) section and go to [Deploying Gluu Server](#deploying-gluu-server) section instead.

## Customizing Installation

### Choosing Services

List of supported services:

| Service             | Setting Name           | Mandatory | Enabled |
| ------------------- | ---------------------- | --------- | ------- |
| `consul`            | -                      | yes       | always  |
| `registrator`       | -                      | yes       | always  |
| `vault`             | -                      | yes       | always  |
| `nginx`             | -                      | yes       | always  |
| `oxauth`            | `SVC_OXAUTH`           | no        | yes     |
| `oxtrust`           | `SVC_OXTRUST`          | no        | yes     |
| `ldap`              | `SVC_LDAP`             | no        | yes     |
| `oxpassport`        | `SVC_OXPASSPORT`       | no        | no      |
| `oxshibboleth`      | `SVC_OXSHIBBOLETH`     | no        | no      |
| `redis`             | `SVC_REDIS`            | no        | no      |
| `radius`            | `SVC_RADIUS`           | no        | no      |
| `vault` auto-unseal | `SVC_VAULT_AUTOUNSEAL` | no        | no      |
| `oxd_server`        | `SVC_OXD_SERVER`       | no        | no      |
| `key_rotation`      | `SVC_KEY_ROTATION`     | no        | no      |
| `cr_rotate`         | `SVC_CR_ROTATE`        | no        | no      |

To enable/disable non-mandatory services listed above, create `settings.sh` (if not exist) and set the value to `"yes"` to enable or set to any value to disable the service. Here's an example:

```python
SVC_LDAP="yes"              # will be enabled
SVC_OXPASSPORT="no"         # will be disabled
SVC_OXSHIBBOLETH=""         # will be disabled
SVC_VAULT_AUTOUNSEAL="yes"  # enable Vault auto-unseal with GCP KMS API
```

To override manifests (i.e. changing oxAuth service definition), add `ENABLE_OVERRIDE=yes` in `settings.sh`, for example:

```python
ENABLE_OVERRIDE="yes"
```

Then define overrides in `docker-compose.override.yml` (create the file if not exists):

```yaml
version: "2.4"

services:
  oxauth:
    container_name: my-oxauth
```

For reference, review the Docker docs for [multiple compose files](https://docs.docker.com/compose/extends/#multiple-compose-files).

### Choosing Persistence Backends

List of supported persistence backends:

- `PERSISTENCE_TYPE`: choose one of `ldap`, `couchbase`, or `hybrid` (default to `ldap`)

- `PERSISTENCE_LDAP_MAPPING`: choose one of `default`, `user`, `site`, `statistic`, `cache`, `authorization`, `token`, or `client` (default to `default`); only effective if `PERSISTENCE_TYPE` is `hybrid`

To choose persistence backend, create `settings.sh` (if not exist) and set the corresponding option as seen above. Here's an example:

```python
PERSISTENCE_TYPE="couchbase"    # Couchbase will be selected
PERSISTENCE_LDAP_MAPPING="user" # store user mapping in LDAP
COUCHBASE_USER="admin"          # Couchbase user
COUCHBASE_URL="192.168.100.4"   # Hosts or IP addresses (comma-separated) of Couchbase
```

If `couchbase` or `hybrid` is selected, there are additional steps required to satisfy dependencies:

- put Couchbase cluster certificate into `couchbase.crt` file
- put Couchbase password into `couchbase_password` file
- Couchbase cluster must have `data`, `index`, and `query` services at minimum

### Using Vault auto-unseal

In this example, Google Cloud Platform (GCP) KMS is going to be used. Here's an example on how to obtain [GCP KMS credentials](https://shadow-soft.com/vault-auto-unseal/) JSON file, and save it as `gcp_kms_creds.json` in the same directory where `run_all.sh` is located. Here's an example:

```json
{
    "type": "service_account",
    "project_id": "project",
    "private_key_id": "1234abcd",
    "private_key": "-----BEGIN PRIVATE KEY-----\nabcdEFGH==\n-----END PRIVATE KEY-----\n",
    "client_email": "sa@project.iam.gserviceaccount.com",
    "client_id": "1234567890",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/sa%40project.iam.gserviceaccount.com"
}
```

Afterwards, create `gcp_kms_stanza.hcl` in the same directory where `run_all.sh` is located. Here's an example:

```
seal "gcpckms" {
    credentials = "/vault/config/creds.json"
    project     = "<PROJECT_NAME>"
    region      = "<REGION_NAME>"
    key_ring    = "<KEYRING_NAME>"
    crypto_key  = "<KEY_NAME>"
}
```

## Deploying Gluu Server

Run the following script:

```sh
./run_all.sh
```

Do not be alarmed for the `warning` alerts that may show up. Wait until it prompts for information or loads the previous configuration found. In the case where this is a fresh install, the output will be similar to the following logs:

```text
./run_all.sh
[I] Determining OS Type and Attempting to Gather External IP Address
Host is detected as Linux
Is this the correct external IP Address: 172.189.222.111 [Y/n]? y
[I] Preparing cluster-wide config and secrets
WARNING: The DOMAIN variable is not set. Defaulting to a blank string.
WARNING: The HOST_IP variable is not set. Defaulting to a blank string.
Pulling consul (consul:)...
latest: Pulling from library/consul
bdf0201b3a05: Pull complete
af3d1f90fc60: Pull complete
d3a756372895: Pull complete
54efc599d7c7: Pull complete
73d2c234fe14: Pull complete
cbf8018e609a: Pull complete
Digest: sha256:bce60e9bf3e5bbbb943b13b87077635iisdksdf993579d8a6d05f2ea69bccd
Status: Downloaded newer image for consul:latest
Creating consul ... done
[I] Checking existing config in Consul
[W] Unable to get config in Consul; retrying ...
[W] Unable to get config in Consul; retrying ...
[W] Unable to get config in Consul; retrying ...
[W] Configuration not found in Consul
[I] Creating new configuration, please input the following parameters
Enter Domain:                 yourdomain
Enter Country Code:           US
Enter State:                  TX
Enter City:                   Austin
Enter Email:                  email@example.com
Enter Organization:           Gluu Inc
Enter Admin/LDAP Password:
Confirm Admin/LDAP Password:
Continue with the above settings? [Y/n]y
```

The startup process may take some time. Keep track of the deployment by using the following command:

```sh
./run_all.sh logs -f
```

!!!NOTE
    On initial deployment, since Vault has not been configured yet, the `run_all.sh` will generate root token and key to interact with Vault API, saved as `vault_key_token.txt`. Secure this file as it contains recovery key and root token.

## Tearing Down Gluu Server

Run the following command to delete all objects during the deployment:

```sh
./run_all.sh down
```

## FAQ

### How to use ldapsearch

```sh
docker exec -ti ldap \
    /opt/opendj/bin/ldapsearch -Z -X \
    -h localhost \
    -p 1636 \
    -D "cn=directory manager" \
    -b "o=gluu" \
    -s base \
    -T "objectClass=*"
```

### Locked out of your Gluu demo?

This is how Vault can be manually unlocked

1. Get Unseal key from `vault_key_token.txt`
1. Log into vault container: `docker exec -it vault sh`
1. Run this command : `vault operator unseal`
1. Wait for about 10 mins for the containers to get back to work.
