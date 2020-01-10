---
title: "Debian"
type: "docs"
---

# WireGuard Server: Debian

In this tutorial, we setup a WireGuard service on a [Debian](https://www.debian.org/) server.
This example uses "vanilla" Debian Buster.

At the end of this tutorial, the Debian server will have a virtual network interface `wg0`
living on private network `{{< lookup vpn-address >}}/{{< lookup vpn-size >}}`.
The Debian server will be ready to [add WireGuard clients](/client).

## Platform

### Install `sudo`

In this tutorial, we execute all commands as a non-root user with help from the
[`sudo` command](https://manpages.debian.org/buster/sudo-ldap/sudo.8.en.html).
Debian doesn't always come with `sudo` installed.

Check that `sudo` is installed.
```text
$ sudo
-bash: sudo: command not found
```

In this example, the `sudo` command is missing.
To fix, login as root, either via login prompt or via `su -`
(which requires the root user password).
```text
# apt install sudo
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following NEW packages will be installed:
  sudo
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
...
Setting up sudo (1.8.27-1+deb10u1) ...
Processing triggers for man-db (2.8.5-2) ...
Processing triggers for systemd (241-7~deb10u2) ...
``` 

### Enable `sudo`

By default, Debian does not allow non-root users to use the `sudo` command.

Check your non-root user.
In this example, the non-root user is `jacob`.
Login in as the non-root user and run `groups`.
```text
$ groups
jacob cdrom floppy audio dip video plugdev netdev
``` 

If the `sudo` group is included in this list, then the non-root user can use `sudo`.
In the above example, the group `sudo` does not appear.
To fix, login as root, either via login prompt or via `su -`
(which requires the root user password).
```text
# adduser jacob sudo
```

Logout the root user.
If `su -` was used to run `adduser` then also logout the non-root user.
Login as the non-root user and run `groups` again.
```text
$ groups
jacob cdrom floppy sudo audio dip video plugdev netdev
```

In the above example, the group `sudo` appears where it was missing before.

## Setup WireGuard

### Install WireGuard

{{< snippet server-debian-install-wireguard.md >}}

### Create Keys

{{< snippet server-debian-create-keys.md >}}

### Create the WireGuard Network Device

{{< snippet server-debian-create-wireguard-device.md >}}
