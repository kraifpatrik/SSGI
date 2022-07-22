if (keyboard_check_pressed(vk_f1))
{
	debug = !debug;
}
show_debug_overlay(debug);

camera_set_view_mat(camera, matrix_build_lookat(
	3.0, ((window_mouse_get_x() / window_get_width()) * 2.0 - 1.0) * 3.0, 1.0,
	0.0, 0.0, 1.0,
	0.0, 0.0, 1.0));
