# This version must match the ExternalProject patch.
set(_ep_version "v3.26.4")

set(_ep_root
    "${CMAKE_CURRENT_BINARY_DIR}/externalproject-${_ep_version}-github")
set(_ep_archive "${_ep_root}/cmake.tar.gz")
set(_ep_stage "${_ep_root}/source")
set(_ep_module "${_ep_stage}/Modules/ExternalProject.cmake")
set(_ep_patch
    "${CMAKE_CURRENT_SOURCE_DIR}/packages/cmake-0001-ExternalProject-changes.patch")
set(_ep_marker "${_ep_root}/ready.txt")

if(NOT EXISTS "${_ep_patch}")
    message(FATAL_ERROR
        "ExternalProject patch not found: ${_ep_patch}")
endif()

find_program(_ep_curl NAMES curl REQUIRED)
find_program(_ep_tar NAMES tar REQUIRED)
find_program(_ep_patch_program NAMES patch REQUIRED)

file(SHA256 "${_ep_patch}" _ep_patch_hash)
set(_ep_signature "${_ep_version}:github:${_ep_patch_hash}")

set(_ep_ready FALSE)

if(EXISTS "${_ep_marker}" AND EXISTS "${_ep_module}")
    file(READ "${_ep_marker}" _ep_saved_signature)
    if("${_ep_saved_signature}" STREQUAL "${_ep_signature}")
        set(_ep_ready TRUE)
    endif()
endif()

if(NOT _ep_ready)
    file(MAKE_DIRECTORY "${_ep_root}")

    # Clean only this script's staging directory.
    file(REMOVE_RECURSE "${_ep_stage}")
    file(REMOVE "${_ep_marker}" "${_ep_archive}")
    file(MAKE_DIRECTORY "${_ep_stage}")

    message(STATUS
        "Downloading CMake ${_ep_version} from the official GitHub mirror")

    execute_process(
        COMMAND "${_ep_curl}"
            -fL
            --retry 5
            --connect-timeout 30
            --max-time 300
            "https://codeload.github.com/Kitware/CMake/tar.gz/refs/tags/${_ep_version}"
            -o "${_ep_archive}"
        RESULT_VARIABLE _ep_result
    )

    if(NOT "${_ep_result}" STREQUAL "0")
        file(REMOVE "${_ep_archive}")
        message(FATAL_ERROR
            "CMake archive download failed: ${_ep_result}")
    endif()

    execute_process(
        COMMAND "${_ep_tar}"
            -xf "${_ep_archive}"
            --strip-components=1
            -C "${_ep_stage}"
        RESULT_VARIABLE _ep_result
    )

    if(NOT "${_ep_result}" STREQUAL "0")
        file(REMOVE "${_ep_archive}")
        message(FATAL_ERROR
            "CMake archive extraction failed: ${_ep_result}")
    endif()

    # The full archive already contains both the module and its templates.
    if(NOT EXISTS "${_ep_module}")
        message(FATAL_ERROR
            "Archive is missing Modules/ExternalProject.cmake")
    endif()

    if(NOT EXISTS
        "${_ep_stage}/Modules/ExternalProject/gitclone.cmake.in")
        message(FATAL_ERROR
            "Archive is missing Modules/ExternalProject/gitclone.cmake.in")
    endif()

    message(STATUS "Checking ExternalProject patch")

    execute_process(
        COMMAND "${_ep_patch_program}"
            --batch
            --forward
            --dry-run
            -p1
            -i "${_ep_patch}"
        WORKING_DIRECTORY "${_ep_stage}"
        RESULT_VARIABLE _ep_result
    )

    if(NOT "${_ep_result}" STREQUAL "0")
        message(FATAL_ERROR
            "ExternalProject patch does not apply to ${_ep_version}. "
            "Check that the patch matches this CMake version.")
    endif()

    execute_process(
        COMMAND "${_ep_patch_program}"
            --batch
            --forward
            -p1
            -i "${_ep_patch}"
        WORKING_DIRECTORY "${_ep_stage}"
        RESULT_VARIABLE _ep_result
    )

    if(NOT "${_ep_result}" STREQUAL "0")
        message(FATAL_ERROR
            "ExternalProject patch failed: ${_ep_result}")
    endif()

    # Mark ready only after download, extraction and patching succeed.
    file(WRITE "${_ep_marker}" "${_ep_signature}")
endif()

include("${_ep_module}")
