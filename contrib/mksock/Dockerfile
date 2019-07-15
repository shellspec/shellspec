FROM alpine
COPY ./mksock.c ./mksock.c
RUN apk add --no-cache gcc libc-dev && gcc --static -o mksock mksock.c
