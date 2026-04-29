#!/opt/julia-1.12.3/bin/julia
include("/nethome/fstein/repositories/schwingermodeltn/src/timeEvolution/SchwingerModelTNTE.jl")

if length(ARGS) == 11
    N         = parse(Int64,   ARGS[1])
    dimension = parse(Int64,   ARGS[2])
    trunc     = ARGS[3]
    x         = parse(Float64, ARGS[4])
    mg        = parse(Float64, ARGS[5])
    epsilon   = 1
    l0        = parse(Float64, ARGS[6])
    dt        = parse(Float64, ARGS[7])
    k         = parse(Int64,   ARGS[8])
    order     = parse(Int64,   ARGS[9])
    cutoff    =  parse(Float64, ARGS[10])
    basedir   = ARGS[11]


    psiname = string("GStest")
    diststr = string("")

    dirname = string(basedir, "/MPF/") 
    dirDMRG = string(basedir, "/DMRG/MPSs/") 
    truncstr = trunc[1]
    if truncstr == 'b'
        truncstr=string()
    end

    outputname = string(dirname, "out/GSevo/", "N", N, "_d", dimension, truncstr, "_X", x, "_mg", mg, "_l0", l0, "_dt", dt, "_k", k, "_order", order, "_cutoff", cutoff, ".out")

    open(outputname, "w") do file
        redirect_stdout(file) do
            fname_gs = string(dirDMRG, "gs", "_renormPBC", "_N", N, "_d", dimension, truncstr, "_x", x, "_mg", mg, "_l0", l0, "_Dmax", 400,     ".jld2")
            f = jldopen(fname_gs, "r")
            s = f["sites"]
            psi0 = f["psi"]
            close(f)
            println("loaded ground  state")


            runTestEvo(N, dimension, x, mg, l0, epsilon, trunc, dt, k, psi0, s, dirname, psiname=psiname, cutoff=cutoff, order=order, diststr=diststr)
        end
    end
else
    println("Wrong number of arguments. Usage:")
        println("run_GSevo.jl N d truncation x m/g l0 dt k  order cutoff basedir")
    end
