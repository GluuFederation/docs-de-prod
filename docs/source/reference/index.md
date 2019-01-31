## Operating System

Size was a major consideration in the base Docker image we used for our containers. Because of that, we use Alpine Linux, in most of our Docker images, which comes in at a whopping 5 MB by default. Based on comparisons between other base images, we've roughly saved 50-70% of space utilizing Alpine. The average size of each of our containers is about 269 MB due to dependencies.

## Startup

Docker containers generally have entrypoint scripts to prepare templates, configure files, run services, or anything else you need to run to properly initialize a container and run the process. For our containers, we pull most of our files and certificates from Consul and Vault.

Because there is a heirarchy of function to Gluu Server, `wait_for.py` script were designed, thanks to contributions from Torstein Krause Johansen (@skybert) who wrote the initial `wait-for-it` script, to try and make sure the containers don't begin their launch processes until the services superior to the container are fully started. However, there is a time limit, so a container dependent upon another container could fail as the `wait_for.py` "health checks" aren't being met.

## Networking Considerations

The mandatory ports need to be published to the host server are port 80 and 443 (both are NGINX ports). By publishing these ports to the host server, Gluu Server can be accessed publicly.

oxTrust is an OpenID Connect client, so its container is dependent upon oxAuth's `/.well-known/openid-configuration` endpoint, which is only accessible if NGINX is started. So if the oxTrust container cannot navigate to `https://<hostname>/.well-known/openid-configuration`, it will fail to finish initialization. The container will most likely not exit.

## Tini as Init for Container

Almost all of the Gluu Server Docker images use [Tini](https://github.com/krallin/tini) to handle signal forwarding and to reap processes.
We decided to include `tini` as not all of container scheduler/orchestrator has easy way to configure signal forwarding and process reaping.
