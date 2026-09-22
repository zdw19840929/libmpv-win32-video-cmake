if(NOT DEFINED LLVM_SOURCE_DIR)
    message(FATAL_ERROR "LLVM_SOURCE_DIR is required")
endif()

set(header
    "${LLVM_SOURCE_DIR}/libcxx/include/__locale_dir/locale_base_api/win32.h")

if(NOT EXISTS "${header}")
    message(FATAL_ERROR "Header not found: ${header}")
endif()

file(READ "${header}" content)

string(FIND "${content}" "#include <stdlib.h>" existing_include)

if(existing_include EQUAL -1)
    string(FIND "${content}" "#include " first_include)

    if(first_include EQUAL -1)
        message(FATAL_ERROR "Cannot find include section in ${header}")
    endif()

    string(SUBSTRING "${content}" 0 ${first_include} prefix)
    string(SUBSTRING "${content}" ${first_include} -1 suffix)

    file(WRITE "${header}"
        "${prefix}#include <stdlib.h>\n${suffix}")

    message(STATUS "Added stdlib.h to Windows locale header")
else()
    message(STATUS "Windows locale header already includes stdlib.h")
endif()
