//uniform sampler2D u_texMetallicRoughness;
//uniform sampler2D u_texNormal;

varying vec2 v_vTexCoord;

void main()
{
	vec4 base = texture2D(gm_BaseTexture, v_vTexCoord);
	if (base.a < 0.8)
	{
		discard;
	}
	//vec2 metallicRoughness = texture2D(u_texMetallicRoughness, v_vTexCoord).bg;
	//vec3 normal = normalize(texture2D(u_texNormal, v_vTexCoord).rgb * 2.0 - 1.0);
	gl_FragColor = vec4(base.rgb, 1.0);
}
