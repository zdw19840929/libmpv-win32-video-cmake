ExternalProject_Add(libudfread
    URL https://download.videolan.org/pub/videolan/libudfread/libudfread-1.1.2.tar.bz2
    URL_HASH SHA256=d5946f19b27288ce0911eb11fe583c136767421220ece3bafc96245efd208915
    DOWNLOAD_DIR ${SOURCE_LOCATION}
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} CONF=1 <SOURCE_DIR>/configure
        --host=${TARGET_ARCH}
        --prefix=${MINGW_INSTALL_PREFIX}
        --disable-shared
    BUILD_COMMAND ${MAKE}
    INSTALL_COMMAND ${MAKE} install
    LOG_DOWNLOAD 1
    LOG_UPDATE 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_INSTALL 1
)

cleanup(libudfread install)
