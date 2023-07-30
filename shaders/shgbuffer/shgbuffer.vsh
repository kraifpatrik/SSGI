attribute vec4 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;

varying vec4 v_vPosition;
varying vec3 v_vPositionWorld;
varying vec3 v_vNormal;
varying vec2 v_vTexCoord;

void main()
{
	v_vPosition = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
	gl_Position = v_vPosition;
	v_vPositionWorld = (gm_Matrices[MATRIX_WORLD] * in_Position).xyz;
	v_vNormal = (gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz;
	v_vTexCoord = in_TextureCoord;
}
