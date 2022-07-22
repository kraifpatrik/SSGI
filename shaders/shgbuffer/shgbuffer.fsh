varying vec4 v_vPosition;
varying vec3 v_vNormal;
varying vec2 v_vTexCoord;

uniform float u_fClipFar;
uniform sampler2D u_texBestFitNormals;

/// @source http://advances.realtimerendering.com/s2010/Kaplanyan-CryEngine3(SIGGRAPH%202010%20Advanced%20RealTime%20Rendering%20Course).pdf
vec3 xBestFitNormal(vec3 normal, sampler2D tex)
{
	normal = normalize(normal);
	vec3 normalUns = abs(normal);
	float maxNAbs = max(max(normalUns.x, normalUns.y), normalUns.z);
	vec2 texCoord = normalUns.z < maxNAbs ? (normalUns.y < maxNAbs ? normalUns.yz : normalUns.xz) : normalUns.xy;
	texCoord = texCoord.x < texCoord.y ? texCoord.yx : texCoord.xy;
	texCoord.y /= texCoord.x;
	normal /= maxNAbs;
	float fittingScale = texture2D(tex, texCoord).r;
	return normal * fittingScale;
}

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
	vec3 N = normalize(v_vNormal);
	vec3 L = normalize(vec3(1.0, 1.0, 1.0));
	float NdotL = max(dot(N, L), 0.0);
	gl_FragData[0] = texture2D(gm_BaseTexture, v_vTexCoord);
	//gl_FragData[0].rgb *= mix(0.25, 1.0, NdotL);
	gl_FragData[1] = vec4(xEncodeDepth(v_vPosition.z / u_fClipFar), 1.0);
	gl_FragData[2] = vec4(N * 0.5 + 0.5, 1.0); //vec4(xBestFitNormal(v_vNormal, u_texBestFitNormals) * 0.5 + 0.5, 1.0);
}
