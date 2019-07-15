FROM alpine
RUN apk add --no-cache gcc libc-dev
COPY ./mksock.c ./mksock.c
RUN gcc --static -o mksock mksock.c
