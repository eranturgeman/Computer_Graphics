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
                };

                // Calculates diffuse lighting of secondary point lights (part 3)
                fixed4 pointLights(v2f input)
                {
                    fixed3 l = normalize(_WorldSpaceLightPos0);
                    fixed4 light = max(0, dot(input.normal.xyz, l)) * _DiffuseColor * _LightColor0;

                    //main light
                    fixed3 l0 = normalize(fixed3(unity_4LightPosX0[0], unity_4LightPosY0[0], unity_4LightPosZ0[0]));
                    light = light +  unity_4LightAtten0[0] * max(0, dot(input.normal.xyz, l0)) * _DiffuseColor * unity_LightColor[0];

                    //first secondary light
                    fixed3 l1 = normalize(fixed3(unity_4LightPosX0[1], unity_4LightPosY0[1], unity_4LightPosZ0[1]));
                    light = light + (unity_4LightAtten0[1] * max(0, dot(input.normal.xyz, l1)) * _DiffuseColor * unity_LightColor[1]);

                    //second secondary light
                    fixed3 l2 = normalize(fixed3(unity_4LightPosX0[2], unity_4LightPosY0[2], unity_4LightPosZ0[2]));
                    light = light + (unity_4LightAtten0[2] * max(0, dot(input.normal.xyz, l2)) * _DiffuseColor * unity_LightColor[2]);

                    //third secondary light
                    fixed3 l3 = normalize(fixed3(unity_4LightPosX0[3], unity_4LightPosY0[3], unity_4LightPosZ0[3]));
                    light = light + (unity_4LightAtten0[3] * max(0, dot(input.normal.xyz, l3)) * _DiffuseColor * unity_LightColor[3]);
                    return light;
                }


                v2f vert (appdata input)
                {
                    v2f output;
                    output.pos = UnityObjectToClipPos(input.vertex);
                    output.normal = input.normal;
                    return output;
                }


                fixed4 frag (v2f input) : SV_Target
                {
                    fixed3 l = normalize(_WorldSpaceLightPos0);
                    fixed3 v = normalize(_WorldSpaceCameraPos.xyz - input.pos.xyz);
                    fixed3 h = normalize(l + v);

                    fixed4 a_color = _AmbientColor * _LightColor0;

                    //fixed4 d_color = max(0, dot(input.normal.xyz, l)) * _DiffuseColor * _LightColor0;
                    fixed4 d_color = pointLights(input);
                          
                    fixed4 s_color = pow(max(0, dot(input.normal, h)), _Shininess) * _SpecularColor * _LightColor0;
                    return a_color + d_color + s_color;
                }

            ENDCG
        }
    }
}
