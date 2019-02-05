The Gluu Server Docker containers consist of in-house and 3rd-party containers.

## Consul

__Note:__ for Kubernetes deployment, this container can be omitted.

The Gluu Server Docker containers were built to be centralized around a configuration KV store. For our use case, we've used [Consul](https://www.consul.io/) as our KV store. The reasoning behind this decision was to allow the containers to be as modular as possible. Services can be replaced without concern for losing any of the default configuration. This isn't to say that there won't need to be persistence using volumes (see [here](https://github.com/GluuFederation/gluu-docker/blob/3.1.5/examples/single-host/docker-compose.yml) for custom files and long standing data requirements.

## Vault

__Note:__ for Kubernetes deployment, this container can be omitted.

Similar to Consul, The Gluu Server Docker containers were built to be centralized around a secrets store. For our use case, we've used [Vault](http://vaultproject.io/).

To use the Vault container within Gluu Server Docker Edition, user need to initialize and unseal Vault first. The initialization also involves enabling specific role and auth method. See [Vault operational guide](/operation/vault) for details.

## Registrator

__Note:__ for Kubernetes deployment, this container can be omitted.

Due to the design of Docker networking where container IP gets recycled dynamically, [Registrator](http://gliderlabs.github.io/registrator/latest/) container is used for registering and deregistering oxAuth, oxTrust, oxShibboleth, and oxPassport container's IP. With the help of Registrator, the NGINX container will route the traffic to available oxAuth/oxTrust/oxShibboleth/oxPassport backend.

To connect to Consul container that deployed using HTTPS scheme, please use `gluufederation/registrator:dev` image instead.