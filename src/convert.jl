
"""
    yuv_to_rgb(C, yuv::AbstractYUVColorant) -> C

Convert a YUV color to an RGB color.
The color primaries, whitepoint and gamma are depends on the YUV color type.
If you need sRGB colors, use `yuv_to_srgb` or simply use `convert` or RGB
constructors.

See also [`yuv_to_srgb`](@ref) and [`rgb_to_yuv`](@ref) .
"""
function yuv_to_rgb(::Type{C}, yuv::AbstractYUVColorant) where {C<:AbstractRGBColorant}
    rgb = yuv_to_rgb(color_type(C), color_type(yuv))
    return C<:TransparentRGB ? C(rgb, alpha(yuv)) : rgb
end

function yuv_to_rgb(::Type{C}, yuv::AbstractYUV) where {C<:AbstractRGB}
    nyuv = scale_yuv(yuv)
    rgb = mul(mat_yuv_to_rgb(C), nyuv)
    return C(rgb...)
end

"""
    yuv_to_srgb(C, yuv::AbstractYUVColorant) -> C

Convert a YUV color to an sRGB color.

See also [`yuv_to_rgb`](@ref) and [`srgb_to_yuv`](@ref).
"""
function yuv_to_srgb(::Type{C}, yuv::AbstractYUVColorant) where {C<:AbstractRGBColorant}
    rgb = yuv_to_srgb(color_type(C), color_type(yuv))
    return C <: TransparentRGB ? C(rgb, alpha(yuv)) : rgb
end

function yuv_to_srgb(::Type{C}, yuv::AbstractYUV) where {C<:AbstractRGB}
    rgb = yuv_to_rgb(C, yuv)
    lrgb = eotf(C).((red(rgb), green(rgb), blue(rgb)))
    if with_d65(C)
        r2sr = mat_rgb_to_srgb(C)
        rgb = mul(r2sr, lrgb)
    else
        error("not yet implemented")
    end
    return rgb
end

"""
    rgb_to_yuv(C, rgb::AbstractRGB) -> C
    rgb_to_yuv(C, argb::TransparentRGB) -> C

Convert an RGB color to a YUV color.
The color primaries, whitepoint and gamma are depends on the YUV color type.
If you need sRGB colors, use `yuv_to_srgb` or simply use `convert` or RGB
constructors.

See also [`srgb_to_yuv`](@ref) and [`yuv_to_rgb`](@ref).
"""
function rgb_to_yuv(::Type{C}, rgb::AbstractRGBColorant) where {C<:AbstractYUVColorant}
    yuv = rgb_to_yuv(color_type(C), color_type(rgb))
    return C <: TransparentYUV ? C(yuv, alpha(rgb)) : yuv
end

function rgb_to_yuv(::Type{C}, rgb::AbstractRGB) where {C<:AbstractYUV}
    nyuv = mul(mat_rgb_to_yuv(C), (red(rgb), green(rgb), blue(rgb)))
    yuv = scale_yuv(C(nyuv...))
    return C <: TransparentYUV ? C(yuv, alpha(rgb)) : yuv
end

"""
    srgb_to_yuv(C, rgb::AbstractRGB) -> C
    srgb_to_yuv(C, argb::TransparentRGB) -> C

Convert an sRGB color to a YUV color.

See also [`rgb_to_yuv`](@ref) and [`yuv_to_srgb`](@ref).
"""
function srgb_to_yuv(::Type{C}, rgb::TransparentRGB) where {C<:AbstractYUVColorant}
    yuv = srgb_to_yuv(C, color_type(rgb))
    return C <: TransparentYUV ? C(yuv, alpha(rgb)) : yuv
end

function srgb_to_yuv(::Type{C}, rgb::AbstractRGB) where {C<:AbstractYUV}
    lrgb = eotf(typeof(rgb)).((red(rgb), green(rgb), blue(rgb)))
    if with_d65(C)
        sr2r = mat_srgb_to_rgb(C)
        lrgb = mul(sr2r, lrgb)
    else
        error("not yet implemented")
    end
    rgb = ieotf(C).(lrgb)
    return rgb_to_yuv(C, RGB(rgb...))
end


function yuv_to_xyz(::Type{C}, yuv::AbstractYUVColorant) where {C<:Union{XYZ,AXYZ,XYZA}}
    xyz = xyz_to_yuv(color_type(C), color_type(yuv))
    return C <: TransparentColor ? XYZ(xyz..., alpha(yuv)) : xyz
end

function yuv_to_xyz(::Type{XYZ}, yuv::AbstractYUV)
    return XYZ()
end



function xyz_to_yuv(::Type{C}, xyz::Cs) where {C<:AbstractYUVColorant,Cs<:Union{XYZ,AXYZ,XYZA}}
    yuv = xyz_to_yuv(color_type(C), color_type(xyz))
    return C <: TransparentYUV ? C(yuv, alpha(xyz)) : yuv
end

function xyz_to_yuv(::Type{C}, xyz::XYZ) where {C<:AbstractYUV}
    return C()
end