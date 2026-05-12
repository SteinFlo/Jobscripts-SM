#!/opt/julia-1.12.3/bin/julia
include("/nethome/fstein/repositories/schwingermodeltn/src/timeEvolution/SchwingerModelTNTE.jl")

if length(ARGS) == 15
    N         = parse(Int64,   ARGS[1])
    dimension = parse(Int64,   ARGS[2])
    trunc     = ARGS[3]
    x         = parse(Float64, ARGS[4])
    mg        = parse(Float64, ARGS[5])
    epsilon   = 1
    l0        = parse(Float64, ARGS[6])
    N1        = parse(Int64,   ARGS[7])
    N2        = parse(Int64,   ARGS[8])
    t1        = parse(Float64, ARGS[9])
    tstep     = parse(Float64, ARGS[10])
    t2        = parse(Float64, ARGS[11])
    k         = parse(Int64,   ARGS[12])
    order     = parse(Int64,   ARGS[13])
    cutoff    =  parse(Float64, ARGS[14])
    basedir   = ARGS[15]


    if iseven(N2-N1)
        println("Sites have wrong parity")
    end

    psiname = string("FermiStrTE")
    diststr = string("dist", N1, "-", N2,"/")

    dirname = string(basedir, "/MPF/") 
    dirDMRG = string(basedir, "/DMRG/MPSs/") 
    truncstr = trunc[1]
    if truncstr == 'b'
        truncstr=string()
    end

    outputname = string(dirname, "out/FermiStrTE/", "N", N, "_d", dimension, truncstr, "_X", x, "_mg", mg, "_l0", l0, "_N1-", N1, "_N2-", N2, "_t", t1,"-", tstep, "-", t2, "_k", k, "_order", order, "_cutoff", cutoff, ".out")

    open(outputname, "w") do file
        redirect_stdout(file) do
            fname_gs = string(dirDMRG, "gs", "_renormPBC", "_N", N, "_d", dimension, truncstr, "_x", x, "_mg", mg, "_l0", l0, "_Dmax", 400,     ".jld2")
            f = jldopen(fname_gs, "r")
            s = f["sites"]
            psi0 = f["psi"]
            close(f)
            println("loaded ground  state")

            psiStr = applyFermiStringMPO(N1, N2, s, psi0, truncation=trunc)
            println("Initialized String")

            for t in t1:tstep:t2
                dt=t/k
                runTestEvo(N, dimension, x, mg, l0, epsilon, trunc, dt, k, psiStr, s, dirname, psiname=psiname, cutoff=cutoff, order=order, diststr=diststr)
            end
        end
    end
else
    println("Wrong number of arguments. Usage:")
        println("run_FermiStrTE.jl N d truncation x m/g l0 N1 N2 t1 tstep t2 k  order cutoff basedir")
    end
