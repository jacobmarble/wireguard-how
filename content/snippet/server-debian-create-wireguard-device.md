Create the WireGuard service config file at `/etc/wireguard/wg0.conf`.
(Use a command like `sudo nano /etc/wireguard/wg0.conf`.)
```text
# define the WireGuard service
[Interface]

# contents of file wg-private.key that was recently created
PrivateKey = server-private

# UDP service port; server-port is a common choice for WireGuard
ListenPort = server-port
```

Create the WireGuard network device at `/etc/network/interfaces.d/wg0`.
(Use a command like `sudo nano /etc/network/interfaces.d/wg0`.)
```text
# indicate that wg0 should be created when the system boots, and on ifup -a
auto wg0

# describe wg0 as an IPv4 interface with static address
iface wg0 inet static

        # static IP address 
        address server-vpn-address/vpn-size

        # before ifup, create the device with this ip link command
        pre-up ip link add $IFACE type wireguard

        # before ifup, set the WireGuard config from earlier
        pre-up wg setconf $IFACE /etc/wireguard/$IFACE.conf

        # after ifdown, destroy the wg0 interface
        post-down ip link del $IFACE
```

Start WireGuard.
```text
$ sudo ifup wg0
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
