use std::env;
use std::fs;
use std::time::Instant;

fn transform(s: &[u8], n: usize, out: &mut [u8]) {
    let mut ones: usize = 0;
    for i in 0..n {
        if s[i] == b'1' {
            ones += 1;
        }
    }
    let zeros = n - ones;
    let mut pos: usize = 0;
    for _ in 0..ones.saturating_sub(1) {
        out[pos] = b'1';
        pos += 1;
    }
    for _ in 0..zeros {
        out[pos] = b'0';
        pos += 1;
    }
    out[pos] = b'1';
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("usage: bench_rust file");
        return;
    }
    let raw = fs::read_to_string(&args[1]).expect("cannot read file");
    let s = raw.trim();
    let bytes = s.as_bytes();
    let n = bytes.len();
    let mut out = vec![0u8; n];

    let mut iters: u64 = 50_000_000u64 / (if n > 0 { n as u64 } else { 1 });
    if iters < 1 {
        iters = 1;
    }
    if iters > 2_000_000 {
        iters = 2_000_000;
    }

    let start = Instant::now();
    for _ in 0..iters {
        transform(bytes, n, &mut out);
        std::hint::black_box(&out);
    }
    let elapsed = start.elapsed();

    let per_op = elapsed.as_nanos() as f64 / iters as f64;
    let total_ms = elapsed.as_nanos() as f64 / 1e6;
    println!("Rust,{},{},{:.2},{:.3}", n, iters, per_op, total_ms);
}
