var _windowWidth = window_get_width();
var _windowHeight = window_get_height();
var _shader;

////////////////////////////////////////////////////////////////////////////////
//
// Render G-buffer
//
surDepth = SurfaceCheck(surDepth, _windowWidth, _windowHeight);
surNormal = SurfaceCheck(surNormal, _windowWidth, _windowHeight);

gpu_push_state();
gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);

surface_set_target_ext(0, application_surface);
surface_set_target_ext(1, surDepth);
surface_set_target_ext(2, surNormal);
draw_clear(c_black);

camera_apply(camera);

_shader = ShGBuffer;
shader_set(_shader);
shader_set_uniform_f(shader_get_uniform(_shader, "u_fClipFar"),
	clipFar);
texture_set_stage(shader_get_sampler_index(_shader, "u_sBestFitNormals"),
	sprite_get_texture(SprBestFitNormals, 0));

model.Submit();
shader_reset();

surface_reset_target();

gpu_pop_state();
