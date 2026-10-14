#!/bin/bash

set -u

CompileShadersOutput="$1"
FxcTool="$2"
shift 2

mkdir -p "$CompileShadersOutput"

# DirectXTK expects generated shader headers in Src/Shaders/Compiled.
find "$CompileShadersOutput" -type f \( -name '*.inc' -o -name '*.pdb' \) -delete 2>/dev/null || true

LOG="$CompileShadersOutput/compileshaders.log"
: > "$LOG"

error=0

compile_shader()
{
    local source="$1"
    local profile="$2"
    local entry="$3"

    local name
    name="$(basename "$source")"
    name="${name%.*}"

    local output="${CompileShadersOutput}/${name}_${entry}.inc"

    echo "Compiling ${source} ${profile} ${entry}" >> "$LOG"

    "$FxcTool" \
        -T "${profile}_6_0" \
        -E "$entry" \
        -Fh "$output" \
        "$source" >> "$LOG" 2>&1

    if [ $? -ne 0 ]; then
        echo "FAILED: ${source} ${profile} ${entry}" >> "$LOG"
        error=1
    fi
}

compile_shader_hlsl()
{
    local source="$1"
    local profile="$2"
    local entry="$3"

    local name
    name="$(basename "$source")"
    name="${name%.*}"

    local output="${CompileShadersOutput}/${name}_${entry}.inc"

    echo "Compiling ${source} ${profile} ${entry}" >> "$LOG"

    "$FxcTool" \
        -T "${profile}_6_0" \
        -E "$entry" \
        -Fh "$output" \
        "$source" >> "$LOG" 2>&1

    if [ $? -ne 0 ]; then
        echo "FAILED: ${source} ${profile} ${entry}" >> "$LOG"
        error=1
    fi
}


# ---------------------------------------------------------------------------
# AlphaTestEffect
# ---------------------------------------------------------------------------

compile_shader AlphaTestEffect.fx vs VSAlphaTest
compile_shader AlphaTestEffect.fx vs VSAlphaTestNoFog
compile_shader AlphaTestEffect.fx vs VSAlphaTestVc
compile_shader AlphaTestEffect.fx vs VSAlphaTestVcNoFog

compile_shader AlphaTestEffect.fx ps PSAlphaTestLtGt
compile_shader AlphaTestEffect.fx ps PSAlphaTestLtGtNoFog
compile_shader AlphaTestEffect.fx ps PSAlphaTestEqNe
compile_shader AlphaTestEffect.fx ps PSAlphaTestEqNeNoFog


# ---------------------------------------------------------------------------
# BasicEffect
# ---------------------------------------------------------------------------

compile_shader BasicEffect.fx vs VSBasic
compile_shader BasicEffect.fx vs VSBasicNoFog
compile_shader BasicEffect.fx vs VSBasicVc
compile_shader BasicEffect.fx vs VSBasicVcNoFog
compile_shader BasicEffect.fx vs VSBasicTx
compile_shader BasicEffect.fx vs VSBasicTxNoFog
compile_shader BasicEffect.fx vs VSBasicTxVc
compile_shader BasicEffect.fx vs VSBasicTxVcNoFog
compile_shader BasicEffect.fx vs VSBasicVertexLighting
compile_shader BasicEffect.fx vs VSBasicVertexLightingBn
compile_shader BasicEffect.fx vs VSBasicVertexLightingVc
compile_shader BasicEffect.fx vs VSBasicVertexLightingVcBn
compile_shader BasicEffect.fx vs VSBasicVertexLightingTx
compile_shader BasicEffect.fx vs VSBasicVertexLightingTxBn
compile_shader BasicEffect.fx vs VSBasicVertexLightingTxVc
compile_shader BasicEffect.fx vs VSBasicVertexLightingTxVcBn
compile_shader BasicEffect.fx vs VSBasicOneLight
compile_shader BasicEffect.fx vs VSBasicOneLightBn
compile_shader BasicEffect.fx vs VSBasicOneLightVc
compile_shader BasicEffect.fx vs VSBasicOneLightVcBn
compile_shader BasicEffect.fx vs VSBasicOneLightTx
compile_shader BasicEffect.fx vs VSBasicOneLightTxBn
compile_shader BasicEffect.fx vs VSBasicOneLightTxVc
compile_shader BasicEffect.fx vs VSBasicOneLightTxVcBn
compile_shader BasicEffect.fx vs VSBasicPixelLighting
compile_shader BasicEffect.fx vs VSBasicPixelLightingBn
compile_shader BasicEffect.fx vs VSBasicPixelLightingTx
#compile_shader BasicEffect.fx vs VSBasicPixelLightingTxNoFog
compile_shader BasicEffect.fx ps PSBasic
compile_shader BasicEffect.fx ps PSBasicNoFog
compile_shader BasicEffect.fx ps PSBasicTx
compile_shader BasicEffect.fx ps PSBasicTxNoFog
compile_shader BasicEffect.fx ps PSBasicVertexLighting
compile_shader BasicEffect.fx ps PSBasicVertexLightingNoFog
compile_shader BasicEffect.fx ps PSBasicVertexLightingTx
compile_shader BasicEffect.fx ps PSBasicVertexLightingTxNoFog
compile_shader BasicEffect.fx ps PSBasicPixelLighting
compile_shader BasicEffect.fx ps PSBasicPixelLightingTx


# ---------------------------------------------------------------------------
# DualTextureEffect
# ---------------------------------------------------------------------------

compile_shader DualTextureEffect.fx vs VSDualTexture
compile_shader DualTextureEffect.fx vs VSDualTextureNoFog
compile_shader DualTextureEffect.fx vs VSDualTextureVc
compile_shader DualTextureEffect.fx vs VSDualTextureVcNoFog

compile_shader DualTextureEffect.fx ps PSDualTexture
compile_shader DualTextureEffect.fx ps PSDualTextureNoFog


# ---------------------------------------------------------------------------
# EnvironmentMapEffect
# ---------------------------------------------------------------------------

compile_shader EnvironmentMapEffect.fx vs VSEnvMap
compile_shader EnvironmentMapEffect.fx vs VSEnvMapBn
compile_shader EnvironmentMapEffect.fx vs VSEnvMapFresnel
compile_shader EnvironmentMapEffect.fx vs VSEnvMapFresnelBn
compile_shader EnvironmentMapEffect.fx vs VSEnvMapOneLight
compile_shader EnvironmentMapEffect.fx vs VSEnvMapOneLightBn
compile_shader EnvironmentMapEffect.fx vs VSEnvMapOneLightFresnel
compile_shader EnvironmentMapEffect.fx vs VSEnvMapOneLightFresnelBn
compile_shader EnvironmentMapEffect.fx vs VSEnvMapPixelLighting
compile_shader EnvironmentMapEffect.fx vs VSEnvMapPixelLightingBn

compile_shader EnvironmentMapEffect.fx ps PSEnvMap
compile_shader EnvironmentMapEffect.fx ps PSEnvMapNoFog
compile_shader EnvironmentMapEffect.fx ps PSEnvMapSpecular
compile_shader EnvironmentMapEffect.fx ps PSEnvMapSpecularNoFog
compile_shader EnvironmentMapEffect.fx ps PSEnvMapPixelLighting
compile_shader EnvironmentMapEffect.fx ps PSEnvMapPixelLightingNoFog
compile_shader EnvironmentMapEffect.fx ps PSEnvMapPixelLightingFresnel
compile_shader EnvironmentMapEffect.fx ps PSEnvMapPixelLightingFresnelNoFog
compile_shader EnvironmentMapEffect.fx ps PSEnvMapSpherePixelLighting
compile_shader EnvironmentMapEffect.fx ps PSEnvMapSpherePixelLightingFresnel
compile_shader EnvironmentMapEffect.fx ps PSEnvMapSpherePixelLightingFresnel
compile_shader EnvironmentMapEffect.fx ps PSEnvMapSpherePixelLightingFresnelNoFog
compile_shader EnvironmentMapEffect.fx ps PSEnvMapDualParabolaPixelLighting
compile_shader EnvironmentMapEffect.fx ps PSEnvMapDualParabolaPixelLightingNoFog
compile_shader EnvironmentMapEffect.fx ps PSEnvMapDualParabolaPixelLightingFresnel
compile_shader EnvironmentMapEffect.fx ps PSEnvMapDualParabolaPixelLightingFresnelNoFog


# ---------------------------------------------------------------------------
# SkinnedEffect
# ---------------------------------------------------------------------------

compile_shader SkinnedEffect.fx vs VSSkinnedVertexLightingOneBone
compile_shader SkinnedEffect.fx vs VSSkinnedVertexLightingOneBoneBn
compile_shader SkinnedEffect.fx vs VSSkinnedVertexLightingTwoBones
compile_shader SkinnedEffect.fx vs VSSkinnedVertexLightingTwoBonesBn
compile_shader SkinnedEffect.fx vs VSSkinnedVertexLightingFourBones
compile_shader SkinnedEffect.fx vs VSSkinnedVertexLightingFourBonesBn
compile_shader SkinnedEffect.fx vs VSSkinnedOneLightOneBone
compile_shader SkinnedEffect.fx vs VSSkinnedOneLightOneBoneBn
compile_shader SkinnedEffect.fx vs VSSkinnedOneLightTwoBones
compile_shader SkinnedEffect.fx vs VSSkinnedOneLightTwoBonesBn
compile_shader SkinnedEffect.fx vs VSSkinnedOneLightFourBones
compile_shader SkinnedEffect.fx vs VSSkinnedOneLightFourBonesBn
compile_shader SkinnedEffect.fx vs VSSkinnedPixelLightingOneBone
compile_shader SkinnedEffect.fx vs VSSkinnedPixelLightingOneBoneBn
compile_shader SkinnedEffect.fx vs VSSkinnedPixelLightingTwoBones
compile_shader SkinnedEffect.fx vs VSSkinnedPixelLightingTwoBonesBn
compile_shader SkinnedEffect.fx vs VSSkinnedPixelLightingFourBones
compile_shader SkinnedEffect.fx vs VSSkinnedPixelLightingFourBonesBn

compile_shader SkinnedEffect.fx ps PSSkinnedVertexLighting
compile_shader SkinnedEffect.fx ps PSSkinnedVertexLightingNoFog
compile_shader SkinnedEffect.fx ps PSSkinnedPixelLighting


# ---------------------------------------------------------------------------
# NormalMapEffect
# ---------------------------------------------------------------------------

compile_shader NormalMapEffect.fx vs VSNormalPixelLightingTx
compile_shader NormalMapEffect.fx vs VSNormalPixelLightingTxBn
compile_shader NormalMapEffect.fx vs VSNormalPixelLightingTxVc
compile_shader NormalMapEffect.fx vs VSNormalPixelLightingTxVcBn
compile_shader NormalMapEffect.fx vs VSNormalPixelLightingTxInst
compile_shader NormalMapEffect.fx vs VSNormalPixelLightingTxBnInst
compile_shader NormalMapEffect.fx vs VSNormalPixelLightingTxVcInst
compile_shader NormalMapEffect.fx vs VSNormalPixelLightingTxVcBnInst

compile_shader NormalMapEffect.fx vs VSSkinnedPixelLightingTx
compile_shader NormalMapEffect.fx vs VSSkinnedPixelLightingTxBn

compile_shader NormalMapEffect.fx ps PSNormalPixelLightingTx
compile_shader NormalMapEffect.fx ps PSNormalPixelLightingTxNoFog
compile_shader NormalMapEffect.fx ps PSNormalPixelLightingTxNoSpec
compile_shader NormalMapEffect.fx ps PSNormalPixelLightingTxNoFogSpec


# ---------------------------------------------------------------------------
# PBREffect
# ---------------------------------------------------------------------------

compile_shader PBREffect.fx vs VSConstant
compile_shader PBREffect.fx vs VSConstantInst
compile_shader PBREffect.fx vs VSConstantVelocity
compile_shader PBREffect.fx vs VSConstantBn
compile_shader PBREffect.fx vs VSConstantBnInst
compile_shader PBREffect.fx vs VSConstantVelocityBn
compile_shader PBREffect.fx vs VSSkinned
compile_shader PBREffect.fx vs VSSkinnedBn

compile_shader PBREffect.fx ps PSConstant
compile_shader PBREffect.fx ps PSTextured
compile_shader PBREffect.fx ps PSTexturedEmissive
compile_shader PBREffect.fx ps PSTexturedVelocity
compile_shader PBREffect.fx ps PSTexturedEmissiveVelocity


# ---------------------------------------------------------------------------
# DebugEffect
# ---------------------------------------------------------------------------

compile_shader DebugEffect.fx vs VSDebug
compile_shader DebugEffect.fx vs VSDebugBn
compile_shader DebugEffect.fx vs VSDebugVc
compile_shader DebugEffect.fx vs VSDebugVcBn
compile_shader DebugEffect.fx vs VSDebugInst
compile_shader DebugEffect.fx vs VSDebugBnInst
compile_shader DebugEffect.fx vs VSDebugVcInst
compile_shader DebugEffect.fx vs VSDebugVcBnInst

compile_shader DebugEffect.fx ps PSHemiAmbient
compile_shader DebugEffect.fx ps PSRGBNormals
compile_shader DebugEffect.fx ps PSRGBTangents
compile_shader DebugEffect.fx ps PSRGBBiTangents


# ---------------------------------------------------------------------------
# NPREffect (Not found, skip for now)
# ---------------------------------------------------------------------------

# compile_shader NPREffect.fx vs VSNPREffect
# compile_shader NPREffect.fx vs VSNPREffectBn
# compile_shader NPREffect.fx vs VSNPREffectVc
# compile_shader NPREffect.fx vs VSNPREffectVcBn
# compile_shader NPREffect.fx vs VSNPREffectInst
# compile_shader NPREffect.fx vs VSNPREffectBnInst
# compile_shader NPREffect.fx vs VSNPREffectVcInst
# compile_shader NPREffect.fx vs VSNPREffectVcBnInst
# compile_shader NPREffect.fx vs VSNPREffectTx
# compile_shader NPREffect.fx vs VSNPREffectBnTx
# compile_shader NPREffect.fx vs VSNPREffectVcTx
# compile_shader NPREffect.fx vs VSNPREffectVcBnTx
# compile_shader NPREffect.fx vs VSNPREffectInstTx
# compile_shader NPREffect.fx vs VSNPREffectBnInstTx
# compile_shader NPREffect.fx vs VSNPREffectVcInstTx
# compile_shader NPREffect.fx vs VSNPREffectBnInstTx
# compile_shader NPREffect.fx vs VSSkinnedNPREffectTx
# compile_shader NPREffect.fx vs VSSkinnedNPREffectTxBn

# compile_shader NPREffect.fx ps PSCelShading
# compile_shader NPREffect.fx ps PSCelShadingTx
# compile_shader NPREffect.fx ps PSGoochShading
# compile_shader NPREffect.fx ps PSGoochShadingTx
# compile_shader NPREffect.fx ps PSMatCapShading
# compile_shader NPREffect.fx ps PSMatCapShadingTx


# ---------------------------------------------------------------------------
# SpriteEffect
# ---------------------------------------------------------------------------

compile_shader SpriteEffect.fx vs SpriteVertexShader
compile_shader SpriteEffect.fx ps SpritePixelShader


# ---------------------------------------------------------------------------
# DGSL
# ---------------------------------------------------------------------------

compile_shader DGSLEffect.fx vs main
compile_shader DGSLEffect.fx vs mainVc
compile_shader DGSLEffect.fx vs main1Bones
compile_shader DGSLEffect.fx vs main1BonesVc
compile_shader DGSLEffect.fx vs main2Bones
compile_shader DGSLEffect.fx vs main2BonesVc
compile_shader DGSLEffect.fx vs main4Bones
compile_shader DGSLEffect.fx vs main4BonesVc

compile_shader_hlsl DGSLUnlit.hlsl ps main
compile_shader_hlsl DGSLLambert.hlsl ps main
compile_shader_hlsl DGSLPhong.hlsl ps main

compile_shader_hlsl DGSLUnlit.hlsl ps mainTk
compile_shader_hlsl DGSLLambert.hlsl ps mainTk
compile_shader_hlsl DGSLPhong.hlsl ps mainTk

compile_shader_hlsl DGSLUnlit.hlsl ps mainTx
compile_shader_hlsl DGSLLambert.hlsl ps mainTx
compile_shader_hlsl DGSLPhong.hlsl ps mainTx

compile_shader_hlsl DGSLUnlit.hlsl ps mainTxTk
compile_shader_hlsl DGSLLambert.hlsl ps mainTxTk
compile_shader_hlsl DGSLPhong.hlsl ps mainTxTk


# ---------------------------------------------------------------------------
# PostProcess / ToneMap
# ---------------------------------------------------------------------------

compile_shader PostProcess.fx vs VSQuad
compile_shader PostProcess.fx ps PSCopy
compile_shader PostProcess.fx ps PSMonochrome
compile_shader PostProcess.fx ps PSSepia
compile_shader PostProcess.fx ps PSDownScale2x2
compile_shader PostProcess.fx ps PSDownScale4x4
compile_shader PostProcess.fx ps PSGaussianBlur5x5
compile_shader PostProcess.fx ps PSBloomExtract
compile_shader PostProcess.fx ps PSBloomBlur
compile_shader PostProcess.fx ps PSMerge
compile_shader PostProcess.fx ps PSBloomCombine

compile_shader ToneMap.fx vs VSQuad
compile_shader ToneMap.fx ps PSCopy
compile_shader ToneMap.fx ps PSSaturate
compile_shader ToneMap.fx ps PSReinhard
compile_shader ToneMap.fx ps PSACESFilmic
compile_shader ToneMap.fx ps PS_SRGB
compile_shader ToneMap.fx ps PSSaturate_SRGB
compile_shader ToneMap.fx ps PSReinhard_SRGB
compile_shader ToneMap.fx ps PSACESFilmic_SRGB
compile_shader ToneMap.fx ps PSHDR10


if [ "$error" -ne 0 ]; then
    echo "There were shader compilation errors!" | tee -a "$LOG"
    exit 1
fi

echo "Shaders compiled ok" | tee -a "$LOG"