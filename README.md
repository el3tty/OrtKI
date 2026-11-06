# OrtKI for nncase k230

OrtKI is an unofficial kernel interface for [onnxruntime](https://github.com/microsoft/onnxruntime). It runs single ONNX
operators from C or C#, without building a whole model first. [nncase](https://github.com/kendryte/nncase) uses it to
evaluate operators while compiling a model.

This is a fork of [kendryte/OrtKI](https://github.com/kendryte/OrtKI). The `k230` branch exists to support the `k230` branch
of [el3tty/nncase](https://github.com/el3tty/nncase), and is not supported by the upstream project.

## Packages

The nncase compiler needs `libortki` and `OrtKISharp` 0.0.3, which are not on nuget.org. Download them from the
[v0.0.3-k230 release](https://github.com/el3tty/OrtKI/releases/tag/v0.0.3-k230). The
[nncase build instructions](https://github.com/el3tty/nncase/blob/k230/docs/k230-branch.md#compiler-1) say where they go.

Linux needs x86-64 with glibc 2.38 or newer. Windows needs x64 with the Visual C++ Redistributable.

## Changes from upstream

* Targets .NET 9.
* Built and tested on Windows x64 and Linux x64 only. Upstream's package also covers macOS on x64 and Arm64.
* Moves to a newer onnxruntime, and generates operators from onnx 1.21 (opset 21). The packages use onnxruntime 1.27.0 on
  Windows and 1.32.0 on Linux.
* Links a source build of onnxruntime through `cmake/onnxruntimeConfig.cmake`, instead of the Conan package.
* Optional inputs can be null.
* A failed onnxruntime call raises `OrtKIException` with the error message, instead of returning an empty result.
* `ortki_parse_onnx_text()` and `OrtKI.ParseOnnxText()` turn a model in the ONNX text format into a serialized `ModelProto`.
  The nncase tests use this to write test models as text.

## Building

Most people only need the packages above. To build them yourself, check out onnxruntime next to this repository, then build
it as static libraries into `../onnxruntime/build-cmake-rel`, and this repository against it. On Linux with clang 22:

```
cmake -S ../onnxruntime/cmake -B ../onnxruntime/build-cmake-rel -G Ninja -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_AR=llvm-ar -DCMAKE_RANLIB=llvm-ranlib \
    -DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=lld -DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=lld \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON -Donnxruntime_BUILD_SHARED_LIB=OFF -Donnxruntime_BUILD_UNIT_TESTS=OFF
cmake --build ../onnxruntime/build-cmake-rel --target all re2
cmake -S . -B build-rel -G Ninja -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_AR=llvm-ar -DCMAKE_RANLIB=llvm-ranlib \
    -DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=lld -DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=lld \
    -Donnxruntime_DIR=$PWD/cmake -DONNXRUNTIME_BUILD_DIR=$PWD/../onnxruntime/build-cmake-rel \
    -DCMAKE_INSTALL_PREFIX=$PWD/install -DBUILD_SHARED_LIBS=ON
cmake --build build-rel
cmake --install build-rel
```

On Windows, run the same steps from a Visual Studio 2022 developer shell without the clang and linker options, adding
`-DONNX_USE_MSVC_STATIC_RUNTIME=OFF -Dprotobuf_MSVC_STATIC_RUNTIME=OFF -DABSL_MSVC_STATIC_RUNTIME=OFF
-Dgtest_force_shared_crt=ON` to the onnxruntime configure step. Use MSVC 14.42: 14.51 stops on a deprecation warning in
onnxruntime. The published Windows library uses onnxruntime 1.27.0 with a backport to its onnx patch of a later upstream fix, for a
static initialization order crash at start-up. Newer onnxruntime versions have the fix and need no patch, as the Linux
build shows.

`CSharp/libortki/libortki.nuspec` packs `install/bin/ortki.dll` and `install/lib/libortki.so`, so `install` has to hold both
builds. A rebuilt package has a different hash, so nncase's lock files need updating with `dotnet restore --force-evaluate`.

## Licence

MIT, see [LICENSE](LICENSE). The packages link onnxruntime and its dependencies statically; their notices are in
`THIRD-PARTY-NOTICES.txt` on the release page.
