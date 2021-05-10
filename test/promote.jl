using Test, YUVColorTypes
using YUVColorTypes: YUVT, AYUVT, YUVAT

@testset "promote_yuv_component_type" begin
    promote_ct = YUVColorTypes.promote_yuv_component_type

    @test @inferred(promote_ct(YUVT{:P,true,false,8}, Int, Int, Int)) === UInt8
    @test @inferred(promote_ct(YUVT{:P,true,false,10}, Int, Int, Int)) === UInt16
    @test @inferred(promote_ct(YUVT{:P,true,false,12}, Int, Int, Int)) === UInt16
    @test @inferred(promote_ct(YUVT{:P,true,false,16}, Int, Int, Int)) === UInt16

    @test @inferred(promote_ct(YUVT{:P,true,false,8}, UInt8, Int, Int)) === UInt8
    @test @inferred(promote_ct(YUVT{:P,true,false,8}, Int, UInt8, Int)) === UInt8
    @test @inferred(promote_ct(YUVT{:P,true,false,8}, Int, Int, UInt8)) === UInt8

    @test @inferred(promote_ct(YUVT{:P,true,false,10}, UInt8, Int, Int)) === UInt16
    @test @inferred(promote_ct(YUVT{:P,true,false,10}, Int, UInt8, Int)) === UInt16
    @test @inferred(promote_ct(YUVT{:P,true,false,10}, Int, Int, UInt8)) === UInt16

    @test @inferred(promote_ct(YUVT{:P,true,false,8}, Float64, Int, Int)) === Float64
    @test @inferred(promote_ct(YUVT{:P,true,false,8}, Int, Float32, Int)) === Float32
    @test @inferred(promote_ct(YUVT{:P,true,false,8}, Int, Int, Float16)) === Float16

end