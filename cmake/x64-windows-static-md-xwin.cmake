set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

# Release-only: we ship a Release DLL. Halves dependency build time and avoids
# building debug variants of the vendored libraries.
set(VCPKG_BUILD_TYPE release)

# Cross-compilation: Linux host → Windows target
#set(VCPKG_CMAKE_SYSTEM_NAME Windows)
set(CMAKE_TRY_COMPILE_CONFIGURATION Release)
set(VCPKG_C_FLAGS_RELEASE "/EHsc")
set(VCPKG_CXX_FLAGS_RELEASE "/EHsc")
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
set(VCPKG_OVERLAY_PORTS "${CMAKE_CURRENT_LIST_DIR}/overlay-ports")
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/xwin-clang-cl.cmake")
