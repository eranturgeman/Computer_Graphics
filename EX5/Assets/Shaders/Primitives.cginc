// Checks for an intersection between a ray and a sphere
// The sphere center is given by sphere.xyz and its radius is sphere.w
void intersectSphere(Ray ray, inout RayHit bestHit, Material material, float4 sphere)
{
    float3 c = sphere.xyz;
    float3 o = ray.origin;
    float3 d = ray.direction;
    float B = 2 * dot(o - c, d);
    float C = dot(o - c, o - c) - pow(sphere.w, 2);
    float D = pow(B, 2) - (4 * C);
    if (D < 0)
    {
        return;
    }

    float t;
    if(D == 0)
    {
        t = -B / 2;
    }
    if(D > 0)
    {
        float t1 = (-B - sqrt(D)) / 2;
        float t2 = (-B + sqrt(D)) / 2;
        t = min(t1, t2);
    }
    bestHit.distance = t;
    bestHit.position = o + (d * t);
    bestHit.normal = normalize(bestHit.position - c); //TODO make sure that the normal doesnt have to start at the hit point
    bestHit.material = material;
    return;
}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
void intersectPlane(Ray ray, inout RayHit bestHit, Material material, float3 c, float3 n)
{
    // Your implementation
}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
// The material returned is either m1 or m2 in a way that creates a checkerboard pattern 
void intersectPlaneCheckered(Ray ray, inout RayHit bestHit, Material m1, Material m2, float3 c, float3 n)
{
    // Your implementation
}


// Checks for an intersection between a ray and a triangle
// The triangle is defined by points a, b, c
void intersectTriangle(Ray ray, inout RayHit bestHit, Material material, float3 a, float3 b, float3 c, bool drawBackface = false)
{
    // Your implementation
}


// Checks for an intersection between a ray and a 2D circle
// The circle center is given by circle.xyz, its radius is circle.w and its orientation vector is n 
void intersectCircle(Ray ray, inout RayHit bestHit, Material material, float4 circle, float3 n, bool drawBackface = false)
{
    // Your implementation
}


// Checks for an intersection between a ray and a cylinder aligned with the Y axis
// The cylinder center is given by cylinder.xyz, its radius is cylinder.w and its height is h
void intersectCylinderY(Ray ray, inout RayHit bestHit, Material material, float4 cylinder, float h)
{
    // Your implementation
}
