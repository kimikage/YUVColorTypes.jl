using Test, YUVColorTypes
using FixedPointNumbers

using YUVColorTypes: mul, _map
using YUVColorTypes: luma_coefs
using YUVColorTypes: mat_rgb_to_yuv, _mat_rgb_to_yuv
using YUVColorTypes: mat_yuv_to_rgb, _mat_yuv_to_rgb

diff(a, b) = sum((a[i] - b[i])^2 for i in 1:3)

@testset "luma_coefs" begin
    @test diff(@inferred(luma_coefs(YCbCr24BT601_625{UInt8})), (0.299, 0.587, 0.114)) < 1e-9

    krgb_5 = luma_coefs(YCbCrBT601_625{Float32})

    @test @inferred(luma_coefs(YCbCr24BT601_525{UInt8})) === krgb_5

end

@testset "mat $Cb" for Cb in (YCbCrBT601_625, YCbCrBT601_525)
    r2yc = _map(Float64, _mat_rgb_to_yuv(Cb{BigFloat}))
    y2rc = _map(Float64, _mat_yuv_to_rgb(Cb{BigFloat}))
    @testset "$(Cb{T})" for T in (Float64, Float32, Float16, Q7f8)
        C = Cb{T}
        if T === Float64
            err = 1e-9
        elseif T === Float16
            err = 1e-3
        else
            err = 1e-6
        end

        r2y = mat_rgb_to_yuv(C)
        y2r = mat_yuv_to_rgb(C)

        @testset "RGB -> YUV [$i][$j]" for i in 1:3, j in 1:3
            @test r2y[i][j] ≈ r2yc[i][j] atol = err
        end
        @testset "YUV -> RGB [$i][$j]" for i in 1:3, j in 1:3
            @test y2r[i][j] ≈ y2rc[i][j] atol = err
        end

        y2y = mul(r2y, y2r)
        r2r = mul(y2r, r2y)
        @testset "YUV -> RGB- > YUV [$i][$j]" for i in 1:3, j in 1:3
            @test y2y[i][j] ≈ Int(i == j) atol = err
        end
        @testset "RGB -> YUV -> RGB [$i][$j]" for i in 1:3, j in 1:3
            @test r2r[i][j] ≈ Int(i == j) atol = err
        end
    end
end

@testset "$Cb" for Cb in (YCbCrBT601_625, YCbCrBT601_525)
    C = Cb{Float64}
    err = 1e-12
    r2y = mat_rgb_to_yuv(C)
    @test diff(mul(r2y, (1.0, 1.0, 1.0)), (1.0, 0.0, 0.0)) < err
    @test diff(mul(r2y, (0.0, 0.0, 0.0)), (0.0, 0.0, 0.0)) < err
    @test diff(mul(r2y, (1.0, 0.0, 0.0)), (0.299, -0.299 / 1.772, 0.5)) < err
    @test diff(mul(r2y, (0.0, 1.0, 0.0)), (0.587, -0.587 / 1.772, -0.587 / 1.402)) < err
    @test diff(mul(r2y, (0.0, 0.0, 1.0)), (0.114, 0.5, -0.114 / 1.402)) < err
    @test diff(mul(r2y, (1.0, 1.0, 0.0)), (0.886, -0.886 / 1.772, 0.114 / 1.402)) < err
    @test diff(mul(r2y, (0.0, 1.0, 1.0)), (0.701, 0.299 / 1.772, -0.701 / 1.402)) < err
    @test diff(mul(r2y, (1.0, 0.0, 1.0)), (0.413, 0.587 / 1.772, 0.587 / 1.402)) < err
end