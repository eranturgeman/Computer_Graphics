Shader "CG/Water"
{
    Properties
    {
        _CubeMap("Reflection Cube Map", Cube) = "" {}
        _NoiseScale("Texture Scale", Range(1, 100)) = 10 
        _TimeScale("Time Scale", Range(0.1, 5)) = 3 
        _BumpScale("Bump Scale", Range(0, 0.5)) = 0.05
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "CGUtils.cginc"
                #include "CGRandom.cginc"

                #define DELTA 0.01

                // Declare used properties
                uniform samplerCUBE _CubeMap;
                uniform float _NoiseScale;
                uniform float _TimeScale;
                uniform float _BumpScale;

                struct appdata
                { 
                    float4 vertex   : POSITION;
                    float3 normal   : NORMAL;
                    float4 tangent  : TANGENT;
                    float2 uv       : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos      : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    float4 worldVertex: TEXTCOORD1;
                    float4 worldTangent: TANGENT;
                    float3 worldNormal: NORMAL;
                };

                // Returns the value of a noise function simulating water, at coordinates uv and time t
                float waterNoise(float2 uv, float t)
                {
                    //return perlin2d(uv); //this is the 2d version

                    return perlin3d(float3(0.5 * uv.x, 0.5 * uv.y, 0.5 * t)) + 0.5 * perlin3d(float3(uv.x, uv.y, t)) + 0.2 * perlin3d(float3(2.0 * uv.x, 2.0 * uv.y, 2.0 * t));
                }

                // Returns the world-space bump-mapped normal for the given bumpMapData and time t
                float3 getWaterBumpMappedNormal(bumpMapData i, float t)
                {
                    float fTagU = (waterNoise(i.uv + i.du, t) - waterNoise(i.uv, t)) / i.du;
                    float fTagV = (waterNoise(i.uv + i.dv, t) - waterNoise(i.uv, t)) / i.dv;
                    float3 nh = normalize(float3(-i.bumpScale * fTagU, -i.bumpScale * fTagV, 1));
                    return normalize(i.tangent * nh.x + i.normal * nh.z + cross(i.tangent, i.normal) * nh.y);
                }


                v2f vert (appdata input)
                {
                    v2f output;
                    float4 displacedVertex = input.vertex + float4(input.normal, 0) * (waterNoise(input.uv * _NoiseScale, _Time.y * _TimeScale) * _BumpScale);
                    output.pos = UnityObjectToClipPos(displacedVertex);
                    output.uv = input.uv;
                    output.worldVertex = mul(unity_ObjectToWorld, input.vertex);
                    output.worldTangent = normalize(mul(unity_ObjectToWorld, input.tangent));
                    output.worldNormal = normalize(mul(unity_ObjectToWorld, input.normal));
                    
                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    bumpMapData i;
                    i.normal = input.worldNormal; 
                    i.tangent = input.worldTangent;  
                    i.uv = input.uv * _NoiseScale;          
                    i.du = DELTA;            
                    i.dv = DELTA;
                    i.bumpScale = _BumpScale;
                    float3 n = getWaterBumpMappedNormal(i, _Time.y * _TimeScale);
                    
                    float3 v = normalize(_WorldSpaceCameraPos.xyz - input.worldVertex.xyz);
                    float3 r = (2 * dot(n, v) * n) - v;
                    fixed4 reflectedColor = texCUBE(_CubeMap, r);

                    return (1 - max(0, dot(n, v)) + 0.2) * reflectedColor;
                }

            ENDCG
        }
    }
}
