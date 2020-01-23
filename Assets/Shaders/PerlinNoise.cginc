
#ifndef __PERLINNOISE_CGINC__
#define __PERLINNOISE_CGINC__

fixed2 random(fixed2 st)
{
    st = fixed2(
        dot(st, fixed2(127.1, 311.7)),
        dot(st, fixed2(269.5, 183.3)));

    return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
}

float perlinNoise(fixed2 st)
{

    fixed2 p = floor(st);
    fixed2 f = frac(st);
    fixed2 u = f * f * (3.0 - 2.0 * f);

    float v00 = random(p + fixed2(0, 0));
    float v10 = random(p + fixed2(1, 0));
    float v01 = random(p + fixed2(0, 1));
    float v11 = random(p + fixed2(1, 1));

    float a = lerp(dot(v00, f - fixed2(0, 0)), dot(v10, f - fixed2(1, 0)), u.x);
    float b = lerp(dot(v01, f - fixed2(0, 1)), dot(v11, f - fixed2(1, 1)), u.x);
    return lerp(a, b, u.y) + 0.5;
}

#endif
