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


# TODO: more comprehensive `ccolor` support
function ColorTypes.ccolor(::Type{Cd}, ::Type{Cs}) where {Td,Cd<:YUV{Td},Ts,Ps,Cs<:YUV{Ts,Ps}}
    YUV{Td,Ps}
end

function ColorTypes.ccolor(::Type{Cd}, ::Type{Cs}) where {Td,Cd<:YUV{Td},Ts,Ps,Us,Cs<:YUV{Ts,Ps,Us}}
    YUV{Td,Ps,Us}
end

function ColorTypes.ccolor(::Type{Cd}, ::Type{Cs}) where {Td,Cd<:YUV{Td},Ts,Ps,Us,Ds,Cs<:YUV{Ts,Ps,Us,Ds}}
    YUV{Td,Ps,Us,Ds}
end
