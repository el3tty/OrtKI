# onnxruntime >= 1.28 internal headers use C++20 (std::ranges)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# onnxruntime checkout next to OrtKI, built with its cmake-build script into build-cmake
get_filename_component(_ORT_DEFAULT_ROOT "${CMAKE_CURRENT_LIST_DIR}/../../onnxruntime" ABSOLUTE)
set(ONNXRUNTIME_ROOT "${_ORT_DEFAULT_ROOT}" CACHE PATH "onnxruntime source tree")
set(ONNXRUNTIME_BUILD_DIR "${ONNXRUNTIME_ROOT}/build-cmake" CACHE PATH "onnxruntime build tree")
set(ONNXRUNTIME_DEPS "${ONNXRUNTIME_BUILD_DIR}/_deps")

set(ONNX_INCLUDE_PATHS
    "${ONNXRUNTIME_ROOT}"
    "${ONNXRUNTIME_ROOT}/include"
    "${ONNXRUNTIME_ROOT}/include/onnxruntime"
    "${ONNXRUNTIME_ROOT}/onnxruntime"
    "${ONNXRUNTIME_BUILD_DIR}"
    "${ONNXRUNTIME_DEPS}/safeint-src"
    "${ONNXRUNTIME_DEPS}/gsl-src/include"
    "${ONNXRUNTIME_DEPS}/flatbuffers-src/include"
    "${ONNXRUNTIME_DEPS}/abseil_cpp-src"
    "${ONNXRUNTIME_DEPS}/onnx-src"
    "${ONNXRUNTIME_DEPS}/onnx-build"
    "${ONNXRUNTIME_DEPS}/protobuf-src/src"
    "${ONNXRUNTIME_DEPS}/mp11-src/include"
)
# protobuf >= 22 headers include utf8_range
if(EXISTS "${ONNXRUNTIME_DEPS}/protobuf-src/third_party/utf8_range")
    list(APPEND ONNX_INCLUDE_PATHS "${ONNXRUNTIME_DEPS}/protobuf-src/third_party/utf8_range")
endif()

set(ONNX_LIB_PREFIX "${CMAKE_STATIC_LIBRARY_PREFIX}")
set(ONNX_LIB_SUFFIX "${CMAKE_STATIC_LIBRARY_SUFFIX}")
set(ONNX_MAIN_LIB "${ONNXRUNTIME_BUILD_DIR}/${ONNX_LIB_PREFIX}onnxruntime_session${ONNX_LIB_SUFFIX}")
file(GLOB_RECURSE ONNX_ALL_LIBS "${ONNXRUNTIME_BUILD_DIR}/*${ONNX_LIB_SUFFIX}")
set(ONNX_DEP_LIBS "")
foreach(LIB_PATH ${ONNX_ALL_LIBS})
    if(NOT "${LIB_PATH}" STREQUAL "${ONNX_MAIN_LIB}" AND NOT "${LIB_PATH}" MATCHES "/install/")
        list(APPEND ONNX_DEP_LIBS "${LIB_PATH}")
    endif()
endforeach()

if(NOT WIN32)
    # static archives depend on each other in no particular order
    find_package(Threads REQUIRED)
    set(ONNX_DEP_LIBS "-Wl,--start-group" ${ONNX_DEP_LIBS} "-Wl,--end-group" Threads::Threads ${CMAKE_DL_LIBS})
endif()

include_directories("${ONNX_INCLUDE_PATHS}")
add_library(onnxruntime::onnxruntime STATIC IMPORTED)
set_target_properties(onnxruntime::onnxruntime PROPERTIES
    IMPORTED_LOCATION "${ONNX_MAIN_LIB}"
    INTERFACE_LINK_LIBRARIES "${ONNX_DEP_LIBS}"
)
