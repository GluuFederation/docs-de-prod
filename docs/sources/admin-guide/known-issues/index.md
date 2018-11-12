# Known Issues

[TOC]

## Unsupported Kernel

*   The Enterprise Edition does not work well when using __kernel 3.13.0-77__.
    One of the symptoms is high CPU usage due to Java process turned into zombie process.
    We can check whether this issue occurs in our server:

        ps -ef | grep defunct

    If we see a Java process with `<defunct>` status, then we're hit by this issue.

    A workaround is to upgrade or downgrade the kernel. Some supported (and tested) kernel versions:

    * 3.13.0-71
    * 3.13.0-79
    * 3.16
    * and many more
