# Build two images with Automated Builds using Docker Hub hooks.
#   See https://github.com/shellspec/shellspec/tree/master/hooks

# ======================================================================
# source code
# ======================================================================
FROM scratch as source
COPY shellspec LICENSE /opt/shellspec/
COPY lib /opt/shellspec/lib
COPY libexec /opt/shellspec/libexec

# ======================================================================
# Kcov builder (requires alpine:edge not alpine:3.11)
# ======================================================================
FROM alpine:edge as builder
ENV KCOV=v38 CXXFLAGS=-D__ptrace_request=int
WORKDIR /usr/local/src
RUN apk add --no-cache build-base cmake ninja python3 \
      binutils-dev curl-dev elfutils-dev
RUN wget -q https://github.com/SimonKagstrom/kcov/archive/$KCOV.tar.gz
RUN tar xzf $KCOV.tar.gz -C ./ --strip-components 1
RUN mkdir build && cd build \
 && cmake -G Ninja .. && cmake --build . --target install

# ======================================================================
# Kcov image
#   TAG: shellspec:kcov, shellspec:[VERSION]-kcov
# ======================================================================
FROM alpine:edge as kcov
# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="shellspec:kcov" \
      org.label-schema.description="shellspec (alpine based with kcov)" \
      org.label-schema.url="https://shellspec.info/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/shellspec/shellspec" \
      org.label-schema.vendor="shellspec" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"
ENV PATH /opt/shellspec/:$PATH
WORKDIR /src
ENTRYPOINT [ "shellspec" ]
RUN apk add --no-cache bash binutils-dev curl-dev elfutils-libelf
COPY --from=builder /usr/local/bin/kcov* /usr/local/bin/
COPY --from=builder /usr/local/share/doc/kcov /usr/local/share/doc/kcov
COPY --from=source /opt/shellspec /opt/shellspec

# ======================================================================
# Standard image (default)
#   TAG: shellspec:latest, shellspec:[VERSION]
# ======================================================================
FROM alpine:3.11 as standard
# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="shellspec" \
      org.label-schema.description="shellspec (alpine based)" \
      org.label-schema.url="https://shellspec.info/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/shellspec/shellspec" \
      org.label-schema.vendor="shellspec" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"
ENV PATH /opt/shellspec/:$PATH
WORKDIR /src
ENTRYPOINT [ "shellspec" ]
COPY --from=source /opt/shellspec /opt/shellspec
