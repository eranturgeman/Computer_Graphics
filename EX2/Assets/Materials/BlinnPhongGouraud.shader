Shader "CG/BlinnPhongGouraud"
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
                    fixed4 color: COLOR0;
                };


                v2f vert (appdata input)
                {
                    v2f output;

                    fixed4 a_color = _AmbientColor * _LightColor0;

                    float4 pos = UnityObjectToClipPos(input.vertex);

                    fixed3 l = normalize(_WorldSpaceLightPos0);
                    fixed3 v = normalize(_WorldSpaceCameraPos.xyz - pos.xyz);
                    fixed3 h = normalize(l + v);

                    fixed4 d_color = max(0, dot(input.normal.xyz, l)) * _DiffuseColor * _LightColor0;
                    
                    
                    fixed4 s_color = pow(max(0, dot(input.normal, h)), _Shininess) * _SpecularColor * _LightColor0;
                    output.color = a_color + d_color + s_color;
                    output.pos = pos;
                
                    return output;
                }


                fixed4 frag (v2f input) : SV_Target
                {
                    return input.color;
                }

            ENDCG
        }
    }
}
