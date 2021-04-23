---
title: "macOS"
type: "docs"
---

# WireGuard Client: macOS

In this tutorial, we setup a WireGuard client on macOS.
Before following this tutorial, you should already have a working [WireGuard server running](/server).
Install the [WireGuard app for macOS](https://itunes.apple.com/us/app/wireguard/id1451685025).

## Get the Server Public Key

From the server, print the server's public key.
We'll need this soon.
```text
$ sudo wg show wg0
interface: wg0
  public key: {{< lookup server-public >}}
  private key: (hidden)
  listening port: {{< lookup server-port >}}
```

## Configure the Client

Click the WireGuard icon in the MacOS menu bar, then click "Manage Tunnels".
Click the plus button at the bottom left corner of the "Manage WireGuard Tunnels" window,
then click "Add Empty Tunnel..."

Give the tunnel a name.
Something human-readable like "office" or "Raspberry Pi".

The client public key is set for us in this dialog, and can be copy-pasted.
We'll need this soon.

Ignore "On-Demand" for this tutorial.

The text area is used to edit the client configuration.
Notice the syntax of the client config is the same as the server config.
```text
# define the local WireGuard interface (client)
[Interface]

# pre-populated by the WireGuard UI
PrivateKey = {{< lookup client-private >}}

# the IP address of this client on the WireGuard network
Address = {{< lookup client-vpn-address >}}/32

# define the remote WireGuard interface (server)
[Peer]

# contents of wg-public.key on the WireGuard server
PublicKey = {{< lookup server-public >}}

# the IP address of the server on the WireGuard network 
AllowedIPs = {{< lookup server-vpn-address >}}/32

# public IP address and port of the WireGuard server
Endpoint = {{< lookup server-public-address >}}:{{< lookup server-port >}}
``` 

Copy the client public key, then click "Save" to close the dialog.

## Configure the Server

Edit the WireGuard service config file at `/etc/wireguard/wg0.conf`.
(Use a command like `sudo nano /etc/wireguard/wg0.conf`.)
Add a `[Peer]` section to the bottom.
```text
# define the remote WireGuard interface (client)
[Peer]

# copied from the client tunnel dialog
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

Back in the macOS client tunnel manager, click the "Activate" button.

## Test the Tunnel from the Server

(TODO)

## Test the Tunnel from the Client

Are packets for the WireGuard server routed via the WireGuard tunnel `utun0`?
Query the routing table.
```text
$ route get {{< lookup server-vpn-address >}}
   route to: {{< lookup server-vpn-address >}}
destination: default
       mask: default
  interface: utun0
      flags: <UP,DONE,CLONING,STATIC>
 recvpipe  sendpipe  ssthresh  rtt,msec    rttvar  hopcount      mtu     expire
       0         0         0         0         0         0      1420         0
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
