208484147 eran.turgeman
318506425 noam137

ANSWER PART1 Q6:
In Q4, when we calculated a vertex normal, we took under consideration all normals of the surfaces touching the vertex. Therefore the vertex normal is calculated as an average of several surface normals, and we get a "smoother" result since the color calculated for a surface (through a vertex normal) depends on its adjacent surfaces.

In Q6, we separated each vertex into several vertices and created a unique set of vertices for each surface. Therefore, each vertex have a SINGLE surface touching it, so the average normal that is being calculated is actually an average of a single normal, which is the normal of the only surface touching it.
As a result the vertex normal equals to the surface normal, and each surface color is independent of any other surfaces, so the result we get is "less smooth" and we can see more noticeable differences between surfaces. This effect results as flat shading.