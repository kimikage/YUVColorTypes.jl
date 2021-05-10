
function luma_coefs(::Type{C}) where {C<:Union{YUVT{:BT601_625},YUVT{:BT601_525}}}
    (0.299, 0.587, 0.11400000000000005) # 5e-17 for reducing errors
end

function mat_rgb_to_yuv(::Type{C}) where {C<:AbstractYUV}
    _mat_rgb_to_yuv(C)
end

# fallback
function _mat_rgb_to_yuv(::Type{C}) where {T,C<:AbstractYUV{T}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    kr, kg, kb = luma_coefs(C)
    return (
        F.((kr, kg, kb)),
        F.((-kr, -kg, 1 - kb) ./ ((1 - kb) * 2)),
        F.((1 - kr, -kg, -kb) ./ ((1 - kr) * 2)),
    )
end


function mat_yuv_to_rgb(::Type{C}) where {C<:AbstractYUV}
    _mat_yuv_to_rgb(C)
end

function _mat_yuv_to_rgb(::Type{C}) where {T,C<:AbstractYUV{T}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return _map(F, _inv(_mat_rgb_to_yuv(C)))
end

function mat_rgb_to_yuv(::Type{C}) where {T,C<:Union{YUV{T,:BT601_625},YUV{T,:BT601_525}}}
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
