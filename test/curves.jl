using Test, YUVColorTypes
using ColorTypes
using FixedPointNumbers

using YUVColorTypes: eotf, ieotf

vs = (0.0f0, 1.0f-3, 5.0f-3, 1.0f-2, 5.0f-2, 0.1f0, 0.2f0, 0.5f0, 0.8f0, 0.9f0, 1.0f0)

@testset "sRGB" begin
    C = RGB{Float32}
    eo = @inferred(eotf(C))
    ieo = @inferred(ieotf(C))

    @test eo(0.0f0) ≈ 0.0f0
    @test eo(1.0f-3) ≈ 7.739938f-5
    @test eo(0.5f0) ≈ 0.21404114f0
    @test eo(1.0f0) ≈ 1.0f0

    @test ieo(0.0f0) ≈ 0.0f0
    @test ieo(1.0f-3) ≈ 0.01292f0
    @test ieo(0.5f0) ≈ 0.735357f0
    @test ieo(1.0f0) ≈ 1.0f0

    @testset "eotf -> ieotf ($v)" for v in vs
        @test ieo(eo(v)) ≈ v
        @test eo(ieo(v)) ≈ v
    end
end

@testset "$Cb" for Cb in (YCbCrBT601_625, YCbCrBT601_525)
    C = Cb{Float32}
    eo = @inferred(eotf(C))
    ieo = @inferred(ieotf(C))

    @test eo(0.0f0) ≈ 0.0f0
    @test eo(1.0f-3) ≈ 0.00022222222f0
    @test eo(0.5f0) ≈ 0.2595894f0
    @test eo(1.0f0) ≈ 1.0f0

    @test ieo(0.0f0) ≈ 0.0f0
    @test ieo(1.0f-3) ≈ 0.0045f0
    @test ieo(0.5f0) ≈ 0.7055151f0
    @test ieo(1.0f0) ≈ 1.0f0

    @testset "eotf -> ieotf ($v)" for v in vs
        @test ieo(eo(v)) ≈ v
        @test eo(ieo(v)) ≈ v
    end

end
