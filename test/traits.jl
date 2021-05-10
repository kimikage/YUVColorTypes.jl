using Test,YUVColorTypes
using YUVColorTypes: YUV
using YUVColorTypes: fullrange, limitedrange

@testset "base_color_type" begin
    # T,P,U,R,d
    @test base_color_type(YCbCrBT601_625{Float32}) == YCbCrBT601_625
    # t,P,U,R,d
    @test base_color_type(YCbCrBT601_625) == YCbCrBT601_625

    # T,P,U,R,D
    @test base_color_type(YCbCr24BT601_625{Float32}) == YCbCr24BT601_625
    # t,P,U,R,D
    @test base_color_type(YCbCr24BT601_625) == YCbCr24BT601_625
end

@testset "ccolor" begin
    @test ccolor(YCbCr24BT601_625{Float32}, RGB{Float64}) == YCbCr24BT601_625{Float32}
    @test ccolor(YCbCr24BT601_625, RGB{Float64}) == YCbCr24BT601_625{Float64}
end

@testset "fullrange" begin
    @test fullrange(YCbCr24BT601_625{Float32}) == (YUV{Float32,:BT601_625,true,true,8})
    @test_broken fullrange(YCbCrBT601_625{Float32}) == (YUV{Float32,:BT601_625,true,true,D} where {D})
    @test fullrange(YCbCrBT601_625) == (YUV{T,:BT601_625,true,true,D} where {T,D})
end

@testset "limitedrange" begin
    @test limitedrange(YCbCr24BT601_625{Float32}) == (YUV{Float32,:BT601_625,true,false,8})
    @test_broken limitedrange(YCbCrBT601_625{Float32}) == (YUV{Float32,:BT601_625,true,false,D} where {D})
    @test limitedrange(YCbCrBT601_625) == (YUV{T,:BT601_625,true,false,D} where {T,D})
end
