
dt0 = 0.01

dts = [0.03 0.04 0.05 0.06]


N 
d
trunc
x
mg
l0
t
order 
cutoff

k0 = ceil(t/dt0)
ks = ceil.(t./dts)

numk = length(ks)
if l <= numk
    get_Fij_MPO(t, k0, k[l], s, x, mg, l0, trunc, dirname, cutoff=cutoff, order=order)
else
    lp = l - numk -1
    i = div(lp, numk)+1
    j = mod(lp, numk)+1
    if i!=j
        get_Fij_MPO(t, k[i], k[j], s, x, mg, l0, trunc, dirname, cutoff=cutoff, order=order)
    end
end
