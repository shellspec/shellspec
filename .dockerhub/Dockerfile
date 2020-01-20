# Build two images with Automated Build using Docker Hub hooks.
#   See https://github.com/shellspec/shellspec/tree/master/hooks
FROM alpine:3.11 as release
ENV PATH /opt/shellspec/:$PATH
WORKDIR /src
COPY shellspec LICENSE /opt/shellspec/
COPY lib /opt/shellspec/lib
COPY libexec /opt/shellspec/libexec
ENTRYPOINT [ "shellspec" ]

# ======================================================================
# Kcov image
#   TAG: shellspec:kcov, shellspec:[VERSION]-kcov
# ======================================================================
FROM alpine:edge as builder
WORKDIR /usr/local/src
RUN apk add --no-cache build-base cmake ninja python3 \
      binutils-dev curl-dev elfutils-dev
ADD https://github.com/SimonKagstrom/kcov/archive/v38.tar.gz kcov.tar.gz
RUN tar xzf kcov.tar.gz -C ./ --strip-components 1 \
 && mkdir build && cd build \
 && export CXXFLAGS="-D__ptrace_request=int" \
 && cmake -G Ninja .. && cmake --build . --target install

FROM release as kcov
# Building kcov requires alpine:edge, so upgrade.
RUN sed -i 's/v3.11/edge/g' /etc/apk/repositories && apk upgrade --available
RUN apk add --no-cache bash binutils-dev curl-dev elfutils-libelf
COPY --from=builder /usr/local/bin/kcov* /usr/local/bin/
COPY --from=builder /usr/local/share/doc/kcov /usr/local/share/doc/kcov

# ======================================================================
# Standard image
#   TAG: shellspec:latest, shellspec:[VERSION]
# ======================================================================
FROM release as standard
