+++
title = "cargo lock-fetch"
weight = 10
date = 2026-07-06

[extra]
local_image = "cargo-lock-fetch/cover.png"
comment = true

[[extra.card_links]]
url = "https://github.com/komar007/cargo-lock-fetch"
icon = "github"
text = "GitHub"

[[extra.card_links]]
url = "https://hub.docker.com/r/komar007/cargo-lock-fetch"
icon = "dockerhub"
text = "Docker Hub"

[[extra.card_links]]
url = "https://crates.io/crates/cargo-lock-fetch"
text = "crates.io"
+++
[`cargo-lock-fetch`](https://crates.io/crates/cargo-lock-fetch) is a cargo plugin I wrote to solve a
build issue at <https://www.adbglobal.com/> which would otherwise require manually specifying
multiple source files from a rust microservice to be copied into a docker layer for dependency
prefetch.

Prefetching dependencies to a docker layer is crucial in reducing build times in docker-based
environments. It allows the service to be rebuilt without redownloading all required crates unless
Cargo.lock changes without providing cargo with a [cache
mount](https://docs.docker.com/build/cache/optimize/#use-cache-mounts), which may not be available.

This can normally be done with `cargo fetch`. However, `cargo fetch` requires a large part of the
project structure, including, but not limited to, all the Cargo.toml files, which becomes a burden
when there is more than one. This makes one end up either "prefetching" after a `COPY . .` which
defeats the purpose, as potentially the same set of crates is downloaded any time *any* project file
changes, or specifying every required file and editing the list on project structure changes.

`cargo-lock-fetch` solves this very issue by requiring only the Cargo.lock file to prefetch all
project's dependencies making prefetching dependencies to a docker layer as simple as:

``` dockerfile
COPY --from=komar007/cargo-lock-fetch \
    /cargo-lock-fetch /usr/local/cargo/bin

COPY Cargo.lock .
RUN cargo lock-fetch
```

allowing for later:

``` dockerfile
COPY . .
RUN cargo build --frozen
```

As a bonus, `cargo-lock-fetch` allows for dependencies vendoring, just like `cargo vendor`, but
requiring access only to Cargo.lock.
