
profile_symbol(::Type{C}) where {P,C<:YUVLumaColorantT{P}} = P

alpha(::C) where {T,C<:YUV{T}} = oneunit(T)

function alpha(c::C) where {T,P,U,R,D,C<:Union{AYUV{T,P,U,R,D}, YUVA{T,P,U,R,D}}}
    c.alpha
end
function alpha(c::C) where {T<:Integer,P,U,R,D,C <:YUVLumaColorant{T,P,U,R,D}}
    f = D === -1 ? 8 : D
    if C <: TransparentColor
        return reinterpret(Normed{unsigned(T),f}, unsigned(c.alpha))
    else
        return oneunit(Normed{unsigned(T),f})
    end
end

"""
    luma(c)

Return the luma component of a YUV-like color.
To avoid confusion, this function does not support `ColorTypes.YCbCr` and
its variants, which are not under the `AbstractYUV`.
"""
luma(c::AbstractYUVColorant) = luma(color_type(c))
luma(c::AbstractYUV) = comp1(c)

"""
    chroma_u(c)

Return the first chroma component of a YUV-like color.
"""
chroma_u(c::AbstractYUVColorant) = chroma_u(color_type(c))
chroma_u(c::AbstractYUV) = comp2(c)

"""
    chroma_v(c)

Return the second chroma component of a YUV-like color.
"""
chroma_v(c::AbstractYUVColorant) = chroma_v(color_type(c))
chroma_v(c::AbstractYUV) = comp3(c)

"""
    chroma_b(c)

Return the Cb component of a YCbCr color.
For general YUV-like colors, use [`chroma_u`](@ref).
To avoid confusion, this function does not support `ColorTypes.YCbCr` and
its variants, which are not under the `AbstractYUV`.
"""
chroma_b(c::AbstractYUVColorant) = chroma_u(color_type(c))
chroma_b(c::C) where {C<:YCbCrColorant} = chroma_u(c)

"""
    chroma_r(c)

Return the Cr component of a YCbCr color.
For general YUV-like colors, use [`chroma_v`](@ref).
To avoid confusion, this function does not support `ColorTypes.YCbCr` and
its variants, which are not under the `AbstractYUV`.
"""
chroma_r(c::AbstractYUVColorant) = chroma_v(color_type(c))
chroma_r(c::C) where {C<:YCbCrColorant} = chroma_v(c)

"""
    chroma_g(c)

Return the Cg component of a YCgCo color.
For general YUV-like colors, use [`chroma_u`](@ref).
"""
chroma_g(c::AbstractYUVColorant) = chroma_u(color_type(c))
chroma_g(c::C) where {C<:YCgCoColorant} = chroma_u(c)

"""
    chroma_o(c)

Return the Co component of an YCgCo color.
For general YUV-like colors, use [`chroma_v`](@ref).
"""
chroma_o(c::AbstractYUVColorant) = chroma_v(color_type(c))
chroma_o(c::C) where {C<:YCgCoColorant} = chroma_v(c)

# TODO: more comprehensive `base_color_type` support
function ColorTypes.base_color_type(::Type{C}) where {T,P,U,R,C<:YUVColorant{T,P,U,R}}
    return YUVT{P,U,R}
end

function ColorTypes.base_color_type(::Type{C}) where {T,P,U,R,D,C<:YUVColorant{T,P,U,R,D}}
    return YUVT{P,U,R,D}
end

function ColorTypes.base_color_type(::Type{C}) where {C<:YUVColorantT}
    return color_type(C)
end

# TODO: more comprehensive `ccolor` support
function ColorTypes.ccolor(::Type{Cd}, ::Type{Cs}) where {Td,Cd<:YUV{Td},Ts,Ps,Cs<:YUVColorant{Ts,Ps}}
    YUV{Td,Ps}
end

function ColorTypes.ccolor(::Type{Cd}, ::Type{Cs}) where {Td,Cd<:YUV{Td},Ts,Ps,Us,Rs,Cs<:YUVColorant{Ts,Ps,Us,Rs}}
    YUV{Td,Ps,Us,Rs}
end

function ColorTypes.ccolor(::Type{Cd}, ::Type{Cs}) where {Td,Cd<:YUV{Td},Ts,Ps,Us,Rs,Ds,Cs<:YUVColorant{Ts,Ps,Us,Rs,Ds}}
    YUV{Td,Ps,Us,Rs,Ds}
end

function ColorTypes.ccolor(::Type{Cd}, ::Type{Cs}) where {Cd<:YUV,Ts,Ps,Cs<:YUVColorant{Ts,Ps}}
    YUV{Ts,Ps}
end

function ColorTypes.ccolor(::Type{Cd}, ::Type{Cs}) where {Cd<:YUV,Ts,Ps,Us,Rs,Cs<:YUVColorant{Ts,Ps,Us,Rs}}
    YUV{Ts,Ps,Us,Rs}
end

function ColorTypes.ccolor(::Type{Cd}, ::Type{Cs}) where {Cd<:YUV,Ts,Ps,Us,Rs,Ds,Cs<:YUVColorant{Ts,Ps,Us,Rs,Ds}}
    YUV{Ts,Ps,Us,Rs,Ds}
end

alphacolor(::Type{C}) where {P,U,R,D,C<:YUVT{P,U,R,D}} = AYUVT{P,U,R,D}
coloralpha(::Type{C}) where {P,U,R,D,C<:YUVT{P,U,R,D}} = YUVAT{P,U,R,D}
alphacolor(::Type{C}) where {T,P,U,R,D,C<:YUV{T,P,U,R,D}} = AYUV{T,P,U,R,D}
coloralpha(::Type{C}) where {T,P,U,R,D,C<:YUV{T,P,U,R,D}} = YUVA{T,P,U,R,D}

"""
    fullrange(C)

Return the full-range variant of YUV-like color type `C <: YUVLumaColorant`.

See also `limitedrange`.
"""
function fullrange(::Type{C}) where {P,U,R,C<:YUVT{P,U,R}}
    YUVT{P,U,true}
end
function fullrange(::Type{C}) where {P,U,R,D,C<:YUVT{P,U,R,D}}
    YUVT{P,U,true,D}
end
function fullrange(::Type{C}) where {T,P,U,R,D, C<:YUV{T,P,U,R,D}}
    YUV{T,P,U,true,D}
end

function fullrange(::Type{C}) where {T,P,U,R,D,C<:YUVColorant{T,P,U,R,D}}
    Co = fullrange(color_type(C))
    return C <: AYUV ? alphacolor(Co) : coloralpha(Co)
end

function fullrange(::Type{C}) where {T,P,U,R,D,C<:Luma{T,P,U,R,D}}
    Luma{T,P,U,true,D}
end

function fullrange(::Type{C}) where {T,P,U,R,D,C<:LumaColorant{T,P,U,R,D}}
    C <: AYUV ? ALuma{T,P,U,true,D} : LumaA{T,P,U,true,D}
end

"""
    limitedrange(C)

Return the limited-range variant of YUV-like color type `C <: YUVLumaColorant`.

See also `fullrange`.
"""
limitedrange(::Type{C}) where {P,U,R,C<:YUVT{P,U,R}} = YUVT{P,U,false}
limitedrange(::Type{C}) where {P,U,R,D,C<:YUVT{P,U,R,D}} = YUVT{P,U,false,D}
function limitedrange(::Type{C}) where {T,P,U,R,D,C<:YUV{T,P,U,R,D}}
    YUV{T,P,U,false,D}
end
function limitedrange(::Type{C}) where {T,P,U,R,D,C<:YUVColorant{T,P,U,R,D}}
    Co = limitedrange(color_type(C))
    return C <: AYUV ? alphacolor(Co) : coloralpha(Co)
end

function limitedrange(::Type{C}) where {T,P,U,R,D,C<:Luma{T,P,U,R,D}}
    Luma{T,P,U,false,D}
end

function limitedrange(::Type{C}) where {T,P,U,R,D,C<:LumaColorant{T,P,U,R,D}}
    C <: AYUV ? ALuma{T,P,U,false,D} : LumaA{T,P,U,false,D}
end
