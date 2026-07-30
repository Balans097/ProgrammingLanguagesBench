#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

static inline void transform(const char *s, size_t n, char *out) {
    size_t ones = 0;
    for (size_t i = 0; i < n; i++) if (s[i] == '1') ones++;
    size_t zeros = n - ones;
    size_t pos = 0;
    for (size_t i = 0; i + 1 < ones; i++) out[pos++] = '1';
    for (size_t i = 0; i < zeros; i++) out[pos++] = '0';
    out[pos++] = '1';
}

int main(int argc, char **argv) {
    if (argc < 2) { fprintf(stderr, "usage: %s file\n", argv[0]); return 1; }
    FILE *f = fopen(argv[1], "rb");
    if (!f) { perror("fopen"); return 1; }
    fseek(f, 0, SEEK_END);
    long sz = ftell(f);
    fseek(f, 0, SEEK_SET);
    char *buf = malloc(sz + 1);
    size_t rd = fread(buf, 1, sz, f);
    buf[rd] = 0;
    fclose(f);

    size_t n = strlen(buf);
    while (n > 0 && (buf[n-1] == '\n' || buf[n-1] == '\r')) n--;

    char *out = malloc(n + 1);

    long iters = 50000000L / (n > 0 ? (long)n : 1);
    if (iters < 1) iters = 1;
    if (iters > 2000000) iters = 2000000;

    struct timespec t0, t1;
    volatile unsigned char sink = 0;
    clock_gettime(CLOCK_MONOTONIC, &t0);
    for (long i = 0; i < iters; i++) {
        transform(buf, n, out);
        sink ^= (unsigned char)out[0];
    }
    clock_gettime(CLOCK_MONOTONIC, &t1);

    double elapsed_ns = (t1.tv_sec - t0.tv_sec) * 1e9 + (t1.tv_nsec - t0.tv_nsec);
    double per_op = elapsed_ns / (double)iters;
    double total_ms = elapsed_ns / 1e6;
    printf("C,%zu,%ld,%.2f,%.3f\n", n, iters, per_op, total_ms);

    free(buf); free(out);
    return 0;
}
