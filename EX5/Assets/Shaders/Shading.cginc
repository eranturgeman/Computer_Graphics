// Implements an adjusted version of the Blinn-Phong lighting model
float3 blinnPhong(float3 n, float3 v, float3 l, float shininess, float3 albedo)
{
    //TODO make sure v, l, n are in world position
    float3 h = normalize(l + v);
    float3 diffuse = max(0, dot(n, l)) * albedo;
    float3 specular = pow(max(0, dot(n, h)), shininess) * 0.4f;
    return diffuse + specular;
}

// Reflects the given ray from the given hit point
void reflectRay(inout Ray ray, RayHit hit)
{
    float3 r = normalize((2 * dot(-ray.direction, hit.normal) * hit.normal) + ray.direction);
    ray.origin = hit.position + EPS * hit.normal;
    ray.direction = r;
    ray.energy = ray.energy * hit.material.specular;
}

// Refracts the given ray from the given hit point
void refractRay(inout Ray ray, RayHit hit)
{
    float3 i = ray.direction;
    float3 n = hit.normal;
    float eta = 1 / hit.material.refractiveIndex; //eta air / eta material

    if (dot(n, i) > 0){
        n = -n;
        eta = hit.material.refractiveIndex;
    }

    float c1 = abs(dot(n, i));
    float c2 = sqrt(1 - (eta * eta * (1 - (c1 * c1))));
    float3 t = normalize((eta * i) + ((eta * c1) - c2) * n);

    ray.origin = hit.position - (EPS * n);
    ray.direction = t;
  
}

// Samples the _SkyboxTexture at a given direction vector
float3 sampleSkybox(float3 direction)
{
    float theta = acos(direction.y) / -PI;
    float phi = atan2(direction.x, -direction.z) / -PI * 0.5f;
    return _SkyboxTexture.SampleLevel(sampler_SkyboxTexture, float2(phi, theta), 0).xyz;
}