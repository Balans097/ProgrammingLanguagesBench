#!/usr/bin/env bash
cd "$(dirname "$0")"

if ! ls data/len_*.txt >/dev/null 2>&1; then
  echo "Тестовые данные не найдены — генерирую (python3 gen_data.py)..."
  python3 gen_data.py
fi

mkdir -p results
OUT=results/results.csv
echo "lang,n,iters,ns_per_op,total_ms" > "$OUT"

run() {
  # $1 = путь к бинарю/команде, остальное - аргументы
  if [ -x "$1" ] || command -v "$1" >/dev/null 2>&1; then
    "$@" | tee -a "$OUT"
  else
    echo "пропущено (не собрано): $1" >&2
  fi
}

for f in data/len_*.txt; do
  run ./bin/bench_c "$f"
  run ./bin/bench_cpp "$f"
  run ./bin/bench_nim "$f"
  run ./bin/bench_nim_danger "$f"
  run ./bin/bench_d "$f"
  run ./bin/bench_rust "$f"
  run python3 src/bench_python.py "$f"
  if command -v julia >/dev/null 2>&1; then
    run julia src/bench_julia.jl "$f"
  fi
done

echo
echo "Результаты сохранены в $OUT"
