#-------------------------------------------------------------------------------
# ITU Recommendation BT.601-7 (03/2011)
#-------------------------------------------------------------------------------

"""
    YCbCrBT601_625{T,D} (= YCbCrBT601{T,D})

625-line version (previously designated PAL)

"""
const YCbCrBT601_625{T,D} = YUV{T,:BT601_625,true,D}


"""
    YCbCr24BT601_625{T}

8-bit representation of the 625-line BT.601 YCbCr color type.
Its *raw* components of type `T` usually have a value in [0, 256).
See also [`YCbCr30BT601_625`](@ref).
"""
const YCbCr24BT601_625{T} = YCbCrBT601_625{T,8}

"""
    YCbCr30BT601_625{T}

10-bit representation of the 625-line BT.601 YCbCr color type.
Its *raw* components of type `T` usually have a value in [0, 1024).
"""
const YCbCr30BT601_625{T} = YCbCrBT601_625{T,10}

"""
    YCbCr36BT601_625{T}

12-bit representation of the 625-line BT.601 YCbCr color type.
Its *raw* components of type `T` usually have a value in [0, 4096).
See also [`YCbCr30BT601_625`](@ref).
"""
const YCbCr36BT601_625{T} = YCbCrBT601_625{T,12}


"""
    YCbCr48BT601_625{T}

16-bit representation of the 625-line BT.601 YCbCr color type.
Its *raw* components of type `T` usually have a value in [0, 65536).
See also [`YCbCr30BT601_625`](@ref).
"""
const YCbCr48BT601_625{T} = YCbCrBT601_625{T,16}

#-------------------------------------------------------------------------------

"""
    YCbCrBT601_525{T,D}

525-line version (previously designated NTSC))

"""
const YCbCrBT601_525{T,D} = YUV{T,:BT601_525,true,D}

"""
    YCbCr24BT601_525{T}

8-bit representation of the 525-line BT.601 YCbCr color type.
Its *raw* components of type `T` usually have a value in [0, 256).
See also [`YCbCr30BT601_525`](@ref).
"""
const YCbCr24BT601_525{T} = YCbCrBT601_525{T,8}

"""
    YCbCr30BT601_525{T}

10-bit representation of the 525-line BT.601 YCbCr color type.
Its *raw* components of type `T` usually have a value in [0, 1024).
"""
const YCbCr30BT601_525{T} = YCbCrBT601_525{T,10}

"""
    YCbCr36BT601_525{T}

12-bit representation of the 525-line BT.601 YCbCr color type.
Its *raw* components of type `T` usually have a value in [0, 4096).
See also [`YCbCr30BT601_525`](@ref).
"""
const YCbCr36BT601_525{T} = YCbCrBT601_525{T,12}


"""
    YCbCr48BT601_525{T}

16-bit representation of the 525-line BT.601 YCbCr color type.
Its *raw* components of type `T` usually have a value in [0, 65536).
See also [`YCbCr30BT601_525`](@ref).
"""
const YCbCr48BT601_525{T} = YCbCrBT601_525{T,16}
