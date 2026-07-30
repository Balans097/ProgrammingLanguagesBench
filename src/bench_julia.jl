function transform!(s::Vector{UInt8}, n::Int, out::Vector{UInt8})
    ones_count = 0
    @inbounds for i in 1:n
        if s[i] == UInt8('1')
            ones_count += 1
        end
    end
    zeros_count = n - ones_count
    pos = 1
    @inbounds for _ in 1:(ones_count - 1)
        out[pos] = UInt8('1')
        pos += 1
    end
    @inbounds for _ in 1:zeros_count
        out[pos] = UInt8('0')
        pos += 1
    end
    out[pos] = UInt8('1')
end

function main()
    if length(ARGS) < 1
        println(stderr, "usage: bench_julia.jl file")
        return
    end
    s = Vector{UInt8}(strip(read(ARGS[1], String)))
    n = length(s)
    out = Vector{UInt8}(undef, n)

    iters = max(1, min(2_000_000, div(50_000_000, max(n, 1))))

    # прогрев / JIT-компиляция — не входит в измерение
    transform!(s, n, out)

    t0 = time_ns()
    for _ in 1:iters
        transform!(s, n, out)
    end
    t1 = time_ns()

    per_op = (t1 - t0) / iters
    total_ms = (t1 - t0) / 1e6
    println("Julia,$n,$iters,$(round(per_op, digits=2)),$(round(total_ms, digits=3))")
end

main()
