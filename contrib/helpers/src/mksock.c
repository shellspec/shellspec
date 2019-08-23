#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

#define UNIX_PATH_MAX 108

int main(int argc, char *argv[])
{
    int sock;
    struct sockaddr_un addr;

    if (argc < 2) {
        return 1;
    }

    if ((sock = socket(AF_UNIX, SOCK_STREAM, 0)) == -1) {
        return 1;
    }

    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, argv[1], UNIX_PATH_MAX);

    if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) == -1) {
        return 1;
    }

    close(sock);

    return 0;
}
