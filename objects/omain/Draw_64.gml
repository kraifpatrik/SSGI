var _windowWidth = window_get_width();
var _windowHeight = window_get_height();

if (!keyboard_check(vk_space))
{
	var _shader = ShCombineLighting;
	shader_set(_shader);
	texture_set_stage(shader_get_sampler_index(_shader, "u_texLight"),
		surface_get_texture(surLight));
	texture_set_stage(shader_get_sampler_index(_shader, "u_texSSGI"),
		surface_get_texture(surSSGI));
	shader_set_uniform_f(shader_get_uniform(_shader, "u_fMultiplier"),
		giMultiplier);
	texture_set_stage(shader_get_sampler_index(_shader, "u_texSSAO"),
		surface_get_texture(surSSAO));
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
	var _x = 0;
	var _y = 0;
	var _width = _windowWidth / 7;
	var _height = _windowHeight / 7;

	draw_surface_stretched(surShadowmap, _x, _y, _height, _height);
	_x += _height;

	draw_surface_stretched(application_surface, _x, _y, _width, _height);
	_x += _width;

	draw_surface_stretched(surDepth, _x, _y, _width, _height);
	_x += _width;

	draw_surface_stretched(surNormal, _x, _y, _width, _height);
	_x += _width;

	draw_surface_stretched(surSSAO, _x, _y, _width, _height);
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
		  "[Ctrl+1] HalfRes: " + (ssgi.HalfRes ? "true" : "false") + "\n"
		+ "[Ctrl+2+MouseWheel] Distance: " + string(ssgi.GIDistance) + "\n"
		+ "[Ctrl+3+MouseWheel] Steps: " + string(ssgi.GISteps) + "\n"
		+ "[Ctrl+4+MouseWheel] Depth thickness: " + string(ssgi.DepthThickness) + "\n"
		+ "[Ctrl+5+MouseWheel] Blur depth range: " + string(ssgi.BlurDepthRange) + "\n"
		+ "[Ctrl+6+MouseWheel] Multiplier: " + string(giMultiplier) + "\n"
		+ "Hold [Space] to hide SSGI\n"
		;

	draw_text(16, 16, _text);
}

////////////////////////////////////////////////////////////////////////////////
// Text
var _font = draw_get_font();
var _halign = draw_get_halign();
var _valign = draw_get_valign();

draw_set_font(FntOpenSans24Bold);
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);

var _x = _windowWidth - 16;
var _y = _windowHeight - 16;
var _text = keyboard_check(vk_space) ? "SSGI OFF" : "SSGI ON";

draw_text_color(_x + 2, _y + 2, _text, c_black, c_black, c_black, c_black, 1.0);
draw_text(_x, _y, _text);

draw_set_font(_font);
draw_set_halign(_halign);
draw_set_valign(_valign);
