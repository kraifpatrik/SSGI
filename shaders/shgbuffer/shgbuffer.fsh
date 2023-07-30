varying vec4 v_vPosition;
varying vec3 v_vPositionWorld;
varying vec3 v_vNormal;
varying vec2 v_vTexCoord;

uniform sampler2D u_texMetallicRoughness;
uniform sampler2D u_texNormal;
uniform float u_fClipFar;
uniform sampler2D u_texBestFitNormals;
uniform vec4 u_vEmissive;
uniform vec3 u_vCameraPosition;

/// @param N  Interpolated vertex normal.
/// @param V  View vector (vertex to eye).
/// @param uv Texture coordinates.
/// @return TBN matrix.
/// @source http://www.thetenthplanet.de/archives/1180
mat3 xCotangentFrame(vec3 N, vec3 V, vec2 uv)
{
	vec3 p = -V;
	vec3 dp1 = dFdx(p);
	vec3 dp2 = dFdy(p);
	vec2 duv1 = dFdx(uv);
	vec2 duv2 = dFdy(uv);
	vec3 dp2perp = cross(dp2, N);
	vec3 dp1perp = cross(N, dp1);
	vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
	vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;
	float invmax = inversesqrt(max(dot(T, T), dot(B, B)));
	return mat3(T * invmax, B * invmax, N);
}

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
	vec4 base = texture2D(gm_BaseTexture, v_vTexCoord);
	if (base.a < 0.8)
	{
		discard;
	}

	vec2 metallicRoughness = texture2D(u_texMetallicRoughness, v_vTexCoord).bg;
	float metallic = metallicRoughness.x;
	float roughness = metallicRoughness.y;
	vec3 normal = texture2D(u_texNormal, v_vTexCoord).xyz * 2.0 - 1.0;
	vec3 V = normalize(u_vCameraPosition - v_vPositionWorld);
	vec3 N = normalize(xCotangentFrame(normalize(v_vNormal), V, v_vTexCoord) * normal);

	gl_FragData[0] = vec4(base.rgb, metallic);
	gl_FragData[1] = vec4(xEncodeDepth(v_vPosition.z / u_fClipFar), 1.0);
	gl_FragData[2] = vec4(xBestFitNormal(N, u_texBestFitNormals) * 0.5 + 0.5, roughness);
	gl_FragData[3] = vec4(u_vEmissive.rgb * u_vEmissive.a, 1.0);
}
