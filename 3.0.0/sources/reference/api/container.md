[TOC]

## Container API

### Overview

Container is an entity represents a `docker` container managed by Gluu.

### Create New Container

    POST /containers/{type}

Any supported container can be created by sending a request to `/containers/{type}` URL,
where `{type}` is one of the container types as listed below:

1. `ldap`
2. `oxauth`
3. `oxtrust`
4. `nginx`

There are few rules about container:

* Only 1 `ldap` container can be deployed in each node.
* Only 1 `nginx` container can be deployed in each node.
* Only 1 `oxtrust` container can be deployed in the cluster and it must be deployed in master node.
* There's no restriction on how many `oxauth` container per node.

__URL:__

    http://localhost:8080/containers/{type}

__Form parameters:__

*   `node_id` (required)

    The ID of Node.

__Request example:__

```sh
curl http://localhost:8080/containers/ldap \
    -d node_id=283bfa41-2121-4433-9741-875004518688 \
    -X POST -i
```

__Response example:__

```http
HTTP/1.0 202 ACCEPTED
Content-Type: application/json
Location: http://localhost:8080/containers/gluuopendj_f42dd3bf-28c8-450c-b221-77b677b59043
X-Container-Setup-Log: http://localhost:8080/container_logs/gluuopendj_f42dd3bf-28c8-450c-b221-77b677b59043/setup

{
    "node_id": "283bfa41-2121-4433-9741-875004518688",
    "name": "gluuopendj_f42dd3bf-28c8-450c-b221-77b677b59043",
    "ldap_port": "1389",
    "ldap_admin_port": "4444",
    "ldap_binddn": "cn=directory manager",
    "ldaps_port": "1636",
    "cluster_id": "9ea4d520-bbba-46f6-b779-c29ee99d2e9e",
    "type": "ldap",
    "id": "58848b94-0671-48bc-9c94-04b0351886f0",
    "ldap_jmx_port": "1689",
    "state": "IN_PROGRESS",
    "hostname": "7d3b34fe4cd9.ldap.weave.local",
    "cid": "7d3b34fe4cd9"
}
```

Since deploying a container may take a while, the build process is running as background job.
As we can see in example above, the ``state`` is set as `IN_PROGRESS`.
To track the deployment progress we can send requests periodically to the URL as shown in `X-Container-Setup-Log` header.

__Status Code:__

* `202`: Request has been accepted.
* `400`: Bad request. Possibly malformed/incorrect parameter value.
* `403`: Access denied.
* `500`: The server having errors.

---

### Get A Container

    GET /containers/{id}

__URL:__

    http://localhost:8080/containers/{id}

__Request example:__

```sh
curl http://localhost:8080/containers/58848b94-0671-48bc-9c94-04b0351886f0 -i
```

or

```sh
curl http://localhost:8080/containers/gluuopendj_f42dd3bf-28c8-450c-b221-77b677b59043 -i
```

__Response example:__

```http
HTTP/1.0 200 OK
Content-Type: application/json

{
    "node_id": "283bfa41-2121-4433-9741-875004518688",
    "name": "gluuopendj_f42dd3bf-28c8-450c-b221-77b677b59043",
    "ldap_port": "1389",
    "ldap_admin_port": "4444",
    "ldap_binddn": "cn=directory manager",
    "ldaps_port": "1636",
    "cluster_id": "9ea4d520-bbba-46f6-b779-c29ee99d2e9e",
    "type": "ldap",
    "id": "58848b94-0671-48bc-9c94-04b0351886f0",
    "ldap_jmx_port": "1689",
    "state": "IN_PROGRESS",
    "hostname": "7d3b34fe4cd9.ldap.weave.local",
    "cid": "7d3b34fe4cd9"
}
```

There are 4 states we need to know:

1. ``IN_PROGRESS``: container is being deployed
2. ``SUCCESS``: container is successfully deployed
3. ``FAILED``: container is failed
4. ``DISABLED``: container is disabled

__Status Code:__

* `200`: Container is exist.
* `404`: Container is not exist.
* `500`: The server having errors.

---

### List All Containers

    GET /containers

__URL:__

    http://localhost:8080/containers

__Request example:__

```sh
curl http://localhost:8080/containers -i
```

__Response example:__

```http
HTTP/1.0 200 OK
Content-Type: application/json

[
    {
        "node_id": "283bfa41-2121-4433-9741-875004518688",
        "name": "gluuopendj_f42dd3bf-28c8-450c-b221-77b677b59043",
        "ldap_port": "1389",
        "ldap_admin_port": "4444",
        "ldap_binddn": "cn=directory manager",
        "ldaps_port": "1636",
        "cluster_id": "9ea4d520-bbba-46f6-b779-c29ee99d2e9e",
        "type": "ldap",
        "id": "58848b94-0671-48bc-9c94-04b0351886f0",
        "ldap_jmx_port": "1689",
        "state": "IN_PROGRESS",
        "hostname": "7d3b34fe4cd9.ldap.weave.local",
        "cid": "7d3b34fe4cd9"
    }
]
```

Note, if there's no container, the response body will return empty list.

__Status Code:__

* `200`: Request is succeed.
* `500`: The server having errors.

---

### Filter Containers

    GET /filter-containers/{type}

__URL:__

    http://localhost:8080/filter-containers/{type}

__Request example:__

```sh
curl http://localhost:8080/filter-containers/ldap -i
```

__Response example:__

```http
HTTP/1.0 200 OK
Content-Type: application/json

[
    {
        "node_id": "283bfa41-2121-4433-9741-875004518688",
        "name": "gluuopendj_f42dd3bf-28c8-450c-b221-77b677b59043",
        "ldap_port": "1389",
        "ldap_admin_port": "4444",
        "ldap_binddn": "cn=directory manager",
        "ldaps_port": "1636",
        "cluster_id": "9ea4d520-bbba-46f6-b779-c29ee99d2e9e",
        "type": "ldap",
        "id": "58848b94-0671-48bc-9c94-04b0351886f0",
        "ldap_jmx_port": "1689",
        "state": "IN_PROGRESS",
        "hostname": "7d3b34fe4cd9.ldap.weave.local",
        "cid": "7d3b34fe4cd9"
    }
]
```

Note, if there's no container, the response body will return empty list.

__Status Code:__

* `200`: Request is succeed.
* `500`: The server having errors.

---

### Delete A Container

    DELETE /containers/{id}

By default, container with `IN_PROGRESS` state cannot be deleted.
Any attempt to delete container with `IN_PROGRESS` state will raise status code 403.
To force container deletion, add `force_rm` option in the request (see below).

__URL:__

    http://localhost:8080/containers/{id}

__Query string parameters:__

*   `force_rm` (optional)

    A boolean to delete the container regardless of its state. By default is set to `false`.

    * Truthy values: `1`, `True`, `true`, or `t`
    * Falsy values: `0`, `False`, `false`, or `f`

    Unknown value will be ignored.

__Request example:__

```sh
curl http://localhost:8080/containers/58848b94-0671-48bc-9c94-04b0351886f0 -X DELETE -i
```

or

```sh
curl http://localhost:8080/containers/gluuopendj_f42dd3bf-28c8-450c-b221-77b677b59043 -X DELETE -i
```

__Response example:__

```http
HTTP/1.0 204 NO CONTENT
Content-Type: application/json
X-Container-Teardown-Log: http://localhost:8080/container_logs/gluuopendj_f42dd3bf-28c8-450c-b221-77b677b59043/teardown
```

Since deleting (teardown) a container may take a while, the deletion process is running as background job.
To track the teardown progress we can make requests periodically to the URL as shown in `X-Container-Teardown-Log` header.

__Status Code:__

* `204`: Container has been deleted.
* `403`: Access denied.
* `404`: Container is not exist.
* `500`: The server having errors.

---

### Scale Container

    POST /scale-containers/{container_type}/{number}

This will try to deploy given numbers of containers of given type

Container type:

* `oxauth`

__URL:__

    http://localhost:8080/scale-containers/{container_type}/{number}

__Request example:__

```sh
curl http://localhost:8080/containers/oxauth/20 -X POST -i
```

__Response example:__

```http
HTTP/1.0 202 ACCEPTED
Content-Type: application/json
{
    "status": 202
    "message": "deploying 20 oxauth"
}
```

__Status Code:__

* `202`: request accepted.
* `403`: Access denied.
* `404`: Container type not supported.
* `500`: The server having errors.

---

### Descale Container

    DELETE /scale-containers/{container_type}/{number}

This will try to remove given numbers of running containers of given type

Container type:

* `oxauth`

__URL:__

    http://localhost:8080/scale-containers/{container_type}/{number}

__Request example:__

```sh
curl http://localhost:8080/containers/oxauth/20 -X DELETE -i
```

__Response example:__

```http
HTTP/1.0 202 ACCEPTED
Content-Type: application/json
{
    "status": 202
    "message": "deleting 20 oxauth"
}
```

__Status Code:__

* `202`: request accepted.
* `403`: Access denied.
* `404`: Container type not supported.
* `500`: The server having errors.
