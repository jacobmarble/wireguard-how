---
type: docs
title: "What is WireGuard?"
bookToc: true
weight: 2
---

# What is WireGuard?

WireGuard is VPN software.
Among VPN alternatives, WireGuard is special because it's [secure, fast, simple, and open source](https://www.wireguard.com/papers/wireguard.pdf).

More specifically, WireGuard is a [secure network tunnel protocol](https://www.wireguard.com/protocol/),
and is also [several implementations](https://www.wireguard.com/repositories/) of the WireGuard protocol.
Secure network tunnels are the backbone of virtual private networks,
so WireGuard is used in concert with standard networking tools to create VPNs.

A virtual private network is an encrypted, private network that securely passes through the
wonderful, chaotic, scary place we call the internet.
It's one way to securely connect two or more computers/phones/things to each other,
and it can also **contribute to** safer internet use.

## What Can a VPN Do for Me?

Below, we'll mention some ways that a VPN can make your life a little better.
Before that, it's important to note that a VPN:
- **doesn't** "protect your online identity"
- **shouldn't** make you "feel safe online"
- **can't** "take back your online privacy"
- **isn't necessary** to "secure your bank transactions"

If the above bullets don't sound right to you,
Sven Slootweg [wrote a gist](https://gist.github.com/joepie91/5a9909939e6ce7d09e29) and
Dennis Schubert [wrote a blog post](https://overengineer.dev/blog/2019/04/08/very-precarious-narrative.html)
that help dismantle some of the common misinformation about VPNs.
[Contact me](/contact) if you're aware of another link that should be added to this list.

With that out of the way, most VPNs are used to
(1) access the public internet or
(2) access a private network via the public internet.

### Gain access to the public internet

The "public category" is about situations where you need **safe access to the complete public internet**.
Some examples follow.

1) It isn't safe to use Wi-Fi access points that are unsecured, or that are secured with a password that many people know.
Think restaurants, public libraries, or your friend Jimmy's house.
In these scenarios, it's easy for an adversary to observe or record your online activity
(man-in-the-middle attack).

1) Some organizations provide internet access with restrictive policies to block specific categories of internet traffic.
Employers, universities, cafés, internet service providers, and whole countries have been known to censor:
   - social networking
   - [voice-over-IP traffic](https://www.wired.com/2005/05/voice-over-ips-unlikely-hero/)
   - video game traffic
   - political information
   - BitTorrent search engines and traffic
   - [Wikipedia](https://en.wikipedia.org/wiki/Censorship_of_Wikipedia)

1) In various parts of the world, the internet looks a little different than you're probably use to.
Services like Netflix and YouTube provide different content to different parts of the world.
Many websites change their default language based on the location of your IP address.

In all of these cases, a VPN acts as a tunnel between the client
(the library, school, traveling) and the server (home, office, datacenter).

### Gain access to a private network

The "private category" is for situations where you need **safe access to a private network**
from anywhere the internet is accessible.

In this context, a private network is
a home, office, or cloud or data center network connected to the internet via
[network address translation](https://en.wikipedia.org/wiki/Network_address_translation).
Devices on a private network usually have IP addresses starting with
[`192.168.` or `10.`](https://en.wikipedia.org/wiki/Private_network).
NAT is usually provided by your cable/DSL modem or Wi-Fi access point.
Devices on the private network can reach the internet, but
the internet can't reach out to the devices on the private network.

The terms "private network", "local area network", "intranet" are sometimes used interchangeably.
Similarly, the terms "firewall", "NAT router", "IP masquerade", "internet router" are sometimes used interchangeably.

Again, examples follow.

1) In many homes, printers, webcams, DVRs and Minecraft servers are attached to the private network
via Wi-Fi or Ethernet.
It can be convenient to check a webcam while away, or to invite friends to join a Minecraft server.
Simply opening up these devices to the world is a bad idea, as these devices
are often designed with security as an afterthought.

1) Similarly, office networks host printers, file servers, databases and internal websites.
Again, security isn't always the top concern when these services are built.

1) As the cost of cloud computing continues to tumble,
organizations have so many assets in (virtual) data centers that the host provides a virtual network
to the organization.
This way, the organization can limit external access to those resources,
allowing the resources to communicate with each other.
Many organizations today have compute and data processing assets in data centers.
TODO This needs more thought.
