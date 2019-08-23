FROM alpine
RUN apk add --no-cache gcc libc-dev
COPY ./src/ ./src
RUN gcc --static -o /usr/local/bin/mksock ./src/mksock.c \
 && gcc --static -o /usr/local/bin/invokesh ./src/invokesh.c \
 && cp ./src/fake-nc.sh ./src/fake-sudo.sh /usr/local/bin/
