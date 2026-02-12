#!/opt/julia-1.12.3/bin/julia
include("/nethome/fstein/repositories/schwingermodeltn/src/timeEvolution/SchwingerModelTNTE.jl")

if length(ARGS) == 13
    N         = parse(Int64,   ARGS[1])
    dimension = parse(Int64,   ARGS[2])
    trunc     =                ARGS[3]
    x         = parse(Float64, ARGS[4])

    mg        = parse(Float64, ARGS[5])
    mg2       = parse(Float64, ARGS[6])
    epsilon   = 1
    l0        = parse(Float64, ARGS[7])
    l0_2      = parse(Float64, ARGS[8])

    dt        = parse(Float64, ARGS[9])
    k         = parse(Int64,   ARGS[10])
    order     = parse(Int64,   ARGS[11])
    cutoff    = parse(Float64, ARGS[12])
    basedir   = ARGS[13]


    psiname = "QuenchTE"
    quenchstr=string("QuenchedFrom_mg", mg, "_l0", l0,"/")

    dirname = string(basedir, "/MPF/") 
    dirDMRG = string(basedir, "/DMRG/MPSs/") 
    truncstr = trunc[1]
    if truncstr == 'b'
        truncstr=string()
    end

    outputname = string(dirname, "out/QuenchTE/", "_N", N, "_d", dimension, truncstr, "_X", x, "_mg", mg, ";", mg2, "_l0", l0, ";", l0_2,  "_dt", dt, "_k", k, "_order", order, "_cutoff", cutoff, ".out")

    open(outputname, "w") do file
        redirect_stdout(file) do
            fname_gs = string(dirDMRG, "gs", "_renormPBC", "_N", N, "_d", dimension, truncstr, "_x", x, "_mg", mg, "_l0", l0, "_Dmax", 400,     ".jld2")
            f = jldopen(fname_gs, "r")
            s = f["sites"]
            psi0 = f["psi"]
            close(f)
            println("loaded ground  state")


            t = k*dt
            runTestEvo(N, dimension, x, mg2, l0_2, epsilon, trunc, dt, k, psi0, s, dirname, psiname=psiname, cutoff=cutoff, order=order, diststr=quenchstr)
        end
    end
else
    println("Wrong number of arguments. Usage:")
        println("run_QuenchTE.jl N d truncation x m/g m/g' l0 l0' dt k  order cutoff basedir")
    end
