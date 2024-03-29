---
title: "Debian"
type: "docs"
---

# WireGuard Client: Debian

In this tutorial, we setup a WireGuard client on a computer running Debian.
Before following this tutorial, you should already have a working [WireGuard server running](/server).
This example uses "vanilla" Debian Buster.

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

Install the WireGuard packages.
After this step, `man wg` and `man wg-quick` will work and the `wg` command gets bash completion.
```text
$ sudo apt install wireguard --assume-yes
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following additional packages will be installed:
  dkms linux-compiler-gcc-8-x86 linux-headers-4.19.0-16-amd64 linux-headers-4.19.0-16-common linux-headers-amd64 linux-kbuild-4.19 wireguard-dkms wireguard-tools
Suggested packages:
  python3-apport menu openresolv | resolvconf
The following NEW packages will be installed:
  dkms linux-compiler-gcc-8-x86 linux-headers-4.19.0-16-amd64 linux-headers-4.19.0-16-common linux-headers-amd64 linux-kbuild-4.19 wireguard wireguard-dkms wireguard-tools
0 upgraded, 9 newly installed, 0 to remove and 0 not upgraded.
...
DKMS: install completed.
Setting up wireguard-tools (1.0.20210223-1~bpo10+1) ...
wg-quick.target is a disabled or a static unit, not starting it.
Setting up linux-headers-4.19.0-16-common (4.19.181-1) ...
Setting up wireguard (1.0.20210223-1~bpo10+1) ...
Setting up linux-headers-4.19.0-16-amd64 (4.19.181-1) ...
Setting up linux-headers-amd64 (4.19+105+deb10u11) ...
Processing triggers for man-db (2.8.5-2) ...
```

## Get the Server Public Key

(We're on the server for this section.)

Print the server's public key.
We'll need this soon.
```text
$ sudo wg show wg0
interface: wg0
  public key: {{< lookup server-public >}}
  private key: (hidden)
  listening port: {{< lookup server-port >}}
```

## Configure the Client

(We're back on the client for this section.)

### Create Client Keys

In every client/server relationship, each peer has its own private and public keys.
Create private and public keys for the WireGuard client service.
Protect the private key with a file mode creation mask.
```text
$ (umask 077 && wg genkey > wg-private.key)
$ wg pubkey < wg-private.key > wg-public.key
```

Print the private key, we'll need it soon.
```text
$ cat wg-private.key
{{< lookup client-private >}}
```

Create the WireGuard client service config file at `/etc/wireguard/wg0.conf`.
(Use a command like `sudo nano /etc/wireguard/wg0.conf`.)
```text
# define the local WireGuard interface (client)
[Interface]

# contents of file wg-private.key that was recently created
PrivateKey = {{< lookup client-private >}}

# define the remote WireGuard interface (server)
[Peer]

# contents of wg-public.key on the WireGuard server
PublicKey = {{< lookup server-public >}}

# the IP address of the server on the WireGuard network 
AllowedIPs = {{< lookup server-vpn-address >}}/32

# public IP address and port of the WireGuard server
Endpoint = {{< lookup server-public-address >}}:{{< lookup server-port >}}
```

Create the WireGuard network device at `/etc/network/interfaces.d/wg0`.
(Use a command like `sudo nano /etc/network/interfaces.d/wg0`.)
```text
# indicate that wg0 should be created when the system boots, and on ifup -a
auto wg0

# describe wg0 as an IPv4 interface with static address
iface wg0 inet static

        # the IP address of this client on the WireGuard network
        address {{< lookup server-vpn-address >}}/{{< lookup vpn-size >}}

        # before ifup, create the device with this ip link command
        pre-up ip link add $IFACE type wireguard

        # before ifup, set the WireGuard config from earlier
        pre-up wg setconf $IFACE /etc/wireguard/$IFACE.conf

        # after ifdown, destroy the wg0 interface
        post-down ip link del $IFACE
```

## Configure the Server

(We're on the server for this section.)

Edit the WireGuard service config file at `/etc/wireguard/wg0.conf`.
(Use a command like `sudo nano /etc/wireguard/wg0.conf`.)
Add a `[Peer]` section to the bottom.
```text
# define the remote WireGuard interface (client)
[Peer]

# contents of file wg-public.key on the WireGuard client
PublicKey = {{< lookup client-public >}}

# the IP address of the client on the WireGuard network
AllowedIPs = {{< lookup client-vpn-address >}}/32
```

Apply the server config change.
```text
$ sudo wg syncconf wg0 /etc/wireguard/wg0.conf
```

Ensure that the server config change was correctly applied.
```text
$ sudo wg show wg0
interface: wg0
  public key: {{< lookup server-public >}}
  private key: (hidden)
  listening port: {{< lookup server-port >}}

peer: {{< lookup client-public >}}
  allowed ips: {{< lookup client-vpn-address >}}/32
```

## Activate the Tunnel

(We're back on the client for this section.)

Start WireGuard.
```text
$ sudo ifup wg0
```

## Test the Tunnel from the Server

(TODO)

## Test the Tunnel from the Client

Are packets for the WireGuard server routed via the WireGuard tunnel `utun0`?
Query the routing table.
```text
$ ip route get {{< lookup server-vpn-address >}}
{{< lookup server-vpn-address >}} dev wg0 src {{< lookup client-vpn-address >}} uid 1000
    cache
```

Is the WireGuard server accessible via the tunnel?
Ping the server from the client.
```text
$ ping -c 3 {{< lookup server-vpn-address >}}
PING {{< lookup server-vpn-address >}} ({{< lookup server-vpn-address >}}): 56 data bytes
64 bytes from {{< lookup server-vpn-address >}}: icmp_seq=0 ttl=64 time=45.234 ms
64 bytes from {{< lookup server-vpn-address >}}: icmp_seq=1 ttl=64 time=67.192 ms
64 bytes from {{< lookup server-vpn-address >}}: icmp_seq=2 ttl=64 time=41.907 ms

--- {{< lookup server-vpn-address >}} ping statistics ---
3 packets transmitted, 3 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 41.907/51.444/67.192/11.218 ms
```



At any time, verify that the WireGuard configuration for `wg0` is what you expect:
```text
$ sudo wg show wg0
interface: wg0
  public key: server-public
  private key: (hidden)
  listening port: server-port
```

At any time, verify that the `wg0` network interface exists.
```text
$ ip address show dev wg0
  7: wg0: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc noqueue state UNKNOWN group default qlen 1000
      link/none
      inet server-vpn-address/vpn-size brd vpn-broadcast-address scope global wg0
         valid_lft forever preferred_lft forever
```
