
YUV{T,P,U}(y, u, v) where {T,P,U} = YUV{T,P,U,false,-1}(y, u, v)
YUV{T,P,U,R}(y, u, v) where {T,P,U,R} = YUV{T,P,U,R,-1}(y, u, v)
YUVT{P,U}(y, u, v) where {P,U} = YUVT{P,U,false,-1}(y, u, v)
YUVT{P,U,R}(y, u, v) where {P,U,R} = YUVT{P,U,R,-1}(y, u, v)

AYUV{T,P,U}(y, u, v, alpha) where {T,P,U} = AYUV{T,P,U,false,-1}(y, u, v, alpha)
AYUV{T,P,U,R}(y, u, v, alpha) where {T,P,U,R} = AYUV{T,P,U,R,-1}(y, u, v, alpha)
AYUVT{P,U}(y, u, v, alpha) where {P,U} = AYUVT{P,U,false,-1}(y, u, v, alpha)
AYUVT{P,U,R}(y, u, v, alpha) where {P,U,R} = AYUVT{P,U,R,-1}(y, u, v, alpha)

YUVA{T,P,U}(y, u, v, alpha) where {T,P,U} = YUVA{T,P,U,false,-1}(y, u, v, alpha)
YUVA{T,P,U,R}(y, u, v, alpha) where {T,P,U,R} = YUVA{T,P,U,R,-1}(y, u, v, alpha)
YUVAT{P,U}(y, u, v, alpha) where {P,U} = YUVAT{P,U,false,-1}(y, u, v, alpha)
YUVAT{P,U,R}(y, u, v, alpha) where {P,U,R} = YUVAT{P,U,R,-1}(y, u, v, alpha)

function YUVT{P,U,R,D}(y, u, v) where {P,U,R,D}
    T = promote_yuv_component_type(YUVT{P,U,R,D}, typeof(y), typeof(u), typeof(v))
    return YUV{T,P,U,R,D}(y, u, v)
end

function AYUVT{P,U,R,D}(y, u, v, alpha) where {P,U,R,D}
    T = promote_yuv_component_type(YUVT{P,U,R,D}, typeof(y), typeof(u), typeof(v))
    return AYUV{T,P,U,R,D}(y, u, v, alpha)
end

function YUVAT{P,U,R,D}(y, u, v, alpha) where {P,U,R,D}
    T = promote_yuv_component_type(YUVT{P,U,R,D}, typeof(y), typeof(u), typeof(v))
    return YUVA{T,P,U,R,D}(y, u, v, alpha)
end

function (::Type{C})(yuv::AbstractYUVColorant) where {C<:AbstractYUVColorant}
    yuv_to_yuv(C, yuv)
end

function (::Type{C})(yuv::AbstractYUVColorant) where {C<:AbstractLumaColorant}
    yuv_to_luma(C, yuv)
end

function (::Type{C})(luma::AbstractLumaColorant) where {C<:AbstractYUVColorant}
    luma_to_yuv(C, luma)
end

function (::Type{C})(luma::AbstractLumaColorant) where {C<:AbstractLumaColorant}
    luma_to_luma(C, luma)
end

function (::Type{C})(c::Colorant, alpha::Real) where {C<:TransparentYUV}
    d = convert(color_type(C), c)
    return C(luma(d), chroma_u(d), chroma_v(d), alpha)
end

function (::Type{C})(c::Colorant, alpha::Real) where {C<:TransparentLuma}
    d = convert(color_type(C), c)
    return C(luma(d), alpha)
end

encode_luma(::Type{C}, luma) where {T,C<:YUV{T}} = convert(T, luma)
encode_luma(::Type{C}, luma) where {T<:Integer,C<:YUV{T}} = round(T, luma)

encode_chroma(::Type{C}, chroma) where {C<:YUV} = encode_luma(C, chroma)

encode_alpha(::Type{C}, alpha) where {T,P,U,R,D,C<:YUV{T,P,U,R,D}} = convert(T, alpha)

function encode_alpha(::Type{C}, alpha) where {T<:Integer,P,U,R,D,C<:YUV{T,P,U,R,D}}
    f = D === -1 ? 8 : D
    return reinterpret(T, reinterpret(Normed{unsigned(T),f}(alpha)))
end

function convert_yuv_repr(::Type{Cd}, yuv::Cs) where {P,U,R,Ds,Cd<:YUVT{P,U,R},Cs<:YUVT{P,U,R,Ds}}
    d = scaling_coef_depth_e(Cd) * scaling_coef_depth_s(Cs)
    y = luma(yuv) * d
    u = chroma_u(yuv) * d
    v = chroma_v(yuv) * d
    Cd(y, u, v)
end
