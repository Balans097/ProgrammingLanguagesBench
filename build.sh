#!/usr/bin/env bash
# Намеренно без "set -e": отсутствие одного компилятора не должно
# останавливать сборку остальных.
cd "$(dirname "$0")"
mkdir -p bin

echo "== C =="
gcc -O3 -march=native -o bin/bench_c src/bench_c.c && echo "OK: bin/bench_c"

echo "== C++ =="
g++ -O3 -march=native -std=c++17 -o bin/bench_cpp src/bench_cpp.cpp && echo "OK: bin/bench_cpp"

echo "== Nim =="
nim c -d:release --opt:speed -o:bin/bench_nim src/bench_nim.nim && echo "OK: bin/bench_nim"

echo "== D =="
# На Fedora обычно есть ldc2 (dnf install ldc) или dmd; gdc отдельно не пакетируется.
if command -v ldc2 >/dev/null; then
  ldc2 -O3 -release -of=bin/bench_d src/bench_d.d && echo "OK: bin/bench_d (ldc2)"
elif command -v dmd >/dev/null; then
  dmd -O -release -of=bin/bench_d src/bench_d.d && echo "OK: bin/bench_d (dmd)"
elif command -v gdc >/dev/null; then
  gdc -O3 -frelease -o bin/bench_d src/bench_d.d && echo "OK: bin/bench_d (gdc)"
else
  echo "ПРОПУЩЕНО: не найден ни ldc2, ни dmd, ни gdc."
  echo "  Fedora: sudo dnf install ldc"
fi

echo "== Rust =="
rustc -O -C opt-level=3 -o bin/bench_rust src/bench_rust.rs && echo "OK: bin/bench_rust"

echo
echo "Готово. Julia и Python не требуют компиляции."
ls -la bin/ 2>/dev/null
