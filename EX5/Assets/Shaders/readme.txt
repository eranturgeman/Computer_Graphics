208484147 eran.turgeman
318506425 noam137


PART 4.8:
We follow the example from TA7 for procedural textures in 3D and adjust it to our case in 2D.

First we search for an intersection with the given plane and assumed the material is m2.

If an intersection wasn't found - return.
If an intersection was found:
1) multiply the hit position by 2 (because we work in 2D and not 3D) and floor it (as seen in class)

2) find the relevant coordinates to the given plane, for example- if the plane is XZ, the relevant
coordinates are the first and third coordinates. This is done by multiplying the hit position by
the complementary vector to the given normal (meaning, if the normal is (0,1,0) we take (1,0,1))

3) we sum the two relevant coordinates (its actually 3 coordinates but one of them must be 0)

4) we apply mod2 and check if the result is 0. If so this means that we are in the other material space
And we switch the material to m1



PART 5.3:
We divide our problem into 2 sub-problems.
First: searching for an intersection with the cylinder tube. If so- what is it?
Second: searching for an intersection with the cylinder top and bottom caps. If so- what is it?

The first problem is solved similarly to the sphere intersection problem. That mean finding the smallest solution to the quadratic equation representing the cylinder.

The second problem is solved by using intersectCircle with the correct heights of the top and bottom caps of
the cylinder.

Finally, by the way we implemented intersecPlane (called by intersectCircle) - the final hit point will be
the closest point to the ray's origin.
