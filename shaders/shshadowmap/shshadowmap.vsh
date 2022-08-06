attribute vec4 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;

varying vec3 v_vPosition;
varying vec2 v_vTexCoord;

void main()
{
	vec4 positionWVP = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
	gl_Position = positionWVP;
	v_vPosition = positionWVP.xyz;
	v_vTexCoord = in_TextureCoord;
}
