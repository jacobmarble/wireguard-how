In every client/server relationship, each peer has it's own private and public keys.
Create private and public keys for the WireGuard service.
Protect the private key with a file mode creation mask.
```text
$ (umask 077 && wg genkey > wg-private.key)
$ wg pubkey < wg-private.key > wg-public.key
```

Print the private key, we'll need it soon.
```text
$ cat wg-private.key
server-private
```
