---
title: "Debian"
type: "docs"
---

# WireGuard Server: Debian

In this tutorial, we setup a WireGuard service on a Debian instance.
Our example uses vanilla Debian 10 running as a VirtualBox guest.
The network interface is connected to a private network,
connected to the Internet via an Apple AirPort Extreme.

## Setup Network



## Setup WireGuard

In this section, we'll use the shell on our VM instance to install and configure WireGuard.

Switch to root.
```
$ su -
Password:
#
```

To install the most recent version of WireGuard,
we'll add the "unstable" Debian release,
and then [pin the unstable priority behind stable](https://wiki.debian.org/AptConfiguration).
This gives us access to unstable packages that are not available in stable,
without upgrading everything to unstable.

