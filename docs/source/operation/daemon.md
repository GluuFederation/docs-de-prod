## Resource

For production, we recommend using server with minimum 8GB memory and 80GB disk.

## Storage Driver

Each Docker installation may have different storage driver depends on host's OS. Check the storage driver used by Docker daemon using `docker info`. Here's an example of the output:

```
Server Version: 18.06.1-ce
Storage Driver: overlay2
 Backing Filesystem: extfs
 Supports d_type: true
 Native Overlay Diff: true
```

From the output above, the storage driver is set to `overlay2`. Refer to this [docs](https://docs.docker.com/storage/storagedriver/select-storage-driver/) to see supported storage drivers.

By default, each container is set to have 10GB disk size. For OpenDJ container, this size might be not enough. There are 2 ways on how to increase the container disk size:

1.  Set the option globally in `/etc/docker/daemon.json` (will be applied to all containers).

    ```
    {
        "storage-driver": "devicemapper",
        "storage-opts": [
            "dm.basesize=20G"
        ]
    }
    ```

    Make sure the Docker daemon service is restarted.

2.  Set the option locally when running the container.

    ```
    docker run --storage-opts dm.basesize=20G gluufederation/opendj:3.1.5_dev
    ```

Please note that the ability to change the disk size for container depends on [storage driver](https://docs.docker.com/storage/storagedriver/select-storage-driver/).

## Log Rotation for Docker Container

By default, the log driver is set to `json-file` which means the log of a container is written to disk under `/var/lib/docker/containers` directory.
Unfortunately when using the default log driver `json-file`, the log file will grow up and eventually takes space on the disk.
To mitigate this issue, user can change the [log driver](https://docs.docker.com/config/containers/logging/configure/) or customize the `log-opts` to rotate the container log by creating `/etc/docker/daemon.json` if not exist. See the example below:

```
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    }
}
```

User can change how many log file per container (`max-file` option) and how big each file is (`max-size` option).
__Note__, any modification in `/etc/docker/daemon.json` requires service restart, i.e. `systemctl restart docker`.
