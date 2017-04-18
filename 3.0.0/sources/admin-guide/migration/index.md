# Migration

[TOC]

## Version 0.5.0

Changelog for v0.5.0 is available [here](https://github.com/GluuFederation/gluu-engine/blob/master/CHANGES.md#version-050).

As version 0.5.0 is not backward compatible with older releases, to migrate to the new version,
user need to backup necessary data (mainly LDAP data) and reinstall everything from scratch.

## Version 0.4.4

Changelog for v0.4.4 is available [here](https://github.com/GluuFederation/gluu-flask/blob/master/CHANGES.md#version-044).

### Master provider

1.  Install latest `gluu-flask` package updates:

        apt-get update && apt-get install -y gluu-flask

2.  Populate node's logs by running this command:

        gluuapi populate-node-logs

    The command above will populate paths to all nodes logs in the cluster.

## Version 0.4.3

Changelog for v0.4.3 is available [here](https://github.com/GluuFederation/gluu-flask/blob/master/CHANGES.md#version-043).

### Master provider

1.  Install latest `gluu-flask` and `gluu-agent` package updates:

        apt-get update && apt-get install -y gluu-flask gluu-agent

2.  Populate node's logs by running this command:

        gluuapi populate-node-logs

    The command above will populate paths to all nodes logs in the cluster.

### Consumer provider

1.  Install latest `gluu-agent` package updates:

        apt-get update && apt-get install -y gluu-agent
>>>>>>> origin/master

## Version 0.4.2

Changelog for v0.4.2 is available [here](https://github.com/GluuFederation/gluu-flask/blob/master/CHANGES.md#version-042).

### Master provider

1.  Install latest `gluu-flask` and `gluu-agent` package updates:

        apt-get update && apt-get install -y gluu-flask gluu-agent

2.  Remove oxauth, oxidp (if any), and nginx nodes.
3.  Remove gluuoxauth, gluuoxidp, and gluunginx images.

        docker rmi gluuoxauth gluuoxidp gluunginx

4.  Re-deploy oxauth, nginx, and oxidp (optional) nodes.
5.  Login to ldap node:

        docker exec -ti $node_id bash

    Afterwards, add new config:

        /opt/opendj/bin/dsconfig \
            --trustAll \
            --no-prompt \
            --bindDN 'cn=Directory Manager' \
            --bindPassword $passwd \
            set-global-configuration-prop --set reject-unauthenticated-requests:true


### Consumer provider

1.  Install latest `gluu-agent` package updates:

        apt-get update && apt-get install -y gluu-agent

2.  Remove oxauth, oxidp (if any), and nginx nodes.
3.  Remove gluuoxauth, gluuoxidp, and gluunginx images.

        docker rmi gluuoxauth gluuoxidp gluunginx

4.  Re-deploy oxauth, nginx, and oxidp (optional) nodes.
5.  Login to ldap node:

        docker exec -ti $node_id bash

    Afterwards, add new config:

        /opt/opendj/bin/dsconfig \
            --trustAll \
            --no-prompt \
            --bindDN 'cn=Directory Manager' \
            --bindPassword $passwd \
            set-global-configuration-prop --set reject-unauthenticated-requests:true

## Version 0.4.1-8 and above

Changelog for v0.4.1 is available [here](https://github.com/GluuFederation/gluu-flask/blob/master/CHANGES.md#version-041).

### Master provider

1.  Install latest `gluu-flask` package updates:

        apt-get update && apt-get install -y gluu-flask

2.  Remove existing ldap, oxauth, oxtrust, and oxidp nodes.
3.  Remove gluuopendj, gluuoxtrust, gluuoxidp, and gluuoxauth images:

        docker rmi gluuopendj gluuoxtrust gluuoxidp gluuoxauth

4.  Re-deploy ldap, oxauth, oxidp (optional), and oxtrust nodes.

### Consumer provider

1.  Remove existing ldap, oxauth, and oxidp nodes.
2.  Remove gluuopendj, gluuoxidp, and gluuoxauth images:

        docker rmi gluuopendj gluuoxidp gluuoxauth

3.  Re-deploy ldap, oxauth, and optionally oxidp nodes.

## Version 0.4.1

Changelog for v0.4.1 is available [here](https://github.com/GluuFederation/gluu-flask/blob/master/CHANGES.md#version-041).

### Master provider

1.  Update `gluu-master`, `gluu-flask`, and `gluu-agent` packages.

        apt-get update && apt-get install -y gluu-master gluu-flask gluu-agent

    Note: since newer `gluu-master` package introduces docker v1.8.3, existing nodes might be
    crashed. To recover the nodes, run the recovery command:

        gluu-agent recover

### Consumer provider

2.  Update `gluu-consumer` and `gluu-agent` packages.

        apt-get update && apt-get install -y gluu-consumer gluu-agent

    Note: since newer `gluu-consumer` package introduces docker v1.8.3, existing nodes might be
    crashed. To recover the nodes, run the recovery command:

        gluu-agent recover

## Version 0.4.0

Changelog for v0.4.0 is available [here](https://github.com/GluuFederation/gluu-flask/blob/master/CHANGES.md#version-040).

### Master provider

1.  Update `gluu-flask`, `gluu-agent` and `weave` packages:

        apt-get update && apt-get install -y gluu-flask gluu-agent weave

2.  Remove old weave container:

        docker rm -f weave

3.  Update weave image:

        weave setup

4.  Update master provider data via REST API/Web UI.

5.  Remove existing ldap, oxauth, httpd and oxtrust nodes (containers).

6.  Remove gluuopendj, gluuoxtrust, and gluuoxauth images:

        docker rmi gluuopendj gluuoxtrust gluuoxauth

7.  Re-deploy ldap, oxauth, oxidp (optional), nginx, and oxtrust nodes.

### Consumer provider

1.  Update `gluu-agent` and `weave` packages:

        apt-get update && apt-get install -y gluu-agent weave

2.  Remove old weave container:

        docker rm -f weave

3.  Update weave image:

        weave setup

4.  Update consumer provider data via REST API/Web UI.

5.  Remove existing ldap, oxauth, and httpd nodes (containers).

6.  Remove gluuopendj and gluuoxauth images:

        docker rmi gluuopendj gluuoxauth

7.  Re-deploy ldap, oxauth, oxidp (optional), and nginx nodes.

## Version 0.3.3-12 and above

Changelog for v0.3.3 is available [here](https://github.com/GluuFederation/gluu-flask/blob/master/CHANGES.md#version-033).

Steps to migrate to Gluu Cluster v0.3.3-12:

1.  Update `gluu-flask` via `apt-get update && apt-get install -y gluu-flask`.
2.  Remove ldap, oxauth, httpd and oxtrust nodes (containers).
3.  Remove gluuoxauth and gluuoxtrust images via `docker rmi` command.
4.  Re-deploy ldap, oxauth, httpd, and oxtrust nodes.
5.  Install gluu-agent: `apt-get update && apt-get install gluu-agent`.
