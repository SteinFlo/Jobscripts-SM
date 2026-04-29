#!/opt/julia-1.12.3/bin/julia
include("/nethome/fstein/repositories/schwingermodeltn/src/timeEvolution/Multiproduct.jl")

if length(ARGS) == 8
    N         = parse(Int64,   ARGS[1])

    CoeffNr   = parse(Float64, ARGS[2])

    t         = parse(Float64, ARGS[3])
    ki        = parse(Int64,   ARGS[4])
    kj        = parse(Int64,   ARGS[5])
    order     = parse(Int64,   ARGS[6])
    cutoff    = parse(Float64, ARGS[7])
    basedir   = ARGS[8]

    s = getHBSites(N)

    dirname = string(basedir, "/MPF/")

    outputname = string(dirname, "out/Fij_HB/", "N", N, "_d", "_coeff", CoeffNr, "_t", t, "_ki", ki, "_kj", kj, "_order", order, "_cutoff", cutoff, ".out")

    open(outputname, "w") do file
        redirect_stdout(file) do
            get_Fij_MPO(t, ki, kj, s, CoeffNr, dirname, cutoff=cutoff, order=order)
        end
    end
else
    println("Wrong number of arguments. Usage:")
    println("run_Fij_MPO_HB.jl N CoeffNr t ki kj  order cutoff basedir")
end
