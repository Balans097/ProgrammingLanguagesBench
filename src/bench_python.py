import sys
import time


def transform(s, n):
    ones = s.count("1")
    zeros = n - ones
    return "1" * (ones - 1) + "0" * zeros + "1"


def main():
    if len(sys.argv) < 2:
        print("usage: bench_python.py file", file=sys.stderr)
        return
    with open(sys.argv[1]) as f:
        s = f.read().strip()
    n = len(s)

    iters = max(1, min(2_000_000, 50_000_000 // max(n, 1)))

    start = time.perf_counter()
    for _ in range(iters):
        transform(s, n)
    end = time.perf_counter()

    per_op_ns = (end - start) * 1e9 / iters
    total_ms = (end - start) * 1e3
    print(f"Python,{n},{iters},{per_op_ns:.2f},{total_ms:.3f}")


if __name__ == "__main__":
    main()
