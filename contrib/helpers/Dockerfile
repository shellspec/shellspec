FROM alpine
RUN apk add --no-cache gcc libc-dev
ADD https://github.com/ncopa/su-exec/archive/v0.2.tar.gz /
COPY ./src/ ./src
RUN gcc --static ./src/mksock.c -o /usr/local/bin/mksock \
 && gcc --static ./src/invokesh.c -o /usr/local/bin/invokesh \
 && cp ./src/fake-nc.sh /usr/local/bin/nc \
 && tar xzf v0.2.tar.gz \
 && gcc -static /su-exec-0.2/su-exec.c -o /usr/local/bin/su-exec \
 && chmod ug+s /usr/local/bin/su-exec
