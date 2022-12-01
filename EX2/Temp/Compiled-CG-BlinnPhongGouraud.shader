// Compiled shader for PC, Mac & Linux Standalone

//////////////////////////////////////////////////////////////////////////
// 
// NOTE: This is *not* a valid shader file, the contents are provided just
// for information and for debugging purposes only.
// 
//////////////////////////////////////////////////////////////////////////
// Skipping shader variants that would not be included into build of current scene.

Shader "CG/BlinnPhongGouraud" {
Properties {
 _DiffuseColor ("Diffuse Color", Color) = (0.140000,0.430000,0.840000,1.000000)
 _SpecularColor ("Specular Color", Color) = (0.700000,0.700000,0.700000,1.000000)
 _AmbientColor ("Ambient Color", Color) = (0.050000,0.130000,0.250000,1.000000)
 _Shininess ("Shininess", Range(0.100000,50.000000)) = 10.000000
}
SubShader { 
 Pass {
  Tags { "LIGHTMODE"="FORWARDBASE" }
  //////////////////////////////////
  //                              //
  //      Compiled programs       //
  //                              //
  //////////////////////////////////
//////////////////////////////////////////////////////
Global Keywords: <none>
Local Keywords: <none>
-- Hardware tier variant: Tier 1
-- Vertex shader for "metal":
Uses vertex data channel "Vertex"
Uses vertex data channel "Normal"

Constant Buffer "VGlobals" (128 bytes) on slot 0 {
  Matrix4x4 unity_ObjectToWorld at 0
  Matrix4x4 unity_MatrixVP at 64
}

Shader Disassembly:
#include <metal_stdlib>
#include <metal_texture>
using namespace metal;

#if !(__HAVE_FMA__)
#define fma(a,b,c) ((a) * (b) + (c))
#endif

struct VGlobals_Type
{
    float4 hlslcc_mtx4x4unity_ObjectToWorld[4];
    float4 hlslcc_mtx4x4unity_MatrixVP[4];
};

struct Mtl_VertexIn
{
    float4 POSITION0 [[ attribute(0) ]] ;
    float3 NORMAL0 [[ attribute(1) ]] ;
};

struct Mtl_VertexOut
{
    float4 mtl_Position [[ position ]];
    float3 NORMAL0 [[ user(NORMAL0) ]];
};

vertex Mtl_VertexOut xlatMtlMain(
    constant VGlobals_Type& VGlobals [[ buffer(0) ]],
    Mtl_VertexIn input [[ stage_in ]])
{
    Mtl_VertexOut output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0 = input.POSITION0.yyyy * VGlobals.hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = fma(VGlobals.hlslcc_mtx4x4unity_ObjectToWorld[0], input.POSITION0.xxxx, u_xlat0);
    u_xlat0 = fma(VGlobals.hlslcc_mtx4x4unity_ObjectToWorld[2], input.POSITION0.zzzz, u_xlat0);
    u_xlat0 = u_xlat0 + VGlobals.hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat1 = u_xlat0.yyyy * VGlobals.hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat1 = fma(VGlobals.hlslcc_mtx4x4unity_MatrixVP[0], u_xlat0.xxxx, u_xlat1);
    u_xlat1 = fma(VGlobals.hlslcc_mtx4x4unity_MatrixVP[2], u_xlat0.zzzz, u_xlat1);
    output.mtl_Position = fma(VGlobals.hlslcc_mtx4x4unity_MatrixVP[3], u_xlat0.wwww, u_xlat1);
    output.NORMAL0.xyz = input.NORMAL0.xyz;
    return output;
}


-- Hardware tier variant: Tier 1
-- Fragment shader for "metal":
Constant Buffer "FGlobals" (100 bytes) on slot 0 {
  Vector3 _WorldSpaceCameraPos at 0
  Vector4 _WorldSpaceLightPos0 at 16
  Vector4 _LightColor0 at 32
  Vector4 _DiffuseColor at 48
  Vector4 _SpecularColor at 64
  Vector4 _AmbientColor at 80
  Float _Shininess at 96
}

Shader Disassembly:
#include <metal_stdlib>
#include <metal_texture>
using namespace metal;

#if !(__HAVE_FMA__)
#define fma(a,b,c) ((a) * (b) + (c))
#endif

#ifndef XLT_REMAP_O
	#define XLT_REMAP_O {0, 1, 2, 3, 4, 5, 6, 7}
#endif
constexpr constant uint xlt_remap_o[] = XLT_REMAP_O;
struct FGlobals_Type
{
    float3 _WorldSpaceCameraPos;
    float4 _WorldSpaceLightPos0;
    float4 _LightColor0;
    float4 _DiffuseColor;
    float4 _SpecularColor;
    float4 _AmbientColor;
    float _Shininess;
};

struct Mtl_FragmentIn
{
    float3 NORMAL0 [[ user(NORMAL0) ]] ;
};

struct Mtl_FragmentOut
{
    float4 SV_Target0 [[ color(xlt_remap_o[0]) ]];
};

fragment Mtl_FragmentOut xlatMtlMain(
    constant FGlobals_Type& FGlobals [[ buffer(0) ]],
    float4 mtl_FragCoord [[ position ]],
    Mtl_FragmentIn input [[ stage_in ]])
{
    Mtl_FragmentOut output;
    float4 hlslcc_FragCoord = float4(mtl_FragCoord.xyz, 1.0/mtl_FragCoord.w);
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0.xyz = hlslcc_FragCoord.xyz + (-FGlobals._WorldSpaceCameraPos.xyzx.xyz);
    u_xlat1 = hlslcc_FragCoord + (-FGlobals._WorldSpaceLightPos0);
    u_xlat6 = dot(u_xlat1, u_xlat1);
    u_xlat6 = rsqrt(u_xlat6);
    u_xlat0.xyz = fma(u_xlat1.xyz, float3(u_xlat6), u_xlat0.xyz);
    u_xlat1.xyz = float3(u_xlat6) * u_xlat1.xyz;
    u_xlat6 = dot(u_xlat1.xyz, input.NORMAL0.xyz);
    u_xlat6 = max(u_xlat6, 0.0);
    u_xlat1 = float4(u_xlat6) * FGlobals._DiffuseColor;
    u_xlat1 = u_xlat1 * FGlobals._LightColor0;
    u_xlat1 = fma(FGlobals._AmbientColor, FGlobals._LightColor0, u_xlat1);
    u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat6 = rsqrt(u_xlat6);
    u_xlat0.xyz = float3(u_xlat6) * u_xlat0.xyz;
    u_xlat0.x = dot(input.NORMAL0.xyz, u_xlat0.xyz);
    u_xlat0.x = max(u_xlat0.x, 0.0);
    u_xlat0.x = log2(u_xlat0.x);
    u_xlat0.x = u_xlat0.x * FGlobals._Shininess;
    u_xlat0.x = exp2(u_xlat0.x);
    u_xlat0 = u_xlat0.xxxx * FGlobals._SpecularColor;
    output.SV_Target0 = fma(u_xlat0, FGlobals._LightColor0, u_xlat1);
    return output;
}


//////////////////////////////////////////////////////
Global Keywords: <none>
Local Keywords: <none>
-- Hardware tier variant: Tier 1
-- Vertex shader for "glcore":
Constant Buffer "$Globals" (100 bytes) {
  Vector3 _WorldSpaceCameraPos at 0
  Vector4 _WorldSpaceLightPos0 at 16
  Vector4 _LightColor0 at 32
  Vector4 _DiffuseColor at 48
  Vector4 _SpecularColor at 64
  Vector4 _AmbientColor at 80
  Float _Shininess at 96
}
Constant Buffer "$Globals" (128 bytes) {
  Matrix4x4 unity_ObjectToWorld at 0
  Matrix4x4 unity_MatrixVP at 64
}

Shader Disassembly:
#ifdef VERTEX
#version 150
#extension GL_ARB_explicit_attrib_location : require
#ifdef GL_ARB_shader_bit_encoding
#extension GL_ARB_shader_bit_encoding : enable
#endif

#define HLSLCC_ENABLE_UNIFORM_BUFFERS 1
#if HLSLCC_ENABLE_UNIFORM_BUFFERS
#define UNITY_UNIFORM
#else
#define UNITY_UNIFORM uniform
#endif
#define UNITY_SUPPORTS_UNIFORM_LOCATION 1
#if UNITY_SUPPORTS_UNIFORM_LOCATION
#define UNITY_LOCATION(x) layout(location = x)
#define UNITY_BINDING(x) layout(binding = x, std140)
#else
#define UNITY_LOCATION(x)
#define UNITY_BINDING(x) layout(std140)
#endif
uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
in  vec4 in_POSITION0;
in  vec3 in_NORMAL0;
out vec3 vs_NORMAL0;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat0 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat0.zzzz + u_xlat1;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat0.wwww + u_xlat1;
    vs_NORMAL0.xyz = in_NORMAL0.xyz;
    return;
}

#endif
#ifdef FRAGMENT
#version 150
#extension GL_ARB_explicit_attrib_location : require
#ifdef GL_ARB_shader_bit_encoding
#extension GL_ARB_shader_bit_encoding : enable
#endif

#define HLSLCC_ENABLE_UNIFORM_BUFFERS 1
#if HLSLCC_ENABLE_UNIFORM_BUFFERS
#define UNITY_UNIFORM
#else
#define UNITY_UNIFORM uniform
#endif
#define UNITY_SUPPORTS_UNIFORM_LOCATION 1
#if UNITY_SUPPORTS_UNIFORM_LOCATION
#define UNITY_LOCATION(x) layout(location = x)
#define UNITY_BINDING(x) layout(binding = x, std140)
#else
#define UNITY_LOCATION(x)
#define UNITY_BINDING(x) layout(std140)
#endif
uniform 	vec3 _WorldSpaceCameraPos;
uniform 	vec4 _WorldSpaceLightPos0;
uniform 	vec4 _LightColor0;
uniform 	vec4 _DiffuseColor;
uniform 	vec4 _SpecularColor;
uniform 	vec4 _AmbientColor;
uniform 	float _Shininess;
in  vec3 vs_NORMAL0;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat0;
vec4 u_xlat1;
float u_xlat6;
void main()
{
vec4 hlslcc_FragCoord = vec4(gl_FragCoord.xyz, 1.0/gl_FragCoord.w);
    u_xlat0.xyz = hlslcc_FragCoord.xyz + (-_WorldSpaceCameraPos.xyz);
    u_xlat1 = hlslcc_FragCoord + (-_WorldSpaceLightPos0);
    u_xlat6 = dot(u_xlat1, u_xlat1);
    u_xlat6 = inversesqrt(u_xlat6);
    u_xlat0.xyz = u_xlat1.xyz * vec3(u_xlat6) + u_xlat0.xyz;
    u_xlat1.xyz = vec3(u_xlat6) * u_xlat1.xyz;
    u_xlat6 = dot(u_xlat1.xyz, vs_NORMAL0.xyz);
    u_xlat6 = max(u_xlat6, 0.0);
    u_xlat1 = vec4(u_xlat6) * _DiffuseColor;
    u_xlat1 = u_xlat1 * _LightColor0;
    u_xlat1 = _AmbientColor * _LightColor0 + u_xlat1;
    u_xlat6 = dot(u_xlat0.xyz, u_xlat0.xyz);
    u_xlat6 = inversesqrt(u_xlat6);
    u_xlat0.xyz = vec3(u_xlat6) * u_xlat0.xyz;
    u_xlat0.x = dot(vs_NORMAL0.xyz, u_xlat0.xyz);
    u_xlat0.x = max(u_xlat0.x, 0.0);
    u_xlat0.x = log2(u_xlat0.x);
    u_xlat0.x = u_xlat0.x * _Shininess;
    u_xlat0.x = exp2(u_xlat0.x);
    u_xlat0 = u_xlat0.xxxx * _SpecularColor;
    SV_Target0 = u_xlat0 * _LightColor0 + u_xlat1;
    return;
}

#endif


-- Hardware tier variant: Tier 1
-- Fragment shader for "glcore":
Shader Disassembly:


 }
}
}