using Test, YUVColorTypes
using Colors

using YUVColorTypes: primary_r, primary_g, primary_b, whitepoint
using YUVColorTypes: cicp_type
using YUVColorTypes: mat_rgb_to_xyz, _mat_rgb_to_xyz
using YUVColorTypes: mat_xyz_to_rgb, _mat_xyz_to_rgb
using YUVColorTypes: mat_rgb_to_srgb
using YUVColorTypes: mat_srgb_to_rgb

@testset "primaries" begin
    @test @inferred(primary_r(RGB{Float64})) === xyY{Float64}(0.64, 0.33, 1)
    @test @inferred(primary_g(RGB{Float32})) === xyY{Float64}(0.30, 0.60, 1)
    @test @inferred(primary_b(RGB{Float16})) === xyY{Float64}(0.15, 0.06, 1)
    @test @inferred(whitepoint(RGB{N0f8})) === xyY{Float64}(0.3127, 0.3290, 1)

    @test @inferred(XYZ(whitepoint(RGB{Q7f8}))) ≈ Colors.WP_D65 atol = 1e-3

    @test @inferred(primary_r(YCbCr24BT601_625{Float64})) === primary_r(RGB)
    @test @inferred(primary_g(YCbCr24BT601_625{Float32})) != primary_g(RGB)
    @test @inferred(primary_b(YCbCr24BT601_625{Float16})) === primary_b(RGB)
    @test @inferred(whitepoint(YCbCr24BT601_625{UInt8})) === whitepoint(RGB)

    @test @inferred(primary_r(YCbCr24BT601_525{Float64})) != primary_r(RGB)
    @test @inferred(primary_g(YCbCr24BT601_525{Float32})) != primary_g(RGB)
    @test @inferred(primary_b(YCbCr24BT601_525{Float16})) != primary_b(RGB)
    @test @inferred(whitepoint(YCbCr24BT601_525{UInt8})) === whitepoint(RGB)
end

@testset "mat $Cb" for Cb in (YCbCrBT601_625, YCbCrBT601_525)
    r2xc = _map(Float64, _mat_rgb_to_xyz(Cb{BigFloat}))
    x2rc = _map(Float64, _mat_xyz_to_rgb(Cb{BigFloat}))

    @testset "$(Cb{T})" for T in (Float64, Float32, Float16, Q7f8)
        C = Cb{T}
        if T === Float64
            err = 1e-9
        elseif T === Float16
            err = 2e-3
        else
            err = 2e-5
        end

        r2x = mat_rgb_to_xyz(C)
        x2r = mat_xyz_to_rgb(C)

        @testset "$(Cb{T}) RGB -> XYZ [$i][$j]" for i in 1:3, j in 1:3
            @test r2x[i][j] ≈ r2xc[i][j] atol = err
        end
        @testset "$(Cb{T}) XYZ -> RGB [$i][$j]" for i in 1:3, j in 1:3
            @test x2r[i][j] ≈ x2rc[i][j] atol = err
        end

        r2r = mul(x2r, r2x)
        x2x = mul(r2x, x2r)
        @testset "$(Cb{T}) RGB -> XYZ -> RGB [$i][$j]" for i in 1:3, j in 1:3
            @test r2r[i][j] ≈ (i == j) atol = err
        end
        @testset "$(Cb{T}) XYZ -> RGB -> XYZ [$i][$j]" for i in 1:3, j in 1:3
            @test x2x[i][j] ≈ (i == j) atol = err
        end

        x2sr = mat_xyz_to_rgb(RGB{T})
        sr2x = mat_rgb_to_xyz(RGB{T})
        r2sr = mat_rgb_to_srgb(C)
        sr2r = mat_srgb_to_rgb(C)
        r2src = mul(x2sr, r2x)
        sr2rc = mul(x2r, sr2x)
        sr2sr = mul(r2sr, sr2r)
        @testset "$(Cb{T}) RGB -> sRGB [$i][$j]" for i in 1:3, j in 1:3
            @test r2sr[i][j] ≈ r2src[i][j] atol = err
        end
        @testset "$(Cb{T}) sRGB -> RGB [$i][$j]" for i in 1:3, j in 1:3
            @test sr2r[i][j] ≈ sr2rc[i][j] atol = err
        end
        @testset "$(Cb{T}) sRGB -> XYZ -> sRGB [$i][$j]" for i in 1:3, j in 1:3
            @test sr2sr[i][j] ≈ Int(i == j) atol = err
        end
    end
end
