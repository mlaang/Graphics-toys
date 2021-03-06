/* Parameters: Incoming ray: ray origin ro, ray direction rd
 *             Sphere: centre c, radius r
 *             Where the ray origin is outside the sphere.
 *             
 * Return value: If no intersection, a negative number,
 *               Otherwise the smallest positive t such that |ro + rd*t - c|=r
 */
float ray_sphere_intersection(vec3 ro, vec3 rd, vec3 c, float r) {
    //Is there some t so that the inequality dot(ro + rd*t - c, ro + rd*t - c) < r*r
    //is satisfied?
    //Let d = ro - c
    
    vec3 d = ro - c;
    
    //Then we have dot(d + rd*t, d + rd*t) < r*r
    //Expanding, we obtain:
    //dot(d,d) + dot(rd,rd)*t^2 + 2*dot(d,rd)*t < r*r
    //Let e = r*r - dot(d,d)
    
    float e = r*r - dot(d,d);
    
    //Then the inequality is dot(rd,rd)*t^2 + 2*dot(d,rd)*t < e
    //rd is chosen so that dot(rd,rd) is nonzero.
    //Thus t^2 + 2*dot(d,rd)/dot(rd,rd)*t < e/dot(rd,rd).
    //Let f = dot(d,rd)/dot(rd,rd) and g = e/dot(rd,rd);
    
    float f = dot(d,rd)/dot(rd,rd),
          g = e/dot(rd,rd);
    
    //Then we have
    //t^2 + 2f*t < g.
    //Completing the square we obtain
    //(t + f)^2 - f^2 < g.
    //Let h = g + f^2
    
    float h = g + f*f;
    
    //Then the inequality is (t + f)^2 < h 
    //If h < 0 there is no solution. Otherwise the solution is the smallest number t
    //such that (t+f)^2 = h.
    
    if(h < 0.0)
        return -1.0;
    else
        return -sqrt(h)-f; //This is the smallest root of (t+f)^2=h for the reason that
    					   //f is always negative: this is because f = dot(d,rd)/dot(rd,rd)
    					   //and therefore has the same sign as dot(d,rd). d = ro - c
    					   //so dot(d,rd)=dot(ro-c,rd)= -dot(c-ro,rd); and c is always in front
    					   //of the ray, so c-ro is in the same direction as rd.
}

/* Parameters: Incoming ray: ray origin ro, ray direction rd
 *             Plane: normal plane_normal, point on the plane, plane_point.
 * Return value: If no intersection, a negative number,
 *               Otherwise the unique t such that ro + rd*t is on the plane.
 */
float ray_plane_intersection(vec3 ro, vec3 rd, vec3 plane_normal, vec3 plane_point) {
    //Is there some t so that dot(plane_normal, plane_point) = dot(plane_normal, ro + rd*t)?
    //If so, that t is to be returned.
    
    //Bilinearity immediately ensures that
    //dot(plane_normal, plane_point) = dot(plane_normal, ro) + dot(plane_normal, rd)*t
    //Thus
    //(dot(plane_normal, plane_point)-dot(plane_normal,ro))/dot(plane_normal, rd) = t
    //This simplifies to
    //dot(plane_normal, plane_point - ro)/dot(plane_normal, rd)=t
    
    //A solution exists if dot(plane_normal, rd) is not zero.    
    if(dot(plane_normal, rd) == 0.0)
        return -1.0;
    else
        return dot(plane_normal, plane_point - ro)/dot(plane_normal, rd);
}

/* Parameters: Incoming ray: ray origin ro, ray direction rd
 *             Sphere: centre c, radius r
 *             Where the ray origin is outside the sphere.
 *
 * Return value: If no intersection, a negative number,
 *               Otherwise the largest positive t such that |ro + rd*t - c|=r
 */
float ray_antisphere_intersection(vec3 ro, vec3 rd, vec3 c, float r) {
    //Calculating as in a ray-sphere intersection, but choosing the other root at the end.
       
    vec3 d = ro - c;
    float e = r*r - dot(d,d);
    float f = dot(d,rd)/dot(rd,rd),
          g = e/dot(rd,rd);
    float h = g + f*f;
    
    if(h < 0.0)
        return -1.0;
    else
        return sqrt(h)-f; //This is the largest root of (t+f)^2=h for the same
                          //reason that the corresponding return value in the ray_sphere_intersection
                          //function is the smallest root.
}

/* Parameters: Interface: Ratio of refractive index in space before interface and refractive index
 *             after interface alpha. Normal direction normal.
 *
 *             Ray direction rd
 *
 * Input ray direction is overwritten by output ray direction.
 */
void refract_ray(float alpha, vec3 normal, inout vec3 rd) {
    //The vector form of Snell's law states that
    //eta0 * cross(rd, N) = eta1 * cross(new_rd, N).
    //Additionally, we know that N is a linear combination of the negative normal
    //and rd.
    //Thus we obtain new_rd = alpha*rd + beta*N
    //We immediately obtain eta0/eta1 * cross(rd, N) = alpha*cross(rd, N) + beta*cross(N,N).
    //cross(N,N)=0 so eta0/eta1 * cross(rd, N) = alpha*cross(rd, N)
    //and we obtain
    //alpha = eta0/eta1 * dot(cross(rd, N), cross(rd, N)) = alpha * dot(cross(rd, N), cross(rd, N))
    //giving
    //alpha = eta0/eta1
    //This is the input alpha.
    
    //eta0<eta1, i.e. eta0/eta1 < 1, i.e. alpha < 1 the refracted ray will be closer to the negative normal
    //when alpha > 1 it will be closer to the positive normal.
    //beta is to be negative when alpha < 1 and positive otherwise.
    //When alpha > 0 it remains to choose beta so that beta <= 0 and dot(new_rd, new_rd)=1.0.
    //dot(new_rd, new_rd) = alpha*alpha*dot(rd, rd) + 2*alpha*beta*dot(rd, N) + beta*beta*dot(N, N) = 1.0
    //First we note that dot(rd,rd)=dot(N,N)=1.0.
    //alpha*alpha + 2*alpha*beta*dot(rd, N) + beta*beta = 1.0
    //Since alpha is known we can simply solve for beta
    
    //(beta + alpha*dot(rd,N))^2 - alpha*alpha*dot(rd,N)^2 = 1.0
    //beta + alpha*dot(rd,N) = +-sqrt(1.0 + alpha*alpha*dot(rd, N)^2)
    
    //The negative root will ensure that beta will be negative
    //beta = -sqrt(1.0 + alpha*alpha*dot(rd, N)^2) - alpha*dot(rd,N)
    //and the positive root that beta will be positive.
    
    float cosine = dot(rd, normal);
    float beta = sign(alpha - 1.0)*sqrt(1.0 + alpha*alpha*cosine*cosine) - alpha*cosine;
    
    rd = alpha*rd + beta*normal;
}
    
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    // Normalized pixel coordinates (from -1.0 to 1.0) 
    vec2 uv = (2.0*fragCoord.xy - iResolution.xy)/min(iResolution.x, iResolution.y);

    
    // Camera: ray origin and direction
    vec3 ro = vec3(0.0, 0.0, -5.0);
    vec3 camera_direction = vec3(0.0, 0.0, 0.0) - ro;
    vec3 rd = vec3(uv.xy, 0.0)-ro;
    
    //Objects
    
    //Large central sphere (object 0), having an antisphere on its surface.
    vec3 c1 = vec3(0.0, 2.0*(0.7+0.3*sin(iTime)-0.5), 0.0);
    float r1 = 0.9;
    
    vec3 ac1 = vec3(1.3, 2.0*(0.7+0.3*sin(iTime)-0.5), -1.0);
    float ar1 = 1.0;
    
    vec3 ac2 = vec3(0.0, 2.0*(0.7+0.3*sin(iTime)-0.5), -1.0);
    float ar2 = 0.3;
    
    //Smaller sphere orbiting around the large central sphere (object 1).
    vec3 c2 = vec3(1.5*sin(iTime), 0.0, 1.5*cos(iTime));
    float r2 = 0.2;
    
    //Plane (object 2).
    vec3 plane_normal = vec3(0.0, 1.0, 0.0);
    vec3 plane_point = vec3(0.0, -0.5, 0.0);
    
    //Sphere (object 3).
    vec3 c3 = vec3(-2.5*cos(-iTime), 0.0, 2.5*sin(-iTime));
    float r3 = 0.15;
    
    //Transparent sphere (object 6)
    vec3 c4 = vec3(iMouse.x/iResolution.x - 0.5, iMouse.y/iResolution.y - 0.5, -4.0);
    float r4 = 0.15;
    
    vec3 col = vec3(0.0, 0.0, 0.0),
         multiplier = vec3(1.0, 1.0, 1.0);
    
    float t[7];
    const float epsilon = 0.000001;
    
    for(int j = 0; j != 15; ++j) {
        t[0] = ray_sphere_intersection(ro, rd, c1, r1);
        t[1] = ray_sphere_intersection(ro, rd, c2, r2);
        t[2] = ray_plane_intersection(ro, rd, plane_normal, plane_point);
        t[3] = ray_sphere_intersection(ro, rd, c3, r3);
        t[4] = ray_antisphere_intersection(ro, rd, ac1, ar1);
        t[5] = ray_antisphere_intersection(ro, rd, ac2, ar2);
        t[6] = ray_sphere_intersection(ro, rd, c4, r4);
        
        //In general, hits within a distance epsilon are disallowed and are to be ignored.
        //This is because we are not nudging the intersection points to ensure that they are
        //on the near side of the surface with which we intersect the ray, this in order
        //to compute more exact reflections.
        
        //That having been said, we will now be concerned with resolving antisphere issues:
        
        //If the antisphere is not hit then we are not concerned with it
        //if it is hit, however, a bunch of situations arise:
        
        //A hit going thorough the antisphere can hit the sphere or other objects
        //this happens when the intersection with the antisphere lies outside the sphere
        //and in that case the antisphere is to be ignored:
        
        if(t[4] > epsilon && dot(ro + rd*t[4]-c1, ro + rd*t[4]-c1) > r1*r1)
            t[4] = -1.0;
        
        //Alternatively, a hit going through the antisphere can hit the concave surface
        //defined by the antisphere. Then we must however ignore the sphere.
        
        if(t[4] > epsilon && dot(ro + rd*t[4]-c1, ro + rd*t[4]-c1) <= r1*r1)
            t[0] = -1.0;
        
        //Finally we do it the same way for the second antisphere.
        if(t[5] > epsilon && dot(ro + rd*t[5]-c1, ro + rd*t[5]-c1) > r1*r1)
            t[5] = -1.0;
        if(t[5] > epsilon && dot(ro + rd*t[5]-c1, ro + rd*t[5]-c1) <= r1*r1)
            t[0] = -1.0;
        
        int chosen_object_along_ray = -1;
        for(int i = 0; i != 7; ++i)
            if(t[i] > epsilon)
                chosen_object_along_ray = i;
            
        if(chosen_object_along_ray != -1)
            for(int i = 0; i != 7; ++i)
                if(t[i] < t[chosen_object_along_ray] && t[i] > epsilon)
                    chosen_object_along_ray = i;
                
        vec3 intersection_point,
             normal_component,
             remainder,
             new_direction;
                
        switch(chosen_object_along_ray) {
            case 0:
                //If we end up here we've hit object zero, a sphere, but not the antisphere
                //that is part of this object.
                    
                intersection_point = ro + rd * t[0];
                vec3 sphere_normal = normalize(intersection_point - c1);
                    
                //It is necessary to ensure that the intersection point is outside the sphere,
                //or the next intersection of the ray may be with the sphere itself.
            
                //The incoming ray can be split into a component along the sphere normal and a remainder
                
                normal_component = sphere_normal * dot(rd, sphere_normal);
                remainder = rd - normal_component;
            
                //The remainder will not be affected by being reflected
                //But the normal component will be negated
            
                new_direction = remainder - normal_component;
            
                //We now have a new ray:
                //with origin intersection_point and direction new_direction.
                //We want to return the colour of whatever that hits
            
                ro = intersection_point;
                rd = new_direction;
            
                col += (multiplier * vec3(0.0, 1.0, 0.0));
                multiplier *= vec3(0.9, 0.9, 0.9);
                break;
            case 1:
                col += (multiplier*vec3(1.0, 1.0, 1.0));
                multiplier = vec3(0.0, 0.0, 0.0);
                break;
            case 2:
                intersection_point = ro + rd * t[2];
                
                //The incoming ray is split into a component along the plane normal and a remainder
            
                normal_component = plane_normal * dot(rd, plane_normal);
                remainder = rd - normal_component;
            
                //The remainder will not be affected by being reflected, but the normal component
                //will be negated
            
                new_direction = remainder - normal_component;
            
                //We now have a new ray:
            
                ro = intersection_point;
                rd = new_direction;
            
                col += (multiplier * vec3(0.0, 0.0, 0.7));
                multiplier *= vec3(0.9, 0.9, 0.9);
                break;
            case 3:
                col += (multiplier * vec3(1.0, 0.0, 0.0));
                multiplier = vec3(0.0, 0.0, 0.0);
            
                //Because this is terminal and sets the multiplier vector to the zero vector
                //it doesn't matter that we do not calculate a new ray.
                break;
            case 4:
                //If we end up here we've hit both the antisphere and the sphere.
                //We thus need to compute things as if though we hit the negative normal of
                //the sphere that is the antisphere.
                    
                intersection_point = ro + rd * t[4];
                   
                vec3 antisphere_normal = -normalize(intersection_point - ac1);
                    
                normal_component = antisphere_normal * dot(rd, antisphere_normal);
                remainder = rd - normal_component;
                    
                new_direction = remainder - normal_component;
                    
                ro = intersection_point;
                rd = new_direction;
                    
                col += multiplier*vec3(0.0, 1.0, 0.0);
                multiplier *= vec3(0.9, 0.9, 0.9);
                break;
            case 5:
                //Here we do it the same way as above, but again
            
                intersection_point = ro + rd*t[5];
                antisphere_normal = -normalize(intersection_point - ac2);
                normal_component = antisphere_normal * dot(rd, antisphere_normal);
                remainder = rd - normal_component;
                new_direction = remainder - normal_component;
                ro = intersection_point;
                rd = new_direction;
            
                col += multiplier*vec3(0.0, 1.0, 0.0);
                multiplier *= vec3(0.9, 0.9, 0.9);
                break;
            case 6:
                intersection_point = ro + rd*t[6];
                sphere_normal = normalize(intersection_point - c4);
                refract_ray(1.0/1.9, sphere_normal, rd);
                float s = ray_antisphere_intersection(intersection_point, rd, c4, r4);            
                intersection_point = intersection_point + s*rd;
                sphere_normal = normalize(intersection_point - c4);
                refract_ray(1.9/1.0, sphere_normal, rd);
                ro = intersection_point;
        }
    }
        
    fragColor = vec4(col, 1.0);
}