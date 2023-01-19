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

    float t = 0;
    if(D == 0)
    {
        t = -B / 2;
    }
    if(D > 0)
    {
        float t1 = (-B - sqrt(D)) / 2;
        float t2 = (-B + sqrt(D)) / 2;
        if (t1 > 0)
        {
            t = t1;
        }
        if (t2 > 0 && t1 <= 0)
        {
            t = t2;
        }
        if (t1 < 0 && t2 < 0)
        {
            return;
        }
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
    float3 o = ray.origin;
    float3 d = ray.direction;
    if(dot(d,n) == 0)
    {
        return;
    }
    float t = (-dot(o - c, n)) / dot(d, n);
    if (t <= 0 || t >= bestHit.distance)
    {
        return;
    }
    bestHit.distance = t;
    bestHit.position = o + (d * t);
    bestHit.normal = n;
    bestHit.material = material;
    return;
    
}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
// The material returned is either m1 or m2 in a way that creates a checkerboard pattern 
void intersectPlaneCheckered(Ray ray, inout RayHit bestHit, Material m1, Material m2, float3 c, float3 n)
{
    intersectPlane(ray, bestHit, m2, c, n);
    if(isinf(bestHit.distance))
    {
        return;
    }

    // this ill be explained in the README
    float sumRelevantCoords = dot(floor(2 * bestHit.position), (1-n));
    if (fmod(sumRelevantCoords, 2) == 0)
    {
        bestHit.material = m1;
    }
    
}


// Checks for an intersection between a ray and a triangle
// The triangle is defined by points a, b, c
void intersectTriangle(Ray ray, inout RayHit bestHit, Material material, float3 a, float3 b, float3 c, bool drawBackface = false)
{
    float3 pos = bestHit.position;
    float dist = bestHit.distance;
    float3 originalNormal = bestHit.normal;
    Material mat = bestHit.material;

    float3 n = normalize(cross(a - c, b - c));
    intersectPlane(ray, bestHit, material, c, n);

    if ((bestHit.distance == dist) || (isinf(bestHit.distance)))
    {
        return;
    }

    float3 p = bestHit.position;
    bool cond1 = dot(cross(b - a, p - a), n) >= 0;
    bool cond2 = dot(cross(c - b, p - b), n) >= 0;
    bool cond3 = dot(cross(a - c, p - c), n) >= 0;
    if (cond1 && cond2 && cond3)
    {
        return; //hit inside the triangle
    }
    if (drawBackface)
    {   
        bool cond1 = dot(cross(b - a, p - a), -n) >= 0;
        bool cond2 = dot(cross(c - b, p - b), -n) >= 0;
        bool cond3 = dot(cross(a - c, p - c), -n) >= 0;
        if (cond1 && cond2 && cond3)
        {
            return;
        }
    }
    bestHit.position = pos;
    bestHit.distance = dist;
    bestHit.normal = originalNormal;
    bestHit.material = mat;
}


// Checks for an intersection between a ray and a 2D circle
// The circle center is given by circle.xyz, its radius is circle.w and its orientation vector is n 
void intersectCircle(Ray ray, inout RayHit bestHit, Material material, float4 circle, float3 n, bool drawBackface = false)
{
    float3 pos = bestHit.position;
    float dist = bestHit.distance;
    float3 originalNormal = bestHit.normal;
    Material mat = bestHit.material;

    float3 c = circle.xyz;
    float r = circle.w;
    intersectPlane(ray, bestHit, material, c, n);

    if ((bestHit.distance == dist) || (isinf(bestHit.distance)))
    {
        return;
    }

    float3 p = bestHit.position;
    if (length(p - c) > r)
    {
        //if the hitpoint OUTSIDE the circle
        bestHit.position = pos;
        bestHit.distance = dist;
        bestHit.normal = originalNormal;
        bestHit.material = mat;
        return;
    }

    if (drawBackface)
    {
        return; //TODO check if need to implement drawBackface
    }
}


// Checks for an intersection between a ray and a cylinder aligned with the Y axis
// The cylinder center is given by cylinder.xyz, its radius is cylinder.w and its height is h
void intersectCylinderY(Ray ray, inout RayHit bestHit, Material material, float4 cylinder, float h)
{
    float3 o = ray.origin;
    float3 d = ray.direction;
    float2 xzCenter = float2(cylinder.x, cylinder.z);
    float r = cylinder.w;
    float2 xzOrigin = float2(ray.origin.x, ray.origin.z);
    float2 xzDirection = float2(ray.direction.x, ray.direction.z);

    //intersect with infinite cylinder
    float A = dot(xzDirection, xzDirection);
    float B = 2 * dot(xzOrigin - xzCenter, xzDirection);
    float C = dot(xzOrigin - xzCenter, xzOrigin - xzCenter) - pow(r, 2);
    float D = pow(B, 2) - (4 * A * C); 

    if (D < 0)
    {
        return;
    }

    float t = 0;
    if(D == 0)
    {
        t = -B / 2;
    }
    if(D > 0)
    {
        float t1 = (-B - sqrt(D)) / (2 * A);
        float t2 = (-B + sqrt(D)) / (2 * A);
        if (t1 > 0)
        {
            t = t1;
        }
        if (t2 > 0 && t1 <= 0)
        {
            t = t2;
        }
        if (t1 < 0 && t2 < 0)
        {
            return;
        }
    }
    if (t >= bestHit.distance)
    {
        return;
    }
    float3 p = o + (d * t);
    if (p.y <= cylinder.y + (h / 2) && p.y >= cylinder.y - (h / 2))
    {
        bestHit.distance = t;
        bestHit.position = p;
        bestHit.normal = normalize(bestHit.position - float3(cylinder.x, p.y, cylinder.z));
        bestHit.material = material;
    }

    //checking intersections with cylinder circles
    intersectCircle(ray, bestHit, material, cylinder + float4(0, h / 2, 0, 0), float3(0, 1, 0));
    intersectCircle(ray, bestHit, material, cylinder - float4(0, h / 2, 0, 0), float3(0, 1, 0));
    return;
}
