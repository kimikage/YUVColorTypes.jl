using Test, YUVColorTypes

using YUVColorTypes: Vec, Mat, mul, _inv

@testset "mul" begin
    ta = (
        (2, 3, 5)::Vec,
        (7, 11, 13)::Vec,
        (17, 19, 23)::Vec
    )::Mat
    ma = [
        2 3 5
        7 11 13
        17 19 23
    ]
    tb = (
        (3, 1, 4)::Vec,
        (1, 5, 9)::Vec,
        (2, 6, 5)::Vec
    )::Mat
    mb = [
        3 1 4
        1 5 9
        2 6 5
    ]
    tv = (2, 7, 1)
    mv = [2, 7, 1]

    tav = mul(ta, tv)
    mav = ma * mv
    @test all(tav .== mav)

    tab = mul(ta, tb)
    mab = ma * mb
    @test all(tab[i][j] .== mab[i, j] for i in 1:3, j in 1:3)

    tba = mul(tb, ta)
    mba = mb * ma
    @test all(tba[i][j] .== mba[i, j] for i in 1:3, j in 1:3)
end

@testset "_inv" begin
    ta = (
        (2, 3, 5)::Vec,
        (7, 11, 13)::Vec,
        (17, 19, 23)::Vec
    )::Mat
    ma = [
        2 3 5
        7 11 13
        17 19 23
    ]

    tia = _inv(ta)
    mia = inv(ma)
    @test tia isa Mat{Float64}
    @test all(tia[i][j] .== mia[i, j] for i in 1:3, j in 1:3)
end