# Adding Profiles
This page describes the internals of YUVColorTypes.jl.

You can implement the conversion methods such as `convert_yuv_to_rgb` directly.
However, except in the case of nonlinear conversions or speed optimization, the
conversion processes are completed simply by defining a profile.

## RGB color primaries and whitepoint

```@docs
YUVColorTypes.primary_r
YUVColorTypes.primary_g
YUVColorTypes.primary_b
YUVColorTypes.whitepoint
```

## RGB <-> XYZ conversion matrices
```@docs
YUVColorTypes.mat_rgb_to_xyz
YUVColorTypes.mat_xyz_to_rgb
```

## RGB <-> sRGB conversion matrices
```@docs
YUVColorTypes.mat_rgb_to_srgb
YUVColorTypes.mat_srgb_to_rgb
```

## YUV <-> RGB conversion matrices

## Transfer functions
```@docs
YUVColorTypes.eotf
YUVColorTypes.ieotf
```