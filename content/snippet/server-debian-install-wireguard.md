To install the most recent version of WireGuard, we'll need packages from the Debian unstable release.
Add the Debian unstable release, and [pin the Debian unstable priority behind Raspbian stable](https://wiki.debian.org/AptConfiguration).
This allows us to install packages that are not available in Debian stable,
while keeping the "stable" versions of everything else.

```text
$ sudo sh -c "echo 'deb http://deb.debian.org/debian/ unstable main' >> /etc/apt/sources.list.d/unstable.list"
$ sudo sh -c "printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' >> /etc/apt/preferences.d/limit-unstable"
```

Update package information from both stable and unstable package repositories.
```text
$ sudo apt update
Get:1 http://deb.debian.org/debian unstable InRelease [142 kB]
Hit:2 http://archive.raspberrypi.org/debian buster InRelease
Hit:3 http://raspbian.raspberrypi.org/raspbian buster InRelease
Get:4 http://deb.debian.org/debian unstable/main armhf Packages [7,977 kB]
Get:5 http://deb.debian.org/debian unstable/main Translation-en [6,192 kB]
Fetched 14.3 MB in 22s (655 kB/s)
Reading package lists... Done
Building dependency tree
Reading state information... Done
All packages are up to date.
```

Install the WireGuard packages.
After this step, `man wg` and `man wg-quick` will work and the `wg` command gets bash completion.
```text
$ sudo apt install wireguard --assume-yes
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following additional packages will be installed:
  dkms raspberrypi-kernel-headers wireguard-dkms wireguard-tools
Suggested packages:
  python3-apport menu
The following NEW packages will be installed:
  dkms raspberrypi-kernel-headers wireguard wireguard-dkms wireguard-tools
0 upgraded, 5 newly installed, 0 to remove and 0 not upgraded.
...
DKMS: install completed.
Module build for kernel 4.19.75-v8+ was skipped since the
kernel headers for this kernel does not seem to be installed.
Setting up wireguard-tools (0.0.20191219-1) ...
Setting up wireguard (0.0.20191219-1) ...
Processing triggers for man-db (2.8.5-2) ...
```
