
function promote_yuv_type(::Type{Ty}, ::Type{Tu}, ::Type{Tv}) where {Ty,Tu,Tv}
    return promote_type(Ty, promote_type(Tu, Tv))
end

YUVT{P,U}(y, u, v) where {P,U} = YUVT{P,U,-1}(y, u, v)

function YUVT{P,U,D}(y, u, v) where {P,U,D}
    T = promote_yuv_type(typeof(y), typeof(u), typeof(v))
    YUV{T,P,U,D}(y, u, v)
end

encode_alpha(::Type{T}, D::Int, alpha) where {T} = convert(T, alpha)

function encode_alpha(::Type{T}, D::Int, alpha::Normed{T,f}) where {T<:Unsigned,f}
    if D == -1
        D = 8
    end
    return reinterpret(T, Normed{T,D}(alpha))
end

function encode_alpha(::Type{T}, D::Int, alpha) where {T<:Signed}
    reinterpret(T, encode_alpha(unsigned(T), D, alpha))
end