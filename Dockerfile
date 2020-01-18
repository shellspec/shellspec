ARG BASE=standard

FROM alpine:3.11 as standard-base


FROM alpine:edge as builder
RUN apk add --no-cache build-base cmake ninja python3 \
      binutils-dev curl-dev elfutils-dev
WORKDIR /root
ADD https://github.com/SimonKagstrom/kcov/archive/v38.tar.gz kcov.tar.gz
RUN tar xzf kcov.tar.gz -C ./ --strip-components 1 \
 && mkdir build && cd build \
 && CXXFLAGS="-D__ptrace_request=int" cmake -G Ninja .. \
 && cmake --build . && cmake --build . --target install

FROM alpine:edge as kcov-base
RUN apk add --no-cache bash binutils-dev curl-dev elfutils-libelf
COPY --from=builder /usr/local/bin/kcov* /usr/local/bin/
COPY --from=builder /usr/local/share/doc/kcov /usr/local/share/doc/kcov


FROM ${BASE}-base
ENV PATH /opt/shellspec/:$PATH
WORKDIR /src
COPY shellspec /opt/shellspec/shellspec
COPY lib /opt/shellspec/lib
COPY libexec /opt/shellspec/libexec
ENTRYPOINT [ "shellspec" ]
