using Test, YUVColorTypes

using YUVColorTypes: normalize_yuv

@testset "BT.601" begin
    C = YCbCrBT601_625{Float32}
    y, u, v = normalize_yuv(C(235.0, 240.0, 240.0))
    @test y ≈ 1.0
    @test u ≈ 0.5
    @test v ≈ 0.5
    y, u, v = normalize_yuv(C(16.0, 16.0, 16.0))
    @test y ≈ 0.0
    @test u ≈ -0.5
    @test v ≈ -0.5
end