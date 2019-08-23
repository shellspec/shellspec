FROM alpine
RUN apk add --no-cache gcc libc-dev
COPY ./src/ ./src
RUN gcc --static ./src/mksock.c -o /usr/local/bin/mksock \
 && gcc --static ./src/invokesh.c -o /usr/local/bin/invokesh \
 && gcc --static ./src/fake-sudo.c -o /usr/local/bin/sudo \
 && cp ./src/fake-nc.sh /usr/local/bin/nc \
 && chmod ug+s /usr/local/bin/sudo
