Shader "Custom/TransparentEffect"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _Transparency ("Transparency", Range(0,1)) = 0.5
    }

    SubShader
    {
        Tags 
        { 
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
        }

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normal       : NORMAL;
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float3 normalWS     : TEXCOORD1;
                float3 positionWS   : TEXCOORD2; // 新增世界空间坐标
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half _Transparency;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                
                // 获取世界空间坐标
                VertexPositionInputs vertexInput = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionHCS = vertexInput.positionCS;
                OUT.positionWS = vertexInput.positionWS; // 存储世界空间坐标
                
                VertexNormalInputs normalInput = GetVertexNormalInputs(IN.normal);
                OUT.normalWS = normalInput.normalWS;
                
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 color = _BaseColor;
                color.a *= _Transparency;

                // 修正后的法线边缘计算
                float3 viewDir = normalize(_WorldSpaceCameraPos - IN.positionWS); // 使用世界空间坐标
                half rim = 1 - saturate(dot(normalize(IN.normalWS), viewDir));
                
                color.rgb += rim * 0.5;
                return color;
            }
            ENDHLSL
        }
    }
}