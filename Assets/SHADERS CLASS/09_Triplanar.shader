Shader "ENTI/09_Triplanar"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
_MainTex("Main Texture", 2D) = "white"{}
_SecondTex("Secondary Texture", 2D) = "white"{}
_Sharpness ("Sharpness", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
    float3 normal : NORMAL;
};

            struct v2f
            {
                float4 vertex : SV_POSITION;
    float3 worldPos : TEXCOORD0;
    float3 normal : NORMAL0;
};

            fixed4 _Color;
sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _SecondTex;
float4 _SecondTex_ST;
float _Sharpness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);   
    float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
    o.worldPos = worldPos.xyz;
    o.normal = normalize(mul(v.normal, (float3x3) unity_WorldToObject));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {                
    //calculate uv for 3 projections
    float2 uv_front = TRANSFORM_TEX(i.worldPos.yz, _SecondTex);
    float2 uv_top = TRANSFORM_TEX(i.worldPos.xz, _SecondTex);
    float2 uv_side = TRANSFORM_TEX(i.worldPos.xy, _SecondTex);
    
    //read textures at uv position of 3 projections
    fixed4 col_side = tex2D(_SecondTex, uv_side);
    fixed4 col_front = tex2D(_SecondTex, uv_front);
    fixed4 col_top = tex2D(_SecondTex, uv_top);
    
    if (i.normal.y > 0)
    {
         uv_top = TRANSFORM_TEX(i.worldPos.xz, _MainTex);
        col_top = tex2D(_MainTex, uv_top);
    }
    
    float3 weights = i.normal;
    weights = abs(weights);
    weights = pow(weights, _Sharpness);
    weights = weights / (weights.x + weights.y + weights.z);
    
    col_front *= weights.x;
    col_top *= weights.y;
    col_side *= weights.z;
    
    fixed4 col = col_front + col_top + col_side;
    
    
    //col.rgb = weights;
    
    return col;
}
            ENDCG
        }
    }
}
