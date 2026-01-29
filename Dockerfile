FROM ghcr.io/inko-lang/inko:main AS builder
ADD . /work
WORKDIR /work
RUN make

FROM ghcr.io/inko-lang/inko:main
COPY --from=builder ["/work/build/release/shost", "/usr/bin/shost"]
CMD ["/usr/bin/shost"]
