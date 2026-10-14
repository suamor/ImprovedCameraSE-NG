#!/bin/bash

set -u

error=0

# Allow the caller to override the output directory:
#
#   CompileShadersOutput=SomeDirectory ./compile-shaders.sh
#
output_dir="${1:-${CompileShadersOutput:-Compiled}}"
fxc="${2:-fxc}"

# Match the batch file's behavior of tolerating a trailing space.
output_dir="${output_dir%"${output_dir##*[![:space:]]}"}"

mkdir -p "$output_dir" || exit 1

# Common FXC options translated for the fxc -> dxc wrapper:
#
#   /nologo          no equivalent needed
#   /WX              -WX
#   /Ges             -Ges
#   /Zi              -Zi
#   /Zpc             -Zpc
#   /Qstrip_reflect -Qstrip_reflect
#   /Qstrip_debug   -Qstrip_debug
#
# /Fd is deliberately not passed. The wrapper removes -Fd because native
# dxc does not use FXC's PDB output behavior in this compatibility mode.
common_args=(
    -WX
    -Ges
    -Zi
    -Zpc
    -Qstrip_reflect
    -Qstrip_debug
)

compile_shader()
{
    local source="$1"
    local entry="$2"
    local profile="$3"
    local suffix="$4"
    shift 4

    local output="${output_dir}/${source}_${entry}${suffix}.inc"


    # The suffix distinguishes the generated header files. It must NOT be
    # part of the C++ array name: cs5 and cs4 headers are included in
    # separate namespaces in BCDirectCompute.cpp.
    local variable="${source}_${entry}"

    local args=(
        "$source.hlsl"
        "${common_args[@]}"
        -T "$profile"
        -E "$entry"
        -Fh "$output"
        -Vn "$variable"
        "$@"
    )

    echo
    echo "fxc ${args[*]}"

    if ! "$fxc" "${args[@]}"; then
        error=1
    fi
}

# DirectXTex/DirectXTex/Shaders/CompileShaders.cmd:
#
#   BC7Encode.hlsl:
#       TryMode456CS
#       TryMode137CS
#       TryMode02CS
#       EncodeBlockCS
#
#   BC6HEncode.hlsl:
#       TryModeG10CS
#       TryModeLE10CS
#       EncodeBlockCS
#
# Each entry point is built for cs_5_0 and cs_4_0. The cs_4_0 variants
# additionally use /DEMULATE_F16C.

# BC7, Shader Model 5.0
compile_shader BC7Encode TryMode456CS cs_5_0 ""
compile_shader BC7Encode TryMode137CS  cs_5_0 ""
compile_shader BC7Encode TryMode02CS   cs_5_0 ""
compile_shader BC7Encode EncodeBlockCS cs_5_0 ""

# BC7, Shader Model 4.0
compile_shader BC7Encode TryMode456CS cs_4_0 "_cs40" -D EMULATE_F16C
compile_shader BC7Encode TryMode137CS  cs_4_0 "_cs40" -D EMULATE_F16C
compile_shader BC7Encode TryMode02CS   cs_4_0 "_cs40" -D EMULATE_F16C
compile_shader BC7Encode EncodeBlockCS cs_4_0 "_cs40" -D EMULATE_F16C

# BC6H, Shader Model 5.0
compile_shader BC6HEncode TryModeG10CS  cs_5_0 ""
compile_shader BC6HEncode TryModeLE10CS cs_5_0 ""
compile_shader BC6HEncode EncodeBlockCS cs_5_0 ""

# BC6H, Shader Model 4.0
compile_shader BC6HEncode TryModeG10CS  cs_4_0 "_cs40" -D EMULATE_F16C
compile_shader BC6HEncode TryModeLE10CS cs_4_0 "_cs40" -D EMULATE_F16C
compile_shader BC6HEncode EncodeBlockCS cs_4_0 "_cs40" -D EMULATE_F16C

echo

if [ "$error" -eq 0 ]; then
    echo "Shaders compiled ok"
else
    echo "There were shader compilation errors!"
    exit 1
fi
