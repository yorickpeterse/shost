# shost

An HTTP server written in [Inko](https://inko-lang.org/), for self-hosting
static websites such as [my personal website](https://yorickpeterse.com/) or the
[Inko manual](https://docs.inko-lang.org/manual/main/).

## Why?

There are plenty of capable HTTP servers such as [nginx](https://nginx.org/),
[Caddy](https://caddyserver.com/) and more. I wrote shost for a few reasons:

- As a showcase for Inko
- To further test Inko's capabilities
- To have full control over how the server works
- Because I can

## Features

- Serves static files from a set of directories, complete with caching related
  headers
- Dynamic gzip compression if requested by the client
- Reasonably fast (with [a lot of room for
  improvement](https://github.com/inko-lang/inko/issues/944)): expect somewhere
  between 50 000 and 100 000 requests/second depending on the underlying
  hardware
- Some simple heuristics for blocking bots that pretend to be browsers or try to
  scan for exploits
- No garbage collector ruining the fun by introducing non-deterministic behavior
- Supports reloading of configuration files using the `SIGHUP` signal or using a
  Unix socket

## Anti-features

- Proxying requests to backend servers
- Complex rules for blocking clients based on user-agent values, IP addresses,
  etc
- Basically whatever isn't currently present or something I have no need for
  myself

## Requirements

- Inko `main`

## Building

To build from source:

```bash
inko build --release
```

For packaging purposes there's also a `Makefile` providing tasks such as `make`
and `make install`.

There's also a container you can use:

```bash
podman run \
    --rm \
    --volume path/to/sites:/var/lib/shost \
    --publish 8888:80 \
    ghcr.io/yorickpeterse/shost:latest
```

This serves the websites in `path/to/sites` on port 8888 on the host.

If you're using a system with SELinux you'll likely need to add the `:z` or `:Z`
option to the `--volume` value, depending on how many containers need access to
the sites directory.

## Getting started

To serve one or more websites, place them in a directory named after the host in
the sites directory (`/var/lib/shost` by default). For example:

```
/var/lib/shost/
  foo.com/
    index.html
  bar.org/
    index.html
```

If a page requested isn't found a default empty 404 response is produced. If the
file `404.html` exists in the root of a website it's served instead, for
example:

```
/var/lib/shost/
  foo.com/
    index.html
    404.html
  bar.org/
    index.html
```

If the `--tls` option is specified, shost will use TLS. In this case it expects
a certificate and private key pair for each website in a similar structure. The
certificate must be called `cert.pem` and the private key `key.pem`. For
example, when using `shost --tls /etc/ssl/shost` the following structure is
expected:

```
/etc/ssl/shost/
  foo.com/
    cert.pem
    key.pem
  bar.org/
    cert.pem
    key.pem
```

If a certificate and private key pair is missing, connections to the website
will be dropped. It's not possible to serve websites using both HTTP and HTTPS
at the same time.

Sending `SIGHUP` to the shost process causes it to reload the list of websites
served and the TLS configuration. Sending signals is only necessary when adding
or removing websites, not when changing their contents. The configuration can
also be reloaded using a Unix socket. This allows cross-container reloads by
mounting the socket into these containers. To do so, run `shost` with the
`--control` option, for example:

```bash
shost --control /var/run/shost.sock
```

Then send the `reload` command like so:

```bash
echo -n reload | nc -U /var/run/shost.sock
```

## License

All source code in this repository is licensed under the Mozilla Public License
version 2.0, unless stated otherwise. A copy of this license can be found in the
file "LICENSE".
