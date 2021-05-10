"""
    primary_r(C) -> xyY{Float64}

Return the red primary of color type `C` in `xyY` where Y is `1.0`.
"""
primary_r(::Type{C}) where {C<:TransparentColor} = primary_r(color_type(C))


"""
    primary_g(C) -> xyY{Float64}

Return the green primary of color type `C` in `xyY` where Y is `1.0`.
"""
primary_g(::Type{C}) where {C<:TransparentColor} = primary_g(color_type(C))


"""
    primary_b(C) -> xyY{Float64}

Return the blue primary of color type `C` in `xyY` where Y is `1.0`.
"""
primary_b(::Type{C}) where {C<:TransparentColor} = primary_b(color_type(C))

"""
    whitepoint(C) -> xyY{Float64}

Return the whitepoint of color type `C` in `xyY.
"""
whitepoint(::Type{C}) where {C<:TransparentColor} = whitepoint(color_type(C))

with_d65(::Type{C}) where {C<:Colorant} = false

function with_d65(::Type{C}) where {
    C<:Union{
        YUVLumaColorantT{:BT601_625},
        YUVLumaColorantT{:BT601_525},
    }}
    return true
end

xy(x, y) = xyY(x, y, 1.0)

# Colors.jl defines WP_D65 in XYZ and There are rounding errors between the two.
const XY_D65 = xy(0.3127, 0.3290)

"""
    mat_rgb_to_xyz(C{T}) -> NTuple{3,NTuple{3,F}}

Return the conversion matrix from CIE XYZ to *linear* RGB based on `C` primaries.
"""
mat_rgb_to_xyz(::Type{C}) where {C<:TransparentColor} = mat_rgb_to_xyz(color_type(C))

"""
    mat_xyz_to_rgb(C{T}) -> NTuple{3,NTuple{3,F}}

Return the conversion matrix from *linear* RGB based on `C` primaries to CIE XYZ.
"""
mat_xyz_to_rgb(::Type{C}) where {C<:TransparentColor} = mat_xyz_to_rgb(color_type(C))

"""
    mat_rgb_to_srgb(C{T}) ->NTuple{3,NTuple{3,F}}

Return the conversion matrix from *linear* RGB based on `C` primaries to *linear* sRGB.
"""
mat_rgb_to_srgb(::Type{C}) where {C<:TransparentYUV} = mat_rgb_to_srgb(color_type(C))

"""
    mat_srgb_to_rgb(C{T}) -> NTuple{3,NTuple{3,F}}

Return the conversion matrix from *linear* sRGB to *linear* RGB based on `C` primaries.
"""
mat_srgb_to_rgb(::Type{C}) where {C<:TransparentYUV} = mat_srgb_to_rgb(color_type(C))


mat_rgb_to_xyz(::Type{C}) where {C<:Color} = _mat_rgb_to_xyz(C)

# fallback
function _mat_rgb_to_xyz(::Type{C}) where {T,C<:Color{T}}
    pr, pg, pb = primary_r(C), primary_g(C), primary_b(C)
    wp = whitepoint(C)
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    z(c::xyY) = 1 - c.x - c.y # Y == 1
    m_prim = (
        F.((pr.x, pg.x, pb.x)),
        F.((pr.y, pg.y, pb.y)),
        F.((z(pr), z(pg), z(pb)))
    )
    wx = F(wp.x) / F(wp.y)
    wy = F(1)
    wz = F(1 - wp.x - wp.y) / F(wp.y)
    s = mul(_map(F, _inv(m_prim)), (wx, wy, wz))
    return Tuple(F.(v .* s) for v in m_prim)
end

mat_xyz_to_rgb(::Type{C}) where {C<:Color} = _mat_xyz_to_rgb(C)

# fallback
function _mat_xyz_to_rgb(::Type{C}) where {T,C<:Color{T}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    mat = _inv(_mat_rgb_to_xyz(C))
    return Tuple(F.(v) for v in mat)
end

mat_rgb_to_srgb(::Type{C}) where {C<:AbstractYUV} = _mat_rgb_to_srgb(C)

# fallback
function _mat_rgb_to_srgb(::Type{C}) where {T,C<:Color{T}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    src = _mat_rgb_to_xyz(C)
    dest = _mat_xyz_to_rgb(RGB{F})
    return mul(dest, src)
end

function mat_srgb_to_rgb(::Type{C}) where {C<:AbstractYUV}
    return _mat_srgb_to_rgb(C)
end

# fallback
function _mat_srgb_to_rgb(::Type{C}) where {T,C<:Color{T}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    src = _mat_rgb_to_xyz(RGB{F})
    if !with_d65(C)
        error("whitepoint conversion is not implemented")
    end
    dest = _mat_xyz_to_rgb(C)
    return mul(dest, src)
end

#-------------------------------------------------------------------------------
# sRGB (default)
#-------------------------------------------------------------------------------
primary_r(::Type{C}) where {C<:Color} = xy(0.64, 0.33)
primary_g(::Type{C}) where {C<:Color} = xy(0.30, 0.60)
primary_b(::Type{C}) where {C<:Color} = xy(0.15, 0.06)
whitepoint(::Type{C}) where {C<:Color} = XY_D65

function mat_rgb_to_xyz(::Type{C}) where {T,C<:AbstractRGB{T}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((0.41239079926595934, 0.357584339383878, 0.18048078840183426)),
        F.((0.2126390058715103, 0.715168678767756, 0.07219231536073371)),
        F.((0.019330818715591825, 0.11919477979462598, 0.9505321522496606)),
    )
end

function mat_xyz_to_rgb(::Type{C}) where {T,C<:AbstractRGB{T}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((3.2409699419045226, -1.537383177570094, -0.4986107602930034)),
        F.((-0.9692436362808797, 1.8759675015077204, 0.04155505740717561)),
        F.((0.055630079696993656, -0.20397695888897655, 1.0569715142428786)),
    )
end

#-------------------------------------------------------------------------------
# BT.601 625-line
#-------------------------------------------------------------------------------
primary_r(::Type{C}) where {C<:YUVT{:BT601_625}} = xy(0.630, 0.340)
primary_g(::Type{C}) where {C<:YUVT{:BT601_625}} = xy(0.310, 0.595)
primary_b(::Type{C}) where {C<:YUVT{:BT601_625}} = xy(0.155, 0.070)
whitepoint(::Type{C}) where {C<:YUVT{:BT601_625}} = XY_D65

function mat_rgb_to_xyz(::Type{C}) where {T,C<:YUV{T,:BT601_625}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((0.39352090365938974, 0.3652580767176036, 0.19167694667467833)),
        F.((0.2123763607050675, 0.7010598569257229, 0.08656378236920957)),
        F.((0.018739090650447113, 0.11193392673603977, 0.9583847333733915)),
    )
end

function mat_xyz_to_rgb(::Type{C}) where {T,C<:YUV{T,:BT601_625}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((3.506003282724663, -1.7397907263028323, -0.5440582683627414)),
        F.((-1.069047559853815, 1.977778882728787, 0.035171419337195135)),
        F.((0.05630659173412771, -0.19697565482077184, 1.0499523282187335)),
    )
end

function mat_rgb_to_srgb(::Type{C}) where {T,C<:YUV{T,:BT601_625}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((0.9395420637732395, 0.05018135685986768, 0.010276579366892854)),
        F.((0.017772223143560816, 0.9657928624969045, 0.016434914359534623)),
        F.((-0.001621599943185542, -0.004369749659735679, 1.0059913496029211)),
    )
end

function mat_srgb_to_rgb(::Type{C}) where {T,C<:YUV{T,:BT601_625}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((1.0653790337699551, -0.05540087282452731, -0.009978160945427719)),
        F.((-0.019632549873145312, 1.0363630945786033, -0.016730544705458067)),
        F.((0.0016320510640102015, 0.004412373157507611, 0.9939555757784821)),
    )
end

#-------------------------------------------------------------------------------
# BT.601 525-line
primary_r(::Type{C}) where {C<:YUVT{:BT601_525}} = xy(0.640, 0.330)
primary_g(::Type{C}) where {C<:YUVT{:BT601_525}} = xy(0.290, 0.600)
primary_b(::Type{C}) where {C<:YUVT{:BT601_525}} = xy(0.150, 0.060)
whitepoint(::Type{C}) where {C<:YUVT{:BT601_525}} = XY_D65
#-------------------------------------------------------------------------------