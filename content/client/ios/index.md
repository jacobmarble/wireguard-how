---
title: "iOS"
type: "docs"
---

# WireGuard Client: iOS

In this tutorial, we setup a WireGuard client on iOS (iPhone, for example).
Before following this tutorial, you should already have a [WireGuard server running](/server).
Install the [WireGuard app for iOS](https://apps.apple.com/us/app/wireguard/id1441195209).

## Get the Server Public Key

From the server, print the server's public key.
We'll need this soon
```text
$ sudo wg show wg0
interface: wg0
  public key: {{< lookup server-public >}}
  private key: (hidden)
  listening port: {{< lookup server-port >}}
```

## Create Client Keys

Create private and public keys for the WireGuard client.
Protect the private key with a file mode creation mask.
```text
$ (umask 077 && wg genkey > wg-private-client.key)
$ wg pubkey < wg-private-client.key > wg-public-client.key
```

Print the client private key.
```text
$ cat wg-private-client.key
{{< lookup client-private >}}
```

## Create the Client WireGuard Config

Create the WireGuard client config file at `~/wg-client.conf`.
(Use a command like `nano ~/wg-client.conf`.)
Notice the syntax of the client config is the same as the server config.
```text
# define the local WireGuard interface (client)
[Interface]

# contents of wg-private-client.key
PrivateKey = {{< lookup client-private >}}

# the IP address of this client on the WireGuard network
Address={{< lookup client-vpn-address >}}/32

# define the remote WireGuard interface (server)
[Peer]

# from `sudo wg show wg0`
PublicKey = {{< lookup server-public >}}

# the IP address of the server on the WireGuard network 
AllowedIPs = {{< lookup server-vpn-address >}}/32

# public IP address and port of the WireGuard server
Endpoint = {{< lookup server-public-address >}}:{{< lookup server-port >}}
```

## Configure the Server

Print the client public key.
```text
$ cat wg-public-client.key
{{< lookup client-public >}}
```

Edit the WireGuard service config file at `/etc/wireguard/wg0.conf`.
(Use a command like `sudo nano /etc/wireguard/wg0.conf`.)
Add a `[Peer]` section to the bottom.
```text
# define the remote WireGuard interface (client)
[Peer]

# contents of wg-public-client.key
PublicKey = {{< lookup client-public >}}

# the IP address of the client on the WireGuard network
AllowedIPs = {{< lookup client-vpn-address >}}/32
```

Apply the server config change.
```text
$ sudo wg syncconf wg0 /etc/wireguard/wg0.conf
```

## Add the Config to the iOS Device

The client config file is on the server.
The easy way to copy that config to the client is via QR code.
Install `qrencode` on the WireGuard server.
```text
$ sudo apt install qrencode --assume-yes
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following additional packages will be installed:
  libqrencode4
The following NEW packages will be installed:
  libqrencode4 qrencode
...
Setting up qrencode (4.0.2-1) ...
Processing triggers for man-db (2.8.5-2) ...
Processing triggers for libc-bin (2.28-10+rpi1) ...
```

Print the QR code in the server terminal.
```text
$ qrencode --read-from=wg-client.conf --type=UTF8 --level=M
█████████████████████████████████████████████████████████████████
█████████████████████████████████████████████████████████████████
████ ▄▄▄▄▄ █▄▀▄█ ▀▄ █ ▀  █▀▄   ▀ █▄█▀█ ▄█▄▄█ █▄▀ ▄▄ ██ ▄▄▄▄▄ ████
████ █   █ █▄█▄  █▄▄█▄▄█▄█  ▀▄▄ █▄ ▄ ▀███ ▀ ▄▀▄ █ ▄ ██ █   █ ████
████ █▄▄▄█ █▀ ▄█▄▄▄▀▀▀▄█▄▀ ▄   ▄▄▄ ▄▄▄▄▀██ ▀██ ▄█ ▀▄██ █▄▄▄█ ████
████▄▄▄▄▄▄▄█▄▀ ▀ ▀ █ █ ▀ █ ▀ █ █▄█ ▀ ▀ █ ▀ █ ▀ ▀ █▄█ █▄▄▄▄▄▄▄████
████ ▀▄▀██▄ ▀ ▄ █▄▄█▄▀▄███████▄▄  ▄▀ ▀██▄ █▀ ██▀ ▀███▀█▄▀█▄▀▄████
█████ ▀▀█▄▄▀▄▀▄▄▀  ▄ ▀█▄▀ ▄▄▄ ▄█▄ ▀██ ▀▄ ▀▄▄▀█▀▄ ▄▀█ █▄█▄▄██▄████
████▀   █ ▄██ ▄▀█▄  ▀█▀█  ▄█▄██▄▄▀█▀▄▀██▄▀▄▀▄▀█▀  ▄ █ ▄▄  █ ▄████
████ ▀▄▀▄▄▄▀▀█▀█  ▀ ▄ ▀█▀▄ █▄▄▄ ▄▀▄ ▀  ▀ ▀█▄█▄  ▀ ▄▀▄ ▄▄▀ █▀ ████
████ ▀▄▀  ▄ ▀▄▄▄▀▄ ▀█▀▀▀▄█▀█▄ ▀▀▄▀██▄█▄ ▄▀█▀▄▀▄█▄▀▄ █▀▄█▄██▀▄████
████ █▀ ▀ ▄▀ ▄▄▄█ ▄█ ▄   █▀▄▄▀▄ █▄██  ▄  ▄▄█ █▀▄ ▀██ ▀▀▄▀▄▄▀▄████
████ ▀▀ ▀▀▄██▀ ▄ ▄█▄▀▄  █   ▄█▄▀▄▀█ ▄▀▄▄▄█▄▀█ ▄█▄ █ █ ██▄▄▀ ▄████
████▀   ▄▀▄▀▄█▄███▄ █▄█▀ ▄ █▀█▄▀▀█ ▄ ▄▀▄  █▄ █▄▀ ███▄█ █ ▀█▀ ████
████ █▀▀██▄▄▄█▄▄ ▄▀█▄█▄▄ ▄█▄███  ▀█▀▀ █▀ ▀▄▀  ██▄▄█▀▄ █▀▄▄▄  ████
████▄█ ▄ ▄▄▄ ▄▄▄█▄▄ █▀▀▀▀▄ ▄▄  ▄▄▄ █▀ ▄▄ ██▄▄ █▄▄ █▄ ▄▄▄  ▄▄ ████
████▄▀█▀ █▄█  ▄▄▄▄ ▄ ███▀ ▄▀█  █▄█ █▄█▄ ▄▀▄▀  ▄ ▀▀▄▄ █▄█   ▀▀████
████      ▄▄  ▄▀   ████ ▄▄▀▀▄█ ▄▄ ▄▀▀▄███▄▀ ▄█▀▄ █▄█  ▄▄▄██▄▄████
████ █ █ █▄▄█ ██ ▀▄ ▀█ ▄█    █ ██▀▄   ██▀█▄▀▄▀█ ▄ █▄  ▄▀██▀█ ████
█████▀▀▄▀▄▄ █  ▀▀ ▀▀  ▀██▄█ ▀█▄▀▄▀ █ ▄▀▄▄▄▀█ ▀█▀▄██▀ █    ▄▄█████
████▀ ▄▀▀▀▄▀▀▀█▀ ▀▄██▀▄▄█ ▄▄█▄ ▄  ██▄ ██▄▀▄█▄ ██  █▄▄█▄▄▄▄ ▄▄████
████▀▄▀▀▀▄▄▄ █▀   ▀ ▀ █ ▄  ▀ ▄█ ▄█ █▄ ▄▄   █▄▄▀ ██▄  ▄▀▄█▄█▀▄████
████▀▄█ ██▄█▄▄█▄▀   ▄██ █▀▄ ██▀ ▄▀▄▀  █ ▄▄  ▄ █▀▄▄▄ █▄ ▀██ █▄████
████▄▄▀▀█▀▄▀▄ ▄ ▀ █▄ ▀█ █▄█▄█▄▀ ▄█ ▀ ██▀▀▄▀▄ ▀  ██▀▀ █ ▀█▀▄█▄████
████▀██▄▀▀▄ ▄▄█ ▀█▀▄ █▄▀█ ███▄▄ ▄▄▄▄ ▀▄▄ █▄█  ▄█ ▀█   █▀█ █▄▀████
████ ▀ ▀▀▄▄█▀█▄█  ▄█▄▀ █▄▀█ ▀█▄▀  ▀▄  ▀ ▀▄▀▄▀ █▄▀▀▀▄▄█  ▀▀▄▄ ████
██████████▄█ ██▄▀▄▄ ▀▀ ▄▀▀▀██▄ ▄▄▄ █▄▄ ▄▄▀█▀▄▀█  █▄▄ ▄▄▄ █▄▄ ████
████ ▄▄▄▄▄ █▄█ █▄ █▄█ ▄ ▄ ▀█ ▄ █▄█ ██▄▀▄▄██▄█▄█   ▄▄ █▄█ ██▀ ████
████ █   █ ██ ▄▄▄▀  █ █▄ ▄▄▄▄█   ▄ ▀▄▀██ ▄▄█▄█▀▀▄██▄ ▄ ▄▄▀██▄████
████ █▄▄▄█ █▄▄▀▄▀▄ ▄ █ ▄ ▄▄▄▄▄▄▀  ██ ▄█▀▀█▀ ▀▄█▄▄▀▀█ ▀█▄█▀█▄▄████
████▄▄▄▄▄▄▄█▄█▄█▄▄▄████▄█▄███▄▄▄▄█▄█▄█▄▄▄█▄█▄█▄▄▄█▄█▄█▄▄▄▄██▄████
█████████████████████████████████████████████████████████████████
█████████████████████████████████████████████████████████████████
```

## Import Client Config

From the WireGuard iOS app, tap "Add a Tunnel", or tap the plus symbol at the upper right corner.
In the dialog, tap "Create from QR code".
(Allow the WireGuard app to use the camera.)
The camera activates; point the camera at the QR code.
Name the tunnel and tap "Save".
(Allow the WireGuard app to add VPN configurations.)

## Activate the Tunnel

From the WireGuard app, tap the toggle switch next to your new tunnel.

## Test the Tunnel from the Server


