////////////////////////////////////////////////////////////////////////////////
// Controls
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
	x += lengthdir_x(_speed, direction + 90.0);
	y += lengthdir_y(_speed, direction + 90.0);
}

if (keyboard_check(ord("D")))
{
	x += lengthdir_x(_speed, direction - 90.0);
	y += lengthdir_y(_speed, direction - 90.0);
}

z += (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * _speed;

var _directionX = dcos(direction);
var _directionY = -dsin(direction);
var _directionZ = dtan(directionUp);

camera_set_view_mat(camera, matrix_build_lookat(
	x, y, z,
	x + _directionX,
	y + _directionY,
	z + _directionZ,
	0.0, 0.0, 1.0));

var _aspectRatio = window_get_width() / window_get_height();
ssgi.AspectRatio = _aspectRatio;
ssgi.Fov = fov;

camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(
	-fov, -_aspectRatio, 0.1, clipFar));

if (instance_exists(sphere))
{
	var _dcosDirectionUp = dcos(directionUp);
	sphere.x = x + lengthdir_x(sphereDistance * _dcosDirectionUp, direction);
	sphere.y = y + lengthdir_y(sphereDistance * _dcosDirectionUp, direction);
	sphere.z = z - lengthdir_y(sphereDistance, directionUp);
}

////////////////////////////////////////////////////////////////////////////////
// Shadowmap
shadowmapView = matrix_build_lookat(
	sunPosition[0],
	sunPosition[1],
	sunPosition[2],
	sunPosition[0] + sunDirection[0],
	sunPosition[1] + sunDirection[1],
	sunPosition[2] + sunDirection[2],
	0.0, 0.0, 1.0);
shadowmapProjection = matrix_build_projection_ortho(
	shadowmapArea, shadowmapArea, -shadowmapArea * 0.5, shadowmapArea * 0.5);
shadowmapViewProjection = matrix_multiply(shadowmapView, shadowmapProjection);

////////////////////////////////////////////////////////////////////////////////
if (keyboard_check(ord("F")))
{
	sunDirection[@ 0] = _directionX;
	sunDirection[@ 1] = _directionY;
	sunDirection[@ 2] = _directionZ;
}

if (keyboard_check_pressed(vk_f1))
{
	guiShow = !guiShow;
}

if (keyboard_check_pressed(vk_f2))
{
	screenshotMode = !screenshotMode;
}

if (keyboard_check_pressed(vk_space))
{
	ssgiEnabled = !ssgiEnabled;
}

gui.Update();
