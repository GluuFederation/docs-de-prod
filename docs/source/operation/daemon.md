## Tweaking Docker Daemon for Production

### Log Rotation for Docker Container

By default, the log driver is set to `json-file` which means the log of a container is written to disk under `/var/lib/docker/containers` directory.
Unfortunately when using the default log driver, the log file will grow up and eventually takes space on the disk.
To mitigate this issue, user can change the log driver or customize the `log-opts` to rotate the container log by creating `/etc/docker/daemon.json` if not exist. See the example below:

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
