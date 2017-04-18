# Troubleshooting

[TOC]

## Testing the Cluster
This section will be added soon.

## Log Files
The setup and deployment logs for the cluster container are available via Container Log API.

Example:

    # setup log
    curl localhost:8080/container_logs/<container-name>/setup

    # teardown log
    curl localhost:8080/container_logs/<container-name>/teardown

The term `<container-name>` represents the currently-supported containers that are `ldap`, `oxauth`, `oxtrust`, and `nginx`.

## Recovering Cluster
There are instances when the cluster server may be rebooted, or for some unavoidable circumstances, the cluster server was shutdown and booted again.

For a detailed step by step cluster recovery see the [Recovery Page](../recovery/).

## Transparent Huge Page in MongoDB

As we are using MongoDB, there will be warnings about Transparent Huge Page (THP).
In special usecase where MongoDB is used in its own dedicated server, we should disable THP on Linux machines to ensure best performance with MongoDB.

In Gluu Server Docker Edition, this warning is considered as acceptable, hence we don't need to do anything to fix THP issue.
But in case we need it, to disable THP, we can modify `/etc/rc.local` and add the following lines,
right before the last line (`exit 0`):

```
if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
    echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi
if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi
```

Run this command once to make sure THP config is modified without restarting the server:

```sh
/etc/rc.local
```
