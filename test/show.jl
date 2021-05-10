using Test, YUVColorTypes
using FixedPointNumbers

@testset "single color" begin
    iob = IOBuffer()
    show(iob, YCbCrBT601_625{UInt8}(20, 30, 40))
    @test String(take!(iob)) == "YCbCrBT601_625{UInt8}(20, 30, 40)"

    show(iob, YCbCrBT601_625{N8f8}(20, 30.2, 40))
    @test String(take!(iob)) == "YCbCrBT601_625{N8f8}(20.0, 30.2, 40.0)"

    show(iob, YCbCrBT601_625{Float64}(20, 100 / 3, 40))
    @test String(take!(iob)) == "YCbCrBT601_625{Float64}(20.0, 33.333333333333336, 40.0)"

    show(IOContext(iob, :compact => true), YCbCrBT601_625{Float64}(20, 100 / 3, 40))
    @test String(take!(iob)) == "YCbCrBT601_625{Float64}(20.0, 33.3333, 40.0)"

    show(iob, AYCbCrBT601_625{UInt8}(20, 30, 40, 0.5))
    @test String(take!(iob)) == "AYCbCrBT601_625{UInt8}(20, 30, 40, 0.502)"

    show(iob, YCbCrABT601_625{UInt8}(20, 30, 40, 0.5))
    @test String(take!(iob)) == "YCbCrABT601_625{UInt8}(20, 30, 40, 0.502)"

    show(IOContext(iob, :compact => true), AYCbCrBT601_625{Float64}(20, 100 / 3, 40, 0.5))
    @test String(take!(iob)) == "AYCbCrBT601_625{Float64}(20.0, 33.3333, 40.0, 0.5)"

    show(IOContext(iob, :compact => true), YCbCrABT601_625{Float64}(20, 100 / 3, 40, 0.5))
    @test String(take!(iob)) == "YCbCrABT601_625{Float64}(20.0, 33.3333, 40.0, 0.5)"


    show(iob, YCbCr30BT601_625(200, 300, 400))
    @test String(take!(iob)) == "YCbCr30BT601_625(200, 300, 400)"

    show(iob, AYCbCr40BT601_625(200, 300, 400, 0.5))
    @test String(take!(iob)) == "AYCbCr40BT601_625(200, 300, 400, 0.5005)"

    show(iob, YCbCrA40BT601_625(200, 300, 400, 0.5))
    @test String(take!(iob)) == "YCbCrA40BT601_625(200, 300, 400, 0.5005)"
end