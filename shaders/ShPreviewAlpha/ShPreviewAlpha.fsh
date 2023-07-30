varying vec2 v_vTexCoord;

void main()
{
	gl_FragColor = vec4(texture2D(gm_BaseTexture, v_vTexCoord).aaa, 1.0);
}
