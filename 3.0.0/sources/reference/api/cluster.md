[TOC]
## Cluster API

### Overview

Cluster holds all `docker` containers within `weave` network.

---

### Create New Cluster

    POST /clusters

Note, currently the API only allow 1 cluster. This may change in the future.

__URL:__

    http://localhost:8080/clusters

__Form parameters:__

*   `name` (required)

    The name of the cluster.

    Rules:

    * Minimum 3 characters.
    * Accepts alphanumeric (case-insensitive), dash, underscore, and dot characters.
    * Cannot use dash, underscore, or dot as leading or traling character.

*   `description` (optional)
*   `org_name` (required)

    Organization name for X.509 certificate.

*   `org_short_name` (required)

    Organization short name for X.509 certificate.

*   `city` (required)

    City for X.509 certificate.

*   `state` (required)

    State or province name for X.509 certificate.

*   `country_code` (required)

    ISO 3166-1 alpha-2 country code.

*   `admin_email` (required)

    Admin email address for X.509 certificate.

*   `ox_cluster_hostname` (required)

    Domain name to use for the admin interface website.

*   `admin_pw` (required)

    Default password for default Admin account. Minimum password length is 6 characters.

__Request example:__

```sh
curl http://localhost:8080/clusters \
    -d name=cluster1 \
    -d org_name=my-org \
    -d org_short_name=my-org \
    -d city=Austin \
    -d state=TX \
    -d country_code=US \
    -d admin_email='info@example.com' \
    -d ox_cluster_hostname=ox.example.com \
    -d admin_pw=secret \
    -X POST -i
```

__Response example:__

```http
HTTP/1.0 201 CREATED
Content-Type: application/json
Location: http://localhost:8080/clusters/1279de28-b6d0-4052-bd0c-cc46a6fd5f9f

{
    "inum_org": "@!FDF8.652A.6EFF.F5A3!0001!DA7B.9EB2",
    "oxauth_containers": [],
    "inum_appliance": "@!FDF8.652A.6EFF.F5A3!0002!FA83.4368",
    "admin_email": "info@example.com",
    "inum_appliance_fn": "FDF8652A6EFFF5A30002FA834368",
    "description": null,
    "city": "Austin",
    "base_inum": "@!FDF8.652A.6EFF.F5A3",
    "inum_org_fn": "FDF8652A6EFFF5A30001DA7B9EB2",
    "ldaps_port": "1636",
    "ox_cluster_hostname": "ox.example.com",
    "state": "TX",
    "country_code": "US",
    "ldap_containers": [],
    "nginx_containers": [],
    "org_short_name": "my-org",
    "org_name": "my-org",
    "id": "1279de28-b6d0-4052-bd0c-cc46a6fd5f9f",
    "oxtrust_containers": [],
    "name": "cluster1",
    "oxidp_containers": []
}
```

__Status Code:__

* `201`: Cluster is successfully created.
* `400`: Bad request. Possibly malformed/incorrect parameter value.
* `403`: Access denied. Possibly unable to create more cluster.
* `500`: The server having errors.

---

### Get A Cluster

    GET /clusters/{id}

__URL:__

    http://localhost:8080/clusters/{id}

__Request example:__

```sh
curl http://localhost:8080/clusters/1279de28-b6d0-4052-bd0c-cc46a6fd5f9f -i
```

__Response example:__

```http
HTTP/1.0 200 OK
Content-Type: application/json

{
    "inum_org": "@!FDF8.652A.6EFF.F5A3!0001!DA7B.9EB2",
    "oxauth_containers": [],
    "inum_appliance": "@!FDF8.652A.6EFF.F5A3!0002!FA83.4368",
    "admin_email": "info@example.com",
    "inum_appliance_fn": "FDF8652A6EFFF5A30002FA834368",
    "description": null,
    "city": "Austin",
    "base_inum": "@!FDF8.652A.6EFF.F5A3",
    "inum_org_fn": "FDF8652A6EFFF5A30001DA7B9EB2",
    "ldaps_port": "1636",
    "ox_cluster_hostname": "ox.example.com",
    "state": "TX",
    "country_code": "US",
    "ldap_containers": [],
    "nginx_containers": [],
    "org_short_name": "my-org",
    "org_name": "my-org",
    "id": "1279de28-b6d0-4052-bd0c-cc46a6fd5f9f",
    "oxtrust_containers": [],
    "name": "cluster1",
    "oxidp_containers": []
}
```

__Status Code:__

* `200`: Cluster is exist.
* `404`: Cluster is not exist.
* `500`: The server having errors.

---

### List All Clusters

`GET /clusters`

__URL:__

`http://localhost:8080/clusters`

__Request example:__

```sh
curl http://localhost:8080/clusters -i
```

__Response example:__

```http
HTTP/1.0 200 OK
Content-Type: application/json

[
    {
        "inum_org": "@!FDF8.652A.6EFF.F5A3!0001!DA7B.9EB2",
        "oxauth_containers": [],
        "inum_appliance": "@!FDF8.652A.6EFF.F5A3!0002!FA83.4368",
        "admin_email": "info@example.com",
        "inum_appliance_fn": "FDF8652A6EFFF5A30002FA834368",
        "description": null,
        "city": "Austin",
        "base_inum": "@!FDF8.652A.6EFF.F5A3",
        "inum_org_fn": "FDF8652A6EFFF5A30001DA7B9EB2",
        "ldaps_port": "1637",
        "ox_cluster_hostname": "ox.example.com",
        "state": "TX",
        "country_code": "US",
        "ldap_containers": [],
        "nginx_containers": [],
        "org_short_name": "my-org",
        "org_name": "my-org",
        "id": "1279de28-b6d0-4052-bd0c-cc46a6fd5f9f",
        "oxtrust_containers": [],
        "name": "cluster1",
        "oxidp_containers": []
    }
]
```

Note, if there's no cluster, the response body will return empty list.

__Status Code:__

* `200`: Request is succeed.
* `500`: The server having errors.

---

### Delete A Cluster

    DELETE /clusters/{id}

__URL:__

    http://localhost:8080/clusters/{id}

__Request example:__

```sh
curl http://localhost:8080/clusters/1279de28-b6d0-4052-bd0c-cc46a6fd5f9f -X DELETE -i
```

__Response example:__

```http
HTTP/1.0 204 NO CONTENT
Content-Type: application/json
```

__Status Code:__

* `204`: Cluster has been deleted.
* `403`: Access denied.
* `404`: Cluster is not exist.
* `500`: The server having errors.
