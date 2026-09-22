# Must match packages/cmake-0001-ExternalProject-changes.patch.
set(_ep_version "v3.26.4")

set(_ep_root
    "${CMAKE_CURRENT_BINARY_DIR}/externalproject-${_ep_version}")
set(_ep_archive "${_ep_root}/modules.tar.gz")
set(_ep_stage "${_ep_root}/source")
set(_ep_module "${_ep_stage}/Modules/ExternalProject.cmake")
set(_ep_patch
    "${CMAKE_CURRENT_SOURCE_DIR}/packages/cmake-0001-ExternalProject-changes.patch")
set(_ep_marker "${_ep_root}/ready.txt")

if(NOT EXISTS "${_ep_patch}")
    message(FATAL_ERROR "ExternalProject patch not found: ${_ep_patch}")
endif()

find_program(_ep_curl NAMES curl REQUIRED)
find_program(_ep_tar NAMES tar REQUIRED)
find_program(_ep_patch_program NAMES patch REQUIRED)

file(SHA256 "${_ep_patch}" _ep_patch_hash)
set(_ep_signature "${_ep_version}:${_ep_patch_hash}")

set(_ep_ready FALSE)
if(EXISTS "${_ep_marker}" AND EXISTS "${_ep_module}")
    file(READ "${_ep_marker}" _ep_saved_signature)
    if("${_ep_saved_signature}" STREQUAL "${_ep_signature}")
        set(_ep_ready TRUE)
    endif()
endif()

if(NOT _ep_ready)
    file(MAKE_DIRECTORY "${_ep_root}")

    # Remove only this script's staging directory, not the build directory.
    file(REMOVE_RECURSE "${_ep_stage}")
    file(REMOVE "${_ep_marker}")
    file(MAKE_DIRECTORY "${_ep_stage}/Modules")

    message(STATUS "Downloading CMake ${_ep_version} ExternalProject modules")

    execute_process(
        COMMAND "${_ep_curl}"
            -fL
            --retry 5
            --connect-timeout 30
            --max-time 300
            "https://gitlab.kitware.com/cmake/cmake/-/archive/${_ep_version}/cmake-${_ep_version}.tar.gz?path=Modules/ExternalProject"
            -o "${_ep_archive}"
        RESULT_VARIABLE _ep_result
    )

    if(NOT "${_ep_result}" STREQUAL "0")
        file(REMOVE "${_ep_archive}")
        message(FATAL_ERROR
            "ExternalProject archive download failed: ${_ep_result}")
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
            "ExternalProject archive extraction failed: ${_ep_result}")
    endif()

    # Download the top-level module from the same version.
    execute_process(
        COMMAND "${_ep_curl}"
            -fL
            --retry 5
            --connect-timeout 30
            --max-time 300
            "https://gitlab.kitware.com/cmake/cmake/-/raw/${_ep_version}/Modules/ExternalProject.cmake"
            -o "${_ep_module}"
        RESULT_VARIABLE _ep_result
    )

    if(NOT "${_ep_result}" STREQUAL "0")
        file(REMOVE "${_ep_module}")
        message(FATAL_ERROR
            "ExternalProject.cmake download failed: ${_ep_result}")
    endif()

    if(NOT EXISTS "${_ep_stage}/Modules/ExternalProject/gitclone.cmake.in")
        message(FATAL_ERROR
            "Archive is missing Modules/ExternalProject/gitclone.cmake.in")
    endif()

    # Check compatibility before changing any source files.
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
            "Check that the patch and CMake version match.")
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

    file(WRITE "${_ep_marker}" "${_ep_signature}")
endif()

include("${_ep_module}")
