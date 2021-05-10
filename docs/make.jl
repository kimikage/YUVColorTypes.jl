using Documenter, YUVColorTypes
using Colors

if :size_threshold in fieldnames(Documenter.HTML)
    size_th = (
        example_size_threshold = nothing,
        size_threshold = nothing,
    )
else
    size_th = ()
end

makedocs(
    clean=false,
    warnonly=true, # FIXME
    modules=[YUVColorTypes],
    format=Documenter.HTML(;prettyurls = get(ENV, "CI", nothing) == "true",
                           size_th...,
                           assets = []),
    sitename="YUVColorTypes",
    pages=[
        "Introduction" => "index.md",
        "Supported Profiles" => "profiles.md",
        "Adding Profiles" => "addingprofiles.md",
        "API Reference" => "api.md",
    ]
)

deploydocs(
    repo="github.com/kimikage/YUVColorTypes.jl.git",
    push_preview = true
)
