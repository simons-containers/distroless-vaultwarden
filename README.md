# Distroless Vaultwarden container

Bare-bones distroless [Vaultwarden](https://github.com/dani-garcia/vaultwarden) container image.

## Running

Mount data directory at `/var/lib/vaultwarden`.

Example:

```bash
docker run -it --rm -v ./data:/var/lib/vaultwarden \
  -e DATABASE_URL=postgresql://user:pass@host/db \
  -p 80:80 \
  ghcr.io/simons-containers/distroless-vaultwarden:latest
```

## Building

| Arg | Description |
|---|---|
| `VAULTWARDEN_VERSION` | Version of Vaultwarden to build |
| `BW_WEB_VERSION` | Version of the Bitwarden web vault UI |
| `GCC_VERSION` | GCC version to use |
| `ZLIB_VERSION` | zlib version to use |
| `OPENSSL_VERSION` | OpenSSL version to use |
| `BROTLI_VERSION` | brotli version to use |
| `ZSTD_VERSION` | zstd version to use |
| `LIBPQ_VERSION` | PostgreSQL client library version |

Build container using build-args from versions.yaml:

```bash
docker build -t \
  distroless-vaultwarden:$(yq -r .vaultwarden versions.yaml) \
  $(yq -r 'to_entries | .[] | "--build-arg \(.key | ascii_upcase)_VERSION=\(.value)"' versions.yaml) -f Containerfile .
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
