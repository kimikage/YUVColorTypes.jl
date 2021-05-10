using FFMPEG

# FFmpeg seems to value speed over accuracy regarding color management.
# However, FFmpeg is the de facto standard tool for encoding and decoding digital videos.
# Therefore, it is used here to generate reference test data.

FFMPEG.versioninfo()

const args_common = [
    "-loglevel", "verbose",
    "-y",
    "-f", "lavfi",
    "-i", "allrgb",
    "-vcodec", "rawvideo",
    "-pix_fmt", "yuv444p12le",
    "-vframes", "1",
]

# cf. https://ffmpeg.org/ffmpeg-filters.html#colorspace
const args_bt601_625_srgb = [
    "-vf", "colorspace=" * join(
        [
            "space=bt470bg",
            "trc=smpte170m",
            "primaries=bt470bg",
            "range=tv",
            "format=yuv444p12",
            "fast=0",
            "wpadapt=identity",
            "ispace=bt709",
            "itrc=srgb",
            "iprimaries=bt709",
            "irange=pc",
        ], ":"),
    "bt601_625_srgb.yuv",
]
const args_bt601_625 = [
    "-vf", "colorspace=" * join(
        [
            "space=bt470bg",
            "trc=smpte170m",
            "primaries=bt470bg",
            "range=tv",
            "format=yuv444p12",
            "fast=0",
            "wpadapt=identity",
            "ispace=bt470bg",
            "itrc=smpte170m",
            "iprimaries=bt470bg",
            "irange=pc",
        ], ":"),
    "bt601_625.yuv",
]
const args_bt601_525_srgb = [
    "-vf", "colorspace=" * join(
        [
            "space=smpte170m",
            "trc=smpte170m",
            "primaries=smpte170m",
            "range=tv",
            "format=yuv444p12",
            "fast=0",
            "wpadapt=identity",
            "ispace=bt709",
            "itrc=srgb",
            "iprimaries=bt709",
            "irange=pc",
        ], ":"),
    "bt601_625_srgb.yuv",
]
const args_bt601_525 = [
    "-vf", "colorspace=" * join(
        [
            "space=smpte170m",
            "trc=smpte170m",
            "primaries=smpte170m",
            "range=tv",
            "format=yuv444p12",
            "fast=0",
            "wpadapt=identity",
            "ispace=smpte170m",
            "itrc=smpte170m",
            "iprimaries=smpte170m",
            "irange=pc",
        ], ":"),
    "bt601_525.yuv",
]

prev = pwd()
cd(@__DIR__)

ffmpeg_exe(args_common..., args_bt601_625_srgb...)
ffmpeg_exe(args_common..., args_bt601_625...)
ffmpeg_exe(args_common..., args_bt601_525_srgb...)
ffmpeg_exe(args_common..., args_bt601_525...)

cd(prev)
