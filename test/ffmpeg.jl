using Test, YUVColorTypes
using ColorTypes
using FixedPointNumbers

# raw planer image
function read_yuv444p12le(::Type{C}, io::IO, len=4096*4096) where {C}
    @show C
    vec = Vector{C}(undef, len)
    for i in 1:len
        y = ltoh(read(io, UInt16))
        vec[i] = C(y, 0x0000, 0x0000)
    end
    for i in 1:len
        u = ltoh(read(io, UInt16))
        y = vec[i].y
        vec[i] = C(y, u, 0x0000)
    end
    for i in 1:len
        v = ltoh(read(io, UInt16))
        y = vec[i].y
        u = vec[i].u
        vec[i] = C(y, u, v)
    end
    return vec
end

# allrgb
function idx_to_rgb(idx::UInt32)
    # (msb) bbbbrrrrrrrrbbbbgggggggg (lsb)
    g = idx % UInt8
    r = (idx >> 12) & UInt8
    b = (((idx >> 8) & 0xf) | ((idx >> 16) & 0xf0)) % UInt8
    return RGB(reinterpret.(N0f8, (r, g, b))...)
end

@testset "BT.601 625-line" begin
    Cref = YCbCrBT601_625{UInt16,12}
    yuv = Cref[]
    open(joinpath(@__DIR__, "bt601_625_srgb.yuv"), "r") do f
        yuv = read_yuv444p12le(Cref, f)
    end
    a = YUVColorTypes.ieotf(RGB{Float64})(0.5)
    aa = YUVColorTypes.eotf(YCbCrBT601_625{Float64})(a)


    b = YUVColorTypes.eotf(RGB{Float64})(0.5)
    bb = YUVColorTypes.ieotf(YCbCrBT601_625{Float64})(b)
    @show aa, bb
    @show yuv[1:4]
    @show yuv[end-3:end]
    @show yuv[0x880080]
    @show yuv[0x880080].y / 16
    @show srgb_to_yuv(YCbCrBT601_625{Float64}, RGB(0.5))

    open(joinpath(@__DIR__, "bt601_625.yuv"), "r") do f
        yuv = read_yuv444p12le(Cref, f)
    end
    @show yuv[0x880080]
    @show yuv[0x880080].y / 16


end