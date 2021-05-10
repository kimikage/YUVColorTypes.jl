function Base.show(io::IO, c::YUVLumaColorant)
    if get(io, :typeinfo, Any) === typeof(c)
        print(io, ColorTypes.colorant_string(typeof(c)))
    else
        ColorTypes.show_colorant_string_with_eltype(io, typeof(c))
    end
    _show_components(io, c)
end

@inline function _components_iocontext(io::IO, c::Colorant{T}) where {T}
    if typeof(c) === base_colorant_type(c)
        return io
    elseif T === Float64
        return io
    elseif T <: FixedPoint # workaround for FPN v0.8 or earlier
        return IOContext(io, :typeinfo => T, :compact => true)
    else
        return IOContext(io, :typeinfo => T)
    end
end

function _show_components(io::IO, c::AbstractLuma)
    io = _components_iocontext(io, c)
    print(io, '(', comp1(c), ')')
end

function _show_components(io::IO, c::TransparentLuma)
    io = _components_iocontext(io, c)
    print(io, '(', comp1(c), ", ")
    a = alpha(c)
    print(_components_iocontext(io, Gray(a)), a)
    print(io, ')')
end

function _show_components(io::IO, c::AbstractYUV)
    io = _components_iocontext(io, c)
    print(io, '(', comp1(c), ", ", comp2(c), ", ", comp3(c), ')')
end

function _show_components(io::IO, c::TransparentYUV)
    io = _components_iocontext(io, c)
    print(io, '(', comp1(c), ", ", comp2(c), ", ", comp3(c), ", ")
    a = alpha(c)
    print(_components_iocontext(io, Gray(a)), a)
    print(io, ')')
end

function ColorTypes.show_colorant_string_with_eltype(io::IO, ::Type{C}) where {C<:YUVLumaColorant}
    if C === fullrange(C)
        print(io, "fullrange(")
        _show_colorant_string_with_eltype(io, limitedrange(C))
        print(io, ')')
    else
        _show_colorant_string_with_eltype(io, C)
    end
end

_show_colorant_string_with_eltype(io::IO, ::Type{C}) where {C} = show(io, C)

function _show_colorant_string_with_eltype(io::IO, ::Type{C}) where {T,U,R,D,C<:YCbCrColorant{T,U,R,D}}
    if C <: AlphaColor
        print(io, "AYCbCr")
    elseif C <: ColorAlpha
        print(io, "YCbCrA")
    else
        print(io, "YCbCr")
    end
    if D in (8, 10, 12, 16)
        print(io, C <: TransparentColor ? D * 4 : D * 3)
    end
    print(io, profile_symbol(C))
    _show_parameters(io, C)
end

function _show_parameters(io::IO, ::Type{C}) where {T,P,U,R,D,C<:YUVColorant{T,P,U,R,D}}
    if D === 8 && T === (U ? UInt8 : Int8)
    elseif D === 10 && T === (U ? UInt16 : Int16)
    elseif D === 12 && T === (U ? UInt16 : Int16)
    elseif D === 16 && T === (U ? UInt16 : Int16)
    else
        print(io, '{', T)
        if !(D in (-1, 8, 10, 12, 16))
            print(io, ", ", D)
        end
        print(io, '}')
    end
end