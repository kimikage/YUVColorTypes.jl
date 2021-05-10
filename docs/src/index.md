# YUVColorTypes
This package is an add-on to [ColorTypes](https://github.com/JuliaGraphics/ColorTypes.jl),
and supports [YUV](https://en.wikipedia.org/wiki/Y%E2%80%B2UV)-like colors.

Unfortunately, the environment surrounding YUV-like colors has historically been
confusing.
In the first place, there is no consensus on even calling a color with one
luminance component and two chroma components a YUV.
Therefore, this package aims to handle well-defined and well-formed YUV-like
colors in a "reasonable" manner.

This package does not provide a public API for the specific storage format of
YUV colors.
This is because YUV-like images are often used with chroma subsampling (e.g.,
YUV 4:2:0) and planar formats with channel-separated images.

Also, this package provides limited support for conversion between RGBs and
YUVs, and does not provide general color management functionality.

## Type design
### Background
The ColorTypes.jl schemes for handling YUV-like colors include the following
problems:
1. There are various profiles.
2. ColorTypes.jl does not provide abstract types for specific color models, except for AbstractRGB.
3. YUV-like components are often normalized in the range [0, 256) instead of [0, 1] or [-0.5, 0.5).
   1. YUV-like components are often handled as integer types, especially `UInt8`.
   2. FixedPointNumbers.jl v0.8 does not support *unsigned* `Fixed`.
4. Alpha component should be normalized in the range [0, 1] like `ARGB`.

YUVColorType.jl uses the following strategies to solve or mitigate the above problems.
1. Use julia's parametric types and CICP (Coding-independent code points).
2. Add some abstract types such as [`AbstractYUV`](@ref).
3. Make the range depend on bit depth instead of normalizing into [0, 1].
4. When the component type is an integer type, encode alpha implicitly as
   `Normed`.

### YUV type
The actual type definition underlying YUVColorTypes is as follows:
```julia
struct YUV{T,P,U,R,D} <: AbstractYUV{T}
    y::T
    u::T
    v::T
end
```
It is worth noting that while `RGB` has a single type parameter `T` which
specifies the type of the component, [`YUV`](@ref) has four additional type
parameters.

Be prepared that this type may not work well because some of the downstream
packages do not assume color types with type parameters other than the component
type `T`.

In any case, the end-users do not need to be aware of the details of the type
implementation, and it is undesirable to write codes relying on the internal
implementation, since it may change in the future.

`YUVColorTypes` provides several type aliases.
For BT.601 625-line, the following type aliases are defined for opaque, i.e.,
without alpha, YCbCr.
- [`YCbCrBT601_625`](@ref)
- [`YCbCr24BT601_625`](@ref)
- [`YCbCr30BT601_625`](@ref)
- [`YCbCr36BT601_625`](@ref)
- [`YCbCr48BT601_625`](@ref)

The first alias is the basic type for which no bit depth is specified.
Subsequent aliases are specified with component bit depths of 8, 10, 12, and 16
bits.

The bit depth specification changes the ranges of possible values for the
components.
The following five colors are different representations of the same color.
```@example ex
using YUVColorTypes

[
    YCbCrBT601_625(100, 80, 100),
    YCbCr24BT601_625(100, 80, 100),
    YCbCr30BT601_625(400, 320, 400),
    YCbCr36BT601_625(1600, 1280, 1600),
    YCbCr48BT601_625(25600, 20480, 25600),
]
```
Note that unlike `RGB24`, the types with bit depths are still parametric.
```@example ex
using FixedPointNumbers
[
    YCbCr24BT601_625{UInt8}(100, 200, 100), # `UInt8` is the default component type
    YCbCr24BT601_625{Int}(100, 200, 100),
    YCbCr24BT601_625{Q11f4}(100.5, 200.5, 100.5),
    YCbCr24BT601_625{Float32}(100.5, 200.5, 100.5),
]
```

Then, what is the difference between `YCbCrBT601_625` without specifying bit
depth and `YCbCr24BT601_625`?
In fact, they behave almost identically.
The difference is the way the component type is determined in the conversion.
`YCbCrBT601_625` attempts to maintain the precision.
On the other hand, types with bit depth do not care about the fractional part or
out-of-range values.
(**FIXME**)

```@repl ex
YCbCrBT601_625(YCbCr30BT601_625{UInt16}(401, 322, 403))
YCbCr24BT601_625(YCbCr30BT601_625{UInt16}(401, 322, 403))
```