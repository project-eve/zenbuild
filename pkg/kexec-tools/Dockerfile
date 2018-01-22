FROM alpine:edge as build

RUN mkdir -p /out/etc/apk && cp -r /etc/apk/* /out/etc/apk/

RUN apk add --no-cache --initdb -p /out --repository http://nl.alpinelinux.org/alpine/edge/testing\
    kexec-tools

# Pattern copied from pkg/wlan
# I don't understand this dance. ask rvs@
#RUN mv /out/usr/sbin/kdump /
#RUN mv /out/usr/sbin/kexec /
#RUN mv /out/usr/lib/libz.so.* /
#RUN mv /out/usr/lib/liblzma.so.* /

FROM scratch
ENTRYPOINT []
WORKDIR /
COPY --from=build /out/usr/sbin/kexec /usr/sbin/
COPY --from=build /out/usr/sbin/kdump /usr/sbin/
#COPY --from=build /out/usr/lib/libz.so.* /usr/lib/
COPY --from=build /out/usr/lib/liblzma.so.* /usr/lib/
