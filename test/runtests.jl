using Test
using WorkGroups

function axpy!(a, xarr::Vector, yarr::Vector, n::Integer)
    for i in 1:n
        yarr[i] += a * xarr[i]
    end
    return nothing
end

function axpyN!(::Val{N}, a, xarr::Vector, yarr::Vector, n::Integer) where {N}
    as = WorkGroup{N}(a)
    for i in 1:N:n
        xs = getindexN(Val(N), xarr, i)
        ys = getindexN(Val(N), yarr, i)
        ys = map(+, ys, map(*, as, xs))
        setindexN!(Val(N), yarr, ys, i)
    end
    return nothing
end

const n = 16
a = rand(1:10)
xs = rand(1:10, n)
ys = rand(1:10, n)

zs1 = copy(ys)
axpy!(a, xs, zs1, n)

zs4 = copy(ys)
axpyN!(Val(4), a, xs, zs4, n)

@test zs1 == zs4
