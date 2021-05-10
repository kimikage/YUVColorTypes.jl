using Test, YUVColorTypes

yuvfiles = [
    "bt601_625_srgb.yuv",
    "bt601_625.yuv",
    "bt601_525_srgb.yuv",
    "bt601_525.yuv",
]
if any(fn -> !isfile(joinpath(@__DIR__), fn), yuvfiles)
    include("testimages.jl")
end

using FixedPointNumbers
using ColorTypes
using Colors

@test isempty(detect_ambiguities(YUVColorTypes, Base, ColorTypes, Colors))

@testset "utilities" begin
    include("utilities.jl")
end

@testset "promote" begin
    include("promote.jl")
end

@testset "traits" begin
    include("traits.jl")
end

@testset "show" begin
    include("show.jl")
end

@testset "ranges" begin
    include("ranges.jl")
end

@testset "matrices" begin
    include("matrices.jl")
end

@testset "primaries" begin
    include("primaries.jl")
end

@testset "curves" begin
    include("curves.jl")
end

@testset "ffmpeg" begin
    include("ffmpeg.jl")
end
