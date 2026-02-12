#!/opt/julia-1.12.3/bin/julia
include("/nethome/fstein/repositories/schwingermodeltn/src/timeEvolution/Multiproduct.jl")

if length(ARGS) == 12
    N         = parse(Int64,   ARGS[1])
    dimension = parse(Int64,   ARGS[2])
    trunc     = ARGS[3]
    x         = parse(Float64, ARGS[4])
    mg        = parse(Float64, ARGS[5])
    epsilon   = 1
    l0        = parse(Float64, ARGS[6])
    t         = parse(Float64, ARGS[7])
    ki        = parse(Int64,   ARGS[8])
    kj        = parse(Int64,   ARGS[9])
    order     = parse(Int64,   ARGS[10])
    cutoff    = parse(Float64, ARGS[11])
    basedir   = ARGS[12]

    s = getSites(N, dimension)



    dirname = string(basedir, "/MPF/")
    truncstr = trunc[1]
    if truncstr == 'b'
        truncstr=string()
    end

    outputname = string(dirname, "out/Fij/", "N", N, "_d", dimension, truncstr, "_x", x, "_mg", mg, "_l0", l0, "_t", t, "_ki", ki, "_kj", kj, "_order", order, "_cutoff", cutoff, ".out")

    open(outputname, "w") do file
        redirect_stdout(file) do
            get_Fij_MPO(t, ki, kj, s, x, mg, l0, trunc, dirname, cutoff=cutoff, order=order)
        end
    end
else
    println("Wrong number of arguments. Usage:")
    println("run_Fij_MPO.jl N d truncation x m/g l0 t ki kj  order cutoff basedir")
end
