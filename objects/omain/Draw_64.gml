if (!keyboard_check(vk_space))
{
	var _shader = ShApplySSGI;
	shader_set(_shader);
	texture_set_stage(shader_get_sampler_index(_shader, "u_texLight"),
		surface_get_texture(surLight));
	texture_set_stage(shader_get_sampler_index(_shader, "u_texSSGI"),
		surface_get_texture(surSSGI));
	shader_set_uniform_f(shader_get_uniform(_shader, "u_fMultiplier"),
		giMultiplier);
	draw_surface(application_surface, 0, 0);
	shader_reset();
}
else
{
	draw_surface(surLight, 0, 0);
}

////////////////////////////////////////////////////////////////////////////////
// Debug
if (debug)
{
	var _windowWidth = window_get_width();
	var _windowHeight = window_get_height();
	var _x = 0;
	var _y = 0;
	var _width = _windowWidth / 8;
	var _height = _windowHeight / 8;

	draw_surface_stretched(application_surface, _x, _y, _width, _height);
	_x += _width;

	draw_surface_stretched(surDepth, _x, _y, _width, _height);
	_x += _width;

	draw_surface_stretched(surNormal, _x, _y, _width, _height);
	_x += _width;

	draw_surface_stretched(surLight, _x, _y, _width, _height);
	_x += _width;

	draw_surface_stretched(surSSGI, _x, _y, _width, _height);
	_x += _width;
}

////////////////////////////////////////////////////////////////////////////////
// Controls
if (keyboard_check(vk_control))
{
	var _text =
		  "(1) Distance: " + string(ssgi.GIDistance) + "\n"
		+ "(2) Steps: " + string(ssgi.GISteps) + "\n"
		+ "(3) Multiplier: " + string(giMultiplier) + "\n";

	draw_text(16, 16, _text);
}
