import std.stdio;
import std.file;
import std.string;
import std.datetime.stopwatch;
import std.algorithm : min, max;

void transform(const(char)[] s, size_t n, char[] output) {
    size_t ones = 0;
    foreach (i; 0 .. n) {
        if (s[i] == '1') ones++;
    }
    size_t zeros = n - ones;
    size_t pos = 0;
    size_t onesMinusOne = (ones > 0) ? ones - 1 : 0;
    foreach (i; 0 .. onesMinusOne) { output[pos] = '1'; pos++; }
    foreach (i; 0 .. zeros) { output[pos] = '0'; pos++; }
    output[pos] = '1';
    pos++;
}

void main(string[] args) {
    if (args.length < 2) {
        stderr.writeln("usage: bench_d file");
        return;
    }
    string s = strip(cast(string) read(args[1]));
    size_t n = s.length;
    char[] output = new char[n];

    long iters = 50_000_000L / (n > 0 ? cast(long) n : 1);
    if (iters < 1) iters = 1;
    if (iters > 2_000_000) iters = 2_000_000;

    auto sw = StopWatch(AutoStart.no);
    sw.start();
    foreach (i; 0 .. iters) {
        transform(s, n, output);
    }
    sw.stop();

    double elapsedNs = cast(double) sw.peek.total!"nsecs";
    double perOp = elapsedNs / cast(double) iters;
    double totalMs = elapsedNs / 1e6;
    writefln("D,%d,%d,%.2f,%.3f", n, iters, perOp, totalMs);
}
