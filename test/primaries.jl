using Test, YUVColorTypes
using Colors

using YUVColorTypes: primary_r, primary_g, primary_b, whitepoint
using YUVColorTypes: mat_rgb_to_xyz, _mat_rgb_to_xyz
using YUVColorTypes: mat_xyz_to_rgb, _mat_xyz_to_rgb
using YUVColorTypes: mat_rgb_to_srgb
using YUVColorTypes: mat_srgb_to_rgb

@testset "$Cb" for Cb in (YCbCrBT601_625, YCbCrBT601_525)
    r2xc = _map(Float64, _mat_rgb_to_xyz(Cb{BigFloat}))
    x2rc = _map(Float64, _mat_xyz_to_rgb(Cb{BigFloat}))

    @test XYZ(whitepoint(Cb)) ≈ Colors.WP_D65 atol = 1e-3

    @testset "$(Cb{T})" for T in (Float64, Float32, Float16, Q7f8)
        C = Cb{T}
        err = T === Float16 ? 2e-3 : 1e-6


        r2x = mat_rgb_to_xyz(C)
        x2r = mat_xyz_to_rgb(C)

        @testset "RGB -> XYZ [$i][$j]" for i in 1:3, j in 1:3
            @test r2x[i][j] ≈ r2xc[i][j] atol = err
        end
        @testset "XYZ -> RGB [$i][$j]" for i in 1:3, j in 1:3
            @test x2r[i][j] ≈ x2rc[i][j] atol = err
        end

        r2r = mul(x2r, r2x)
        x2x = mul(r2x, x2r)
        @testset "RGB -> XYZ -> RGB [$i][$j]" for i in 1:3, j in 1:3
            @test r2r[i][j] ≈ (i == j) atol = err
        end
        @testset "XYZ -> RGB -> XYZ [$i][$j]" for i in 1:3, j in 1:3
            @test x2x[i][j] ≈ (i == j) atol = err
        end

        x2sr = mat_xyz_to_rgb(RGB{T})
        sr2x = mat_rgb_to_xyz(RGB{T})
        r2sr = mat_rgb_to_srgb(C)
        sr2r = mat_srgb_to_rgb(C)
        r2src = mul(x2sr, r2x)
        sr2rc = mul(x2r, sr2x)
        sr2sr = mul(r2sr, sr2r)
        @testset "RGB -> sRGB [$i][$j]" for i in 1:3, j in 1:3
            @test r2sr[i][j] ≈ r2src[i][j] atol = err
        end
        @testset "sRGB -> RGB [$i][$j]" for i in 1:3, j in 1:3
            @test sr2r[i][j] ≈ sr2rc[i][j] atol = err
        end
        @testset "sRGB -> XYZ -> sRGB [$i][$j]" for i in 1:3, j in 1:3
            @test sr2sr[i][j] ≈ Int(i == j) atol = err
        end
    end
end