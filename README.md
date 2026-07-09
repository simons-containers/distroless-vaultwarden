[![Current Version](https://raw.githubusercontent.com/simons-containers/distroless-vaultwarden/badges/.badges/main/release.svg)](https://github.com/simons-containers/distroless-vaultwarden/pkgs/container/distroless-vaultwarden) [![Tags](https://raw.githubusercontent.com/simons-containers/distroless-vaultwarden/badges/.badges/main/tags.svg)](https://github.com/simons-containers/distroless-vaultwarden/pkgs/container/distroless-vaultwarden) <br> ![Current Size](https://raw.githubusercontent.com/simons-containers/distroless-vaultwarden/badges/.badges/main/size.svg) ![Wasted Size](https://raw.githubusercontent.com/simons-containers/distroless-vaultwarden/badges/.badges/main/wasted.svg) ![Efficiency](https://raw.githubusercontent.com/simons-containers/distroless-vaultwarden/badges/.badges/main/efficiency.svg) <br> ![Critical](https://raw.githubusercontent.com/simons-containers/distroless-vaultwarden/badges/.badges/main/critical.svg) ![High](https://raw.githubusercontent.com/simons-containers/distroless-vaultwarden/badges/.badges/main/high.svg) ![Medium](https://raw.githubusercontent.com/simons-containers/distroless-vaultwarden/badges/.badges/main/medium.svg) ![Low](https://raw.githubusercontent.com/simons-containers/distroless-vaultwarden/badges/.badges/main/low.svg) <br> [![Publish Workflow](https://img.shields.io/github/actions/workflow/status/simons-containers/distroless-vaultwarden/deploy.yaml?label=Publish%20Workflow&logo=github)](https://github.com/simons-containers/distroless-vaultwarden/actions/workflows/deploy.yaml) [![Update Workflow](https://img.shields.io/github/actions/workflow/status/simons-containers/distroless-vaultwarden/update-versions.yaml?label=Update%20Workflow&logo=github)](https://github.com/simons-containers/distroless-vaultwarden/actions/workflows/update-versions.yaml)

# Distroless Vaultwarden container

Bare-bones distroless [Vaultwarden](https://github.com/dani-garcia/vaultwarden) container image.

## Running

Mount data directory at `/var/lib/vaultwarden`.

Example:

```bash
docker run -it --rm -v ./data:/var/lib/vaultwarden \
  -e DATABASE_URL=postgresql://user:pass@host/db \
  -e ROCKET_PORT=8080 -p 8080:8080 \
  ghcr.io/simons-containers/distroless-vaultwarden:latest
```

## License

Repository contents (e.g., `Containerfile`, build scripts, and configuration) are licensed under the **MIT License**.

Software included in built container images (such as **Vaultwarden**, **glibc**, **OpenSSL**, and other dependencies) are provided under their respective upstream licenses and are not covered by the MIT license for this repository.

## Acknowledgements

This project depends on several upstream components that provide essential runtime libraries, toolchains, and platform capabilities:

- **Vaultwarden** – An unofficial Bitwarden-compatible server implementation written in Rust, offering a lightweight self-hosted alternative to the official Bitwarden server.  
  https://github.com/dani-garcia/vaultwarden

- **bw_web_builds** – Pre-built releases of the Bitwarden web vault frontend, patched for compatibility with Vaultwarden.  
  https://github.com/dani-garcia/bw_web_builds

- **OpenSSL** – A comprehensive cryptographic library offering TLS, hashing, and encryption primitives required for secure communication and data integrity.  
  https://www.openssl.org

- **PostgreSQL** – The World's Most Advanced Open Source Relational Database.  
  https://www.postgresql.org

- **glibc** – The GNU C Library, providing the standard C runtime and POSIX interfaces used by most Linux systems.  
  https://www.gnu.org/software/libc/

- **GCC** – The GNU Compiler Collection, a full-featured compilation system supporting multiple languages and target architectures.  
  https://gcc.gnu.org

- **zlib** – A foundational compression library implementing the DEFLATE algorithm, widely used across system software for efficient data compression and decompression.  
  https://zlib.net

- **brotli** – A generic-purpose lossless compression algorithm developed by Google, providing fast compression with a high compression ratio.  
  https://github.com/google/brotli

- **zstd** – A fast lossless compression algorithm developed by Meta, offering real-time compression at high ratios across a wide range of use cases.  
  https://github.com/facebook/zstd
