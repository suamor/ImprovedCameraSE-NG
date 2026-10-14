#!/bin/bash

set -u

CompileShadersOutput="${1:-${CompileShadersOutput:-Compiled}}"
FxcTool="${2:-fxc}"
shift 2

mkdir -p "$CompileShadersOutput"

LOG="$CompileShadersOutput/compileshaders.log"
: > "$LOG"

error=0

# DirectXTK's CompileShaders.cmd uses /Fh for generated C++ headers,
# /Fd for PDBs and /Vn for the generated symbol name.
#
# Native DXC equivalents:
#   /T  -> -T
#   /E  -> -E
#   /Fh -> -Fh
#   /Fd -> -Fd
#   /Vn -> -Vn
#
# FXC compatibility options are supplied by the wrapper itself.

compile_shader()
{
    local shader="$1"
    local profile="$2"
    local entry="$3"

    local source="${shader}.fx"
    local header="${CompileShadersOutput}/${shader}_${entry}.inc"
    local pdb="${CompileShadersOutput}/${shader}_${entry}.pdb"
    local symbol="${shader}_${entry}"

    echo >> "$LOG"
    echo "$FxcTool \"$source\" -T \"${profile}_4_0_level_9_1\" -E \"$entry\" -Fh \"$header\" -Fd \"$pdb\" -Vn \"$symbol\"" >> "$LOG"

    "$FxcTool" \
        "$source" \
        -T "${profile}_4_0_level_9_1" \
        -E "$entry" \
        -Fh "$header" \
        -Fd "$pdb" \
        -Vn "$symbol" >> "$LOG" 2>&1

    if [ $? -ne 0 ]; then
        error=1
    fi
}

compile_shader_sm4()
{
    local shader="$1"
    local profile="$2"
    local entry="$3"

    local source="${shader}.fx"
    local header="${CompileShadersOutput}/${shader}_${entry}.inc"
    local pdb="${CompileShadersOutput}/${shader}_${entry}.pdb"
    local symbol="${shader}_${entry}"

    echo >> "$LOG"
    echo "$FxcTool \"$source\" -T \"${profile}_4_0\" -E \"$entry\" -Fh \"$header\" -Fd \"$pdb\" -Vn \"$symbol\"" >> "$LOG"

    "$FxcTool" \
        "$source" \
        -T "${profile}_4_0" \
        -E "$entry" \
        -Fh "$header" \
        -Fd "$pdb" \
        -Vn "$symbol" >> "$LOG" 2>&1

    if [ $? -ne 0 ]; then
        error=1
    fi
}

compile_shader_hlsl()
{
    local shader="$1"
    local profile="$2"
    local entry="$3"

    local source="${shader}.hlsl"
    local header="${CompileShadersOutput}/${shader}_${entry}.inc"
    local pdb="${CompileShadersOutput}/${shader}_${entry}.pdb"
    local symbol="${shader}_${entry}"

    echo >> "$LOG"
    echo "$FxcTool \"$source\" -T \"${profile}_4_0_level_9_1\" -E \"$entry\" -Fh \"$header\" -Fd \"$pdb\" -Vn \"$symbol\"" >> "$LOG"

    "$FxcTool" \
        "$source" \
        -T "${profile}_4_0_level_9_1" \
        -E "$entry" \
        -Fh "$header" \
        -Fd "$pdb" \
        -Vn "$symbol" >> "$LOG" 2>&1

    if [ $? -ne 0 ]; then
        error=1
    fi
}


# ---------------------------------------------------------------------------
# AlphaTestEffect
# ---------------------------------------------------------------------------

compile_shader AlphaTestEffect vs VSAlphaTest
compile_shader AlphaTestEffect vs VSAlphaTestNoFog
compile_shader AlphaTestEffect vs VSAlphaTestVc
compile_shader AlphaTestEffect vs VSAlphaTestVcNoFog
compile_shader AlphaTestEffect ps PSAlphaTestLtGt
compile_shader AlphaTestEffect ps PSAlphaTestLtGtNoFog
compile_shader AlphaTestEffect ps PSAlphaTestEqNe
compile_shader AlphaTestEffect ps PSAlphaTestEqNeNoFog


# ---------------------------------------------------------------------------
# BasicEffect
# ---------------------------------------------------------------------------

compile_shader BasicEffect vs VSBasic
compile_shader BasicEffect vs VSBasicNoFog
compile_shader BasicEffect vs VSBasicVc
compile_shader BasicEffect vs VSBasicVcNoFog
compile_shader BasicEffect vs VSBasicTx
compile_shader BasicEffect vs VSBasicTxNoFog
compile_shader BasicEffect vs VSBasicTxVc
compile_shader BasicEffect vs VSBasicTxVcNoFog
compile_shader BasicEffect vs VSBasicVertexLighting
compile_shader BasicEffect vs VSBasicVertexLightingBn
compile_shader BasicEffect vs VSBasicVertexLightingVc
compile_shader BasicEffect vs VSBasicVertexLightingVcBn
compile_shader BasicEffect vs VSBasicVertexLightingTx
compile_shader BasicEffect vs VSBasicVertexLightingTxBn
compile_shader BasicEffect vs VSBasicVertexLightingTxVc
compile_shader BasicEffect vs VSBasicVertexLightingTxVcBn
compile_shader BasicEffect vs VSBasicOneLight
compile_shader BasicEffect vs VSBasicOneLightBn
compile_shader BasicEffect vs VSBasicOneLightVc
compile_shader BasicEffect vs VSBasicOneLightVcBn
compile_shader BasicEffect vs VSBasicOneLightTx
compile_shader BasicEffect vs VSBasicOneLightTxBn
compile_shader BasicEffect vs VSBasicOneLightTxVc
compile_shader BasicEffect vs VSBasicOneLightTxVcBn
compile_shader BasicEffect vs VSBasicPixelLighting
compile_shader BasicEffect vs VSBasicPixelLightingBn
compile_shader BasicEffect vs VSBasicPixelLightingVc
compile_shader BasicEffect vs VSBasicPixelLightingVcBn
compile_shader BasicEffect vs VSBasicPixelLightingTx
compile_shader BasicEffect vs VSBasicPixelLightingTxBn
compile_shader BasicEffect vs VSBasicPixelLightingTxVc
compile_shader BasicEffect vs VSBasicPixelLightingTxVcBn
compile_shader BasicEffect ps PSBasic
compile_shader BasicEffect ps PSBasicNoFog
compile_shader BasicEffect ps PSBasicTx
compile_shader BasicEffect ps PSBasicTxNoFog
compile_shader BasicEffect ps PSBasicVertexLighting
compile_shader BasicEffect ps PSBasicVertexLightingNoFog
compile_shader BasicEffect ps PSBasicVertexLightingTx
compile_shader BasicEffect ps PSBasicVertexLightingTxNoFog
compile_shader BasicEffect ps PSBasicPixelLighting
compile_shader BasicEffect ps PSBasicPixelLightingTx


# ---------------------------------------------------------------------------
# DualTextureEffect
# ---------------------------------------------------------------------------

compile_shader DualTextureEffect vs VSDualTexture
compile_shader DualTextureEffect vs VSDualTextureNoFog
compile_shader DualTextureEffect vs VSDualTextureVc
compile_shader DualTextureEffect vs VSDualTextureVcNoFog
compile_shader DualTextureEffect ps PSDualTexture
compile_shader DualTextureEffect ps PSDualTextureNoFog


# ---------------------------------------------------------------------------
# EnvironmentMapEffect
# ---------------------------------------------------------------------------

compile_shader EnvironmentMapEffect vs VSEnvMap
compile_shader EnvironmentMapEffect vs VSEnvMapBn
compile_shader EnvironmentMapEffect vs VSEnvMapFresnel
compile_shader EnvironmentMapEffect vs VSEnvMapFresnelBn
compile_shader EnvironmentMapEffect vs VSEnvMapOneLight
compile_shader EnvironmentMapEffect vs VSEnvMapOneLightBn
compile_shader EnvironmentMapEffect vs VSEnvMapOneLightFresnel
compile_shader EnvironmentMapEffect vs VSEnvMapOneLightFresnelBn
compile_shader EnvironmentMapEffect vs VSEnvMapPixelLighting
compile_shader EnvironmentMapEffect vs VSEnvMapPixelLightingBn

compile_shader_sm4 EnvironmentMapEffect vs VSEnvMapPixelLightingSM4
compile_shader_sm4 EnvironmentMapEffect vs VSEnvMapPixelLightingBnSM4

compile_shader EnvironmentMapEffect ps PSEnvMap
compile_shader EnvironmentMapEffect ps PSEnvMapNoFog
compile_shader EnvironmentMapEffect ps PSEnvMapSpecular
compile_shader EnvironmentMapEffect ps PSEnvMapSpecularNoFog
compile_shader EnvironmentMapEffect ps PSEnvMapPixelLighting
compile_shader EnvironmentMapEffect ps PSEnvMapPixelLightingNoFog
compile_shader EnvironmentMapEffect ps PSEnvMapPixelLightingFresnel
compile_shader EnvironmentMapEffect ps PSEnvMapPixelLightingFresnelNoFog
compile_shader EnvironmentMapEffect ps PSEnvMapSpherePixelLighting
compile_shader EnvironmentMapEffect ps PSEnvMapSpherePixelLightingNoFog
compile_shader EnvironmentMapEffect ps PSEnvMapSpherePixelLightingFresnel
compile_shader EnvironmentMapEffect ps PSEnvMapSpherePixelLightingFresnelNoFog

compile_shader_sm4 EnvironmentMapEffect ps PSEnvMapDualParabolaPixelLighting
compile_shader_sm4 EnvironmentMapEffect ps PSEnvMapDualParabolaPixelLightingNoFog
compile_shader_sm4 EnvironmentMapEffect ps PSEnvMapDualParabolaPixelLightingFresnel
compile_shader_sm4 EnvironmentMapEffect ps PSEnvMapDualParabolaPixelLightingFresnelNoFog


# ---------------------------------------------------------------------------
# SkinnedEffect
# ---------------------------------------------------------------------------

compile_shader SkinnedEffect vs VSSkinnedVertexLightingOneBone
compile_shader SkinnedEffect vs VSSkinnedVertexLightingOneBoneBn
compile_shader SkinnedEffect vs VSSkinnedVertexLightingTwoBones
compile_shader SkinnedEffect vs VSSkinnedVertexLightingTwoBonesBn
compile_shader SkinnedEffect vs VSSkinnedVertexLightingFourBones
compile_shader SkinnedEffect vs VSSkinnedVertexLightingFourBonesBn
compile_shader SkinnedEffect vs VSSkinnedOneLightOneBone
compile_shader SkinnedEffect vs VSSkinnedOneLightOneBoneBn
compile_shader SkinnedEffect vs VSSkinnedOneLightTwoBones
compile_shader SkinnedEffect vs VSSkinnedOneLightTwoBonesBn
compile_shader SkinnedEffect vs VSSkinnedOneLightFourBones
compile_shader SkinnedEffect vs VSSkinnedOneLightFourBonesBn
compile_shader SkinnedEffect vs VSSkinnedPixelLightingOneBone
compile_shader SkinnedEffect vs VSSkinnedPixelLightingOneBoneBn
compile_shader SkinnedEffect vs VSSkinnedPixelLightingTwoBones
compile_shader SkinnedEffect vs VSSkinnedPixelLightingTwoBonesBn
compile_shader SkinnedEffect vs VSSkinnedPixelLightingFourBones
compile_shader SkinnedEffect vs VSSkinnedPixelLightingFourBonesBn
compile_shader SkinnedEffect ps PSSkinnedVertexLighting
compile_shader SkinnedEffect ps PSSkinnedVertexLightingNoFog
compile_shader SkinnedEffect ps PSSkinnedPixelLighting


# ---------------------------------------------------------------------------
# NormalMapEffect
# ---------------------------------------------------------------------------

compile_shader_sm4 NormalMapEffect vs VSNormalPixelLightingTx
compile_shader_sm4 NormalMapEffect vs VSNormalPixelLightingTxBn
compile_shader_sm4 NormalMapEffect vs VSNormalPixelLightingTxVc
compile_shader_sm4 NormalMapEffect vs VSNormalPixelLightingTxVcBn
compile_shader_sm4 NormalMapEffect vs VSNormalPixelLightingTxInst
compile_shader_sm4 NormalMapEffect vs VSNormalPixelLightingTxBnInst
compile_shader_sm4 NormalMapEffect vs VSNormalPixelLightingTxVcInst
compile_shader_sm4 NormalMapEffect vs VSNormalPixelLightingTxVcBnInst
compile_shader_sm4 NormalMapEffect vs VSSkinnedPixelLightingTx
compile_shader_sm4 NormalMapEffect vs VSSkinnedPixelLightingTxBn
compile_shader_sm4 NormalMapEffect ps PSNormalPixelLightingTx
compile_shader_sm4 NormalMapEffect ps PSNormalPixelLightingTxNoFog
compile_shader_sm4 NormalMapEffect ps PSNormalPixelLightingTxNoSpec
compile_shader_sm4 NormalMapEffect ps PSNormalPixelLightingTxNoFogSpec


# ---------------------------------------------------------------------------
# PBREffect
# ---------------------------------------------------------------------------

compile_shader_sm4 PBREffect vs VSConstant
compile_shader_sm4 PBREffect vs VSConstantInst
compile_shader_sm4 PBREffect vs VSConstantVelocity
compile_shader_sm4 PBREffect vs VSConstantBn
compile_shader_sm4 PBREffect vs VSConstantBnInst
compile_shader_sm4 PBREffect vs VSConstantVelocityBn
compile_shader_sm4 PBREffect vs VSSkinned
compile_shader_sm4 PBREffect vs VSSkinnedBn
compile_shader_sm4 PBREffect ps PSConstant
compile_shader_sm4 PBREffect ps PSTextured
compile_shader_sm4 PBREffect ps PSTexturedEmissive
compile_shader_sm4 PBREffect ps PSTexturedVelocity
compile_shader_sm4 PBREffect ps PSTexturedEmissiveVelocity


# ---------------------------------------------------------------------------
# DebugEffect
# ---------------------------------------------------------------------------

compile_shader_sm4 DebugEffect vs VSDebug
compile_shader_sm4 DebugEffect vs VSDebugBn
compile_shader_sm4 DebugEffect vs VSDebugVc
compile_shader_sm4 DebugEffect vs VSDebugVcBn
compile_shader_sm4 DebugEffect vs VSDebugInst
compile_shader_sm4 DebugEffect vs VSDebugBnInst
compile_shader_sm4 DebugEffect vs VSDebugVcInst
compile_shader_sm4 DebugEffect vs VSDebugVcBnInst
compile_shader_sm4 DebugEffect ps PSHemiAmbient
compile_shader_sm4 DebugEffect ps PSRGBNormals
compile_shader_sm4 DebugEffect ps PSRGBTangents
compile_shader_sm4 DebugEffect ps PSRGBBiTangents


# ---------------------------------------------------------------------------
# SpriteEffect
# ---------------------------------------------------------------------------

compile_shader SpriteEffect vs SpriteVertexShader
compile_shader SpriteEffect ps SpritePixelShader


# ---------------------------------------------------------------------------
# DGSL
# ---------------------------------------------------------------------------

compile_shader DGSLEffect vs main
compile_shader DGSLEffect vs mainVc
compile_shader DGSLEffect vs main1Bones
compile_shader DGSLEffect vs main1BonesVc
compile_shader DGSLEffect vs main2Bones
compile_shader DGSLEffect vs main2BonesVc
compile_shader DGSLEffect vs main4Bones
compile_shader DGSLEffect vs main4BonesVc

compile_shader_hlsl DGSLUnlit ps main
compile_shader_hlsl DGSLLambert ps main
compile_shader_hlsl DGSLPhong ps main

compile_shader_hlsl DGSLUnlit ps mainTk
compile_shader_hlsl DGSLLambert ps mainTk
compile_shader_hlsl DGSLPhong ps mainTk

compile_shader_hlsl DGSLUnlit ps mainTx
compile_shader_hlsl DGSLLambert ps mainTx
compile_shader_hlsl DGSLPhong ps mainTx

compile_shader_hlsl DGSLUnlit ps mainTxTk
compile_shader_hlsl DGSLLambert ps mainTxTk
compile_shader_hlsl DGSLPhong ps mainTxTk


# ---------------------------------------------------------------------------
# PostProcess
# ---------------------------------------------------------------------------

compile_shader_sm4 PostProcess vs VSQuad
compile_shader_sm4 PostProcess ps PSCopy
compile_shader_sm4 PostProcess ps PSMonochrome
compile_shader_sm4 PostProcess ps PSSepia
compile_shader_sm4 PostProcess ps PSDownScale2x2
compile_shader_sm4 PostProcess ps PSDownScale4x4
compile_shader_sm4 PostProcess ps PSGaussianBlur5x5
compile_shader_sm4 PostProcess ps PSBloomExtract
compile_shader_sm4 PostProcess ps PSBloomBlur
compile_shader_sm4 PostProcess ps PSMerge
compile_shader_sm4 PostProcess ps PSBloomCombine


# ---------------------------------------------------------------------------
# ToneMap
# ---------------------------------------------------------------------------

compile_shader_sm4 ToneMap vs VSQuad
compile_shader_sm4 ToneMap ps PSCopy
compile_shader_sm4 ToneMap ps PSSaturate
compile_shader_sm4 ToneMap ps PSReinhard
compile_shader_sm4 ToneMap ps PSACESFilmic
compile_shader_sm4 ToneMap ps PS_SRGB
compile_shader_sm4 ToneMap ps PSSaturate_SRGB
compile_shader_sm4 ToneMap ps PSReinhard_SRGB
compile_shader_sm4 ToneMap ps PSACESFilmic_SRGB
compile_shader_sm4 ToneMap ps PSHDR10


if [ "$error" -eq 0 ]; then
    echo "Shaders compiled ok" | tee -a "$LOG"
else
    echo "There were shader compilation errors!" | tee -a "$LOG"
    exit 1
fi
