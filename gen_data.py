#!/usr/bin/env python3
"""Генерирует тестовые бинарные строки для бенчмарка.
Каждая строка гарантированно содержит хотя бы одну '1' (иначе нечётное
число сформировать невозможно).
"""
import random
import os

SIZES = [10, 100, 1_000, 10_000, 100_000, 1_000_000, 10_000_000]
OUT_DIR = os.path.join(os.path.dirname(__file__), "data")

def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    rng = random.Random(42)  # фиксированный seed -> одинаковые данные для всех языков
    for n in SIZES:
        bits = rng.choices("01", weights=[0.5, 0.5], k=n)
        if "1" not in bits:
            bits[0] = "1"
        s = "".join(bits)
        path = os.path.join(OUT_DIR, f"len_{n}.txt")
        with open(path, "w") as f:
            f.write(s)
        print(f"{path}: {n} bit(s)")

if __name__ == "__main__":
    main()
