# API Reference
```@contents
Pages = ["api.md"]
```

## Module
```@docs
YUVColorTypes
```

## Basic Types
```@docs
# AbstractYUV
# TransparentYUV
# AbstractAYUV
# AbstractYUVA
# AbstractYUVColorant

# AbstractLuma
# TransparentLuma
# AbstractALuma
# AbstractLumaA
# AbstractLumaColorant

YUVColorTypes.YUV
YUVColorTypes.AYUV
YUVColorTypes.YUVA
YUVColorTypes.Luma
YUVColorTypes.ALuma
YUVColorTypes.LumaA
```

## Specific YCbCr Types (Aliases)
```@docs
YCbCrBT601_625
YCbCr30BT601_625
YCbCr24BT601_625
YCbCr36BT601_625
YCbCr48BT601_625
YCbCrBT601_525
YCbCr30BT601_525
YCbCr24BT601_525
YCbCr36BT601_525
YCbCr48BT601_525
```


## Functions
```@docs
luma
chroma_u
chroma_v
chroma_b
chroma_r
chroma_g
chroma_o
rgb_to_yuv
srgb_to_yuv
yuv_to_rgb
yuv_to_srgb
```