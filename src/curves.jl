"""
    eotf(C) -> function

Return the display EOTF (Electro-Optical Transfer Function) for color type `C`.

See also [`eotf`](@ref)
"""
eotf(::Type{C}) where {C<:TransparentColor} = eotf(color_type(C))
eotf(::Type{C}) where {C<:Color} = identity


"""
    ieotf(::Type{C})

Return the inverse EOTF (Electro-Optical Transfer Function) for color type `C`.
This is sometimes referred to as OETF (Opto-Electronic Transfer Function), but
OETF is essentially a camera-side characteristic and is distinct from a
display-side characteristic.

See also [`eotf`](@ref)
"""
ieotf(::Type{C}) where {C<:TransparentColor} = ieotf(color_type(C))
ieotf(::Type{C}) where {C<:Color} = identity

#-------------------------------------------------------------------------------
# sRGB
#-------------------------------------------------------------------------------

function eotf(::Type{C}) where {T,C<:AbstractRGB{T}}
    F = promote_type(T, Float32)
    return (v::T) ->
        v < F(0.04045) ? T(F(1 / 12.92) * v) : T((F(1 / 1.055) * (F(v) + F(0.055)))^F(2.4))
end

function ieotf(::Type{C}) where {T,C<:AbstractRGB{T}}
    F = promote_type(T, Float32)
    return (v::T) ->
        v < F(0.0031308) ? T(F(12.92) * v) : T(F(1.055) * F(v)^(1 / 2.4) - F(0.055))
end

#-------------------------------------------------------------------------------
# BT.601
#-------------------------------------------------------------------------------

# BT.601 does not define the EOTF.
# Here we refer to the definition of the OETF at source.

function eotf(::Type{C}) where {T,C<:Union{YUV{T,:BT601_625},YUV{T,:BT601_525}}}
    F = promote_type(T, Float32)
    return (v::T) ->
        v < F(0.081) ? T(F(1 / 4.5) * v) : T((F(1/1.099) * (F(v) + F(0.099)))^(1 / 0.45))
end

function ieotf(::Type{C}) where {T,C<:Union{YUV{T,:BT601_625},YUV{T,:BT601_525}}}
    F = promote_type(T, Float32)
    return (v::T) ->
        v < F(0.018) ? T(F(4.5) * v) : T(F(1.099) * F(v)^F(0.45) - F(0.099))
end
