[TOC]

## Node API

### Overview

Node is an entity represents the host of containers.
Currently there are various supported node types:

1. Discovery; used for service discovery
2. Master
3. Worker

---

### Create New Node

    POST /nodes/{type}

Any supported node type can be created by sending a request to `/nodes/{type}` URL, where `{type}` is the name of node type mentioned above.

#### Discovery Node

__URL:__

    http://localhost:8080/nodes/discovery

__Form parameters:__

*   `name` (required)

    Name of the node. This is also acts as its hostname. Currently, the name must be set as `gluu.discovery`.

*   `provider_id` (required)

    The ID of provider. Note, `generic` provider can be used only once by a node.

__Request example:__

```sh
curl http://localhost:8080/nodes/discovery \
    -d name=gluu.discovery \
    -d provider_id=fe3eeb1d-7731-43f7-aa90-767d16fa3ab4 \
    -X POST -i
```

__Response example:__

```http
HTTP/1.0 202 ACCEPTED
Content-Type: application/json
Location: http://localhost:8080/nodes/gluu.discovery

{
    "provider_id": "fe3eeb1d-7731-43f7-aa90-767d16fa3ab4",
    "name": "gluu.discovery",
    "id": "283bfa41-2121-4433-9741-875004518677",
    "type": "discovery"
}
```
__Status Code:__

* `202`: Request has been accepted.
* `400`: Bad request. Possibly malformed/incorrect parameter value.
* `403`: Access denied. Refer to message key in JSON response for details.
* `500`: The server having errors.

#### Master Node

There are prerequisites before creating a `master` node:

1. `discovery` node must exist.

__URL:__

    http://localhost:8080/nodes/master

__Form parameters:__

*   `name` (required)

    Name of the node. This is also acts as its hostname.

*   `provider_id` (required)

    The ID of provider. Note, `generic` provider can be used only once by a node.

__Request example:__

```sh
curl http://localhost:8080/nodes/master \
    -d name=master-node \
    -d provider_id=fe3eeb1d-7731-43f7-aa90-767d16fa3ab4 \
    -X POST -i
```

__Response example:__

```http
HTTP/1.0 201 CREATED
Content-Type: application/json
Location: http://localhost:8080/nodes/master-node

{
    "provider_id": "fe3eeb1d-7731-43f7-aa90-767d16fa3ab4",
    "name": "master-node",
    "id": "283bfa41-2121-4433-9741-875004518688",
    "type": "master"
}
```

__Status Code:__

* `201`: Node is successfully created.
* `400`: Bad request. Possibly malformed/incorrect parameter value.
* `403`: Access denied. Refer to message key in JSON response for details.
* `500`: The server having errors.

#### Worker Node

There are prerequisites before creating a `worker` node:

1. `master` node must exist.
2. Must have a license key. See [License Key API](./license_key.md) for details.

It's worth noting that when license for `worker` node is expired,
server will try to retrieve new license automatically. If succeed, the node will use new license.
Otherwise, all `oxauth` containers deployed inside the node will be disabled from cluster.

__URL:__

    http://localhost:8080/nodes/worker

__Form parameters:__

*   `name` (required)

    Name of the node. This is also acts as its hostname.

*   `provider_id` (required)

    The ID of provider. Note, `generic` provider can be used only once by a node.

__Request example:__

```sh
curl http://localhost:8080/nodes/worker \
    -d name=worker-node-1 \
    -d provider_id=fe3eeb1d-7731-43f7-aa90-767d16fa3ab4 \
    -X POST -i
```

__Response example:__

```http
HTTP/1.0 201 CREATED
Content-Type: application/json
Location: http://localhost:8080/nodes/worker-node-1

{
    "provider_id": "fe3eeb1d-7731-43f7-aa90-767d16fa3ab4",
    "name": "worker-node-1",
    "id": "283bfa41-2121-4433-9741-875004518699",
    "type": "worker"
}
```

__Status Code:__

* `201`: Node is successfully created.
* `400`: Bad request. Possibly malformed/incorrect parameter value.
* `403`: Access denied. Refer to message key in JSON response for details.
* `500`: The server having errors.

---

### Get A Node

    GET /nodes/{name}

__URL:__

    http://localhost:8080/nodes/{name}

__Request example:__

```sh
curl http://localhost:8080/nodes/worker-node-1 -i
```

__Response example:__

```http
HTTP/1.0 200 OK
Content-Type: application/json

{
    "provider_id": "fe3eeb1d-7731-43f7-aa90-767d16fa3ab4",
    "name": "worker-node-1",
    "id": "283bfa41-2121-4433-9741-875004518699",
    "type": "worker"
}
```

__Status Code:__

* `200`: Node is exist.
* `404`: Node is not exist.
* `500`: The server having errors.

---

### Retry a Node deployment

    PUT /nodes/{name}

__URL:__

    http://localhost:8080/nodes/{name}

__Request example:__

```sh
curl http://localhost:8080/nodes/worker-node-1 -X PUT -i
```

__Response example:__

```http
HTTP/1.0 202 ACCEPTED
Content-Type: application/json
Location: http://localhost:8080/nodes/worker-node-1

{
    "provider_id": "fe3eeb1d-7731-43f7-aa90-767d16fa3ab4",
    "name": "worker-node-1",
    "id": "283bfa41-2121-4433-9741-875004518699",
    "type": "worker"
}
```

__Status Code:__

* `202`: Request has been accepted.
* `404`: Node is not exist.
* `500`: The server having errors.

---

### List All Nodes

    GET /nodes

__URL:__

    http://localhost:8080/nodes

__Request example:__

```sh
curl http://localhost:8080/nodes -i
```

__Response example:__

```http
HTTP/1.0 200 OK
Content-Type: application/json

[
    {
        "provider_id": "fe3eeb1d-7731-43f7-aa90-767d16fa3ab4",
        "name": "gluu.discovery",
        "id": "283bfa41-2121-4433-9741-875004518677",
        "type": "discovery"
    },
    {
        "provider_id": "fe3eeb1d-7731-43f7-aa90-767d16fa3ab4",
        "name": "master-node",
        "id": "283bfa41-2121-4433-9741-875004518688",
        "type": "master"
    },
    {
        "provider_id": "fe3eeb1d-7731-43f7-aa90-767d16fa3ab4",
        "name": "worker-node-1",
        "id": "283bfa41-2121-4433-9741-875004518699",
        "type": "worker"
    }
]
```

Note, if there's no node, the response body will return empty list.

__Status Code:__

* `200`: Request is succeed.
* `500`: The server having errors.

---

### Delete A Node

    DELETE /nodes/{name}

__URL:__

    http://localhost:8080/nodes/{name}

__Request example:__

```sh
curl http://localhost:8080/nodes/worker-node-1 -X DELETE -i
```

__Response example:__

```http
HTTP/1.0 204 NO CONTENT
Content-Type: application/json
```

__Status Code:__

* `204`: Node has been deleted.
* `403`: Access denied. Refer to `message` key in JSON response for details.
* `404`: Node is not exist.
* `500`: The server having errors.
