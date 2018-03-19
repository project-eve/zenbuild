# The final image is called 'toolchain'
# It is composed of toolchain-base + other magic.
FROM linuxkit/alpine:d307c8a386fa3f32cddda9409b9687e191cdd6f1 AS toolchain-base

RUN apk update

RUN apk add \
    argp-standalone \
    attr-dev \
    autoconf \
    automake \
    bash \
    bc \
    binutils-dev \
    bison \
    build-base \
    curl \
    diffutils \
    file \
    flex \
    git \
    gmp-dev \
    gnupg \
    installkernel \
    kmod \
    libelf-dev \
    libressl-dev \
    libtirpc-dev \
    libtool \
    linux-headers \
    mpc1-dev \
    mpfr-dev \
    ncurses-dev \
    python2 \
    sed \
    squashfs-tools \
    tar \
    util-linux-dev \
    xz \
    xz-dev \
    zlib-dev

FROM scratch
ENTRYPOINT []
CMD []
WORKDIR /
COPY --from=toolchain-base /* /
