### Multi Host using Docker Swarm Mode

This an example of running Gluu Server Enterprise Edition (EE) on multiple VMs using Docker Swarm Mode.

[Here](https://github.com/GluuFederation/enterprise-edition/tree/4.0/examples/multi-hosts) are the instructions to deploy clustered instances of Gluu Server Docker containers. This example consists of several shell scripts and config files (including docker-compose files).

What follows is an explanation of the process we used to deploy clustered Gluu Server Docker containers.

#### Node

As this example uses Docker Swarm Mode, the node refers to a Docker Swarm node (either `manager` or `worker`), which is basically a host/server. For simplicity, the clustered Gluu Server is distributed into 3 nodes (called `manager`, `worker-1`, and `worker-2`), with each node having a full stack of containers (Consul, Registrator, Redis, Twemproxy, OpenDJ, oxAuth, oxTrust, oxPassport, oxShibboleth, and NGINX).
Given this topology, the Gluu Server is still able to serve the request even when one of the nodes is down.  
Another interesting case is by using 3 nodes, the possibility of having an [issue](https://github.com/GluuFederation/gluu-docker/issues/34) with Consul is minimized.

#### Networking

The cluster operates over native Docker Swarm networking called `overlay`.
To allow a container that is running using the plain `docker run` command to connect to the network, a custom network called `gluu` is created (based on `overlay` with `--attachable` option).

By having this custom network, we can address the following concerns:

- any container that doesn't execute long-running processes (e.g. `config-init`) is able to access the Consul container inside the network
- deploy container that requires fixed IP address/hostname (for example: LDAP replication), but can be reached by other containers inside the network

#### Shared Volume Between Nodes

oxTrust and oxShibboleth rely on a mounted volume to share oxShibboleth configuration files. Given there are three nodes that need to share the same copy of oxShibboleth files, [csync2](http://oss.linbit.com/csync2/) is used. Note, `csync2` is installed as node's OS package, not a container version. The `csync2` setup is executed when running `nodes.sh` script (see section below).

#### Scripts

- `nodes.sh`: provision Swarm nodes and setup `csync2` replication
- `config.sh`: generate, dump, or load configuration required by the cluster
- `cache.sh`: deploy Redis and Twemproxy as cache storage
- `ldap-manager.sh`: deploy OpenDJ, including creating initial data
- `ldap-worker-1.sh`: deploy OpenDJ that replicates the data from another OpenDJ container
- `ldap-worker-2.sh`: deploy OpenDJ that replicates the data from another OpenDJ container

#### Docker Compose Files

- `cache.yml`: contains the Docker Swarm service definition for Twemproxy container
- `registrator.yml`: contains the Docker Swarm service definition for Registrator container
- `consul.yml`: contains the Docker Swarm service definition for Consul container
- `web.yml`: contains the Docker Swarm service definition for oxAuth, oxTrust, oxShibboleth, oxPassport, and NGINX container

#### Load Balancer

With three nodes that run a clustered Gluu Server, it's recommended to deploy an external loadbalancer, for example: NGINX or [DigitalOcean loadbalancer](https://www.digitalocean.com/products/load-balancer/).  
The process of deploying an external loadbalancer is out of the scope of this document.
