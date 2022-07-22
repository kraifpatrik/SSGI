uniform vec2 u_vTexel;

varying vec2 v_vTexCoord;

void main()
{
	gl_FragColor = (texture2D(gm_BaseTexture, v_vTexCoord)
		+ texture2D(gm_BaseTexture, v_vTexCoord + vec2(1.0, 0.0) * u_vTexel)
		+ texture2D(gm_BaseTexture, v_vTexCoord + vec2(0.0, 1.0) * u_vTexel)
		+ texture2D(gm_BaseTexture, v_vTexCoord + vec2(1.0, 1.0) * u_vTexel)) * 0.25
		;
}
