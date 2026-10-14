# cmake/xwin-clang-cl.cmake

# Who came on the idea to use debug HERE in all places ?!?
set(CMAKE_TRY_COMPILE_CONFIGURATION Release)

set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_TRY_COMPILE_CONFIGURATION Release)

# Compilers
set(CMAKE_C_COMPILER   clang-cl)
set(CMAKE_CXX_COMPILER clang-cl)

# Linker
set(CMAKE_LINKER       lld-link)
set(CMAKE_AR           llvm-lib)
set(CMAKE_RANLIB       llvm-lib)

# Another bastard that tries to prevent build check
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")

# Sysroot / SDK
if(DEFINED ENV{XWIN_DIR})
    set(XWIN_DIR "$ENV{XWIN_DIR}")
else()
    message(FATAL_ERROR "XWIN_DIR not set; please set it to the xwin SDK root")
endif()

# Fix problems with recognizing the linker
set(CMAKE_C_FLAGS_INIT "${CMAKE_C_FLAGS_INIT} -fuse-ld=lld-link")
set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} -fuse-ld=lld-link")
set(CMAKE_RC_FLAGS_INIT "${CMAKE_RC_FLAGS_INIT}")
# Ugly fix for missing exceptions
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHsc")

# Include and library paths for MSVC ABI
set(xwin_include_flags "/imsvc${XWIN_DIR}/crt/include /imsvc${XWIN_DIR}/sdk/include/ucrt /imsvc${XWIN_DIR}/sdk/include/um /imsvc${XWIN_DIR}/sdk/include/winrt /imsvc${XWIN_DIR}/sdk/include/shared /imsvc${XWIN_DIR}/sdk/include")
set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   ${xwin_include_flags}" )
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${xwin_include_flags}" )
set(CMAKE_RC_FLAGS  "${CMAKE_RC_FLAGS} ${xwin_include_flags}" )

set(CMAKE_EXE_LINKER_FLAGS    "${CMAKE_EXE_LINKER_FLAGS}    -LIBPATH:${XWIN_DIR}/crt/lib/x86_64 -LIBPATH:${XWIN_DIR}/sdk/lib/ucrt/x86_64 -LIBPATH:${XWIN_DIR}/sdk/lib/um/x86_64")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -LIBPATH:${XWIN_DIR}/crt/lib/x86_64 -LIBPATH:${XWIN_DIR}/sdk/lib/ucrt/x86_64 -LIBPATH:${XWIN_DIR}/sdk/lib/um/x86_64")

# Ensure clang uses lld-link
set(CMAKE_EXE_LINKER_FLAGS    "${CMAKE_EXE_LINKER_FLAGS}    -fuse-ld=lld-link")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -fuse-ld=lld-link")

# Target triplet (optional but explicit)
set(CMAKE_C_COMPILER_TARGET   x86_64-pc-windows-msvc)
set(CMAKE_CXX_COMPILER_TARGET x86_64-pc-windows-msvc)

# Let CMake know we’re cross-compiling
set(CMAKE_CROSSCOMPILING TRUE)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
