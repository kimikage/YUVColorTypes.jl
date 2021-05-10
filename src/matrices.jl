"""
    luma_coefs(C) -> NTuple{3, Float64}
"""
luma_coefs(::Type{C}) where {C<:TransparentColor} = luma_coefs(color_type(C))
luma_coefs(::Type{C}) where {C} = luma_coefs(cicp_type(C))

"""
    mat_rgb_to_yuv(C) -> NTuple{3, NTuple{3, F}}
"""
mat_rgb_to_yuv(::Type{C}) where {C<:TransparentColor} = mat_rgb_to_yuv(color_type(C))
mat_rgb_to_yuv(::Type{C}) where {T,C<:AbstractYUV{T}} = mat_rgb_to_yuv(T, cicp_type(C))
mat_rgb_to_yuv(::Type{T}, ::Type{C}) where {T,C<:Cicp} = _mat_rgb_to_yuv(T, C)

# fallback
_mat_rgb_to_yuv(::Type{C}) where {T,C<:AbstractYUV{T}} = _mat_rgb_to_yuv(T, cicp_type(C))
function _mat_rgb_to_yuv(::Type{T}, ::Type{C}) where {T,C<:Cicp}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    kr, kg, kb = luma_coefs(C)
    return (
        F.((kr, kg, kb)),
        F.((-kr, -kg, 1 - kb) ./ ((1 - kb) * 2)),
        F.((1 - kr, -kg, -kb) ./ ((1 - kr) * 2)),
    )
end

"""
    mat_yuv_to_rgb(C) -> NTuple{3, NTuple{3, F}}
"""
mat_yuv_to_rgb(::Type{C}) where {C<:TransparentColor} = mat_yuv_to_rgb(color_type(C))
mat_yuv_to_rgb(::Type{C}) where {T,C<:AbstractYUV{T}} = mat_yuv_to_rgb(T, cicp_type(C))
mat_yuv_to_rgb(::Type{T}, ::Type{C}) where {T,C<:Cicp} = _mat_yuv_to_rgb(T, C)

# fallback
_mat_yuv_to_rgb(::Type{C}) where {T,C<:AbstractYUV{T}} = _mat_yuv_to_rgb(T, cicp_type(C))
function _mat_yuv_to_rgb(::Type{T}, ::Type{C}) where {T,C<:Cicp}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return _map(F, _inv(_mat_rgb_to_yuv(F, C)))
end

#-------------------------------------------------------------------------------
# CICP MatrixCoefficients 5 and 6
#-------------------------------------------------------------------------------
function luma_coefs(::Type{C}) where {C<:Union{CicpMC{0x5}, CicpMC{0x6}}}
    (0.299, 0.587, 0.11400000000000005) # Kb = Float64(1 - (big(0.299) + big(0.587)))
end

function mat_rgb_to_yuv(::Type{T}, ::Type{C}) where {T,C<:Union{CicpMC{0x5}, CicpMC{0x6}}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((0.299, 0.587, 0.11400000000000005)),
        F.((-0.16873589164785555, -0.3312641083521444, 0.5)),
        F.((0.5, -0.4186875891583452, -0.0813124108416548)),
    )
end

function mat_yuv_to_rgb(::Type{C}) where {T,C<:Union{YUV{T,:BT601_625},YUV{T,:BT601_525}}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((1, 0, 1.402)),
        F.((1, -0.34413628620102227, -0.7141362862010222)),
        F.((1, 1.772, 0)),
    )
end
