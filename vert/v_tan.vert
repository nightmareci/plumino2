uniform float time;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    vec4 newpos = vertex_position;
    newpos.x += tan((time*5.0)+newpos.y)*25.0;
    return transform_projection * newpos;
}
