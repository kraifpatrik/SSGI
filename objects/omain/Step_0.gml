if (keyboard_check_pressed(vk_f1))
{
	debug = !debug;
}
show_debug_overlay(debug);

////////////////////////////////////////////////////////////////////////////////
// Camera controls
var _mouseX = window_mouse_get_x();
var _mouseY = window_mouse_get_y();

if (mouse_check_button(mb_right))
{
	direction += (mouseLastX - _mouseX);
	directionUp = clamp(directionUp + (mouseLastY - _mouseY), -89.0, 89.0);
}

mouseLastX = _mouseX;
mouseLastY = _mouseY;

var _speed = keyboard_check(vk_shift) ? 0.4 : 0.1;

if (keyboard_check(ord("W")))
{
	x += lengthdir_x(_speed, direction);
	y += lengthdir_y(_speed, direction);
}

if (keyboard_check(ord("S")))
{
	x -= lengthdir_x(_speed, direction);
	y -= lengthdir_y(_speed, direction);
}

if (keyboard_check(ord("A")))
{
	x += lengthdir_x(_speed, direction + 90);
	y += lengthdir_y(_speed, direction + 90);
}

if (keyboard_check(ord("D")))
{
	x += lengthdir_x(_speed, direction - 90);
	y += lengthdir_y(_speed, direction - 90);
}

z += (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * _speed;

camera_set_view_mat(camera, matrix_build_lookat(
	x, y, z,
	x + dcos(direction),
	y - dsin(direction),
	z + dtan(directionUp),
	0.0, 0.0, 1.0));

camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(
	-fov, -window_get_width() / window_get_height(), 0.1, clipFar));
