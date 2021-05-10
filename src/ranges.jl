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
    d = scaling_coef_depth_s(C)
    return (
        (F(luma(yuv)) * d - F(yofs)) * F(1 / ys),
        (F(chroma_u(yuv)) * d - F(uofs)) * F(1 / us),
        (F(chroma_v(yuv)) * d - F(vofs)) * F(1 / vs),
    )
end

function scale_yuv(yuv::C) where {T,C<:AbstractYUV{T}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    ys, yofs = F.(scaling_coefs_y(C))
    us, uofs = F.(scaling_coefs_u(C))
    vs, vofs = F.(scaling_coefs_v(C))
    d = scaling_coef_depth_s(C)
    return (
        muladd(F(luma(yuv)) * d, ys, yofs),
        muladd(F(chroma_u(yuv)) * d, us, uofs),
        muladd(F(chroma_v(yuv)) * d, vs, vofs),
    )
end

scaling_coef_depth_s(::Type{C}) where {C<:YUV} = true
function scaling_coef_depth_s(::Type{C}) where {T,P,U,R,D,C<:YUV{T,P,U,R,D}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    D === -1 && return F(1.0)
    D === 8 && return F(0x1p0)
    D === 9 && return F(0x1p-1)
    D === 10 && return F(0x1p-2)
    D === 11 && return F(0x1p-3)
    D === 12 && return F(0x1p-4)
    D === 13 && return F(0x1p-5)
    D === 14 && return F(0x1p-6)
    D === 15 && return F(0x1p-7)
    D === 16 && return F(0x1p-8)
    return F(2.0^(D - 8))
end

scaling_coef_depth_e(::Type{C}) where {C<:YUV} = true
function scaling_coef_depth_e(::Type{C}) where {T,P,U,R,D,C<:YUV{T,P,U,R,D}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    D === -1 && return F(1.0)
    D === 8 && return F(0x1p0)
    D === 9 && return F(0x1p1)
    D === 10 && return F(0x1p2)
    D === 11 && return F(0x1p3)
    D === 12 && return F(0x1p4)
    D === 13 && return F(0x1p5)
    D === 14 && return F(0x1p6)
    D === 15 && return F(0x1p7)
    D === 16 && return F(0x1p8)
    return F(2.0^(8 - D))
end