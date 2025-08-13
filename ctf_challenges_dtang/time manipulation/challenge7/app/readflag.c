#include <stdio.h>
int main(void) {
    FILE *f = fopen("/root/flag.txt", "r");
    if (!f) return 1;
    int c; while ((c = fgetc(f)) != EOF) putchar(c);
    fclose(f);
    return 0;
}
