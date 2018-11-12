# Recovery Overview

A provider may crashes due to various reasons (i.e. power outage).
When it crashes, all containers will crash as well.

## Version 0.5.0 and Above

Starting from v0.5.0, we have simplified the [script](https://github.com/GluuFederation/cluster-tools/blob/master/recovery/recovery.py)
which is installed during node creation.
To run this script, simply execute `supervisorctl restart recovery` in the shell.

## Older Releases

As of v0.3.3-12, recovery script is moved to Gluu Agent package.
Refer to installation section to install the package for [master](../installation/#installing-gluu-agent-on-master-provider) and [consumer](../installation/#installing-gluu-agent-on-consumer-provider) provider.

One of Gluu Agent jobs is to recover nodes automatically after provider is rebooted.
We can also recover the provider manually using the following command:

    gluu-agent recover

The recovery process is logged to stdout by default. We can store the log into a file by passing `--logfile` option.

    gluu-agent recover --logfile /var/log/gluuagent-recover.log

Note, Gluu Agent relies on local cluster data that is pushed by `gluu-flask` v0.3.3-12 to each provider,
hence it is recommended to upgrade to `gluu-flask` v0.3.3-12.
