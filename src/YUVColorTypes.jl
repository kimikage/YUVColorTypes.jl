"""
    YUVColorTypes

An add-on libray to `ColorTypes` supporting YUV-like colors.

# Type Hierarchy
## `ColorTypes.Color{T,N}`
- `AbstractYUV{T}`
    - [`YUV{T,P,U,D}`](@ref)
- `AbstractLuma{T}`
    - [`Luma{T,P,U,D}`](@ref)

## `ColorTypes.AlphaColor{C,T,N}`
- `AbstractAYUV{C,T}`
    - [`AYUV{T,P,U,D}`](@ref)
- `AbstractALuma{C,T}`
    - [`ALuma{T,P,U,D}`](@ref)

## `ColorTypes.ColorAlpha{C,T,N}`
- `AbstractYUVA{C,T}`
  - [`YUVA{T,P,U,D}`](@ref)
- `AbstractLumaA{C,T}`
  - [`LumaA{T,P,U,D}`](@ref)

# Supported Profiles
- [`YCbCrBT601_625`](@ref)
- [`YCbCrBT601_525`](@ref)
"""
module YUVColorTypes

using ColorTypes
using ColorTypes.FixedPointNumbers

import ColorTypes: _convert, ccolor

include("utilities.jl")

export AbstractYUV, TransparentYUV, AbstractAYUV, AbstractYUVA
export AbstractLuma, TransparentLuma, AbstractALuma, AbstractLumaA
export AbstractYUVColorant, AbstractLumaColorant, YUVColorant

export YCbCrBT601_625, YCbCrBT601_525
export YCbCr24BT601_625, YCbCr30BT601_625, YCbCr36BT601_625, YCbCr48BT601_625
export YCbCr24BT601_525, YCbCr30BT601_525, YCbCr36BT601_525, YCbCr48BT601_525

export luma, chroma_u, chroma_v, chroma_b, chroma_r, chroma_g, chroma_o

export rgb_to_yuv, srgb_to_yuv
export yuv_to_rgb, yuv_to_srgb

abstract type AbstractYUV{T} <: Color{T,3} end
abstract type AbstractAYUV{C<:AbstractYUV,T} <: AlphaColor{C,T,4} end
abstract type AbstractYUVA{C<:AbstractYUV,T} <: ColorAlpha{C,T,4} end
const TransparentYUV{C<:AbstractYUV,T} = TransparentColor{C,T,4}
const AbstractYUVColorant{T,C} = Union{
    AbstractYUV{T},
    TransparentYUV{C,T},
}

# "Y" is too generic a name, therefore, we name it "Luma".
abstract type AbstractLuma{T} <: AbstractGray{T} end
abstract type AbstractALuma{C<:AbstractLuma,T} <: AlphaColor{C,T,2} end
abstract type AbstractLumaA{C<:AbstractLuma,T} <: ColorAlpha{C,T,2} end
const TransparentLuma{C<:AbstractLuma,T} = TransparentColor{C,T,2}
const AbstractLumaColorant{T,C} = Union{
    AbstractLuma{T},
    TransparentLuma{C,T},
}

const AbstractYUVLumaColorant{T,C} = Union{
    AbstractYUVColorant{T,C},
    AbstractLumaColorant{T,C}
}

const AbstractRGBColorant{T,C} = Union{
    AbstractRGB{T},
    TransparentRGB{C,T}
}

"""
    YUV{T,P,U,D} <: AbsrtractYUV{T}

- `T`: component type
- `P`: symbol of profile
- `U`: unsigned chroma components if `true`
- `D`: bit-depth

See also [`AYUV`](@ref) and [`YUVA`](@ref) for transparent versions,
and [`Luma`](@ref) for the single Y component version.
"""
struct YUV{T,P,U,D} <: AbstractYUV{T}
    y::T
    u::T
    v::T
    YUV{T,P,U}(y, u, v) where {T,P,U} = new{T,P,U,-1}(y, u, v)
    YUV{T,P,U,D}(y, u, v) where {T,P,U,D} = new{T,P,U,D}(y, u, v)
end

"""
    AYUV{T,P,U,D} <: AbstractAYUV{YUV{T,P,U,D},T}
"""
struct AYUV{T,P,U,D} <: AbstractAYUV{YUV{T,P,U,D},T}
    alpha::T
    y::T
    u::T
    v::T
end

"""
    YUVA{T,P,U,D} <: AbstractYUVA{YUV{T,P,U,D},T}
"""
struct YUVA{T,P,U,D} <: AbstractYUVA{YUV{T,P,U,D},T}
    y::T
    u::T
    v::T
    alpha::T
end

"""
    Luma{T,P,U,D} <: AbstractLuma{T}

The single Y component, i.e. grayscale version of a YUV-like color.
"""
struct Luma{T,P,U,D} <: AbstractLuma{T}
    y::T
end

"""
    ALuma{T,P,U,D} <: AbstractALuma{Luma{T,P,U,D},T}
"""
struct ALuma{T,P,U,D} <: AbstractALuma{Luma{T,P,U,D},T}
    alpha::T
    y::T
end

"""
    LumaA{T,P,U,D} <: AbstractLumaA{YUV{T,P,U,D},T}
"""
struct LumaA{T,P,U,D} <: AbstractLumaA{YUV{T,P,U,D},T}
    y::T
    alpha::T
end

const YUVColorant{T,P,U,D} = Union{
    YUV{T,P,U,D},
    AYUV{T,P,U,D},
    YUVA{T,P,U,D},
}

const LumaColorant{T,P,U,D} = Union{
    Luma{T,P,U,D},
    ALuma{T,P,U,D},
    LumaA{T,P,U,D},
}

const YUVLumaColorant{T,P,U,D} = Union{
    YUVColorant{T,P,U,D},
    Luma{T,P,U,D},
}

const YUVT{P,U,D} = YUV{T,P,U,D} where {T}
const LumaT{P,U,D} = Luma{T,P,U,D} where {T}
const YUVLumaColorantT{P,U,D} = YUVLumaColorant{T,P,U,D} where {T}


# type (alias) definitions
include("bt601.jl")


const YCbCrColorant{T,P,U,D} = Union{
    YUVColorant{T,:BT601_625,U,D},
    YUVColorant{T,:BT601_525,U,D},
}

const YCgCoColorant{T,P,U,D} = Union{
}

include("construct.jl")
include("traits.jl")

include("ranges.jl")
include("matrices.jl")
include("primaries.jl")
include("curves.jl")

include("convert.jl")

end # module
