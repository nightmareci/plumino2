vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    vec4 texcolor = Texel(tex, texture_coords);
    vec4 newcol = color;
    newcol.x *= 8.0;
    newcol.yz /= (1.0/(newcol.x))*4.0;
    return texcolor * newcol;
}
