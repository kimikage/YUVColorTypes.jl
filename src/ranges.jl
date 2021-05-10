# The `gamutmin` and `gamutmax` are just for `rand` convenience.

scaling_coefs_v(::Type{C}) where {C<:AbstractYUV} = scaling_coefs_u(C)

scaling_coefs_y(::Type{<:Union{YUVT{:BT601_625},YUVT{:BT601_525}}}) = (219.0, 16.0)
scaling_coefs_u(::Type{<:Union{YUVT{:BT601_625},YUVT{:BT601_525}}}) = (224.0, 128.0)

ColorTypes.gamutmin(::Type{<:Union{YUVT{:BT601_625},YUVT{:BT601_525}}}) = (16, 16, 16)
ColorTypes.gamutmax(::Type{<:Union{YUVT{:BT601_625},YUVT{:BT601_525}}}) = (235, 240, 240) # FIXME: use sRGB

function normalize_yuv(yuv::C) where {T,C<:AbstractYUV{T}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    ys, yofs = scaling_coefs_y(C)
    us, uofs = scaling_coefs_u(C)
    vs, vofs = scaling_coefs_v(C)
    return (
        (F(luma(yuv)) - F(yofs)) * F(1 / ys),
        (F(chroma_u(yuv)) - F(uofs)) * F(1 / us),
        (F(chroma_v(yuv)) - F(vofs)) * F(1 / vs),
    )
end

function scale_yuv(yuv::C) where {T,C<:AbstractYUV{T}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    ys, yofs = F.(scaling_coefs_y(C))
    us, uofs = F.(scaling_coefs_u(C))
    vs, vofs = F.(scaling_coefs_v(C))
    return C(
        muladd(F(luma(yuv)), ys, yofs),
        muladd(F(chroma_u(yuv)), us, uofs),
        muladd(F(chroma_v(yuv)), vs, vofs),
    )
end