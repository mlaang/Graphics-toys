void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from -1. to 1. in the shortest window direction, something else for the other)
    vec2 uv = (fragCoord-0.5*iResolution.xy)/min(iResolution.x, iResolution.y);
    
    float t = 0.4+0.393*cos(2.0*iTime);
    
    vec3 p1 = vec3(t, 1.0, 0.0),
         p2 = vec3(0.0, -1.0, t);
    
    vec3 mix = 0.5*(1.0-uv.y)*p1 + 0.5*(1.0 + uv.y)*p2;
        
    vec3 col;
    if(uv.x*uv.x < dot(mix,mix))
        col = vec3(0.0, 0.0, 0.0);
    else
        // Time varying pixel color
        col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));

    // Output to screen
    fragColor = vec4(col,1.0);
}