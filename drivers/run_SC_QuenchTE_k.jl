#!/opt/julia-1.12.3/bin/julia
include("/nethome/fstein/repositories/schwingermodeltn/src/timeEvolution/SchwingerModelTNTE.jl")


if length(ARGS) == 11
    N         = parse(Int64,   ARGS[1])
    dimension = parse(Int64,   ARGS[2])
    trunc     =                ARGS[3]
    x         = parse(Float64, ARGS[4])

    mg2       = parse(Float64, ARGS[5])
    epsilon   = 1
    l0_2      = parse(Float64, ARGS[6])

    t         = parse(Float64, ARGS[7])
    k         = parse(Int64,   ARGS[8])
    order     = parse(Int64,   ARGS[9])
    cutoff    = parse(Float64, ARGS[10])
    basedir   = ARGS[11]


    psiname = "QuenchTE"
    quenchstr=string("QuenchedFrom_SC/")

    dirname = string(basedir, "/MPF/") 
    dirDMRG = string(basedir, "/DMRG/MPSs/") 
    truncstr = trunc[1]
    if truncstr == 'b'
        truncstr=string()
    end

    dt = t/k

    outputname = string(dirname, "out/QuenchTE/", "_N", N, "_d", dimension, truncstr, "_X", x, "_mg_inf", ";", mg2, "_l0_0", ";", l0_2,  "_dt", dt, "_k", k, "_order", order, "_cutoff", cutoff, ".out")

    open(outputname, "w") do file
        redirect_stdout(file) do
            s = getSites(N,dimension)
            psi0 = getStrongCouplingState(s)
            println("loaded strong coupling  state")

            runTestEvo(N, dimension, x, mg2, l0_2, epsilon, trunc, dt, k, psi0, s, dirname, psiname=psiname, cutoff=cutoff, order=order, diststr=quenchstr)
        end
    end
else
    println("Wrong number of arguments. Usage:")
        println("run_SC_QuenchTE.jl N d truncation x  m/g'  l0' dt k  order cutoff basedir")
end
