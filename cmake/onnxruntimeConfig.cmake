set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(ONNXRUNTIME_ROOT "c:/AS/kendryte/onnxruntime")
set(ONNXRUNTIME_BUILD_DIR "${ONNXRUNTIME_ROOT}/build-cmake")
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
    "${ONNXRUNTIME_ROOT}/${ONNXRUNTIME_BUILD_DIR}"
)

set(ONNX_DEP_LIBS "")
set(ONNX_MAIN_LIB "${ONNXRUNTIME_BUILD_DIR}/onnxruntime_session.lib")
file(GLOB_RECURSE ONNX_ALL_LIBS "${ONNXRUNTIME_BUILD_DIR}/*.lib")
foreach(LIB_PATH ${ONNX_ALL_LIBS})
    if(NOT "${LIB_PATH}" STREQUAL "${ONNX_MAIN_LIB}")
        list(APPEND ONNX_DEP_LIBS "${LIB_PATH}")
    endif()
endforeach()

include_directories("${ONNX_INCLUDE_PATHS}")
add_library(onnxruntime::onnxruntime STATIC IMPORTED)
set_target_properties(onnxruntime::onnxruntime PROPERTIES
    IMPORTED_LOCATION "${ONNX_MAIN_LIB}"
    INTERFACE_LINK_LIBRARIES "${ONNX_DEP_LIBS}"
)