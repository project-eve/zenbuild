FROM unikernel/mirage:latest AS mirage
#ADD --chown=opam:opam unikernels/mirage/hello /vms/mirage-hello
# RUN nohup bash -lc "cd /vms/mirage-hello/ ; opam update ; mirage configure -t xen ; make depend ; make"

ADD unikernels/mirage/hello /vms/mirage-hello
USER root
RUN chown opam:opam /vms/mirage-hello

FROM scratch
# COPY --from=mirage /vms/mirage-hello/hello* /vms/mirage-hello/
ADD unikernels/mirage/README /vms/mirage-hello/
ADD vms/green_grass /vms/green_grass 
