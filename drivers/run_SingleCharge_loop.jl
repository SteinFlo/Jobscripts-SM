#!/opt/julia-1.12.3/bin/julia
include("/nethome/fstein/repositories/schwingermodeltn/src/timeEvolution/SchwingerModelTNTE.jl")

if length(ARGS) == 14
    N         = parse(Int64,   ARGS[1])
    dimension = parse(Int64,   ARGS[2])
    trunc     = ARGS[3]
    x         = parse(Float64, ARGS[4])
    mg        = parse(Float64, ARGS[5])
    epsilon   = 1
    l0        = parse(Float64, ARGS[6])
    N1        = parse(Int64,   ARGS[7])
    dt        = parse(Float64, ARGS[8])

    t1        = parse(Float64,   ARGS[9])
    ts        = parse(Float64,   ARGS[10])
    t2        = parse(Float64,   ARGS[11])
    order     = parse(Int64,   ARGS[12])
    cutoff    =  parse(Float64, ARGS[13])
    basedir   = ARGS[14]


    psiname = string("singleFermion")
    diststr = string("Pos", N1, "/")

    dirname = string(basedir, "/MPF/") 
    dirDMRG = string(basedir, "/DMRG/MPSs/") 
    truncstr = trunc[1]
    if truncstr == 'b'
        truncstr=string()
    end

    outputname = string(dirname, "out/single/", "N", N, "_d", dimension, truncstr, "_X", x, "_mg", mg, "_l0", l0, "_N1-", N1, "_dt", dt, "_t", t1,"-", ts, "-", t2, "_order", order, "_cutoff", cutoff, ".out")

    open(outputname, "w") do file
        redirect_stdout(file) do
            fname_gs = string(dirDMRG, "gs", "_renormPBC", "_N", N, "_d", dimension, truncstr, "_x", x, "_mg", mg, "_l0", l0, "_Dmax", 400,     ".jld2")
            f = jldopen(fname_gs, "r")
            s = f["sites"]
            psi0 = f["psi"]
            close(f)
            println("loaded ground  state")

            if iseven(N1)
                S=op("S+", s[2*N1-1])
            else
                S=op("S-", s[2*N1-1])
            end

            psiStr = normalize(apply(S ,psi0))
            println("Initialized Fermion")

            for t in t1:ts:t2
                k=Int(round(t/dt, digits=4))
                runTestEvo(N, dimension, x, mg, l0, epsilon, trunc, dt, k, psiStr, s, dirname, psiname=psiname, cutoff=cutoff, order=order, diststr=diststr)
                flush(stdout)
            end
        end
    end
else
    println("Wrong number of arguments. Usage:")
        println("run_FermiStrTE_loop.jl N d truncation x m/g l0 N1 N2 dt t1 ts t2  order cutoff basedir")
    end
