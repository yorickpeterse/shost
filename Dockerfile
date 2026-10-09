FROM ghcr.io/inko-lang/inko:main AS builder
ADD . /work
WORKDIR /work
RUN microdnf install --assumeyes jemalloc-devel
RUN inko build --release --linker-arg '-ljemalloc'

FROM registry.fedoraproject.org/fedora-minimal:44
RUN microdnf install --assumeyes jemalloc-devel
COPY --from=builder ["/work/build/release/shost", "/usr/bin/shost"]
ENV MALLOC_CONF "abort_conf:true,background_thread:true"
CMD ["/usr/bin/shost"]
