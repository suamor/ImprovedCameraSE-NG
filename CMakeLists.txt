cmake_minimum_required(VERSION 3.21)

# Get rid of overly annoying errors even though qmake is in PATH
set(QT_QMAKE_EXECUTABLE "/usr/bin/qmake")
# "Improved Camera SE" - Enables 1st Person body and allows playback of 3rd Person Animations
# One DLL supports Skyrim SE 1.5.97, AE 1.6.1130+, AE 1.7.104+.
project(ImprovedCameraSE VERSION 1.1.3 LANGUAGES CXX RC)

# Version components: the first three come from project(VERSION ...).
set(VERSION_MAJOR    "${PROJECT_VERSION_MAJOR}")
set(VERSION_MINOR    "${PROJECT_VERSION_MINOR}")
set(VERSION_REVISION "${PROJECT_VERSION_PATCH}")

# Explicit build number, preserved from the current version.h.
# Override with -DVERSION_BUILD=4230 for the next build.
set(VERSION_BUILD "4229" CACHE STRING "Improved Camera build number")

# Product metadata
set(VERSION_PRODUCTNAME_STR "ImprovedCameraSE")
set(VERSION_YEARS_STR      "(C) 2021-2026")
set(VERSION_AUTHOR_STR     "IC Team")
set(VERSION_LICENSE_STR    "(GPL v3.0)")

# Some versions of MSVC collide in own Windows headers with oder min/max declarations
if (WIN32)
    add_compile_definitions(NOMINMAX)
endif()

# alandtse's CommonLibSSE-NG, branch ng, pinned as a submodule (see
# .gitmodules). Consumed with add_subdirectory. Its own tests and their
# Catch2 dependency stay out of this build, and the add_commonlibsse_plugin
# helper is only pulled in by the library's prebuilt path, so the source
# build includes it here. The version goes into the DLL for the self-check
# line, read from the library's own project() rather than typed twice.
# SE and AE only. Fitting Room has never run on VR, and the library's VR-aware
# layouts hide the members and virtual functions past the point where VR
# compatibility breaks (NiSkinData's bone count, the flat CrosshairPickData,
# BSGeometry's update passes), all of which this mod reads.
set(ENABLE_SKYRIM_VR OFF CACHE BOOL "Improved Camera SE supports SE and AE only" FORCE)
set(BUILD_TESTS OFF CACHE BOOL "CommonLibSSE-NG tests are not built by this consumer" FORCE)
add_subdirectory(ImprovedCamera/vendor/CommonLibSSE-NG EXCLUDE_FROM_ALL)
# The preset's /we4062 (an enumerator left out of a switch) is this mod's rule
# and not the library's: BSFaceGenKeyframeMultiple.cpp leaves Type::Undefined
# out of one switch, and one refused library file means nothing links.
target_compile_options(CommonLibSSE PRIVATE /wd4062)
include("${CMAKE_CURRENT_SOURCE_DIR}/ImprovedCamera/vendor/CommonLibSSE-NG/cmake/CommonLibSSE.cmake")
get_directory_property(IC_COMMONLIB_VERSION DIRECTORY ImprovedCamera/vendor/CommonLibSSE-NG DEFINITION CommonLibSSE_VERSION)
message(STATUS "ImprovedCameraSE builds on CommonLibSSE-NG ${IC_COMMONLIB_VERSION}")
# jsoncpp's exported config predates CMake 3.5's policy floor.
set(CMAKE_POLICY_VERSION_MINIMUM 3.5)
find_package(jsoncpp CONFIG REQUIRED)
unset(CMAKE_POLICY_VERSION_MINIMUM)
# ⚠ We do not use the external package but keep version info (dependency for CommonLibSSE)
# Later updates will require update of custom port of imgui
# find_package(imgui CONFIG REQUIRED)
find_package(tinyxml2 CONFIG REQUIRED)
# ⚠ NAMED HERE SO A TEST TARGET CAN LINK IT. The plugin picks spdlog up through
# CommonLibSSE and its precompiled header, but a test executable carries neither,
# so a source shared between the two cannot log without this. BodySlideCatalog
# went 663 lines with no logging at all partly because adding one line did not
# build.
find_package(spdlog CONFIG REQUIRED)
# The overlay picker's thumbnails. WIC, which PreviewPng already encodes
# through, decodes DXT1 and DXT5 and REFUSES BC7; measured 2026-08-16, BC7 is
# 595 of the 1851 overlay textures on the reference load order. This decodes
# every block format on the CPU, so the work stays off the render thread and
# away from the game's immediate context.
find_package(directxtex CONFIG REQUIRED)
# OS-154: the ONLY dependency here that exists to hook a function ENTRY. Every
# other Fitting Room hook patches a call SITE, which CommonLib's trampoline does
# natively. The item-preview appender cannot be reached that way: it is
# non-virtual, and callers differ per runtime, so a call-site hook would be a
# handful of patches that silently under-cover when one changes shape.
# SafetyHook relocates the stolen prologue, which CommonLib's write_branch does
# NOT do, and that is what makes one entry detour possible.
# ⚠ zydis is pinned to 4.1.1 on purpose: safetyhook 0.7.0 needs the 4.x decoder
# API and the vcpkg baseline resolves 3.2.1, which fails to compile with
# "ZYDIS_STACK_WIDTH_64: undeclared identifier". Both need overrides entries
# because the baseline predates the safetyhook port.
find_package(safetyhook CONFIG REQUIRED)

add_commonlibsse_plugin(${PROJECT_NAME}
    SOURCES
        ImprovedCamera/PCH/PCH.h
        ImprovedCamera/PCH/PCH.cpp
    	ImprovedCamera/source/api/skse_api.cpp
    	ImprovedCamera/source/build/vendor.cpp
    	ImprovedCamera/source/cameras/DeathCinematic.cpp
    	ImprovedCamera/source/cameras/Dragon.cpp
    	ImprovedCamera/source/cameras/FirstPerson.cpp
    	ImprovedCamera/source/cameras/Furniture.cpp
    	ImprovedCamera/source/cameras/Horse.cpp
    	ImprovedCamera/source/cameras/ICamera.cpp
    	ImprovedCamera/source/cameras/Ragdoll.cpp
    	ImprovedCamera/source/cameras/ThirdPerson.cpp
    	ImprovedCamera/source/cameras/Transition.cpp
    	ImprovedCamera/source/dllmain.cpp
    	ImprovedCamera/source/menu/Camera.cpp
    	ImprovedCamera/source/menu/EventsMenu.cpp
    	ImprovedCamera/source/menu/Fov.cpp
    	ImprovedCamera/source/menu/General.cpp
    	ImprovedCamera/source/menu/Headbob.cpp
    	ImprovedCamera/source/menu/Hide.cpp
    	ImprovedCamera/source/menu/IMenu.cpp
    	ImprovedCamera/source/menu/NearDistance.cpp
    	ImprovedCamera/source/menu/RestrictAngles.cpp
    	ImprovedCamera/source/menu/UIMenu.cpp
    	ImprovedCamera/source/menu/UIMenuHelper.cpp
    	ImprovedCamera/source/plugin.cpp
    	ImprovedCamera/source/skyrimse/Addresses.cpp
    	ImprovedCamera/source/skyrimse/EventsSkyrim.cpp
    	ImprovedCamera/source/skyrimse/Hooks.cpp
    	ImprovedCamera/source/skyrimse/ImprovedCameraSE.cpp
    	ImprovedCamera/source/skyrimse/SkyrimSE.cpp
    	ImprovedCamera/source/systems/Config.cpp
    	ImprovedCamera/source/systems/Graphics.cpp
    	ImprovedCamera/source/systems/Logging.cpp
    	ImprovedCamera/source/systems/UI.cpp
    	ImprovedCamera/source/systems/Window.cpp
    	ImprovedCamera/source/utils/ICMath.cpp
    	ImprovedCamera/source/utils/PatternScan.cpp
    	ImprovedCamera/source/utils/Utils.cpp
)

set(GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
set(GENERATED_INCLUDE_DIR "${GENERATED_DIR}/include")
set(GENERATED_RESOURCE_DIR "${GENERATED_DIR}/cmake")

file(MAKE_DIRECTORY
    "${GENERATED_INCLUDE_DIR}"
    "${GENERATED_RESOURCE_DIR}"
)

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/version.h.in"
    "${GENERATED_INCLUDE_DIR}/version.h"
    @ONLY
)

# ⚠ A CRASH LOG THAT CANNOT NAME OUR BUILD COSTS A DIAGNOSIS. This puts the
# version into the DLL itself, so Crash Logger and Trainwreck print it beside
# our name like every other plugin. Generated from project() so it cannot
# drift from the other version files.
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/version.rc.in"
    "${GENERATED_RESOURCE_DIR}/version.rc"
    @ONLY
)

target_include_directories(ImprovedCameraSE BEFORE PRIVATE
    "${GENERATED_INCLUDE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

target_sources(ImprovedCameraSE PRIVATE
    "${GENERATED_RESOURCE_DIR}/version.rc"
)

target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_23)
target_precompile_headers(${PROJECT_NAME} PRIVATE ImprovedCamera/PCH/PCH.h)
# ImprovedCamera/vendor holds the vendored headers glm, imgui, mINI, stb
# resolved at runtime via RequestFUCK / GetProcAddress - no link-time coupling).
target_include_directories(${PROJECT_NAME} PRIVATE ImprovedCamera/include ImprovedCamera/PCH ImprovedCamera/vendor ImprovedCamera/vendor/glm ImprovedCamera/vendor/imgui ImprovedCamera/vendor/mINI/src ImprovedCamera/vendor/minhook/include)
# Additional dependencies for dll (see above)
target_link_libraries(${PROJECT_NAME} PRIVATE JsonCpp::JsonCpp
                                              safetyhook::safetyhook)

target_compile_definitions(${PROJECT_NAME} PRIVATE IMGUI_DEFINE_MATH_OPERATORS)
target_compile_definitions(${PROJECT_NAME} PRIVATE
    IC_BUILD_ID="${IC_BUILD_ID}"
    IC_COMMONLIB_VERSION="${IC_COMMONLIB_VERSION}"
    IC_DATA_SUBDIR="${IC_DATA_SUBDIR}")

# Ship debug symbols with the optimised build, so a crash address can be
# turned into a function name.
#
# ⚠ /Zi AND /DEBUG DO NOT CHANGE THE GENERATED CODE, but /DEBUG alone WOULD:
# the linker silently turns /OPT:REF and /OPT:ICF off when /DEBUG is given, so
# they are asked for explicitly. Without them the binary really would be a
# different one from the build that was tested, which is the opposite of what a
# diagnostic aid should do.
if (MSVC)
    target_compile_options(${PROJECT_NAME} PRIVATE $<$<NOT:$<CONFIG:Debug>>:/Zi>)
    target_link_options(${PROJECT_NAME} PRIVATE
        $<$<NOT:$<CONFIG:Debug>>:/DEBUG /OPT:REF /OPT:ICF>)
endif ()

# Pure-logic unit tests (no RE/engine deps).

if(NOT DEFINED OUTPUT_FOLDER)
    set(OUTPUT_FOLDER "$ENV{TEMP}/improvedcamerase-unrouted-build")
endif()
set(DLL_FOLDER "${OUTPUT_FOLDER}/SKSE/Plugins")
message(STATUS "ImprovedCameraSE deploy folder: ${DLL_FOLDER}")
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${DLL_FOLDER}"
    # copy_directory rather than copy_if_different on named files, so anything
    # dropped into assets/ is picked up with no CMakeLists change;
    # copy_directory_if_different needs CMake 3.26 and this project's floor is
    # 3.21, so this always rewrites rather than skipping unchanged files, which
    # is cheap for a folder of small JSON files and one font.
    # REWORK required: fomod is not usable in this state because we have NG setup (single dll)
    # COMMAND "${CMAKE_COMMAND}" -E copy_directory "${CMAKE_SOURCE_DIR}/assets" "${DLL_FOLDER}/"
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different "$<TARGET_FILE:${PROJECT_NAME}>" "${DLL_FOLDER}/$<TARGET_FILE_NAME:${PROJECT_NAME}>"
    VERBATIM)
set(IMGUI_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ImprovedCamera/vendor/imgui")

target_sources(ImprovedCameraSE PRIVATE
    "${IMGUI_DIR}/imgui.cpp"
    "${IMGUI_DIR}/imgui_draw.cpp"
    "${IMGUI_DIR}/imgui_tables.cpp"
    "${IMGUI_DIR}/imgui_widgets.cpp"
    "${IMGUI_DIR}/imgui_demo.cpp"
)

target_include_directories(ImprovedCameraSE BEFORE PRIVATE
    "${IMGUI_DIR}"
)
enable_language(C)

set(MINHOOK_DIR
    "${CMAKE_CURRENT_SOURCE_DIR}/ImprovedCamera/vendor/minhook"
)

add_library(ImprovedCameraMinHook STATIC
    "${MINHOOK_DIR}/src/buffer.c"
    "${MINHOOK_DIR}/src/hook.c"
    "${MINHOOK_DIR}/src/trampoline.c"
    "${MINHOOK_DIR}/src/hde/hde64.c"
)

target_include_directories(ImprovedCameraMinHook PUBLIC
    "${MINHOOK_DIR}/include"
)

target_link_libraries(ImprovedCameraSE PRIVATE
    ImprovedCameraMinHook
)
