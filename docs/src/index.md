# YUVColorTypes.jl
This package is an add-on to [ColorTypes](https://github.com/JuliaGraphics/ColorTypes.jl),
and supports [YUV](https://en.wikipedia.org/wiki/Y%E2%80%B2UV)-like colors.

Unfortunately, the environment surrounding YUV-like colors has historically been
confusing.
In the first place, there is no consensus on even calling a color with one
luminance component and two chroma components a YUV.
Therefore, this package aims to handle well-defined and well-formed YUV-like
colors in a "reasonable" manner.

This package does not provide a public API for the specific storage format of
YUV colors.
This is because YUV-like images are often used with chroma resampling (e.g.,
YUV 4:2:0) and planar formats with channel-separated images.

Also, this package provides limited support for conversion between RGBs and
YUVs, and does not provide general color management functionality.
