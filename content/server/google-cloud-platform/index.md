---
title: "Google Cloud Platform"
type: "docs"
---

# WireGuard Server: Google Cloud Platform

In this tutorial, we setup a WireGuard service in Google Cloud Platform.
Open a [Google Cloud Platform account](https://cloud.google.com/), which is free.

## Configure Google Cloud Platform Resources

In this section, we'll use the [GCP web console](https://console.cloud.google.com/).

Create a new project just for WireGuard.
In this example, the project name is `my-wireguard-project`.

You'll need to decide which region your WireGuard service will live in.
In this example I use `us-west1 (Oregon)` because it happens to be geographically close.

### Open a Port

The new project comes pre-configured with a VPC network named `default`,
and firewall rules that block inbound packets to all but a few ports.
WireGuard uses UDP, and is commonly configured to listen on port 51820.

Navigate to [VPC network > Firewall rules](https://console.cloud.google.com/networking/firewalls).

Click "Create Firewall Rule" near the top of the page.

![screenshot](/i/server/google-cloud-platform/vpc-network_firewall-rules_head.png)

- Give the rule a name. Here, I'm using `wireguard`.
- This is an ingress rule on the default network.
- Targets include "All instances in the network".
- Source filter is "IP ranges", specifically `0.0.0.0/0`.
- Under "Protocols and ports", select "Specified protocols and ports".
- Check "udp" and enter 51820.
- Click "Create".

{{< expand Screenshot >}}
![screenshot](/i/server/google-cloud-platform/vpc-network_create-a-firewall-rule_form.png)
{{< /expand >}}

### Create a Static IP Address

We'll need to reserve a static IP address so that our clients know where to find the service.

Navigate to [VPC network > External IP addresses](https://console.cloud.google.com/networking/addresses).

Click "Reserve Static Address" in the dialog
(or near the top of the page if you already have an address or two here).

![screenshot](/i/server/google-cloud-platform/vpc-network_external-ip-addresses_dialog.png)

- Give the IP address a name. Here, I'm using `marge`.
- Use the premium network service tier, but be aware that [two network tiers exist](https://cloud.google.com/network-tiers/) and this might matter depending on your reason for using a VPN.
- We'll use IPv4 and "regional" type.
- Select the region where you intend to run the WireGuard service.
- Click "Reserve".

![screenshot](/i/server/google-cloud-platform/vpc-network_reserve-a-static-address_form.png)

### Create a VM Instance

The VM instance is the virtual machine where our WireGuard service will run.

Navigate to [Compute Engine > VM instances](https://console.cloud.google.com/compute/instances).

Click "Create" in the dialog
(or click "Create Instance" near the top of the page if you already have an instance or two here).

![screenshot](/i/server/google-cloud-platform/compute-engine_vm-instances_dialog.png)

- Give the VM instance a name. Here, I'm using `marge`.
- Select the region where you intend to run the WireGuard service. The zone selection doesn't matter.
- The machine type drives the price you'll pay each month. Here, I'm using `f1-micro` because [the first 744 hours are free every month](https://cloud.google.com/free/docs/gcp-free-tier#always-free).
- Boot disk is how we select an operating system. In this example, I'll use "Debian GNU/Linux 10 (buster)".
- Assign the reserved static IP address.
  - Click "Management, security, disks, networking, sole tenancy".
  - Click "Networking".
  - Click the "default" network interface.
    ![screenshot](/i/server/google-cloud-platform/compute-engine_create-an-instance_default-network-interface_button.png)
  - Under "External IP" select the static IP address created in the previous section.
  - Click "Done" in the network interface section
- Click "Create" at the bottom of the page.

![screenshot](/i/server/google-cloud-platform/compute-engine_create-an-instance_form.png)

Watch for the green check mark indicating that the new VM instance has initialized.
Open a terminal on the new VM instance.
Under the "Connect" column, click "SSH", or use the `gcloud` command to.

![screenshot](/i/server/google-cloud-platform/compute-engine_vm-instances_ssh_dialog.png)

## Setup WireGuard

In this section, we'll use the shell on our VM instance to install and configure WireGuard.

Set the a password for the root user and switch to root.
```text
$ sudo passwd
New password:
Retype new password:
passwd: password updated successfully
$ su -
Password:
#
```

To install the most recent version of WireGuard,
we'll add the "unstable" Debian release,
and then [pin the unstable priority behind stable](https://wiki.debian.org/AptConfiguration).
This gives us access to unstable packages that are not available in stable,
without upgrading everything to unstable.

```text
# echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable.list
# printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable
# apt update
Get:1 http://security.debian.org/debian-security buster/updates InRelease [65.4 kB]
Hit:2 http://deb.debian.org/debian buster InRelease                             
Get:3 http://deb.debian.org/debian buster-updates InRelease [49.3 kB]           
...
Get:86 http://deb.debian.org/debian buster-backports/main Translation-en 2019-12-31-1430.36.pdiff [1206 B]
Get:86 http://deb.debian.org/debian buster-backports/main Translation-en 2019-12-31-1430.36.pdiff [1206 B]
Get:87 http://deb.debian.org/debian unstable/main amd64 Packages [8251 kB]
Get:88 http://deb.debian.org/debian unstable/main Translation-en [6195 kB]
Fetched 15.4 MB in 12s (1276 kB/s)
Reading package lists... Done
Building dependency tree
Reading state information... Done
4 packages can be upgraded. Run 'apt list --upgradable' to see them.
```

Install the [wireguard package](https://packages.debian.org/sid/wireguard).
This also adds manual pages for wireguard, so:
- `man wg` and `man wg-quick` work if you also `apt install man`
- the `wg` command gets bash completion if you also `apt install bash-completion`
```text
# apt install wireguard -y
Reading package lists... Done
 Building dependency tree       
 Reading state information... Done
 The following additional packages will be installed:
...
Setting up g++ (4:8.3.0-1) ...
update-alternatives: using /usr/bin/g++ to provide /usr/bin/c++ (c++) in auto mode
Setting up build-essential (12.6) ...
Setting up linux-headers-amd64 (4.19+105+deb10u1) ...
Processing triggers for man-db (2.8.5-2) ...
Processing triggers for libc-bin (2.28-10) ...
```

Also install linux-headers-VERSION,
as it seems the [Debian WireGuard packages don't declare that dependency yet](https://stackoverflow.com/questions/37570910/rtnetlink-answers-operation-not-supported).

```text
# apt install linux-headers-$(uname -r)
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following NEW packages will be installed:
...
Fetched 556 kB in 0s (7381 kB/s)                       
Selecting previously unselected package linux-headers-4.19.0-6-cloud-amd64.
(Reading database ... 60668 files and directories currently installed.)
Preparing to unpack .../linux-headers-4.19.0-6-cloud-amd64_4.19.67-2+deb10u2_amd64.deb ...
Unpacking linux-headers-4.19.0-6-cloud-amd64 (4.19.67-2+deb10u2) ...
Setting up linux-headers-4.19.0-6-cloud-amd64 (4.19.67-2+deb10u2) ...
```

Create the WireGuard network device as `wg0`
```text
# ip link add dev wg0 type wireguard
```

Give the device a private address.
This does not change the routing table.
```text
# ip address add dev wg0 192.168.255.1/24
```

Create private and public keys for the WireGuard service.
Protect the private key by applying a file mode creation mask.
```text
# (umask 077 && wg genkey > wg-private.key)
# wg pubkey < wg-private.key > wg-public.key
```

Print the private key, we'll need it in the next step.
```text
# cat wg-private.key
iLiXdq6j04TDL8+gMInGPylcIcvkKH+tH4wux2HTmFU=
```

Create the WireGuard service config file at `/etc/wireguard/wg0.conf`.
- `ListenPort` is the UDP service port, 51820 is a common choice for WireGuard.
- `PrivateKey` is the contents of the file `wg-private.key` that we just created.
```text
[Interface]
ListenPort = 51820
PrivateKey = iLiXdq6j04TDL8+gMInGPylcIcvkKH+tH4wux2HTmFU=
```

Finally, set the device state to `up`.
This does change the routing table
```text
# ip link set up dev wg0
```

Verify that:
- the route exists
- 192.168.255.xxx will route through `wg0`
- everything else will *not* route through `wg0`
```text
# ip route 
default via 10.138.0.1 dev ens4 
10.138.0.1 dev ens4 scope link 
192.168.255.0/24 dev wg0 proto kernel scope link src 192.168.255.1 
# ip route get 192.168.255.2
192.168.255.2 dev wg0 src 192.168.255.1 uid 0 
    cache 
# ip route get 1.1.1.1
1.1.1.1 via 10.138.0.1 dev ens4 src 10.138.0.9 uid 0 
    cache 
```
