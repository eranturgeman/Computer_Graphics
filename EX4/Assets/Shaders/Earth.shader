Shader "CG/Earth"
{
    Properties
    {
        [NoScaleOffset] _AlbedoMap ("Albedo Map", 2D) = "defaulttexture" {}
        _Ambient ("Ambient", Range(0, 1)) = 0.15
        [NoScaleOffset] _SpecularMap ("Specular Map", 2D) = "defaulttexture" {}
        _Shininess ("Shininess", Range(0.1, 100)) = 50
        [NoScaleOffset] _HeightMap ("Height Map", 2D) = "defaulttexture" {}
        _BumpScale ("Bump Scale", Range(1, 100)) = 30
        [NoScaleOffset] _CloudMap ("Cloud Map", 2D) = "black" {}
        _AtmosphereColor ("Atmosphere Color", Color) = (0.8, 0.85, 1, 1)
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "CGUtils.cginc"

                // Declare used properties
                uniform sampler2D _AlbedoMap;
                uniform float _Ambient;
                uniform sampler2D _SpecularMap;
                uniform float _Shininess;
                uniform sampler2D _HeightMap;
                uniform float4 _HeightMap_TexelSize;
                uniform float _BumpScale;
                uniform sampler2D _CloudMap;
                uniform fixed4 _AtmosphereColor;

                struct appdata
                { 
                    float4 vertex : POSITION;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float4 worldVertex: TEXTCOORD0;
                    float4 objectVertex: TEXTCOOR1;
                };

                v2f vert (appdata input)
                {
                    v2f output;
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.worldVertex = mul(unity_ObjectToWorld, input.vertex);
                    output.objectVertex = input.vertex;
                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
                    float3 l = _WorldSpaceLightPos0;
                    float3 v = normalize(_WorldSpaceCameraPos.xyz - input.worldVertex.xyz);

                    float2 uv = getSphericalUV(input.worldVertex.xyz);

                    float4 n = normalize(mul(unity_ObjectToWorld, normalize(input.objectVertex - float4(0,0,0,1)))); //getting the normalized normal in world coordinate 

                    bumpMapData i;
                    i.normal = n; 
                    i.tangent = normalize(cross(n, float4(0,1,0,0)));
                    i.uv = uv;          
                    i.heightMap = _HeightMap;
                    i.du = _HeightMap_TexelSize.x;            
                    i.dv = _HeightMap_TexelSize.y;
                    i.bumpScale = _BumpScale / 10000.0;
                    float3 bummpedN = getBumpMappedNormal(i);
                    float3 finalNormal = (1 - tex2D(_SpecularMap, uv)) * bummpedN + tex2D(_SpecularMap, uv) * n;

                    float lambert = max(0, dot(n.xyz, l));
                    fixed4 atmosphere = (1 - max(0, dot(n.xyz, v))) * sqrt(lambert) * _AtmosphereColor;
                    fixed4 clouds = tex2D(_CloudMap, uv) * (sqrt(lambert) + _Ambient);
                
                    fixed3 bf = blinnPhong(finalNormal, v, l, _Shininess, tex2D(_AlbedoMap, uv), tex2D(_SpecularMap, uv), _Ambient);
                    return fixed4(bf, 1) + atmosphere + clouds;
                }

            ENDCG
        }
    }
}
