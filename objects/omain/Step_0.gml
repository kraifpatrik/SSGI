event_inherited();

ssgi.AspectRatio = window_get_width() / window_get_height();
ssgi.Fov = fov;

if (instance_exists(sphere))
{
	var _dcosDirectionUp = dcos(directionUp);
	sphere.x = x + lengthdir_x(sphereDistance * _dcosDirectionUp, direction);
	sphere.y = y + lengthdir_y(sphereDistance * _dcosDirectionUp, direction);
	sphere.z = z - lengthdir_y(sphereDistance, directionUp);
}

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

if (keyboard_check(ord("F")))
{
	sunDirection[@ 0] = dcos(direction);
	sunDirection[@ 1] = -dsin(direction);
	sunDirection[@ 2] = dtan(directionUp);
}

if (keyboard_check_pressed(vk_space))
{
	ssgiEnabled = !ssgiEnabled;
}
