import std/[os, strutils, monotimes, times]

# Работаем с сырым непрерывным буфером байт
# (как Vector{UInt8}), а не с высокоуровневым Nim string через
# двойной указатель (var string) — это раньше мешало GCC
# распознавать цикл заполнения как memset/векторизовать подсчёт.
#
# {.push checks: off.} отключает проверки границ/переполнения ЛОКАЛЬНО
# для этой функции - это прямой аналог @inbounds в Julia: не нужно
# компилировать всю программу с -d:danger, проверки безопасности
# остаются включёнными везде, кроме явно размеченного горячего пути.



type ByteArr = ptr UncheckedArray[byte]



{.push checks: off, optimization: speed.}
proc transform(s: ByteArr, n: int, output: ByteArr) =
  var ones = 0
  for i in 0 ..< n:
    if s[i] == byte('1'):
      inc ones
  let zeros = n - ones
  var pos = 0
  for i in 0 ..< (ones - 1):
    output[pos] = byte('1')
    inc pos
  for i in 0 ..< zeros:
    output[pos] = byte('0')
    inc pos
  output[pos] = byte('1')
{.pop.}




when isMainModule:
  let args = commandLineParams()
  if len(args) < 1:
    quit("usage: bench_nim file")

  var s = strip(readFile(args[0]))
  let n = len(s)
  var output = newString(n)

  let sPtr = cast[ByteArr](addr s[0])
  let outPtr = cast[ByteArr](addr output[0])

  var iters = 50_000_000 div (if n > 0: n else: 1)
  if iters < 1:
    iters = 1
  if iters > 2_000_000:
    iters = 2_000_000

  let t0 = getMonoTime()
  for i in 0 ..< iters:
    transform(sPtr, n, outPtr)
  let t1 = getMonoTime()

  let elapsedNs = float(inNanoseconds(t1 - t0))
  let perOp = elapsedNs / float(iters)
  let totalMs = elapsedNs / 1e6
  let label = when defined(danger): "NimDanger" else: "Nim"
  echo label, ",", n, ",", iters, ",", formatFloat(perOp, ffDecimal, 2), ",",
      formatFloat(totalMs, ffDecimal, 3)
