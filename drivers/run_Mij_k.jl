#!/opt/julia-1.12.3/bin/julia
include("/nethome/fstein/repositories/schwingermodeltn/src/timeEvolution/Multiproduct.jl")

if length(ARGS) == 13

    N         = parse(Int64,   ARGS[1])
    dimension = parse(Int64,   ARGS[2])
    trunc     = ARGS[3]
    x         = parse(Float64, ARGS[4])

    mg        = parse(Float64, ARGS[5])
    l0        = parse(Float64, ARGS[6])
    epsilon   = 1 

    dt0       = parse(Float64, ARGS[7])
    ks = let expr = Meta.parse(ARGS[8])
        @assert expr.head == :vect
        Int64.(expr.args)
    end
    timestep = parse(Float64, ARGS[9])

    order     = parse(Int64,   ARGS[10])
    cutoff    = parse(Float64, ARGS[11])
    basedir   = ARGS[12]
    counter   = parse(Int64,   ARGS[13])

    numk = length(ks)

    
    counter2 = mod(counter-1, numk^2+numk)+1
    counter_t = div(counter, numk^2+numk)+1
    
    #println(counter)
    #println(counter2)

    t = timestep * counter_t
    k0 = Int(round(t/dt0))
    dts = t./ks

    dirname = string(basedir, "/MPF/")
    truncstr = trunc[1]
    if truncstr == 'b'
        truncstr=string()
    end

    s = getSites(N, dimension)

    if counter2 <= numk
        outputname = string(dirname, "out/Fij/", "N", N, "_d", dimension, truncstr, "_x", x, "_mg", mg, "_l0", l0, "_t", t, "_ki", k0, "_kj", ks[counter2], "_order", order, "_cutoff", cutoff, ".out")
        open(outputname, "w") do file
            redirect_stdout(file) do
                get_Fij_MPO(t, k0, ks[counter2], s, x, mg, l0, trunc, dirname, cutoff=cutoff, order=order)
            end
        end
    else
        counter_p = counter2 - numk -1
        i = div(counter_p, numk)+1
        j = mod(counter_p, numk)+1
        #println(counter_p, " ", numk)
        #println("i,j", i, " ", j)
        if i!=j
            outputname = string(dirname, "out/Fij/", "N", N, "_d", dimension, truncstr, "_x", x, "_mg", mg, "_l0", l0, "_t", t, "_ki", ks[i], "_kj", ks[j], "_order", order, "_cutoff", cutoff, ".out")
            open(outputname, "w") do file
                redirect_stdout(file) do
                    get_Fij_MPO(t, ks[i], ks[j], s, x, mg, l0, trunc, dirname, cutoff=cutoff, order=order)
                end
            end
        end
    end
else
    println("Wrong number of arguments. Usage:")
    println("run_Mij.jl N d truncation x mg l0 dt0 [dts] timestep order cutoff basedir counter")
end
