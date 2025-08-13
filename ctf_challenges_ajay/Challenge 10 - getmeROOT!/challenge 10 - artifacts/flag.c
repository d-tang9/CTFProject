#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
    if (geteuid() != 0) {
        fprintf(stderr, "Error: must be run with sudo/root privileges.\n");
        return 1;
    }

    FILE *fp = fopen("/root/flag_revealed.txt", "w");
    if (fp == NULL) {
        perror("Failed to write flag");
        return 1;
    }

    fprintf(fp, "Flag{damn_you_got_me_outside}\n");
    fclose(fp);

    printf("Implant executed. Flag dropped.\n");
    return 0;
}
