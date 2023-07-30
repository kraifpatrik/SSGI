SurfaceCheck(application_surface, window_get_width(), window_get_height())
gpu_push_state();
gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
gpu_set_tex_filter(true);
gpu_set_tex_mip_enable(mip_on);
gpu_set_tex_repeat(true);
draw_clear(c_black);
camera_apply(camera);
shader_set(ShPassthrough);
matrix_set(matrix_world, modelMatrix);
model.Submit();
matrix_set(matrix_world, matrix_build_identity());
shader_reset();
gpu_pop_state();
