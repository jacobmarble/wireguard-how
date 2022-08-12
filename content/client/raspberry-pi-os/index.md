---
title: "Raspberry Pi OS"
type: "docs"
---

# WireGuard Client: Raspberry Pi OS

In this tutorial, we setup a WireGuard client on a Raspberry Pi 4 running Raspbian OS Bullseye (64-bit).
Before following this tutorial, you should already have a working [WireGuard server running](/server).

## Setup WireGuard

### Install WireGuard

Install the WireGuard packages.
After this step, `man wg` and `man wg-quick` will work and the `wg` command gets bash completion.
```text
$ sudo apt install wireguard
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  wireguard-tools
The following NEW packages will be installed:
  wireguard wireguard-tools
0 upgraded, 2 newly installed, 0 to remove and 0 not upgraded.
Need to get 97.1 kB of archives.
After this operation, 332 kB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://deb.debian.org/debian bullseye/main arm64 wireguard-tools arm64 1.0.20210223-1 [88.9 kB]
Get:2 http://deb.debian.org/debian bullseye/main arm64 wireguard all 1.0.20210223-1 [8,164 B]
Fetched 97.1 kB in 0s (678 kB/s)
Selecting previously unselected package wireguard-tools.
(Reading database ... 37611 files and directories currently installed.)
Preparing to unpack .../wireguard-tools_1.0.20210223-1_arm64.deb ...
Unpacking wireguard-tools (1.0.20210223-1) ...
Selecting previously unselected package wireguard.
Preparing to unpack .../wireguard_1.0.20210223-1_all.deb ...
Unpacking wireguard (1.0.20210223-1) ...
Setting up wireguard-tools (1.0.20210223-1) ...
wg-quick.target is a disabled or a static unit, not starting it.
Setting up wireguard (1.0.20210223-1) ...
Processing triggers for man-db (2.9.4-2) ...
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
