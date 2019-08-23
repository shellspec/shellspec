#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <sys/wait.h>
#include <sys/types.h>

// DO NOT USE IN A PRODUCTION ENVIRONMENT!
// This is for testing purposes only.

int main(int argc, char *argv[])
{
  if (argc < 2) {
    return 1;
  }

  pid_t pid;
  if ((pid = fork()) < 0) {
    perror("fork failed");
    return 1;
  }

  if (pid == 0) {
    char *prog = argv[1];
    for (int i = 0; i < argc; i++) {
      argv[i] = argv[i+1];
    }
    uid_t uid = getuid();
    uid_t euid = geteuid();
    gid_t gid = getgid();
    gid_t egid = getegid();

    char uid_str[10];
    char gid_str[10];

    snprintf(uid_str, sizeof(uid_str), "%d", uid);
    snprintf(gid_str, sizeof(uid_str), "%d", gid);

    setenv("SUDO_UID", uid_str, 1);
    setenv("SUDO_GID", gid_str, 1);

    setuid(euid);
    setgid(egid);

    execvp(prog, argv);
    fprintf(stderr, "%s\n", strerror(errno));
    return errno;
  }

  int status;
  if (wait(&status) < 0) {
    return 1;
  }

  return 0;
}
