Shader "Unlit/Bubble"
{
    Properties
    {
        [PowerSlider(0.1)] _F0("F0", Range(0, 1)) = 0.02
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _DTex ("D Texture", 2D) = "gray" {}
        _LETex ("LE Texture", 2D) = "gray" {}
        _CubeMap ("Cube Map", Cube) = "white" {}
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
                float3 lightDir : TEXCOORD4;
                half fresnel : TEXCOORD5;
                half3 reflDir : TEXCOORD6;
            };

            sampler2D _MainTex;
            sampler2D _DTex;
            sampler2D _LETex;

            UNITY_DECLARE_TEXCUBE(_CubeMap);

            float _F0;
            float4 _MainTex_ST;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = v.normal;
                o.tangent = v.tangent;
                o.viewDir  = normalize(ObjSpaceViewDir(v.vertex));
                o.lightDir = normalize(ObjSpaceLightDir(v.vertex));
                o.fresnel = _F0 + (1.0h - _F0) * pow(1.0h - dot(o.viewDir, v.normal.xyz), 5.0);
                o.reflDir = mul(unity_ObjectToWorld, reflect(-o.viewDir, v.normal.xyz));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float d = tex2D(_DTex, i.uv + _Time.xy * 0.1);
                // float d = tex2D(_DTex, i.uv);

                float ln = dot(i.lightDir, i.normal);
                ln = (ln * 0.5) * d;

                float lt = dot(i.lightDir, i.tangent);
                lt = ((lt + 1.0) * 0.5) * d;

                float u = tex2D(_LETex, float2(ln, lt)).x;

                float en = dot(i.viewDir, i.normal);
                en = ((1.0 - en) * 0.5 + 0.5) * d;

                float et = dot(i.viewDir, i.tangent);
                et = ((et + 1.0) * 0.5) * d;

                float v = tex2D(_LETex, float2(en, et)).x;

                fixed4 cubemap = UNITY_SAMPLE_TEXCUBE(_CubeMap, i.reflDir);

                float uv = u + v;
                float4 col = tex2D(_MainTex, uv.xx);
                // float4 col = tex2D(_MainTex, float2(u, v));
                col.a = min(1.0, i.fresnel * 0.5);

                float NdotL = dot(i.normal, i.lightDir);
                float3 refDir = -i.lightDir + (2.0 * i.normal * NdotL);
                float spec = pow(max(0, dot(i.viewDir, refDir)), 3.0) * 0.8;

                return col + spec;
            }
            ENDCG
        }
    }
}
