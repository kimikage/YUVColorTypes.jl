using Test, YUVColorTypes
using FixedPointNumbers

@testset "YUV constructors [0, 256)" begin
    Cyuv = (
        YCbCrBT601_625,
        YCbCr24BT601_625,
        YCbCr30BT601_625,
        YCbCr36BT601_625,
        YCbCr48BT601_625,
        YCbCrBT601_525,
        YCbCr24BT601_525,
        YCbCr30BT601_525,
        YCbCr36BT601_525,
        YCbCr48BT601_525,
    )
    @testset "$C constructor without component type" for C in Cyuv
        for val1 in (100.0, 100.0f0, Q7f8(100))
            for val2 in (0.5, 0.5f0, Q7f8(0.5))
                c = C(val1, val1, val2)
                @test c isa C
                @test c.y ≈ 100.0
                @test c.u ≈ 100.0
                @test c.v ≈ 0.5
            end
        end
        # 0-arg constructor
        @test_broken C() === C{UInt8}(0, 0, 0)

    end
end
