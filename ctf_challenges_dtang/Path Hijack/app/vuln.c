#include <unistd.h>
#include <stdio.h>

int main(void) {
    // make sure we’re really root (euid already root due to SUID)
    if (setgid(0) != 0 || setuid(0) != 0) {
        perror("setuid/setgid");
        return 1;
    }

    // Call 'logger' directly; PATH will be searched (vulnerable!)
    char *argv[] = {"logger", "-t", "vuln", "user ran vuln", NULL};
    execvp("logger", argv);

    // If we get here, exec failed
    perror("execvp");
    return 127;
}
