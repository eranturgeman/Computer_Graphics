#ifndef CG_RANDOM_INCLUDED
// Upgrade NOTE: excluded shader from DX11 because it uses wrong array syntax (type[size] name)
#pragma exclude_renderers d3d11
#define CG_RANDOM_INCLUDED

// Returns a psuedo-random float between -1 and 1 for a given float c

float random(float c)
{
    return -1.0 + 2.0 * frac(43758.5453123 * sin(c));
}

// Returns a psuedo-random float2 with componenets between -1 and 1 for a given float2 c
float2 random2(float2 c)
{
    c = float2(dot(c, float2(127.1, 311.7)), dot(c, float2(269.5, 183.3)));

    float2 v = -1.0 + 2.0 * frac(43758.5453123 * sin(c));
    return v;
}

// Returns a psuedo-random float3 with componenets between -1 and 1 for a given float3 c 
float3 random3(float3 c)
{
    float j = 4096.0 * sin(dot(c, float3(17.0, 59.4, 15.0)));
    float3 r;
    r.z = frac(512.0*j);
    j *= .125;
    r.x = frac(512.0*j);
    j *= .125;
    r.y = frac(512.0*j);
    r = -1.0 + 2.0 * r;
    return r.yzx;
}

// Interpolates a given array v of 4 float values using bicubic interpolation
// at the given ratio t (a float2 with components between 0 and 1)
//
// [0]=====o==[1]
//         |
//         t
//         |
// [2]=====o==[3]
//
float bicubicInterpolation(float v[4], float2 t)
{
    float2 u = t * t * (3.0 - 2.0 * t); // Cubic interpolation

    // Interpolate in the x direction

    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);

    // Interpolate in the y direction and return
    return lerp(x1, x2, u.y);
}

// Interpolates a given array v of 4 float values using biquintic interpolation
// at the given ratio t (a float2 with components between 0 and 1)
float biquinticInterpolation(float v[4], float2 t)
{
    float2 u = t * t * t * (6.0 * t * t - 15.0 * t + 10.0); // Quintic interpolation

    // Interpolate in the x direction

    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);

    // Interpolate in the y direction and return
    return lerp(x1, x2, u.y);
}

// Interpolates a given array v of 8 float values using triquintic interpolation
// at the given ratio t (a float3 with components between 0 and 1)
float triquinticInterpolation(float v[8], float3 t)
{
    float3 u = t * t * t * (6.0 * t * t - 15.0 * t + 10.0); // Quintic interpolation

    // Interpolate in the x direction

    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);
    float x3 = lerp(v[4], v[5], u.x);
    float x4 = lerp(v[6], v[7], u.x);

    // Interpolate in the y direction

    float y1 = lerp(x1, x2, u.y);
    float y2 = lerp(x3, x4, u.y);

    // Interpolate in the z direction and return

    return lerp(y1, y2, u.z);
}

// Returns the value of a 2D value noise function at the given coordinates c
float value2d(float2 c)
{
    float xLow = floor(c.x);
    float yLow = floor(c.y);
    float r1 = random2(float2(xLow, yLow)).x;
    float r2 = random2(float2(xLow + 1, yLow)).x;
    float r3 = random2(float2(xLow, yLow + 1)).x;
    float r4 = random2(float2(xLow + 1, yLow + 1)).x;
    float v[4] = {r1, r2, r3, r4};
    return bicubicInterpolation(v, c - float2(xLow, yLow));
}

// Returns the value of a 2D Perlin noise function at the given coordinates c

float perlin2d(float2 c)
{
    float xLow = floor(c.x);
    float yLow = floor(c.y);
    float2 r1 = random2(float2(xLow, yLow));
    float2 r2 = random2(float2(xLow + 1, yLow));
    float2 r3 = random2(float2(xLow, yLow + 1));
    float2 r4 = random2(float2(xLow + 1, yLow + 1));

    float2 v1 = c - float2(xLow, yLow);
    float2 v2 = c - float2(xLow + 1, yLow);
    float2 v3 = c - float2(xLow, yLow + 1);
    float2 v4 = c - float2(xLow + 1, yLow + 1);

    float v[4] = {dot(r1, v1), dot(r2, v2), dot(r3, v3), dot(r4, v4)};

    return biquinticInterpolation(v, c - float2(xLow, yLow));
}

// Returns the value of a 3D Perlin noise function at the given coordinates c

float perlin3d(float3 c)
{                    
    float xLow = floor(c.x);
    float yLow = floor(c.y);
    float zLow = floor(c.z);

    float3 r1 = random3(float3(xLow, yLow, zLow));
    float3 r2 = random3(float3(xLow + 1, yLow, zLow));
    float3 r3 = random3(float3(xLow, yLow + 1, zLow));
    float3 r4 = random3(float3(xLow + 1, yLow + 1, zLow));
    float3 r5 = random3(float3(xLow, yLow, zLow + 1));
    float3 r6 = random3(float3(xLow + 1, yLow, zLow + 1));
    float3 r7 = random3(float3(xLow, yLow + 1, zLow + 1));
    float3 r8 = random3(float3(xLow + 1, yLow + 1, zLow + 1));

    float3 v1 = c - float3(xLow, yLow, zLow);
    float3 v2 = c - float3(xLow + 1, yLow, zLow);
    float3 v3 = c - float3(xLow, yLow + 1, zLow);
    float3 v4 = c - float3(xLow + 1, yLow + 1, zLow);
    float3 v5 = c - float3(xLow, yLow, zLow + 1);
    float3 v6 = c - float3(xLow + 1, yLow, zLow + 1);
    float3 v7 = c - float3(xLow, yLow + 1, zLow + 1);
    float3 v8 = c - float3(xLow + 1, yLow + 1, zLow + 1);

    float v[8] = {dot(r1, v1), dot(r2, v2), dot(r3, v3), dot(r4, v4), dot(r5, v5), dot(r6, v6), dot(r7, v7), dot(r8, v8)};
    return triquinticInterpolation(v, c - float3(xLow, yLow, zLow));
}


#endif // CG_RANDOM_INCLUDED
