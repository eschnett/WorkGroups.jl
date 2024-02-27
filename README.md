# WorkGroups.jl

Prototype for mapping abstract compute kernels to CPUs. We introduce a
new data type `WorkGroup` that holds data for a whole workgroup. This
is similar to a SIMD vector, but is more flexible in case we need to
represent types that cannot be handle by `SIMD.jl`.

When translating a kernel, we would:
- Choose a fixed workgroup size `N` (maybe 16?)
- Wrap each literal with a call to `WorkGroup{N}`
- Translate each function call to calling `map`

This package is a demonstration. The `WorkGroups` module implements
this idea (roughly), the test cases show a simple scalar kernel
(`axpy!`) and how it would look like after translation (`axpyN!`).
