"""
    YUVColorTypes

An add-on libray to `ColorTypes` supporting YUV-like colors.

# Type Hierarchy
## `ColorTypes.Color{T,N}`
- [`AbstractYUV{T}`](@ref)
    - [`YUV{T,P,U,R,D}`](@ref)
- `AbstractLuma{T}`
    - [`Luma{T,P,U,R,D}`](@ref)
## `ColorTypes.AlphaColor{C,T,N}`
- `AbstractAYUV{C,T}`
    - [`AYUV{T,P,U,R,D}`](@ref)
- `AbstractALuma{C,T}`
    - [`ALuma{T,P,U,R,D}`](@ref)

## `ColorTypes.ColorAlpha{C,T,N}`
- `AbstractYUVA{C,T}`
  - [`YUVA{T,P,U,R,D}`](@ref)
- `AbstractLumaA{C,T}`
  - [`LumaA{T,P,U,R,D}`](@ref)

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

export YCbCrBT601_625, AYCbCrBT601_625, YCbCrABT601_625
export YCbCr24BT601_625, YCbCr30BT601_625, YCbCr36BT601_625, YCbCr48BT601_625
export AYCbCr32BT601_625, AYCbCr40BT601_625, AYCbCr48BT601_625, AYCbCr64BT601_625
export YCbCrA32BT601_625, YCbCrA40BT601_625, YCbCrA48BT601_625, YCbCrA64BT601_625

export YCbCrBT601_525, AYCbCrBT601_525, YCbCrABT601_525
export YCbCr24BT601_525, YCbCr30BT601_525, YCbCr36BT601_525, YCbCr48BT601_525
export AYCbCr32BT601_525, AYCbCr40BT601_525, AYCbCr48BT601_525, AYCbCr64BT601_525
export YCbCrA32BT601_525, YCbCrA40BT601_525, YCbCrA48BT601_525, YCbCrA64BT601_525

export fullrange, limitedrange
export luma, chroma_u, chroma_v, chroma_b, chroma_r, chroma_g, chroma_o

export rgb_to_yuv, srgb_to_yuv
export yuv_to_rgb, yuv_to_srgb

abstract type AbstractYUV{T} <: Color{T,3} end
abstract type AbstractAYUV{C<:AbstractYUV,T} <: AlphaColor{C,T,4} end
abstract type AbstractYUVA{C<:AbstractYUV,T} <: ColorAlpha{C,T,4} end
const TransparentYUV{C<:AbstractYUV,T} = TransparentColor{C,T,4}
const AbstractYUVColorant{T} = Union{
    AbstractYUV{T},
    TransparentYUV{C,T} where {C<:AbstractYUV},
}

# "Y" is too generic a name, therefore, we name it "Luma".
abstract type AbstractLuma{T} <: AbstractGray{T} end
abstract type AbstractALuma{C<:AbstractLuma,T} <: AlphaColor{C,T,2} end
abstract type AbstractLumaA{C<:AbstractLuma,T} <: ColorAlpha{C,T,2} end
const TransparentLuma{C<:AbstractLuma,T} = TransparentColor{C,T,2}
const AbstractLumaColorant{T} = Union{
    AbstractLuma{T},
    TransparentLuma{C,T} where {C<:AbstractLuma},
}

const AbstractYUVLumaColorant{T} = Union{
    AbstractYUVColorant{T},
    AbstractLumaColorant{T},
}

const AbstractRGBColorant{T} = Union{
    AbstractRGB{T},
    TransparentRGB{C,T} where {C<:AbstractRGB},
}

"""
    AbstractYUV{T} <: Color{T,3}

An abstract type for opaque YUV-like colors.
"""
AbstractYUV

"""
    TransparentYUV{C<:AbstractYUV,T} = TransparentColor{C,T,4}

An alias of abstract type `TransparentColor` for transparent YUV-like colors.
"""
TransparentYUV

"""
    Cicp{CP,TC,MC,FR}

Coding-independent code points for video signal type identification.
The parameters ColourPrimaries, TransferCharacteristics, MatrixCoefficients,
and VideoFullRangeFlag shall be encoded as specified in Recommendation ITU-T
H.273.

YUVColorTypes.jl uses CICP for internal implementation efficiency and It is not
intended to support all codes.

# Parameters
- `CP::UInt8`: ColourPrimaries
- `TC::UInt8`: TransferCharacteristics
- `MC::UInt8`: MatrixCoefficients
- `FR::UInt8`: VideoFullRangeFlag
"""
struct Cicp{CP,TC,MC,FR} end

const CicpCP{CP,TC,MC,FR} = Cicp{CP,TC,MC,FR}
const CicpTC{TC,CP,MC,FR} = Cicp{CP,TC,MC,FR}
const CicpMC{MC,CP,TC,FR} = Cicp{CP,TC,MC,FR}
const CicpFR{FR,CP,TC,MC} = Cicp{CP,TC,MC,FR}

cicp_cp(::Type{C}) where {CP,C<:CicpCP{CP}} = CP::UInt8
cicp_tc(::Type{C}) where {TC,C<:CicpTC{TC}} = TC::UInt8
cicp_mc(::Type{C}) where {MC,C<:CicpMC{MC}} = MC::UInt8
cicp_fr(::Type{C}) where {FR,C<:CicpFR{FR}} = FR::UInt8

cicp_type(::Type) = Cicp
cicp_type(::Type{C}) where {C<:AbstractRGB} = Cicp{0x1,0xd,0x0,0x1}


"""
    YUV{T,P,U,R,D} <: AbsrtractYUV{T}

- `T`: component type
- `P`: symbol of profile
- `U`: unsigned chroma components if `true`
- `R`: full range if `true`
- `D`: bit-depth

See also [`AYUV`](@ref) and [`YUVA`](@ref) for transparent versions,
and [`Luma`](@ref) for the single Y component version.
"""
struct YUV{T,P,U,R,D} <: AbstractYUV{T}
    y::T
    u::T
    v::T
    function YUV{T,P,U,R,D}(y, u, v) where {T,P,U,R,D}
        C = YUV{T,P,U,R,D}
        return new{T,P,U,R,D}(
            encode_luma(C, y),
            encode_chroma(C, u),
            encode_chroma(C, v),
        )
    end
end

"""
    AYUV{T,P,U,R,D} <: AbstractAYUV{YUV{T,P,U,R,D},T}
"""
struct AYUV{T,P,U,R,D} <: AbstractAYUV{YUV{T,P,U,R,D},T}
    alpha::T
    y::T
    u::T
    v::T
    function AYUV{T,P,U,R,D}(y, u, v, alpha) where {T,P,U,R,D}
        C = YUV{T,P,U,R,D}
        return new{T,P,U,R,D}(
            encode_alpha(C, alpha),
            encode_luma(C, y),
            encode_chroma(C, u),
            encode_chroma(C, v),
        )
    end
end

"""
    YUVA{T,P,U,R,D} <: AbstractYUVA{YUV{T,P,U,R,D},T}
"""
struct YUVA{T,P,U,R,D} <: AbstractYUVA{YUV{T,P,U,R,D},T}
    y::T
    u::T
    v::T
    alpha::T
    function YUVA{T,P,U,R,D}(y, u, v, alpha) where {T,P,U,R,D}
        C = YUV{T,P,U,R,D}
        return new{T,P,U,R,D}(
            encode_luma(C, y),
            encode_chroma(C, u),
            encode_chroma(C, v),
            encode_alpha(C, alpha),
        )
    end
end

"""
    Luma{T,P,U,R,D} <: AbstractLuma{T}

The single Y component, i.e. grayscale version of a YUV-like color.
"""
struct Luma{T,P,U,R,D} <: AbstractLuma{T}
    y::T
    function Luma{T,P,U,R,D}(y::Real) where {T,P,U,R,D}
        return new{T,P,U,R,D}(
            encode_luma(Luma{T,P,U,R,D}, y),
        )
    end
end

"""
    ALuma{T,P,U,R,D} <: AbstractALuma{Luma{T,P,U,R,D},T}
"""
struct ALuma{T,P,U,R,D} <: AbstractALuma{Luma{T,P,U,R,D},T}
    alpha::T
    y::T
    function ALuma{T,P,U,R,D}(y::Real, alpha::Real) where {T,P,U,R,D}
        return new{T,P,U,R,D}(
            encode_luma(Luma{T,P,U,R,D}, y),
            encode_alpha(Luma{T,P,U,R,D}, 0x1),
        )
    end
end

"""
    LumaA{T,P,U,R,DR,} <: AbstractLumaA{YUV{T,P,U,R,D},T}
"""
struct LumaA{T,P,U,R,D} <: AbstractLumaA{YUV{T,P,U,R,D},T}
    y::T
    alpha::T
    function LumaA{T,P,U,R,D}(y::Real, alpha::Real) where {T,P,U,R,D}
        return new{T,P,U,R,D}(
            encode_alpha(Luma{T,P,U,R,D}, alpha),
            encode_luma(Luma{T,P,U,R,D}, y),
        )
    end
end

const YUVColorant{T,P,U,R,D} = Union{
    YUV{T,P,U,R,D},
    AYUV{T,P,U,R,D},
    YUVA{T,P,U,R,D},
}

const LumaColorant{T,P,U,R,D} = Union{
    Luma{T,P,U,R,D},
    ALuma{T,P,U,R,D},
    LumaA{T,P,U,R,D},
}

const YUVLumaColorant{T,P,U,R,D} = Union{
    YUVColorant{T,P,U,R,D},
    Luma{T,P,U,R,D},
}

const YUVT{P,U,R,D} = YUV{T,P,U,R,D} where {T}
const AYUVT{P,U,R,D} = AYUV{T,P,U,R,D} where {T}
const YUVAT{P,U,R,D} = YUVA{T,P,U,R,D} where {T}

const LumaT{P,U,R,D} = Luma{T,P,U,R,D} where {T}
const ALumaT{P,U,R,D} = ALuma{T,P,U,R,D} where {T}
const LumaAT{P,U,R,D} = LumaA{T,P,U,R,D} where {T}

const YUVColorantT{P,U,R,D} = YUVColorant{T,P,U,R,D} where {T}
const YUVLumaColorantT{P,U,R,D} = YUVLumaColorant{T,P,U,R,D} where {T}


# type (alias) definitions
include("bt601.jl")


const YCbCrColorant{T,U,R,D} = Union{
    YUVColorant{T,:BT601_625,U,R,D},
    YUVColorant{T,:BT601_525,U,R,D},
}

const YCgCoColorant{T,U,R,D} = Union{
}

include("promote.jl")
include("construct.jl")
include("traits.jl")

include("ranges.jl")
include("matrices.jl")
include("primaries.jl")
include("curves.jl")

include("convert.jl")
include("show.jl")

end # module
