#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#define max_size 256

int main(int argc, char *argv[])
{
  FILE *fp;
  if ((fp = fopen("/etc/invokesh.conf", "r")) == NULL) {
    return EXIT_FAILURE;
  }

  char bin[max_size];
  if ( fgets(bin, max_size, fp) == NULL ) {
    fclose(fp);
    return EXIT_FAILURE;
  }

  char *newline;
  if ((newline = strchr(bin, '\n')) != NULL) {
    *newline = '\0';
  }

  fclose(fp);

  argv[0] = bin;
  execvp(bin, argv);
  fprintf(stderr, "invokesh: %s: %s\n", bin, strerror(errno));
  return errno;
}
