FROM archlinux:base-devel-20260308.0.497099 AS builder

ARG GCC_VERSION
ARG ZLIB_VERSION
ARG OPENSSL_VERSION
ARG BROTLI_VERSION
ARG ZSTD_VERSION
ARG LIBPQ_VERSION
ARG VAULTWARDEN_VERSION
ARG BW_WEB_VERSION

ARG GCC_SOURCE=https://mirrors.ocf.berkeley.edu/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz
ARG ZLIB_SOURCE=https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz
ARG OPENSSL_SOURCE=https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz
ARG BROTLI_SOURCE=https://github.com/google/brotli/archive/refs/tags/v${BROTLI_VERSION}.tar.gz
ARG ZSTD_SOURCE=https://github.com/facebook/zstd/releases/download/v${ZSTD_VERSION}/zstd-${ZSTD_VERSION}.tar.gz
ARG LIBPQ_SOURCE=https://ftp.postgresql.org/pub/source/v${LIBPQ_VERSION}/postgresql-${LIBPQ_VERSION}.tar.gz
ARG VAULTWARDEN_SOURCE=https://github.com/dani-garcia/vaultwarden/archive/refs/tags/${VAULTWARDEN_VERSION}.tar.gz
ARG BW_WEB_RELEASE=https://github.com/dani-garcia/bw_web_builds/releases/download/v${BW_WEB_VERSION}/bw_web_v${BW_WEB_VERSION}.tar.gz

RUN pacman -Sy --noconfirm cmake cargo >/dev/null

WORKDIR /build/gcc
RUN curl --silent --show-error --location --output gcc.tar.gz \
    "${GCC_SOURCE}" \
    && tar xf gcc.tar.gz --strip-components=1 \
    && ./contrib/download_prerequisites \
    && mkdir build && cd build \
    && ../configure \
        --prefix=/usr \
        --libdir=/usr/lib \
        --libexecdir=/usr/lib \
        --disable-multilib \
        --disable-bootstrap \
        --enable-languages=c \
    && make -j$(nproc) all-target-libgcc \
    && mkdir -p /base/usr/lib && ln -s lib /base/usr/lib64 \
    && make install-target-libgcc DESTDIR=/base

WORKDIR /build/zlib
RUN curl --silent --show-error --location --output zlib.tar.gz \
    "${ZLIB_SOURCE}" \
    && tar xf zlib.tar.gz --strip-components=1 \
    && ./configure --prefix=/usr \
    && make -s -j$(nproc) \
    && make install \
    && make install DESTDIR=/base

WORKDIR /build/openssl
RUN curl --silent --show-error --location --output openssl.tar.gz \
    "${OPENSSL_SOURCE}" \
    && tar xf openssl.tar.gz --strip-components=1 \
    && ./Configure linux-x86_64 --prefix=/usr --libdir=/usr/lib no-tests no-docs \
    && make -s -j$(nproc) \
    && make install \
    && make install DESTDIR=/base

WORKDIR /build/brotli
RUN curl --silent --show-error --location --output brotli.tar.gz \
    "${BROTLI_SOURCE}" \
    && tar xf brotli.tar.gz --strip-components=1 \
    && cmake -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_SKIP_INSTALL_RPATH=ON \
    && cmake --build build -j$(nproc) \
    && cmake --install build \
    && DESTDIR=/base cmake --install build

WORKDIR /build/zstd
RUN curl --silent --show-error --location --output zstd.tar.gz \
    "${ZSTD_SOURCE}" \
    && tar xf zstd.tar.gz --strip-components=1 \
    && make -s -j$(nproc) \
    && make install PREFIX=/usr \
    && make install PREFIX=/usr DESTDIR=/base

WORKDIR /build/libpq
RUN curl --silent --show-error --location --output postgresql.tar.gz \
    "${LIBPQ_SOURCE}" \
    && tar xf postgresql.tar.gz --strip-components=1 \
    && ./configure --prefix=/usr --disable-rpath \
        --with-openssl --without-gssapi --without-ldap \
        --enable-thread-safety \
    && make -s -j$(nproc) -C src/interfaces/libpq \
    && make install -C src/interfaces/libpq \
    && make install -C src/interfaces/libpq DESTDIR=/base \
    && make -s -j$(nproc) -C src/bin/pg_config \
    && make install -C src/bin/pg_config \
    && make install -C src/include

WORKDIR /build/vaultwarden
RUN curl --silent --show-error --location --output vaultwarden.tar.gz \
    "${VAULTWARDEN_SOURCE}" \
    && tar xf vaultwarden.tar.gz --strip-components=1 \
    && cargo build --quiet --release --locked --no-default-features \
        --features postgresql \
    && cp target/release/vaultwarden /base/usr/bin/

WORKDIR /base/usr/share/vaultwarden/web_vault
RUN curl --silent --show-error --location --output bw_web.tar.gz \
    "${BW_WEB_RELEASE}" \
    && tar xf bw_web.tar.gz --strip-components=1 \
    && rm bw_web.tar.gz \
    && find /base/usr/share/vaultwarden/web_vault \
      -type f -name '*.map' -delete


RUN rm -fr /base/usr/lib/{pkgconfig,cmake,gcc} /base/usr/lib/*.a /base/usr/lib/*.la \
    /base/usr/share/{doc,info,man,locale,postgresql} /base/usr/share/gcc-* \
    /base/usr/include

FROM ghcr.io/simons-containers/distroless-glibc:2.43
ARG GCC_VERSION
ARG ZLIB_VERSION
ARG OPENSSL_VERSION
ARG BROTLI_VERSION
ARG ZSTD_VERSION
ARG LIBPQ_VERSION
ARG VAULTWARDEN_VERSION
ARG BW_WEB_VERSION

COPY --from=builder /base/usr/lib/ /usr/lib/
COPY --from=builder /base/usr/bin/vaultwarden /usr/bin/vaultwarden
COPY --from=builder /base/usr/share/ /usr/share/

WORKDIR /var/lib/vaultwarden
ENV ROCKET_ADDRESS=0.0.0.0
ENV WEB_VAULT_FOLDER=/usr/share/vaultwarden/web_vault
ENV DATA_FOLDER=/var/lib/vaultwarden/data
ENV ATTACHMENTS_FOLDER=/var/lib/vaultwarden/attachments
ENV ICON_CACHE_FOLDER=/var/lib/vaultwarden/icon_cache

ENTRYPOINT ["/usr/bin/vaultwarden"]

LABEL org.opencontainers.image.title="distroless vaultwarden"
LABEL org.opencontainers.image.description="distroless vaultwarden"
LABEL org.opencontainers.image.version="${VAULTWARDEN_VERSION}"
LABEL org.opencontainers.image.source="https://github.com/simons-containers/distroless-vaultwarden"
LABEL org.opencontainers.image.volumes.config="/var/lib/vaultwarden"
LABEL org.opencontainers.image.base.libs="gcc@${GCC_VERSION},zlib@${ZLIB_VERSION},openssl@${OPENSSL_VERSION},brotli@${BROTLI_VERSION},zstd@${ZSTD_VERSION},libpq@${LIBPQ_VERSION},bw_web@${BW_WEB_VERSION}"
