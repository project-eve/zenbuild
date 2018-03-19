#
FROM linuxkit/alpine:d307c8a386fa3f32cddda9409b9687e191cdd6f1 AS build
RUN apk add \
    attr-dev \
    autoconf \
    automake \
    build-base \
    file \
    git \
    libtirpc-dev \
    libtool \
    mpc1-dev \
    mpfr-dev \
    util-linux-dev \
    linux-headers \
    bison \
    flex \
    zlib-dev \
    curl

# Version 5.1
ENV WATCHDOGD_COMMIT a85ea52881755be4a368478b899d5107d5e09ccb
ENV WATCHDOGD_SRC_ZIP watchdog-code-${WATCHDOGD_COMMIT}.zip
ENV WATCHDOGD_URL https://sourceforge.net/code-snapshots/git/w/wa/watchdog/code.git/${WATCHDOGD_SRC_ZIP}

RUN \
    [ -f ${WATCHDOGD_SRC_ZIP} ] || curl -fsSLO ${WATCHDOGD_URL} && \
      gzip -d ${WATCHDOGD_SRC_ZIP}
      

FROM scratch
ENTRYPOINT []
CMD []
WORKDIR /
#COPY --from=build /out/ /
#COPY files/ /
