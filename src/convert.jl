
function Base.convert(::Type{C}, yuv::AbstractYUVLumaColorant) where {C<:Union{AbstractRGB,TransparentRGB}}
    yuv_to_srgb(C, yuv)
end

function Base.convert(::Type{C}, yuv::Union{AbstractRGB,TransparentRGB}) where {C<:AbstractYUVLumaColorant}
    srgb_to_yuv(C, yuv)
end

function Base.convert(::Type{C}, yuv::AbstractYUVLumaColorant) where {C<:AbstractYUVLumaColorant}
    if C <: AbstractYUVColorant
        return yuv isa AbstractYUV ? yuv_to_yuv(C, yuv) : luma_to_yuv(C, yuv)
    else
        return yuv isa AbstractYUV ? yuv_to_luma(C, yuv) : luma_to_luma(C, yuv)
    end
end


function yuv_to_yuv(::Type{C}, yuv::AbstractYUVColorant) where {C<:AbstractYUVColorant}
    dyuv = yuv_to_yuv(color_type(C), color(yuv))
    return C <: TransparentYUV ? C(dyuv, alpha(yuv)) : dyuv
end

function yuv_to_yuv(::Type{C}, yuv::AbstractYUV) where {C<:AbstractYUV}
    xyz = yuv_to_xyz(XYZ, color(yuv))
    dyuv = xyz_to_yuv(color_type(C), xyz)
    return C <: TransparentYUV ? C(dyuv, alpha(yuv)) : dyuv
end

function yuv_to_yuv(::Type{C}, yuv::YUVT{P}) where {P,C<:YUVColorantT{P}}
    dyuv = convert_yuv_repr(C, yuv)
    return C <: TransparentYUV ? C(dyuv, alpha(yuv)) : dyuv
end

"""
    yuv_to_rgb(C, yuv::AbstractYUVColorant) -> C

Convert a YUV color to an RGB color.
The color primaries, whitepoint and gamma are depends on the YUV color type.
If you need sRGB colors, use `yuv_to_srgb` or simply use `convert` or RGB
constructors.

See also [`yuv_to_srgb`](@ref) and [`rgb_to_yuv`](@ref) .
"""
function yuv_to_rgb(::Type{C}, yuv::AbstractYUVColorant) where {C<:AbstractRGBColorant}
    rgb = yuv_to_rgb(color_type(C), color(yuv))
    return C <: TransparentRGB ? C(rgb, alpha(yuv)) : rgb
end

function yuv_to_rgb(::Type{C}, yuv::AbstractYUV) where {C<:AbstractRGB}
    nyuv = normalize_yuv(yuv)
    rgb = mul(mat_yuv_to_rgb(typeof(yuv)), nyuv)
    return C(clamp_rgb(C, rgb)...)
end

"""
    yuv_to_srgb(C, yuv::AbstractYUVColorant) -> C

Convert a YUV color to an sRGB color.

See also [`yuv_to_rgb`](@ref) and [`srgb_to_yuv`](@ref).
"""
function yuv_to_srgb(::Type{C}, yuv::AbstractYUVColorant) where {C<:AbstractRGBColorant}
    rgb = yuv_to_srgb(color_type(C), color(yuv))
    return C <: TransparentRGB ? C(rgb, alpha(yuv)) : rgb
end

function yuv_to_srgb(::Type{C}, yuv::AbstractYUV{T}) where {T,C<:AbstractRGB}
    Cyuv = ccolor(base_color_type(yuv), YUV{promote_type(T, Float32)})
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    rgb = yuv_to_rgb(RGB{F}, yuv)
    lrgb = eotf(Cyuv).((red(rgb), green(rgb), blue(rgb)))
    if has_d65_wp(Cyuv)
        r2sr = mat_rgb_to_srgb(Cyuv)
        lrgb = mul(r2sr, lrgb)
    else
        error("not yet implemented")
    end
    rgb = ieotf(RGB{F}).(lrgb)
    return C(clamp_rgb(C, rgb)...)
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
    yuv = rgb_to_yuv(color_type(C), color(rgb))
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
    yuv = srgb_to_yuv(C, color(rgb))
    return C <: TransparentYUV ? C(yuv, alpha(rgb)) : yuv
end

function srgb_to_yuv(::Type{C}, rgb::AbstractRGB) where {C<:AbstractYUV}
    return rgb_to_yuv(C, srgb_to_rgb(C, rgb))
end

function srgb_to_rgb(::Type{C}, rgb::TransparentRGB) where {C<:AbstractYUVColorant}
    yrgb = srgb_to_rgb(C, color(rgb))
    return C <: TransparentYUV ? C(yrgb, alpha(rgb)) : yrgb
end

function srgb_to_rgb(::Type{C}, rgb::AbstractRGB) where {C<:AbstractYUV}
    lrgb = eotf(typeof(rgb)).((red(rgb), green(rgb), blue(rgb)))
    if has_d65_wp(C)
        sr2r = mat_srgb_to_rgb(C)
        lrgb = mul(sr2r, lrgb)
    else
        error("not yet implemented") # TODO
    end
    rgb = ieotf(C).(lrgb)
    return RGB(rgb...)
end

function yuv_to_xyz(::Type{C}, yuv::AbstractYUVColorant) where {C<:Union{XYZ,AXYZ,XYZA}}
    xyz = xyz_to_yuv(color_type(C), color(yuv))
    return C <: TransparentColor ? XYZ(xyz..., alpha(yuv)) : xyz
end

function yuv_to_xyz(::Type{XYZ}, yuv::AbstractYUV)
    return XYZ() # FIXME
end



function xyz_to_yuv(::Type{C}, xyz::Cs) where {C<:AbstractYUVColorant,Cs<:Union{XYZ,AXYZ,XYZA}}
    yuv = xyz_to_yuv(color_type(C), color(xyz))
    return C <: TransparentYUV ? C(yuv, alpha(xyz)) : yuv
end

function xyz_to_yuv(::Type{C}, xyz::XYZ) where {C<:AbstractYUV}
    return C() # FIXME
end

clamp_rgb(::Type{C}, rgb) where {C<:AbstractRGB} = rgb
function clamp_rgb(::Type{C}, rgb) where {T<:FixedPoint,C<:AbstractRGB{T}}
    (clamp.(rgb[1], T), clamp.(rgb[2], T), clamp.(rgb[3], T))
end
