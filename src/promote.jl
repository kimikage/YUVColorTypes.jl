

function promote_yuv_type(::Type{C}, ::Type{Crgb}) where {C<:AbstractYUV,Crgb<:AbstractRGB}
    return ccolor(base_color_type(C){Float32}, C)
end

function promote_yuv_component_type(::Type{C}, ::Type{T}, ::Type{T}, ::Type{T}) where {T,C<:YUVT}
    return T
end

function promote_yuv_component_type(::Type{C}, ::Type{T}, ::Type{T}, ::Type{T}) where {T<:Integer,P,D,C<:YUVT{P,true,false,D}}
    if D <= 8
        return UInt8
    elseif D <= 16
        return UInt16
    elseif D <= 32
        return UInt32
    else
        return UInt
    end
end

function promote_yuv_component_type(::Type{C}, ::Type{T}, ::Type{T}, ::Type{T}) where {T<:Integer,P,D,C<:YUVT{P,false,false,D}}
    if D <= 8
        return Int8
    elseif D <= 16
        return Int16
    elseif D <= 32
        return Int32
    else
        return Int
    end
end

function promote_yuv_component_type(::Type{C}, ::Type{Ty}, ::Type{Tuv}, ::Type{Tuv}) where {Ty,Tuv,C<:YUVT}
    T = promote_type(Ty, Tuv)
    return promote_yuv_component_type(C, T, T, T)
end

function promote_yuv_component_type(::Type{C}, ::Type{Ty}, ::Type{Tu}, ::Type{Tv}) where {Ty,Tu,Tv,C<:YUVT}
    Tuv = promote_type(Tu, Tv)
    return promote_yuv_component_type(C, Ty, Tuv, Tuv)
end
