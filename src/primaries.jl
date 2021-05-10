"""
    primary_r(C) -> xyY{Float64}

Return the red primary of color type `C` in `xyY` where Y is `1.0`.
"""
primary_r(::Type{C}) where {C<:TransparentColor} = primary_r(color_type(C))
primary_r(::Type{C}) where {C} = primary_r(cicp_type(C))

"""
    primary_g(C) -> xyY{Float64}

Return the green primary of color type `C` in `xyY` where Y is `1.0`.
"""
primary_g(::Type{C}) where {C<:TransparentColor} = primary_g(color_type(C))
primary_g(::Type{C}) where {C} = primary_g(cicp_type(C))

"""
    primary_b(C) -> xyY{Float64}

Return the blue primary of color type `C` in `xyY` where Y is `1.0`.
"""
primary_b(::Type{C}) where {C<:TransparentColor} = primary_b(color_type(C))
primary_b(::Type{C}) where {C} = primary_b(cicp_type(C))

"""
    has_d65_wp(C) -> Bool

Return `true` if the color type `C` uses D65 white point (`xyY(0.3127, 0.3290, 1.0)`).
"""
has_d65_wp(::Type{C}) where {C<:Colorant} = false

const D65Colorant = Union{
    # We do not assume here that `RGB` is sRGB.
    YUVLumaColorantT{:BT601_625},
    YUVLumaColorantT{:BT601_525},
}

has_d65_wp(::Type{<:D65Colorant}) =  true


"""
    whitepoint(C) -> xyY{Float64}

Return the whitepoint of color type `C` in `xyY.
"""
whitepoint(::Type{C}) where {C<:TransparentColor} = whitepoint(color_type(C))
whitepoint(::Type{C}) where {C} = whitepoint(cicp_type(C))

xy(x, y) = xyY(x, y, 1.0)

# Colors.jl defines WP_D65 in XYZ and There are rounding errors between the two.
const XY_D65 = xy(0.3127, 0.3290)

whitepoint(::Type{<:D65Colorant}) = XY_D65

"""
    mat_rgb_to_xyz(C{T}) -> NTuple{3,NTuple{3,F}}

Return the conversion matrix from CIE XYZ to *linear* RGB based on `C` primaries.
"""
mat_rgb_to_xyz(::Type{C}) where {C<:TransparentColor} = mat_rgb_to_xyz(color_type(C))
mat_rgb_to_xyz(::Type{C}) where {T,C<:Color{T}} = mat_rgb_to_xyz(T, cicp_type(C))
mat_rgb_to_xyz(::Type{T}, ::Type{C}) where {T, C<:Cicp} = _mat_rgb_to_xyz(T, C)

# fallback
_mat_rgb_to_xyz(::Type{C}) where {T,C<:AbstractYUV{T}} = _mat_rgb_to_xyz(T, cicp_type(C))
function _mat_rgb_to_xyz(::Type{T}, ::Type{C}) where {T,C<:Cicp}
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

"""
    mat_xyz_to_rgb(C{T}) -> NTuple{3,NTuple{3,F}}

Return the conversion matrix from *linear* RGB based on `C` primaries to CIE XYZ.
"""
mat_xyz_to_rgb(::Type{C}) where {C<:TransparentColor} = mat_xyz_to_rgb(color_type(C))
mat_xyz_to_rgb(::Type{C}) where {T,C<:Color{T}} = mat_xyz_to_rgb(T, cicp_type(C))
mat_xyz_to_rgb(::Type{T}, ::Type{C}) where {T,C<:Cicp} = _mat_xyz_to_rgb(T, C)

# fallback
_mat_xyz_to_rgb(::Type{C}) where {T,C<:AbstractYUV{T}} = _mat_xyz_to_rgb(T, cicp_type(C))
function _mat_xyz_to_rgb(::Type{T}, ::Type{C}) where {T,C<:Cicp}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    mat = _inv(_mat_rgb_to_xyz(F, C))
    return Tuple(F.(v) for v in mat)
end

"""
    mat_rgb_to_srgb(C{T}) ->NTuple{3,NTuple{3,F}}

Return the conversion matrix from *linear* RGB based on `C` primaries to *linear* sRGB.
"""
mat_rgb_to_srgb(::Type{C}) where {C<:TransparentYUV} = mat_rgb_to_srgb(color_type(C))
mat_rgb_to_srgb(::Type{C}) where {T,C<:AbstractYUV{T}} = mat_rgb_to_srgb(T, cicp_type(C))
mat_rgb_to_srgb(::Type{T}, ::Type{C}) where {T,C<:Cicp} = _mat_rgb_to_srgb(T, C)

# fallback
_mat_rgb_to_srgb(::Type{C}) where {T,C<:AbstractYUV{T}} = _mat_rgb_to_srgb(T, cicp_type(C))
function _mat_rgb_to_srgb(::Type{T}, ::Type{C}) where {T,C<:Cicp}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    src = _mat_rgb_to_xyz(F, C)
    dest = _mat_xyz_to_rgb(F, cicp_type(RGB))
    return mul(dest, src)
end

"""
    mat_srgb_to_rgb(C{T}) -> NTuple{3,NTuple{3,F}}

Return the conversion matrix from *linear* sRGB to *linear* RGB based on `C` primaries.
"""
mat_srgb_to_rgb(::Type{C}) where {C<:TransparentYUV} = mat_srgb_to_rgb(color_type(C))
mat_srgb_to_rgb(::Type{C}) where {T,C<:AbstractYUV{T}} = mat_srgb_to_rgb(T, cicp_type(C))
mat_srgb_to_rgb(::Type{T}, ::Type{C}) where {T,C<:Cicp} = _mat_srgb_to_rgb(T, C)

# fallback
_mat_srgb_to_rgb(::Type{C}) where {T,C<:AbstractYUV{T}} = _mat_srgb_to_rgb(T, cicp_type(C))
function _mat_srgb_to_rgb(::Type{T}, ::Type{C}) where {T,C<:Cicp}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    src = _mat_rgb_to_xyz(F, cicp_type(RGB))
    if whitepoint(C) !== whitepoint(RGB)
        error("whitepoint conversion is not implemented")
    end
    dest = _mat_xyz_to_rgb(F, C)
    return mul(dest, src)
end

#-------------------------------------------------------------------------------
# CICP ColorPrimaries 1
#-------------------------------------------------------------------------------
primary_r(::Type{C}) where {C<:CicpCP{0x1}} = xy(0.64, 0.33)
primary_g(::Type{C}) where {C<:CicpCP{0x1}} = xy(0.30, 0.60)
primary_b(::Type{C}) where {C<:CicpCP{0x1}} = xy(0.15, 0.06)
whitepoint(::Type{C}) where {C<:CicpCP{0x1}} = XY_D65

function mat_rgb_to_xyz(::Type{T}, ::Type{C}) where {T,C<:CicpCP{0x1}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((0.41239079926595934, 0.357584339383878, 0.18048078840183426)),
        F.((0.2126390058715103, 0.715168678767756, 0.07219231536073371)),
        F.((0.019330818715591825, 0.11919477979462598, 0.9505321522496606)),
    )
end

function mat_xyz_to_rgb(::Type{T}, ::Type{C}) where {T,C<:CicpCP{0x1}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((3.2409699419045226, -1.537383177570094, -0.4986107602930034)),
        F.((-0.9692436362808797, 1.8759675015077204, 0.04155505740717561)),
        F.((0.055630079696993656, -0.20397695888897655, 1.0569715142428786)),
    )
end

#-------------------------------------------------------------------------------
# CICP ColorPrimaries 5
#-------------------------------------------------------------------------------
primary_r(::Type{C}) where {C<:CicpCP{0x5}} = xy(0.64, 0.33)
primary_g(::Type{C}) where {C<:CicpCP{0x5}} = xy(0.29, 0.60)
primary_b(::Type{C}) where {C<:CicpCP{0x5}} = xy(0.15, 0.06)
whitepoint(::Type{C}) where {C<:CicpCP{0x5}} = XY_D65

function mat_rgb_to_xyz(::Type{T}, ::Type{C}) where {T,C<:CicpCP{0x5}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((0.4305538133299024, 0.3415498035305533, 0.17835231019121595)),
        F.((0.22200430999823093, 0.7066547659252826, 0.07134092407648639)),
        F.((0.020182209999839155, 0.1295533737529685, 0.9393221670070707)),
    )
end

function mat_xyz_to_rgb(::Type{T}, ::Type{C}) where {T,C<:CicpCP{0x5}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((3.063361090083271, -1.3933901749073672, -0.47582373799752986)),
        F.((-0.9692436362808797, 1.8759675015077204, 0.04155505740717561)),
        F.((0.06786104755356685, -0.2287992696204957, 1.0690896180160279)),
    )
end

function mat_rgb_to_srgb(::Type{T}, ::Type{C}) where {T,C<:CicpCP{0x5}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((1.044043208762835, -0.04404320876283499, 0.0)),
        F.((0.0, 1.0, 0.0)),
        F.((0.0, 0.011793378284005162, 0.9882066217159948)),
    )
end

function mat_srgb_to_rgb(::Type{T}, ::Type{C}) where {T,C<:CicpCP{0x5}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((0.9578147643764428, 0.04218523562355727, 0.0)),
        F.((0.0, 1.0, 0.0)),
        F.((0.0, -0.011934121898036132, 1.0119341218980362)),
    )
end

#-------------------------------------------------------------------------------
# CICP ColorPrimaries 6
#-------------------------------------------------------------------------------
primary_r(::Type{C}) where {C<:CicpCP{0x6}} = xy(0.630, 0.340)
primary_g(::Type{C}) where {C<:CicpCP{0x6}} = xy(0.310, 0.595)
primary_b(::Type{C}) where {C<:CicpCP{0x6}} = xy(0.155, 0.070)
whitepoint(::Type{C}) where {C<:CicpCP{0x6}} = XY_D65

function mat_rgb_to_xyz(::Type{T}, ::Type{C}) where {T,C<:CicpCP{0x6}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((0.39352090365938974, 0.3652580767176036, 0.19167694667467833)),
        F.((0.2123763607050675, 0.7010598569257229, 0.08656378236920957)),
        F.((0.018739090650447113, 0.11193392673603977, 0.9583847333733915)),
    )
end

function mat_xyz_to_rgb(::Type{T}, ::Type{C}) where {T,C<:CicpCP{0x6}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((3.506003282724663, -1.7397907263028323, -0.5440582683627414)),
        F.((-1.069047559853815, 1.977778882728787, 0.035171419337195135)),
        F.((0.05630659173412771, -0.19697565482077184, 1.0499523282187335)),
    )
end

function mat_rgb_to_srgb(::Type{T}, ::Type{C}) where {T,C<:CicpCP{0x6}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((0.9395420637732395, 0.05018135685986768, 0.010276579366892854)),
        F.((0.017772223143560816, 0.9657928624969045, 0.016434914359534623)),
        F.((-0.001621599943185542, -0.004369749659735679, 1.0059913496029211)),
    )
end

function mat_srgb_to_rgb(::Type{T}, ::Type{C}) where {T,C<:CicpCP{0x6}}
    F = T <: AbstractFloat ? T : promote_type(T, Float32)
    return (
        F.((1.0653790337699551, -0.05540087282452731, -0.009978160945427719)),
        F.((-0.019632549873145312, 1.0363630945786033, -0.016730544705458067)),
        F.((0.0016320510640102015, 0.004412373157507611, 0.9939555757784821)),
    )
end
