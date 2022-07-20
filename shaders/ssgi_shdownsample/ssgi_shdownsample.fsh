uniform vec2 u_vTexel;

varying vec2 v_vTexCoord;

void main()
{
	gl_FragColor = (texture2D(gm_BaseTexture, v_vTexCoord + vec2(0.5, 0.5) * u_vTexel)
		+ texture2D(gm_BaseTexture, v_vTexCoord + vec2(1.5, 0.5) * u_vTexel)
		+ texture2D(gm_BaseTexture, v_vTexCoord + vec2(0.5, 1.5) * u_vTexel)
		+ texture2D(gm_BaseTexture, v_vTexCoord + vec2(1.5, 1.5) * u_vTexel)) * 0.25
		;
}
