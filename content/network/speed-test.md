---
title: "Speed Test"
type: "docs"
---

# Network: Speed Test

In this tutorial, we test TCP WireGuard tunnel performance with
[the `iperf3` tool](https://manpages.debian.org/buster/iperf3/iperf3.1.en.html).

`iperf3` measures network throughput (maximum bits per second).

## Install iperf3

Install an `iperf3` implementation on both the WireGuard server and client.
- Linux Debian Buster: `sudo apt install iperf3 --assume-yes`
- macOS: `brew install iperf3`
- Windows: TODO
- iOS: [install the app](https://apps.apple.com/us/app/iperf-3-wifi-speed-test/id1462260546)
- Android: [install the app]()

## Test

### Run iperf3 Server

The `iperf3` server listens for incoming `iperf3` client requests.

Run `iperf3` in server mode on the WireGuard server.
This is a blocking process; use ctrl-C to terminate the server.
```text
$ iperf3 --server
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
```

### Test from macOS or Linux Client

With the WireGuard tunnel active, test the network speed.
In this example:
- `--client {{< lookup server-vpn-address >}}` test against the WireGuard server via the tunnel
- `--omit 1` the first sample is omitted from the summary
- `--parallel 2` two network streams are run concurrently
- `--time 5` test is run for 5 seconds
- `--reverse` we're testing download (leave this out to test upload)
- resulting average download speed is about 30 megabits per second

```text
$ iperf3 --client {{< lookup server-vpn-address >}} --omit 1 --parallel 2 --time 10 --reverse
Connecting to host {{< lookup server-vpn-address >}}, port 5201
Reverse mode, remote host {{< lookup server-vpn-address >}} is sending
[  5] local {{< lookup client-vpn-address >}} port 55507 connected to {{< lookup server-vpn-address >}} port 5201
[  7] local {{< lookup client-vpn-address >}} port 55508 connected to {{< lookup server-vpn-address >}} port 5201
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.00   sec   383 KBytes  3.14 Mbits/sec                  (omitted)
[  7]   0.00-1.00   sec   394 KBytes  3.23 Mbits/sec                  (omitted)
[SUM]   0.00-1.00   sec   778 KBytes  6.37 Mbits/sec                  (omitted)
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   0.00-1.00   sec   898 KBytes  7.35 Mbits/sec
[  7]   0.00-1.00   sec  1002 KBytes  8.21 Mbits/sec
[SUM]   0.00-1.00   sec  1.86 MBytes  15.6 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
...
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   9.00-10.00  sec   919 KBytes  7.52 Mbits/sec
[  7]   9.00-10.00  sec   882 KBytes  7.22 Mbits/sec
[SUM]   9.00-10.00  sec  1.76 MBytes  14.7 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.04  sec  18.6 MBytes  15.5 Mbits/sec    8             sender
[  5]   0.00-10.00  sec  18.2 MBytes  15.3 Mbits/sec                  receiver
[  7]   0.00-10.04  sec  17.6 MBytes  14.7 Mbits/sec    6             sender
[  7]   0.00-10.00  sec  17.0 MBytes  14.3 Mbits/sec                  receiver
[SUM]   0.00-10.04  sec  36.2 MBytes  30.2 Mbits/sec   14             sender
[SUM]   0.00-10.00  sec  35.2 MBytes  29.6 Mbits/sec                  receiver

iperf Done.
```

## Keep the iperf3 Service Running in the Background

It is convenient to keep `iperf3` always running on the WireGuard server.

Create a [systemd unit configuration file](https://manpages.debian.org/buster/systemd/systemd.service.5.en.html)
at `/etc/systemd/system/iperf3.service`.
(Use a command like `sudo nano /etc/systemd/system/iperf3.service`.)
```text
[Unit]
Description=iperf3

[Service]
ExecStart=/usr/bin/iperf3 --server

[Install]
WantedBy=multi-user.target
```

Start the systemd unit and "enable" it so that it starts on boot.
```text
$ sudo systemctl start iperf3
$ sudo systemctl enable iperf3
Created symlink /etc/systemd/system/multi-user.target.wants/iperf3.service → /etc/systemd/system/iperf3.service.
```

With `iperf3` running as a systemd service, the STDOUT logs are written to log files instead of to the console.
To view the logs, use [journalctl](https://manpages.debian.org/buster/systemd/journalctl.1.en.html).
```text
$ sudo journalctl --follow --identifier iperf3 --output cat
```
