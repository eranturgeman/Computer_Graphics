Shader "CG/BlinnPhong"
{
    Properties
    {
        _DiffuseColor ("Diffuse Color", Color) = (0.14, 0.43, 0.84, 1)
        _SpecularColor ("Specular Color", Color) = (0.7, 0.7, 0.7, 1)
        _AmbientColor ("Ambient Color", Color) = (0.05, 0.13, 0.25, 1)
        _Shininess ("Shininess", Range(0.1, 50)) = 10
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
                #include "Lighting.cginc"

                // Declare used properties
                uniform fixed4 _DiffuseColor;
                uniform fixed4 _SpecularColor;
                uniform fixed4 _AmbientColor;
                uniform float _Shininess;

                struct appdata
                { 
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float3 normal: NORMAL;
                    float4 worldVertex: TEXTCOORD0;
                };

                // Calculates diffuse lighting of secondary point lights (part 3)
                fixed4 pointLights(v2f input)
                {
                    float3 n = normalize(input.normal);
                    

                    //first secondary light
                    float3 l0 = float3(unity_4LightPosX0[0], unity_4LightPosY0[0], unity_4LightPosZ0[0]) - input.worldVertex.xyz;
                    float i0 = 1 / (1 + pow(length(l0), 2) * unity_4LightAtten0[0]);
                    fixed4 light = i0 * max(0, dot(n, l0)) * _DiffuseColor * unity_LightColor[0];

                    //second secondary light
                    float3 l1 = float3(unity_4LightPosX0[1], unity_4LightPosY0[1], unity_4LightPosZ0[1]) - input.worldVertex.xyz;
                    float i1 = 1 / (1 + pow(length(l1), 2) * unity_4LightAtten0[1]);
                    light = light + (i1 * max(0, dot(n, l1)) * _DiffuseColor * unity_LightColor[1]);

                    //third secondary light
                    float3 l2 = float3(unity_4LightPosX0[2], unity_4LightPosY0[2], unity_4LightPosZ0[2]) - input.worldVertex.xyz;
                    float i2 = 1 / (1 + pow(length(l2), 2) * unity_4LightAtten0[2]); 
                    light = light + (i2 * max(0, dot(n, l2)) * _DiffuseColor * unity_LightColor[2]);

                    //fourth secondary light
                    float3 l3 = float3(unity_4LightPosX0[3], unity_4LightPosY0[3], unity_4LightPosZ0[3]) - input.worldVertex.xyz;
                    float i3 = 1 / (1 + pow(length(l3), 2) * unity_4LightAtten0[3]);
                    light = light + (i3 * max(0, dot(n, l3)) * _DiffuseColor * unity_LightColor[3]);

                    return light;
                }


                v2f vert (appdata input)
                {
                    v2f output;
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.worldVertex = mul(unity_ObjectToWorld, input.vertex);
                    output.normal = mul(unity_ObjectToWorld, input.normal);
                    return output;
                }


                fixed4 frag (v2f input) : SV_Target
                {
                    float3 l = _WorldSpaceLightPos0;
                    float3 v = normalize(_WorldSpaceCameraPos.xyz - input.worldVertex.xyz);
                    float3 h = normalize(l + v);
                    float3 n = normalize(input.normal);

                    fixed4 a_color = _AmbientColor * _LightColor0;

                    fixed4 d_color = max(0, dot(n, l)) * _DiffuseColor * _LightColor0;
                    d_color = d_color + pointLights(input);
                          
                    fixed4 s_color = pow(max(0, dot(n, h)), _Shininess) * _SpecularColor * _LightColor0;
                    return a_color + d_color + s_color;
                }

            ENDCG
        }
    }
}
