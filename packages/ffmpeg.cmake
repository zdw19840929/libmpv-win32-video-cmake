# Broad playback support; Vulkan rendering is configured separately in mpv/libplacebo.
# GPL is enabled, matching the supplied configuration.
ExternalProject_Add(ffmpeg
        DEPENDS
        amf-headers
        avisynth-headers
        ${nvcodec_headers}
        bzip2
        lame
        lcms2
        openssl
        libssh
        libsrt
        libass
        libbluray
        libdvdnav
        libdvdread
        libmodplug
        libpng
        libsoxr
        libbs2b
        libwebp
        libzimg
        libmysofa
        fontconfig
        harfbuzz
        opus
        speex
        vorbis
        libvpl
        libjxl
        libxml2
        shaderc
        libplacebo
        dav1d
        openal-soft
    GIT_REPOSITORY https://github.com/FFmpeg/FFmpeg.git
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_TAG release/7.1
    GIT_CLONE_FLAGS "--sparse --filter=tree:0"
    GIT_CLONE_POST_COMMAND "sparse-checkout set --no-cone /* !tests/ref/fate"
    PATCH_COMMAND ${EXEC} git apply ${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg-*.patch
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} CONF=1 <SOURCE_DIR>/configure
        --cross-prefix=${TARGET_ARCH}-
        --prefix=${MINGW_INSTALL_PREFIX}
        --arch=${TARGET_CPU}
        --target-os=mingw32
        --pkg-config-flags=--static
        --enable-cross-compile

        --enable-gpl
        --disable-nonfree
        --enable-version3
        --enable-static
        --disable-shared
        --disable-vulkan
        --disable-iconv
        --enable-stripping

        --disable-muxers
        --enable-decoders
        --disable-encoders
        --enable-demuxers
        --enable-parsers
        --disable-protocols
        --disable-filters
        --disable-doc
        --disable-postproc
        --disable-programs
        --disable-gray
        --disable-swscale-alpha

        --enable-bsfs

        --enable-amf
        --enable-dxva2
        --enable-d3d11va

        --disable-vaapi
        --disable-vdpau
        --disable-bzlib
        --disable-libmfx
        --disable-libuavs3d
        --disable-linux-perf
        --disable-videotoolbox
        --disable-audiotoolbox

        --disable-bsf=mjpeg2jpeg
        --disable-bsf=mjpega_dump_header
        --disable-bsf=mov2textsub
        --disable-bsf=text2movsub
        --disable-bsf=eac3_core

        --enable-small
        --enable-hwaccels
        --enable-optimizations
        --enable-runtime-cpudetect

        --enable-openssl
        --enable-libssh

        --enable-libdav1d

        --enable-libjxl

        --enable-libvpl
        --enable-libbs2b
        --enable-libwebp
        --enable-libzimg
        --enable-libxml2
        --enable-libsoxr
        --enable-libspeex
        --enable-libmysofa
        --enable-libshaderc
        --enable-libfribidi
        --enable-libfreetype

        --enable-avutil
        --enable-avcodec
        --enable-avfilter
        --enable-avformat
        --enable-avdevice
        --enable-swscale
        --enable-swresample

        --enable-filter=overlay
        --enable-filter=equalizer
        --enable-filter=vflip
        --enable-filter=hflip
        --enable-filter=transpose
        --enable-filter=rotate
        --enable-filter=crop
        --enable-filter=scale
        --enable-filter=format
        --enable-filter=fps
        --enable-filter=minterpolate
        --enable-filter=trim
        --enable-filter=setpts
        --enable-filter=null
        --enable-filter=aecho

        --enable-protocol=async
        --enable-protocol=cache
        --enable-protocol=crypto
        --enable-protocol=data
        --enable-protocol=ffrtmphttp
        --enable-protocol=file
        --enable-protocol=ftp
        --enable-protocol=hls
        --enable-protocol=http
        --enable-protocol=httpproxy
        --enable-protocol=https
        --enable-protocol=pipe
        --enable-protocol=rtmp
        --enable-protocol=rtmps
        --enable-protocol=rtmpt
        --enable-protocol=rtmpts
        --enable-protocol=rtp
        --enable-protocol=subfile
        --enable-protocol=tcp
        --enable-protocol=tls
        --enable-protocol=srt
        --enable-protocol=udp

        --enable-encoder=mjpeg
	--enable-encoder=ljpeg
	--enable-encoder=jpegls
	--enable-encoder=jpeg2000
	--enable-encoder=png
	--enable-encoder=jpegls

        --enable-network
        
        ${ffmpeg_cuda}
        ${ffmpeg_lto}
        --extra-cflags='-Wno-error=int-conversion'
        "--extra-libs='${ffmpeg_extra_libs}'" # -lstdc++ / -lc++ needs by libjxl and shaderc
        BUILD_COMMAND ${MAKE}
        INSTALL_COMMAND ${MAKE} install
        LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

force_rebuild_git(ffmpeg)
cleanup(ffmpeg install)
