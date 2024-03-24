Shader"ENTI/03_Terrain"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex("Main Texture", 2D) = "white" {}
        _Heatmap("Heatmap", 2D) = "white" {}
        _MaxHeight("Max Height", float) = 1.0
        _Center("Center", Vector) = (200,0,200,0)
_Radius("Radius", Float) = 100
_RadiusColor("Radius Color", Color) = (1,0,0,1)
_RadiusWidth("Radius Width", Float) = 10

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
                
            struct Input
{
 float2 uv_MainTex; // The UV of the terrain texture
 float3 worldPos; // The in-world position
};

            struct appdata
            {
                float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

            struct v2f
            {
                float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
    float4 albedo : fixed4;
    float3 worldPos : TEXCOORD1;
    
};
sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _Heatmap;
float4 _Heatmap_ST;
fixed4 _Color;
float _MaxHeight;
float3 _Center;
float _Radius;
fixed4 _RadiusColor;
float _RadiusWidth;

            v2f vert (appdata v)
            {
    v2f o;
    o.uv = v.uv;
    o.vertex=v.vertex;
    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
                ////A
                //o.vertex = mul(UNITY_MATRIX_VP, o.vertex);
                ////B
                //o.vertex = mul(UNITY_MATRIX_V, o.vertex);
                //o.vertex = mul(UNITY_MATRIX_P, o.vertex);

                //float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                //o.uv = TRANSFORM_TEX(worldPos.xz, _MainTex);

    float2 local_tex_Height = tex2Dlod(_MainTex, float4(v.uv, 0, 0));
    float l_Height = local_tex_Height.y * _MaxHeight;
    o.uv = float2(v.uv.x, local_tex_Height.y);

    o.vertex = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));
    o.vertex.y = o.vertex.y + l_Height;
    o.vertex = mul(UNITY_MATRIX_VP, o.vertex);

    //o.uv = v.uv;
    return o;

            }

            fixed4 frag (v2f i) : SV_Target
            {       
    fixed4 col;
    float d = distance(_Center, i.worldPos);
 // If the distance is larger than the radius and
 // it is less than our radius + width change the color
 if ((d > _Radius) && (d < (_Radius + _RadiusWidth)))
 {
    col = _RadiusColor;
 }
 // Otherwise, use the normal color
 else
 {
     col = tex2D(_Heatmap, i.uv);
 }
                return col;
            }
            ENDCG
        }
    }
}
