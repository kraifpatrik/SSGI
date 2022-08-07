var _windowWidth = window_get_width();
var _windowHeight = window_get_height();
var _aspectRatio = _windowWidth / _windowHeight;
var _modelSphere = modelSphere;
var _shader;

gpu_push_state();
gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
gpu_set_tex_filter(true);
gpu_set_tex_mip_enable(mip_on);
gpu_set_texrepeat(true);

////////////////////////////////////////////////////////////////////////////////
// Shadowmap
surShadowmap = SSGI_SurfaceCheck(surShadowmap, shadowmapResolution, shadowmapResolution);

surface_set_target(surShadowmap);
draw_clear(c_red);

matrix_set(matrix_view, shadowmapView);
matrix_set(matrix_projection, shadowmapProjection);

_shader = ShShadowmap;
shader_set(_shader);
shader_set_uniform_f(shader_get_uniform(_shader, "u_fClipFar"),
	shadowmapArea);

matrix_set(matrix_world, modelMatrix);
model.Submit()

with (OSphere)
{
	matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, 0, scale, scale, scale));
	_modelSphere.Submit();
}
matrix_set(matrix_world, matrix_build_identity());

shader_reset();

surface_reset_target();

////////////////////////////////////////////////////////////////////////////////
// G-buffer
SSGI_SurfaceCheck(application_surface, _windowWidth, _windowHeight);
surDepth = SSGI_SurfaceCheck(surDepth, _windowWidth, _windowHeight);
surNormal = SSGI_SurfaceCheck(surNormal, _windowWidth, _windowHeight);
surLight = SSGI_SurfaceCheck(surLight, _windowWidth, _windowHeight);

surface_set_target_ext(0, application_surface);
surface_set_target_ext(1, surDepth);
surface_set_target_ext(2, surNormal);
surface_set_target_ext(3, surLight);
draw_clear(c_black);

camera_apply(camera);

var _matrixView = matrix_get(matrix_view);
ssgi.MatrixView = _matrixView;
ssgi.MatrixProjection = matrix_get(matrix_projection);
var _matrixViewInverse = array_create(16);
MatrixInverse(_matrixView, _matrixViewInverse);

_shader = ShGBuffer;
var _uEmissive = shader_get_uniform(_shader, "u_vEmissive");

shader_set(_shader);
shader_set_uniform_f(shader_get_uniform(_shader, "u_fClipFar"),
	clipFar);
texture_set_stage(shader_get_sampler_index(_shader, "u_texBestFitNormals"),
	sprite_get_texture(SprBestFitNormals, 0));

shader_set_uniform_f(_uEmissive, 0.0, 0.0, 0.0);
matrix_set(matrix_world, modelMatrix);
model.Submit()

with (OSphere)
{
	shader_set_uniform_f(_uEmissive,
		color_get_red(color) / 255,
		color_get_green(color) / 255,
		color_get_blue(color) / 255);
	matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, 0, scale, scale, scale));
	_modelSphere.Submit();
}
matrix_set(matrix_world, matrix_build_identity());

shader_reset();

surface_reset_target();

gpu_pop_state();

////////////////////////////////////////////////////////////////////////////////
// Deferred lighting
surface_set_target(surLight);
//draw_clear(c_black);

_shader = ShDeferredLighting;
shader_set(_shader);
texture_set_stage(shader_get_sampler_index(_shader, "u_texDepth"),
	surface_get_texture(surDepth));
texture_set_stage(shader_get_sampler_index(_shader, "u_texNormal"),
	surface_get_texture(surNormal));
shader_set_uniform_f(shader_get_uniform(_shader, "u_fClipFar"),
	clipFar);
shader_set_uniform_f(shader_get_uniform(_shader, "u_vTanAspect"),
	dtan(fov * 0.5) * _aspectRatio, -dtan(fov * 0.5));
shader_set_uniform_matrix_array(shader_get_uniform(_shader, "u_mViewInverse"),
	_matrixViewInverse);

shader_set_uniform_f_array(shader_get_uniform(_shader, "u_vSunDirection"),
	sunDirection);

texture_set_stage(shader_get_sampler_index(_shader, "u_texShadowmap"),
	surface_get_texture(surShadowmap));
shader_set_uniform_f(shader_get_uniform(_shader, "u_vShadowmapTexel"),
	1.0 / shadowmapResolution, 1.0 / shadowmapResolution);
shader_set_uniform_f(shader_get_uniform(_shader, "u_fShadowmapArea"),
	shadowmapArea);
shader_set_uniform_f(shader_get_uniform(_shader, "u_fShadowmapNormalOffset"),
	shadowmapNormalOffset);
shader_set_uniform_f(shader_get_uniform(_shader, "u_fShadowmapBias"),
	shadowmapBias);
shader_set_uniform_matrix_array(shader_get_uniform(_shader, "u_mShadowmap"),
	shadowmapViewProjection);

shader_set_uniform_f(shader_get_uniform(_shader, "u_vCameraPosition"),
	x, y, z);

gpu_set_blendmode(bm_add);
draw_surface(application_surface, 0, 0);
gpu_set_blendmode(bm_normal);

shader_reset();

surface_reset_target();

////////////////////////////////////////////////////////////////////////////////
// SSGI
surSSGI = SSGI_SurfaceCheck(surSSGI, _windowWidth, _windowHeight);
surWork = SSGI_SurfaceCheck(surWork, _windowWidth / 2, _windowHeight / 2);
surWork2 = SSGI_SurfaceCheck(surWork2, _windowWidth / 4, _windowHeight / 4);
surWork3 = SSGI_SurfaceCheck(surWork3, _windowWidth / 8, _windowHeight / 8);

ssgi.SurLight = surLight;
ssgi.TextureDepth = surface_get_texture(surDepth);
ssgi.TextureNormals = surface_get_texture(surNormal);
ssgi.SurResult = surSSGI;
ssgi.SurHalf = surWork;
ssgi.SurQuarter = surWork2;
ssgi.SurEighth = surWork3;
ssgi.Render();
