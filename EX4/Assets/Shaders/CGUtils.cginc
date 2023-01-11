#ifndef CG_UTILS_INCLUDED
#define CG_UTILS_INCLUDED

#define PI 3.141592653

// A struct containing all the data needed for bump-mapping
struct bumpMapData
{ 
    float3 normal;       // Mesh surface normal at the point (world space)
    float3 tangent;      // Mesh surface tangent at the point (world space)
    float2 uv;           // UV coordinates of the point
    sampler2D heightMap; // Heightmap texture to use for bump mapping
    float du;            // Increment size for u partial derivative approximation
    float dv;            // Increment size for v partial derivative approximation
    float bumpScale;     // Bump scaling factor
};


// Receives pos in 3D cartesian coordinates (x, y, z)
// Returns UV coordinates corresponding to pos using spherical texture mapping
float2 getSphericalUV(float3 pos)
{
    float r = sqrt(pos.x * pos.x + pos.y * pos.y + pos.z * pos.z);
    float u = 0.5 + (atan2(pos.z, pos.x) /  (2 * PI));
    float v = 1 - (acos(pos.y / r) / PI);
    return float2(u, v);
}

// Implements an adjusted version of the Blinn-Phong lighting model
fixed3 blinnPhong(float3 n, float3 v, float3 l, float shininess, fixed4 albedo, fixed4 specularity, float ambientIntensity)
{
    fixed4 ambient = ambientIntensity * albedo;
    fixed4 diffuse = max(0, dot(n,l)) * albedo;
    float3 h = normalize(l + v);
    fixed4 specular = pow(max(0, dot(n, h)), shininess) * specularity;
    return (ambient + diffuse + specular).rgb;
}

// Returns the world-space bump-mapped normal for the given bumpMapData
float3 getBumpMappedNormal(bumpMapData i)
{
    float fTagU = (tex2D(i.heightMap, (i.uv + i.du)) - tex2D(i.heightMap, i.uv)) / i.du;
    float fTagV = (tex2D(i.heightMap, (i.uv + i.dv)) - tex2D(i.heightMap, i.uv)) / i.dv;
    float3 nh = normalize(float3(-i.bumpScale * fTagU, -i.bumpScale * fTagV, 1)); //this is after the cross product, scaled with bumpScale factor and normalized
    return i.tangent * nh.x + i.normal * nh.z + cross(i.tangent, i.normal) * nh.y;
}


#endif // CG_UTILS_INCLUDED
