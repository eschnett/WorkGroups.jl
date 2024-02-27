module WorkGroups

"""
    struct WorkGroup{N,T}

A `WorkGroup` holds data for a whole workgroup. Applying a function to
a `WorkGroup` implicitly iterates over all elements.
"""
struct WorkGroup{N,T}
    items::NTuple{N,T}
end
export WorkGroup

# Construct a `WorkGroup` from a tuple
WorkGroup{N}(xs::NTuple{N,T}) where {N,T} = WorkGroup{N,T}(xs)
# WorkGroup(xs::NTuple{N}) where {N} = WorkGroup{N}(xs)

# Construct a `WorkGroup` from a number (todo: extend to other scalars)
WorkGroup{N}(x::Number) where {N} = WorkGroup{N}(ntuple(i -> x, N))

# Apply a function to a workgroup
Base.map(f, xs::WorkGroup) = WorkGroup(map(f, xs.items))
Base.map(f, xs::WorkGroup{N}, ys::WorkGroup{N}) where {N} = WorkGroup(map(f, xs.items, ys.items))

# Memory access
getindexN(::Val{N}, arr::Vector, n::Integer) where {N} = WorkGroup(ntuple(i -> arr[n + i - 1], N))
function setindexN!(::Val{N}, arr::Vector, val::WorkGroup{N}, n::Integer) where {N}
    for i in 1:N
        arr[n + i - 1] = val.items[i]
    end
    return arr
end
export getindexN, setindexN!

# Synchronisation
syncN() = nothing
export syncN

# Overload some functions

# More types here
const SIMDTYPE = Union{Int32,Int64,Float32,Float64,Bool}

# These specializations would actually use `SIMD` instead
simd_map(f, xs::WorkGroup) = WorkGroup(map(f, xs.items))
simd_map(f, xs::WorkGroup{N}, ys::WorkGroup{N}) where {N} = WorkGroup(map(f, xs.items, ys.items))

Base.map(::typeof(zero), xs::WorkGroup{N,<:SIMDTYPE}) where {N} = simd_map(zero, xs)
Base.map(::typeof(one), xs::WorkGroup{N,<:SIMDTYPE}) where {N} = simd_map(one, xs)

Base.map(::typeof(+), xs::WorkGroup{N,<:SIMDTYPE}) where {N} = simd_map(+, xs)
Base.map(::typeof(-), xs::WorkGroup{N,<:SIMDTYPE}) where {N} = simd_map(-, xs)
Base.map(::typeof(!), xs::WorkGroup{N,<:SIMDTYPE}) where {N} = simd_map(!, xs)
Base.map(::typeof(~), xs::WorkGroup{N,<:SIMDTYPE}) where {N} = simd_map(~, xs)

Base.map(::typeof(inv), xs::WorkGroup{N,<:SIMDTYPE}) where {N} = simd_map(inv, xs)

Base.map(::typeof(+), xs::WorkGroup{N,T}, ys::WorkGroup{N,T}) where {N,T<:SIMDTYPE} = simd_map(+, xs, ys)
Base.map(::typeof(-), xs::WorkGroup{N,T}, ys::WorkGroup{N,T}) where {N,T<:SIMDTYPE} = simd_map(-, xs, ys)
Base.map(::typeof(*), xs::WorkGroup{N,T}, ys::WorkGroup{N,T}) where {N,T<:SIMDTYPE} = simd_map(*, xs, ys)
Base.map(::typeof(/), xs::WorkGroup{N,T}, ys::WorkGroup{N,T}) where {N,T<:SIMDTYPE} = simd_map(/, xs, ys)
Base.map(::typeof(\), xs::WorkGroup{N,T}, ys::WorkGroup{N,T}) where {N,T<:SIMDTYPE} = simd_map(\, xs, ys)
Base.map(::typeof(^), xs::WorkGroup{N,T}, ys::WorkGroup{N,T}) where {N,T<:SIMDTYPE} = simd_map(^, xs, ys)
Base.map(::typeof(&), xs::WorkGroup{N,T}, ys::WorkGroup{N,T}) where {N,T<:SIMDTYPE} = simd_map(&, xs, ys)
Base.map(::typeof(|), xs::WorkGroup{N,T}, ys::WorkGroup{N,T}) where {N,T<:SIMDTYPE} = simd_map(|, xs, ys)

end
