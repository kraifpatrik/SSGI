uniform float u_fClipFar;

varying vec3 v_vPosition;
varying vec2 v_vTexCoord;

/// @param d Linearized depth to encode.
/// @return Encoded depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
vec3 xEncodeDepth(float d)
{
	const float inv255 = 1.0 / 255.0;
	vec3 enc;
	enc.x = d;
	enc.y = d * 255.0;
	enc.z = enc.y * 255.0;
	enc = fract(enc);
	float temp = enc.z * inv255;
	enc.x -= enc.y * inv255;
	enc.y -= temp;
	enc.z -= temp;
	return enc;
}

void main()
{
	vec4 base = texture2D(gm_BaseTexture, v_vTexCoord);
	if (base.a < 0.8)
	{
		discard;
	}
	gl_FragColor.rgb = xEncodeDepth(v_vPosition.z / u_fClipFar);
	gl_FragColor.a = 1.0;
}
