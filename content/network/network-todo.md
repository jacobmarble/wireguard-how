---
title: "Network TODO"
type: "docs"
draft: true
---

## Configure the Network Masquerade/NAT/Forwarder

The `wg0` network interface isn't good for much, other than connecting clients to the service.
In this section, we will configure the Raspberry Pi to allow access to the internet via the WireGuard server.

### Enable Packet Forwarding

Verify that packets from this system will route properly.
```text
$ ip route show
default via 10.0.1.1 dev eth0 proto dhcp src 10.0.1.10 metric 202
10.0.1.0/24 dev eth0 proto dhcp scope link src 10.0.1.10 metric 202
10.0.2.0/24 dev wg0 proto kernel scope link src 10.0.2.1
```

By default, the Linux kernel is configured disallow packet forwarding.
The `sysctl` tool allows us to enable packet forwarding.

Edit the file `/etc/sysctl.conf`.
(Use a command like `sudo nano /etc/sysctl.conf`.)
Jump to about line 28 and uncomment `net.ipv4.ip_forward=1`.
```text
...
# Uncomment the next line to enable packet forwarding for IPv4
net.ipv4.ip_forward=1
...
```

The kernel will respect the change to `sysctl.conf` the next time it boots.
Use the `sysctl` command to apply the change now.
```text
$ sudo sysctl --load --system
* Applying /etc/sysctl.d/98-rpi.conf ...
kernel.printk = 3 4 1 3
vm.min_free_kbytes = 16384
* Applying /etc/sysctl.d/99-sysctl.conf ...
net.ipv4.ip_forward = 1
* Applying /etc/sysctl.d/protect-links.conf ...
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
* Applying /etc/sysctl.conf ...
net.ipv4.ip_forward = 1
```

At any time, verify that packet forwarding is enabled.
```text
$ sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 1
```

## Configure Packet Forwarding

Install the `nft` CLI, used to configure things like packet filtering and network address translation.
```text
$ sudo apt install nftables --assume-yes
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following additional packages will be installed:
  libjansson4 libnftables0
The following NEW packages will be installed:
  libjansson4 libnftables0 nftables
0 upgraded, 3 newly installed, 0 to remove and 0 not upgraded.
...
Setting up libjansson4:armhf (2.12-1) ...
Setting up libnftables0:armhf (0.9.0-2) ...
Setting up nftables (0.9.0-2) ...
Processing triggers for man-db (2.8.5-2) ...
Processing triggers for libc-bin (2.28-10+rpi1) ...
```

Enable the `nftables` service.
```text
$ sudo systemctl enable --now nftables.service
Created symlink /etc/systemd/system/sysinit.target.wants/nftables.service → /lib/systemd/system/nftables.service.
```

Edit the file `/etc/nftables.conf`.
(Use a command like `sudo nano /etc/nftables.conf`.)
Delete the filter table that is configured by default, and create a table called "wireguard".
```text
#!/usr/sbin/nft -f

flush ruleset
add table wireguard
add chain wireguard postrouting { type nat hook postrouting priority 0; }
add rule wireguard postrouting masquerade
```

This change will take effect the next time the system boots.
Restart `nftables` to apply the change now.
```text
$ sudo systemctl restart nftables.service
```

At any time, verify that the firewall is configured properly.
```text
$ sudo nft list ruleset
table ip wireguard {
	chain postrouting {
		type nat hook postrouting priority 0; policy accept;
		masquerade
	}
}
```

Check the route for any address listed in the client config, Peer->AllowedIPs.
In this example, we see that 10.0.1.1 is, indeed routing through the `utun1` interface.
```text
$ route get 10.0.1.1
   route to: 10.0.1.1
destination: default
       mask: default
  interface: utun1
      flags: <UP,DONE,CLONING,STATIC>
 recvpipe  sendpipe  ssthresh  rtt,msec    rttvar  hopcount      mtu     expire
       0         0         0         0         0         0      1420         0
```

If the client config Interface->DNS is set and Peer-AllowedIPs is set to 0.0.0.0/0,
then check that public DNS addresses are being routed.
```text
$ route get 1.1.1.1
   route to: one.one.one.one
destination: one.one.one.one
  interface: utun1
      flags: <UP,HOST,DONE,WASCLONED,IFSCOPE,IFREF>
 recvpipe  sendpipe  ssthresh  rtt,msec    rttvar  hopcount      mtu     expire
       0         0         0         0         0         0      1420         0

$ host news.ycombinator.com
news.ycombinator.com has address 209.216.230.240

$ route get 209.216.230.240
   route to: news.ycombinator.com
destination: default
       mask: default
  interface: utun1
      flags: <UP,DONE,CLONING,STATIC>
 recvpipe  sendpipe  ssthresh  rtt,msec    rttvar  hopcount      mtu     expire
       0         0         0         0         0         0      1420         0

$ curl --silent --output /dev/null -w "%{http_code}" https://news.ycombinator.com
200
```
