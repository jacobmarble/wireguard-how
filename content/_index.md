---
type: docs
title: "Jacob's WireGuard VPN Guide"
bookToc: false
---

# Jacob's WireGuard VPN Guide

These guides assume some experience with Linux.
[Contact me](/contact) if you see something wrong or missing.

Be sure to read [What is WireGuard?](/meta/what)
if you aren't certain that you need WireGuard.
You might not.

## How to Use This Site

The tutorials are categorized: server, client, network.
Follow a server tutorial, then a client tutorial, then a network tutorial,
and you should have a working VPN.

### 1) Server

First, setup a WireGuard server.

WireGuard performs very well on Linux hosts because it's implemented as a virtual network interface in a kernel module.
For consistency, the server guides favor [the Debian distribution](https://www.debian.org/), release 10/Buster.
You may need to adjust if that doesn't work for your situation.
The WireGuard server is one end of the secure network tunnel.

Follow whichever server guide fits your situation best.
When you complete any server guide, you'll have a WireGuard server ready for clients.

### 2) Client

Second, configure a client.

A WireGuard client is a device with a problem that can be solved by
opening a tunnel to the WireGuard server.
A client is most often a laptop or mobile device.
Easy-to-install apps exist for the major platforms.

When you complete any client guide,
the client will have access to the WireGuard server,
and no other resources on the server end of the tunnel.

### 3) Network Configuration

Third, adjust network settings to fulfill your VPN requirements.

Before this step, the server provides access to:
- other services running on the WireGuard host
- (optional) its private network
- (optional) the public internet

If you installed the WireGuard server on the only system that the client needs to reach,
like a file server or Minecraft server, then skip this step.

If the client needs access to the server's private network, follow the TODO guide.

If the client needs access to the public internet, complete the TODO guide
and then follow the TODO2 guide.
