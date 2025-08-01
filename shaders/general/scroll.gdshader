shader_type canvas_item;

uniform float scroll_x = 1.;
uniform float scroll_y = 1.;
uniform vec3 color : source_color = vec3(0.0, 0.0, 0.0);

void fragment()
{
    vec2 uv = UV;
    uv.x = UV.x + TIME * scroll_x;
    uv.y = UV.y + TIME * scroll_y;
    COLOR = texture(TEXTURE, uv);
    
    //COLOR.rgb *= fract(-SCREEN_UV.x*2.) - 0.35;
    COLOR.rgb = mix(COLOR.rgb, color, SCREEN_UV.x*2.2);
    COLOR.a *= 0.5-SCREEN_UV.x;
}