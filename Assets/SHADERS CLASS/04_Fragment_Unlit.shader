Shader"ENTI/04_Fragment_Unlit"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
_Color2("Color 2", Color)=(1,1,1,1)
_Blend("Blend Value", Range(0,1))=1.0
_MainTex("Main Texture", 2D) = "white"{}
_SecondTex("Secondary Texture", 2D) = "white"{}
_ThirdTex("Third Texture", 2D) = "white"{}
_BlendTex("Blend Texture", 2D) = "white"{}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
    Blend SrcAlpha OneMinusSrcAlpha
    ZWrite Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

            struct v2f
            {
                float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
};
sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _SecondTex;
float4 _SecondTex_ST;
sampler2D _ThirdTex;
float4 _ThirdTex_ST;
sampler2D _BlendTex;
float4 _BlendTex_ST;


            fixed4 _Color;
            fixed4 _Color2;
            float _Blend;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);         
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {                
                 fixed4 col;

                //1. Blending
                col = _Color + _Color2 * _Blend;    

                //2. Interpolation
                col = _Color * (1 - _Blend) + _Color2 * _Blend;
                col = lerp(_Color, _Color2, _Blend);

                //3. Textures
                //calculate uv coordinates
                float2 main_uv = TRANSFORM_TEX(i.uv, _MainTex);
                float2 second_uv = TRANSFORM_TEX(i.uv, _SecondTex);
                float2 third_uv = TRANSFORM_TEX(i.uv, _ThirdTex);
                //read colors from texture
                fixed4 main_color = tex2D(_MainTex, main_uv);
                fixed4 second_color = tex2D(_SecondTex, second_uv);
                fixed4 third_color = tex2D(_ThirdTex, third_uv);
                //interpolate
                float2 blend_uv = TRANSFORM_TEX(i.uv, _BlendTex);
                fixed4 blend_color = tex2D(_BlendTex, blend_uv);
                col = _Color;
                col = lerp(col, main_color, blend_color.r);
                col = lerp(col, second_color, blend_color.g);
                col = lerp(col, third_color, blend_color.b);

    ////Sin
    //float sin_value = sin(_Time.y);
    //sin_value = saturate(sin_value);//clamps value (0,1)
    //sin_value = frac(sin_value);//returns fractional(decimal) = (0.0, 0.9)
    //col = lerp(_Color, _Color2, sin_value);
    
    return col;

            }
            ENDCG
        }
    }
}
