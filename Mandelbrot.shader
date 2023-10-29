Shader "Unlit/Mandelbrot"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" {}
        _MaxIterations ("Maximum Iterations", Range(1, 1024)) = 256
        _Color ("Color", Color) = (1,1,1,1)
        _Zoom ("Zoom", Range(0.0001,10)) = 3
        _Move ("Move", Vector) = (-0.15,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _MaxIterations;
            float _Zoom;
            float4 _Move;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = (v.uv - 0.5) * _Zoom + _Move.xy;
                return o;
            }

            float mandelbrot (float2 constant){
                float B = 256;
                float zr, zi = 0;

                float iterations = 0.0;
                //z = z^2 + c
                //z is a float2, has x and yi
                //                 i^2 = -1
                //z^2 = x^2 + 2xyi + (-1)y^2

                //Re(z^2) = x^2 - y^2   => zr
                //Im(z^2) = 2xy         => zi

                //|z| = dot(z,z) = x^2 + y^2

                //B is the maximum value that an iteration can return. |z| should be lesser than |B|

                for(iterations = 0; iterations < _MaxIterations; iterations+=1.0){
                    zr = zr * zr - zi * zi + constant.x;
                    zi = 2.0 * zr * zi + constant.y;
                    if(zr*zr + zi*zi > B*B){
                        break;
                    }
                }
                //Smooth iteration count formula by Inigo Quilez
                //https://iquilezles.org/articles/msetsmooth/
                float sn = iterations - log(log(zr*zr + zi*zi)/log(B))/log(2.0); // smooth iteration count
                //float sn = iterations - log2(log2(zr*zr + zi*zi)) + 4.0;  // equivalent optimized smooth iteration count
                
                return sn;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float mand = mandelbrot(i.uv);
                float3 col = fixed4(0,0,0,0);
                
                
                col += 0.5 + 0.5*cos( 3.0 + mand*0.15 + float3(0.0,0.6,1.0));
                return fixed4(col.xyz, 1);
            }
            ENDCG
        }
    }
}
