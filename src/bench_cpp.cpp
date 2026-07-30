#include <chrono>
#include <cstdio>
#include <fstream>
#include <iostream>
#include <string>

static inline void transform(const std::string &s, size_t n, std::string &out) {
    size_t ones = 0;
    for (size_t i = 0; i < n; i++) if (s[i] == '1') ones++;
    size_t zeros = n - ones;
    size_t pos = 0;
    for (size_t i = 0; i + 1 < ones; i++) out[pos++] = '1';
    for (size_t i = 0; i < zeros; i++) out[pos++] = '0';
    out[pos++] = '1';
}

int main(int argc, char **argv) {
    if (argc < 2) { std::cerr << "usage: " << argv[0] << " file\n"; return 1; }
    std::ifstream f(argv[1], std::ios::binary);
    if (!f) { std::cerr << "cannot open file\n"; return 1; }
    std::string s((std::istreambuf_iterator<char>(f)), std::istreambuf_iterator<char>());
    while (!s.empty() && (s.back() == '\n' || s.back() == '\r')) s.pop_back();
    size_t n = s.size();

    std::string out(n, '0');

    long iters = 50000000L / (n > 0 ? (long)n : 1);
    if (iters < 1) iters = 1;
    if (iters > 2000000) iters = 2000000;

    volatile unsigned char sink = 0;
    auto t0 = std::chrono::steady_clock::now();
    for (long i = 0; i < iters; i++) {
        transform(s, n, out);
        sink ^= (unsigned char)out[0];
    }
    auto t1 = std::chrono::steady_clock::now();

    double elapsed_ns = std::chrono::duration<double, std::nano>(t1 - t0).count();
    double per_op = elapsed_ns / (double)iters;
    double total_ms = elapsed_ns / 1e6;
    std::printf("C++,%zu,%ld,%.2f,%.3f\n", n, iters, per_op, total_ms);
    return 0;
}
