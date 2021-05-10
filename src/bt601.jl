#-------------------------------------------------------------------------------
# ITU Recommendation BT.601-7 (03/2011)
#-------------------------------------------------------------------------------

"""
    YCbCrBT601_625{T,D}

The 625-line version of BT.601 YCbCr color type (previously designated PAL).
"""
const YCbCrBT601_625{T,D} = YUV{T,:BT601_625,true,false,D}


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



const AYCbCrBT601_625{T,D} = AYUV{T,:BT601_625,true,false,D}

const AYCbCr32BT601_625{T} = AYCbCrBT601_625{T,8}
const AYCbCr40BT601_625{T} = AYCbCrBT601_625{T,10}
const AYCbCr48BT601_625{T} = AYCbCrBT601_625{T,12}
const AYCbCr64BT601_625{T} = AYCbCrBT601_625{T,16}


const YCbCrABT601_625{T,D} = YUVA{T,:BT601_625,true,false,D}

const YCbCrA32BT601_625{T} = YCbCrABT601_625{T,8}
const YCbCrA40BT601_625{T} = YCbCrABT601_625{T,10}
const YCbCrA48BT601_625{T} = YCbCrABT601_625{T,12}
const YCbCrA64BT601_625{T} = YCbCrABT601_625{T,16}

#-------------------------------------------------------------------------------

"""
    YCbCrBT601_525{T,D}

The 525-line version of BT.601 YCbCr color type (previously designated NTSC).

"""
const YCbCrBT601_525{T,D} = YUV{T,:BT601_525,true,false,D}

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


const AYCbCrBT601_525{T,D} = AYUV{T,:BT601_525,true,false,D}

const AYCbCr32BT601_525{T} = AYCbCrBT601_525{T,8}
const AYCbCr40BT601_525{T} = AYCbCrBT601_525{T,10}
const AYCbCr48BT601_525{T} = AYCbCrBT601_525{T,12}
const AYCbCr64BT601_525{T} = AYCbCrBT601_525{T,16}


const YCbCrABT601_525{T,D} = YUVA{T,:BT601_525,true,false,D}

const YCbCrA32BT601_525{T} = YCbCrABT601_525{T,8}
const YCbCrA40BT601_525{T} = YCbCrABT601_525{T,10}
const YCbCrA48BT601_525{T} = YCbCrABT601_525{T,12}
const YCbCrA64BT601_525{T} = YCbCrABT601_525{T,16}

#-------------------------------------------------------------------------------

cicp_type(::Type{C}) where {U,R,C<:YUVT{:BT601_625,U,R}} = Cicp{0x5,0x6,0x5,UInt8(R)}
cicp_type(::Type{C}) where {U,R,C<:YUVT{:BT601_525,U,R}} = Cicp{0x6,0x6,0x6,UInt8(R)}
